"Convert between frequency and radians-per-sample"
freqtorads(f::Unitful.Frequency) = 2π * ustrip(f) / sr
radstofreq(r::Sample) = (r * sr / 2π)Hz

