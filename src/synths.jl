# This is a sort of sample voice

osc1 = SawOscillator()
osc2 = SawOscillator()
noise1 = NoiseOscillator()
noise2 = NoiseOscillator()
noise3 = NoiseOscillator()
noise4 = NoiseOscillator()

test_srcs = [osc1, osc2, noise1, noise2, noise3, noise4]

test_lvls = Sample[1, 1, 0, 0, 0, 0]

modb = ModBus([osc1, osc1, osc2, osc2],
    [freq!, level!, freq!, level!],
    [440Hz, 1.0, 440Hz, 1])

modm = [0Hz 0 0Hz 0;
    0Hz 0 0Hz 0;
    1Hz 0 0Hz 0;
    0Hz 0.1 0Hz 0;
    0Hz 0 1Hz 0;
    0Hz 0 0Hz 0.1]

test_voice = Voice(test_srcs, test_lvls, modb, modm, [], [])
