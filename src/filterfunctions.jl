function onepole_lp(ω::Unitful.Frequency, r::Sample, sample::Sample, prevstate::Sample)
    g = tan(freqtorads(ω)/2)
    G = g / (1+g)
    v = (sample - prevstate) * G
    out = v + prevstate
    currstate = out + v
    (out, currstate)
end

function onepole_lp(ω::Unitful.Frequency, r::Sample, samples::Vector{Sample}, prevstate::Sample)
    sample = sum(samples)
    g = tan(freqtorads(ω)/2)
    G = g / (1+g)
    v = (sample - prevstate) * G
    out = v + prevstate
    currstate = out + v
    (out, currstate)
end

function svf_lp(ω::Unitful.Frequency, r::Sample, sample::Sample, prevstate::Tuple{Sample, Sample})
    g = tan(freqtorads(ω)/2)
    G = g / (1+g)
end
