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
	hit = hit * EnvGen.ar(Env.perc(0.01, 0.01, 1, -4));

	output = body + hit;
	output = output *0.5;

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
	output = output * 0.5;

	Out.ar(0, {output}!2);
}).add;

SynthDef(\clHiHat, {
	var output, noise, tones;

	noise = WhiteNoise.ar(0.25);
	tones = LFPulse.ar(2000) + LFPulse.ar(1150) + LFPulse.ar(820) + LFPulse.ar(465);
	tones = tones/4;
	noise = noise + (tones/2);

	noise = HPF.ar(noise, 1750);
	noise = noise * EnvGen.ar(Env.perc(0.005, 0.025, 1, -1));

	output = noise;

	Out.ar(0, {output}!2);
}).add;

SynthDef(\opHiHat, {
	var output, noise, tones;

	noise = WhiteNoise.ar(0.25);
	tones = LFPulse.ar(2000) + LFPulse.ar(1150) + LFPulse.ar(820) + LFPulse.ar(465);
	tones = tones/4;
	noise = noise + (tones/2);

	noise = HPF.ar(noise, 3500);
	noise = noise * EnvGen.ar(Env.perc(0.05, 0.05, 1, -1));

	output = noise;

	Out.ar(0, {output}!2);
}).add;

)

(
	~samplePlayer = Synth.new(\opHiHat);
)