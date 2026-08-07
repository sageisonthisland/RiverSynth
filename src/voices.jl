struct ModBus
    destinations::Vector{}
    setters::Vector{Function}
    original::Vector{} # original values that modulation will
    # move around
end

destinations(m::ModBus) = m.destinations
original(m::ModBus) = m.original
setters(m::ModBus) = m.setters

mutable struct Voice <: Signal
    sources::Vector{Signal}
    levels::Vector{Sample}
    modbus::ModBus
    modmatrix::Array
    # A funny thing happened on the way to the mod matrix:
    # array entries must have the appropriate units.
    # Not sure how I feel 'bout that but it's where we are.
    # Honestly, my #1 complaint about most mod matrices
    # is that it's unclear how much modulation is happening.
    # At least here you have to be *very* explicit.
    sourceprocessors::Vector{Vector{Processor}}
    voiceprocessors::Vector{Processor}
end

sources(v::Voice) = v.sources
levels(v::Voice) = v.levels
modbus(v::Voice) = v.modbus
modmatrix(v::Voice) = v.modmatrix
function modmatrix!(v::Voice, m::Matrix{Sample})
    v.modmatrix = m
end
sourceprocessors(v::Voice) = v.sourceprocessors
voiceprocessors(v::Voice) = v.voiceprocessors

function tick!(v::Voice)
    m = modbus(v)
    modm = modmatrix(v)
    srcs = sources(v)

    dests = destinations(m)
    orig = original(m)
    sets = setters(m)

    sourceprocs = sourceprocessors(v)
    voiceprocs = voiceprocessors(v)

    n = length(srcs)
    m = length(dests)

    outs = zeros(Sample, n)

    for i in 1:n
        outs[i] = tick!(srcs[i])
        if length(sourceprocs)>0
            for j in 1:length(sourceprocs[i])
                outs[i] = sourceprocs[i][j](outs[i])
            end
        end
    end

    # i -> sources
    # j -> destinations
    for i in 1:n
        for j in 1:m
            setter! = x -> sets[j](dests[j], x)
            modifier = modm[i, j] * outs[i]
            if setter! == phase!
                setter!(phase(dests[j]) + modifier)
            else
                setter!(orig[j] + modifier)
            end
        end
    end

    out = levels(v)' * outs

    for i in 1:length(voiceprocs)
        out = voiceprocs[i](out)
    end

    out
end



