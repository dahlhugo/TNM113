(
SynthDef(\coinSonification,{
	Pbind(
	\degree, Pseq(#[7, 12, 19], 1),
		\dur, Pseq(#[0.01, 0.1, 0.1], 1)).play;

	//Out.ar(0, {output}!2);
}).add;

SynthDef(\keySonification, { arg keyTotal;
	var output = SinOsc.ar;

	Out.ar(0, {output}!2);
}).add;

//Done for now
SynthDef(\scaleSonification, { arg scale, volumeMod = 1.0;
	var sound;
	var env;
	var output;

	sound = Resonz.ar(
		WhiteNoise.ar(0.5),
		200/scale,
		XLine.kr(0.1, 0.3, 0.3)
	);

	env = EnvGen.ar(
		Env.linen(0.5, 0.2, 0.2, 2, \welch),
		doneAction: 2
	);

	output = sound * env * volumeMod;

	Out.ar(0, {output}!2);
}).add;

// Effects and output
SynthDef(\outputEffects, {arg inputbus, bus, delaytime = 0.0, feedback = 0.0;
	var input = In.ar(inputbus, numChannels: 2);
	var delay = DelayC.ar(input, 1, delaytime);
	var reverbed = FreeVerb.ar(in: input, mix: 1, room: 0.5, damp: 0.1, mul: 1.0);
	//var echo = Greyhole.ar(in: input, delayTime: 2.5, damp: 0.5, diff: 0.8, feedback: 0.5);
	var roomEffects =  ( delay * feedback);
	var output = input + (roomEffects * 0.75);
	Out.ar(bus, output);
}).add;
SynthDef(\outputChannel, {arg inputbus, rate = 0.5;
	var output = In.ar(inputbus, numChannels: 2);


	Out.ar(0, {output}!2);
}).add;

SynthDef(\comboSamplePlayer, { arg bus, bufnum = 0, level = 0.1;
	var sound = PlayBuf.ar(
		numChannels: 2,
		bufnum: bufnum,
		rate: BufRateScale.kr(bufnum),
		trigger: 1,
		startPos: 0,
		loop: 0,
		doneAction: 2
	);

	var sound2 = LFSaw.ar(200);

	var output = (sound + (sound2 *0.2)) * level;
	output = BHiShelf.ar(output, freq: 1000, rs: 0.5, db: 9);
	Out.ar(bus, {output}!2);
}).add;

SynthDef(\applauseSamplePlayer, { arg bus, bufnum = 0, level = 0.1;
	var sound = PlayBuf.ar(
		numChannels: 2,
		bufnum: bufnum,
		rate: BufRateScale.kr(bufnum),
		trigger: 1,
		startPos: 0,
		loop: 0,
		doneAction: 2
	);


	var output = sound * level;
	output = BHiShelf.ar(output, freq: 1000, rs: 0.5, db: 9);
	Out.ar(bus, {output}!2);
}).add;

(
SynthDef(\delay, {
    arg in, out, delaytime = 0.5, feedback = 0.5;
    var input, delay;
    input = In.ar(in, 2);
    delay = DelayC.ar(input, 1, delaytime);
    Out.ar(out, input + (delay * feedback));
}).add;
)

)



(
thisProcess.openUDPPort(57120);

// Följande registrerar outputEffect synthdefinitionen på servern
~outputChannelBus = Bus.audio(s, numChannels: 2);
~outputChannel = Synth.new(\outputChannel, [\inputbus, ~outputChannelBus.index;]).register;
~outputEffectBus = Bus.audio(s, numChannels: 2);
~outputEffect = Synth.new(\outputEffects, [\inputbus, ~outputEffectBus.index, \bus, ~outputChannelBus.index;]).register;

~comboSample = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/sounds/combo.wav");
~applauseSample = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/sounds/applause.wav");

~speed = 1;

OSCdef(\CoinOSC, {|msg|
	Pbind(
	\degree, Pseq(#[7, 12, 19], 1),
		\dur, Pseq(#[0.2, 0.5, 0.5], 1),
	\tempo, 0.5 * ~speed
	).play;
}, '/coin');


OSCdef(\KeyOSC, {|msg|
	Pbind(
	\degree, Pseq(#[12, 17, 17, 19], 1),
		\dur, Pseq(#[0.1, 0.01, 0.01, 0.2], 1)).play;

	//msg.postln
}, '/key');

OSCdef(\ScaleOSC, {|msg|
	var scale = msg[1];
	var volumeMod = 1.0;
	if(scale > 2.5) {
		scale = 2.5;
	};

	if(scale < 0.5) {
		volumeMod = 0.3;
	};

	Synth.new(\scaleSonification, [\scale, scale, \volumeMod, volumeMod]);

}, '/scale');

OSCdef(\ComboOSC, {|msg|
	var value = msg[1];
	~speed = value;
	~speed.postln;
	//Synth.new(\comboSamplePlayer, [\bufnum, ~comboSample, \level, 0.3;]);

	//Synth.new(\scaleSonification, [\scale, scale, \volumeMod, volumeMod]);

}, '/combo');

OSCdef(\WinOSC, {|msg|
		Synth.new(\applauseSamplePlayer, [\bufnum, ~applauseSample, \level, 0.2;]);
}, '/win');



)

(
Pbind((
	\degree, Pseq(#[7, 12, 19], 1),
	\dur, Pseq(#[0.01, 0.1, 0.1], 1)).play;
)

