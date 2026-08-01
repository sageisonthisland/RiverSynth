"""
    This is what glues the synth into SampledSignals.

    Interface: must implement tick!(s::Signal) which
    outputs next sample and updates state
"""
abstract type Signal <: SampleSource end

SampledSignals.samplerate(osc::T) where {T<:Signal} = sr
SampledSignals.nchannels(::T) where {T<:Signal} = 1
Base.eltype(::T) where {T<:Signal} = Sample

function SampledSignals.unsafe_read!(sig::T, buf::Array, frameoffset, framecount) where {T<:Signal}
    for i in 1:framecount
        buf[i+frameoffset] = tick!(sig)
    end
    framecount
end

