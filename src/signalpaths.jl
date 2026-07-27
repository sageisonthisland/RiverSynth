"""
A SignalPath applies Processors to SampleSources of type T to 
produce a new SampleSource.
"""
struct SignalPath <: Signal
    source::Signal
    processors::Vector{<:Processor}
    function SignalPath(source, processors::Vector{<:Processor})
        new(source, processors)
    end
end

source(s::SignalPath) = s.source
processors(s::SignalPath) = s.processors

function SignalPath(source::T, processor::Processor) where {T<:SampleSource}
    SignalPath(source, [processor])
end

function tick!(s::SignalPath)
    out = tick!(source(s))
    for p in processors(s)
        out = p(out)
    end
    out
end

