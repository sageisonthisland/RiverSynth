"""
A Processor statefully modifies audio. Really
they're just stateful functions.

processor(sample) -> return processed sample and update state
processors([sample1, sample2,...]) -> return process applied to the sum
of the samples and update state
"""
abstract type Processor end

mutable struct Filter <: Processor
    filterfunction # Takes ω, r, sample, state and returns (output, state)
    ω::Unitful.Frequency
    r::Sample
    state
    function Filter(filterfunction, ω::Unitful.Frequency, r::Sample=Sample(0), state::Sample=Sample(0))
        new(filterfunction, ω, r, state)
    end
end

function cutoff(f::Filter)
    f.ω
end

function cutoff!(f::Filter, ω::Unitful.Frequency)
    f.ω = ω
end

function resonance(f::Filter)
    f.r
end

function resonance!(f::Filter, r::Sample)
    f.r = r
end

function (f::Filter)(sample::Sample)
    output, f.state = f.filterfunction(f.ω, f.r, sample, f.state)
    output
end

function (f::Filter)(samples::Vector{Sample})
    output, f.state = f.filterfunction(f.ω, f.r, samples, f.state)
    output
end

mutable struct Waveshaper <: Processor
end
