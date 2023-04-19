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
	body = body * EnvGen.ar(Env.perc(0.01, 0.1));

	hit = LFTri.ar(220);
	hit = hit * EnvGen.ar(Env.perc(0.01, 0.01));

	output = body + (hit/3);
	output = output *0.5;

	Out.ar(0, {output}!2);
}).add;

SynthDef(\snareDrum, {
	var body, hit, output, noise;

	body = SinOsc.ar(220) + (SinOsc.ar(330)*0.10);

	body = body * EnvGen.ar(Env.perc(0, 0.1));

	hit = LFPulse.ar(220) * 0.05;
	hit = hit * EnvGen.ar(Env.perc(0.01, 0.01));

	noise = WhiteNoise.ar(0.25);
	noise = HPF.ar(noise, 1750);
	noise = noise * EnvGen.ar(Env.perc(0, 0.1));

	output = body + hit + noise;
	output = output *0.5;

	Out.ar(0, {output}!2);
}).add;

SynthDef(\clHiHat, {
	var output, noise, tones;

	noise = WhiteNoise.ar(0.25);
	noise = HPF.ar(noise, 3500);

	tones = (LFPulse.ar(2000, 0.0, 0.5) + LFPulse.ar(1150, 0.0, 0.5) + LFPulse.ar(820, 0.0, 0.5) + LFPulse.ar(465, 0.0, 0.5))/4;
	noise = noise + (tones/2);

	noise = noise * EnvGen.ar(Env.perc(0.05, 0.02, 1, -1));


	output = noise;
	output = output * 0.5;

	Out.ar(0, {output}!2);
}).add;

SynthDef(\opHiHat, {
	var output, noise;

	noise = WhiteNoise.ar(0.25);
	noise = HPF.ar(noise, 3500);

	tones = (LFPulse.ar(2000, 0.0, 0.5) + LFPulse.ar(1150, 0.0, 0.5) + LFPulse.ar(820, 0.0, 0.5) + LFPulse.ar(465, 0.0, 0.5))/4;
	noise = noise + (tones/2);

	noise = noise * EnvGen.ar(Env.perc(0.05, 0.2));

	output = noise;
	output = output * 0.5;

	Out.ar(0, {output}!2);
}).add;

)

(
~samplePlayer = Synth.new(\snareDrum);
)


(
SynthDef(\opHiHat, {
	var output;

	var sawtooth = LFSaw.kr(0.1, iphase: 1).range(1, 8);
	var sound = LFPulse.ar(440 * sawtooth, width: 0.5, mul: 0.25);

	var soundLevelMod = LFSaw.kr(4).range(0.1);

	var noise = WhiteNoise.ar(0.2);
	var envelope = EnvGen.ar(Env.perc(attackTime: 0.01, releaseTime: 2, level:
		1, curve: -4.0), gate: (sawtooth - 1));
	var filteredNoise = RLPF.ar(noise, 100 + (10000 * envelope), 0.1);
	var envelopedNoise = filteredNoise * envelope;

	output = sound * soundLevelMod + envelopedNoise;

	Out.ar(0, {output}!2);
}).play;

)

(
fork{
	loop{
		play{
			Splay.ar({
				Klank.ar(`[99.rand * (1 .. 10)], Crackle.ar(2, 0.01));
			}!2) * LFGauss.ar(10, 0.25, 0, 0, 2)
		};
		1.wait;
	}
};
)

(
fork{
	loop{
		var h = ([34, 36, 41, 43].choose.midicps) * (2 ** ((0 .. 4).choose));
		play{
			Splay.ar({
				LFSaw.ar(exprand(h - (h / 128), h + (h / 128)), 0, 0.1)}!8) * LFGauss.ar(10, 0.15, 0, 0, 2);
		};
		1.wait;
	}
};
)