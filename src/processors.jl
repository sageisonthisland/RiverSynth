"""
A Processor statefully modifies audio.

processor(sample) -> return processed sample and update state
processor(buffer) -> return new processed buffer and update state
processor(SampleStream) -> return a SignalPath that routes
                           the sample stream through the processor.
                           Only updates state when read is called
                           on the resulting SignalPath
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

function (f::Filter)(inbuf::SampleBuf)
    outbuf = SampleBuf(Sample, sr, nframes(inbuf))
    f.state = inbuf[1]
    for i in 1:nframes(inbuf)
        outbuf[i] = f(inbuf[i])
    end
    outbuf
end

function (f::Filter)(stream::U) where {U<:SampleSource}
    SignalPath(stream, f)
end


mutable struct Waveshaper <: Processor
end
