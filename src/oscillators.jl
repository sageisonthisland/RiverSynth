"""
In addition to the SampleSource interface,
an oscillator should implement:
* freq(o::Oscillator)::Unitful.Frequency
* phase(o::Oscillator)::Sample
* level(o::Oscillator)::Sample
and their corresponding ! versions.
Furhtermore, an oscillator should implement tick!(osc) which
updates the oscillator and returns its value

These are implemented by default if your oscillator
has fields rads::Sample, φ::Sample, and level::Sample
but you may overwrite them.
"""
abstract type Oscillator <: Signal end

freq(osc::T) where {T<:Oscillator} = radstofreq(osc.rads)
phase(osc::T) where {T<:Oscillator} = osc.φ
level(osc::T) where {T<:Oscillator} = osc.level

function freq!(osc::T, f::Unitful.Frequency) where {T<:Oscillator}
    osc.rads = freqtorads(f)
end

function phase!(osc::T, φ::Sample) where {T<:Oscillator}
    osc.φ = φ
end

function level!(osc::T, level::Sample) where {T<:Oscillator}
    osc.level = level
end

"""
    Now begins the actual oscillators!
    Starting with: Sine
"""

mutable struct SineOscillator <: Oscillator
    rads::Sample # In radians per sample
    φ::Sample # Phase
    level::Sample

    function SineOscillator(freq::Unitful.Frequency=440Hz, φ=0.0, level=1)
        new(freqtorads(freq), φ, level)
    end
end

function tick!(osc::SineOscillator)
    out = osc.level * sin(osc.φ)
    osc.φ = mod(osc.φ + osc.rads, 2π)
    out
end



"""
This algorithm comes from Välimäki and Huovilainen (2006).
Reduced aliasing, slightly warmer tone

SawOscillator(freq::Unitful.Frequency, φ, level)
"""
mutable struct SawOscillator <: Oscillator
    rads::Sample
    φ::Sample
    level::Sample
    z2::Sample
    z1::Sample
    function SawOscillator(freq::Unitful.Frequency=440Hz, φ=0.0, level=1.0)
        new(freqtorads(freq), φ, level, 1.0, 1.0)
    end
end


function tick!(osc::SawOscillator)
    f = ustrip(freq(osc))
    scaling_factor = sr / (4f * (1 - (f / sr)))
    γ = mod(osc.φ / 2π, 1)
    β = 2γ - 1
    δ = (β^2 - osc.z2) / 2
    out = osc.level * scaling_factor * δ
    osc.z2 = osc.z1
    osc.z1 = β^2
    osc.φ = mod(osc.φ + osc.rads, 2π)
    out
end

# Quick note on noise: call it like noise(type, input)
# * simplex creates smooth, random variation
# * fbm ("fractal brownian motion") creates rich, even, dense textures
# * multi ("multifractal") creates noise where smooth sections remain smooth
#   and rough sections become rougher
#
# simplex will cross zero approximately 1.5 to 2 times per unit of input,
# and has a slew rate of 2/3. The same approximately holds for fbm and multi
# but there will be more variation, especially with respect to the zero
# crossing rate.
#
# So if we want our noise to have an angular position, we can just
# use 2π * input as our "radians". We can divide by sr to get our
# "rads" (radians per sample).

"""
    Generates a noise source of type: simplex, fbm, or multi.

    Unlike other oscillators, φ does *not* get reduced to mod 2π.
    It increments and holds the noise state.
    
"""
mutable struct NoiseOscillator <: Oscillator
    rads::Sample
    φ::Sample
    level::Sample
    noise_sampler
    function NoiseOscillator(type=simplex, freq::Unitful.Frequency=1Hz, level=1.0)
        new(freqtorads(freq), 0.0, level, type())
        # very sneaky!! look at type() rather than type
        # This is because we instantiate a new noise source
        # with every noise oscillator, so when we pass it a type
        # (e.g., fbm) then we need to construct a new noise sampler
    end
end

function tick!(osc::NoiseOscillator)
    out = samplenoise(osc.noise_sampler, osc.φ / 2π)
    osc.φ += osc.rads
    out
end
