function filtertest(filter, oscillator, ℓ=2000)
    fig = Figure()

    ax_osc = Axis(fig[1,1], title="Oscillator Output", xlabel="Time", ylabel="Amplitude")
    ylims!(ax_osc, -1.2, 1.2)
    ax_osc_spec = Axis(fig[2,1], title="Oscillator Spectrum", xlabel="Frequency", ylabel="Level (dB)")
    ylims!(ax_osc_spec, -25, 55)
    freq_sl = Slider(fig[3,1], range=1:0.1:3520, startvalue=440)

    ax_filt = Axis(fig[1,2], title="Filtered Output", xlabel="Time", ylabel="Amplitude")
    ylims!(ax_filt, -1.2, 1.2)
    ax_filt_spec = Axis(fig[2,2], title="Filtered Spectrum", xlabel="Frequency", ylabel="Level (dB)")
    ylims!(ax_filt_spec, -25, 55)
    cutoff_sl = Slider(fig[3,2], range=1:0.1:3520, startvalue=440)
    reso_sl = Slider(fig[4,2], range = 0:0.01:10, startvalue=0)

    osc = lift(freq_sl.value) do val
        read(oscillator(val * Hz, 0, 1), ℓ)
    end

    osc_spec = lift(osc) do val
        val |> fft .|> abs .|> amp2db
    end
    
    filt = lift(osc, cutoff_sl.value, reso_sl.value) do buf, ω, r
        cutoff!(filter, ω*Hz)
        resonance!(filter, r)
        filter(buf)
    end

    filt_spec = lift(filt) do val
        val |> fft .|> abs .|> amp2db
    end

    osc_times = @lift(domain($osc))
    osc_freqs = @lift(domain($osc_spec[0kHz..15kHz]))
    filt_times = @lift(domain($filt))
    filt_freqs = @lift(domain($filt_spec[0kHz..15kHz]))

    lines!(ax_osc, osc_times, @lift($osc[begin:end]))
    lines!(ax_osc_spec, osc_freqs, @lift($osc_spec[0kHz..15kHz]))
    lines!(ax_filt, filt_times, @lift($filt[begin:end]))
    lines!(ax_filt_spec, filt_freqs, @lift($filt_spec[0kHz..15kHz]))

    fig#, osc, osc_spec, filt, filt_spec
       # It'd be cool to pass these but somehow it breaks observables
       # and interaction??
end
