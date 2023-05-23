(
SynthDef(\coinSonification, { arg coinTotal;
	var output = SinOsc.ar;

	Out.ar(0, {output}!2);
}).add;

SynthDef(\keySonification, { arg keyTotal;
	var output = SinOsc.ar;

	Out.ar(0, {output}!2);
}).add;

SynthDef(\scaleSonification, { arg scale;
	var output = LFTri.ar((550 + WhiteNoise.ar(1))*scale);
	var env = EnvGen.ar(Env.perc(0.1, 0.5), doneAction: 2);

	var lfo = SinOsc.kr(1).range(150, 2500);


	var filteredSound = LPF.ar(output, lfo);

	var lfo2 = SinOsc.kr(1).range(5000, 10000);
	var fs = LPF.ar(filteredSound, lfo2);

	output = fs * env;

	Out.ar(0, {output}!2);
}).add;
)



(
thisProcess.openUDPPort(57120);

OSCdef(\CoinOSC, {|msg|
	msg.postln
}, '/coin');


OSCdef(\KeyOSC, {|msg|
	msg.postln
}, '/key');


OSCdef(\ScaleOSC, {|msg|
	var scale = msg[1];

	Synth.new(\scaleSonification, [\scale, scale]);

}, '/scale');
)