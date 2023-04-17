// Starta servern
s.boot; // en rad kod körs med <Shift> och <Enter>
// Stop server
s.quit;
// Start oscilloscope
s.scope;

// När servern är igång skickar man över en eller flera synth definitioner till serven.
(
// Kod inom parenteser körs med <cmd> och <Enter> på Mac eller <ctrl> och <Enter> i Windows

SynthDef(\bassDrum, {
	var body, hit, output;

	body = SinOsc.ar(75);
	body = body * EnvGen.ar(Env.perc(0, 0.1, 1, -4));

	hit = LFPulse.ar(220) * 0.10;
	hit = hit * EnvGen.ar(Env.perc(0.01, 0.01));

	output = body + hit;

	Out.ar(0, {output}!2);
}).add;

SynthDef(\snareDrum, {
	var body, hit, output, noise;

	body = SinOsc.ar(220) + (SinOsc.ar(330)*0.10);

	body = body * EnvGen.ar(Env.perc(0, 0.1, 1, -4));

	hit = LFPulse.ar(220) * 0.10;
	hit = hit * EnvGen.ar(Env.perc(0.01, 0.01));

	noise = WhiteNoise.ar(0.25);
	noise = HPF.ar(noise, 1750);
	noise = noise * EnvGen.ar(Env.perc(0, 0.1, 1, -4));

	output = body + hit + noise;

	Out.ar(0, {output}!2);
}).add;

SynthDef(\closedHiHat, {
	var output, noise, tones;

	noise = WhiteNoise.ar(0.25);



	tones = LFPulse.ar(2000, 0.0, 0.5) + LFPulse.ar(1150, 0.0, 0.5) + LFPulse.ar(820, 0.0, 0.5) + LFPulse.ar(465, 0.0, 0.5);
	tones = tones/4;

	noise = noise + tones;
	noise = noise * EnvGen.ar(Env.perc(0.05, 0.02, 1, -1));
	noise = HPF.ar(noise, 8500);
	noise = BPF.ar(noise, [1000, 4500])
	output = noise * 0.7;

	Out.ar(0, {output}!2);
}).add;

SynthDef(\openHiHat, {
	var output, noise;

	noise = WhiteNoise.ar(0.25);
	noise = HPF.ar(noise, 3500);
	noise = noise * EnvGen.ar(Env.perc(0.05, 0.2));

	output = noise * 0.7;

	Out.ar(0, {output}!2);
}).add;

)

(
	~samplePlayer = Synth.new(\closedHiHat);
)