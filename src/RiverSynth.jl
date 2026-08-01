"""
Architecture:
* Oscillators are the basic sources of sound, subtyping SampleStream
* Processors are callable objects that statefully process samples and buffers
* SignalPaths allow processors to process SampleStreams without knowing
  what the stream will output in advance. They start with a stream and
  run it sequentially through a Vector of processors. The resulting
  SignalPath subtypes SampleStream

"""
module RiverSynth

const sr = 192000
const Sample = Float64

using GLMakie, FileIO
using Unitful, FFTW
using PortAudio, LibSndFile, SampledSignals
using CoherentNoise: fbm_fractal_1d as fbm, multi_fractal_1d as multi, simplex_1d as simplex, sample as samplenoise

export Sample, Hz, kHz, s
export Signal

export tick!
export ModBus, Voice
export sources, levels, modbus, modmatrix, modmatrix!
export destinations, orginal, setters
export Oscillator, SineOscillator, SawOscillator
export freq, freq!, phase, phase!, level, level!
export NoiseOscillator, fbm, multi, simplex
export Processor, Filter
export cutoff, cutoff!, resonance, resonance!
export onepole_lp
export filtertest

include("utils.jl")
include("signals.jl")
include("oscillators.jl")
include("processors.jl")
include("filterfunctions.jl")
include("voices.jl")
include("visualization.jl")

end # module RiverSynth
