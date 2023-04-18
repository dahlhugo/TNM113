

(
s.record("S:/TNM113/TNM113/Lab2/ljud1.wav");

~tempoInBPM = 120;
~tempoClock = TempoClock.new(~tempoInBPM/60, 4);

Pdef(
	\opHiHat,
	Pbind(
		\instrument, \opHiHat,
		\dur, Pseq([Rest(1), Rest(1/2), 1/2], inf),
	);
).play(~tempoClock);

Pdef(
	\clHiHat,
	Pbind(
		\instrument, \clHiHat,
		\dur, Pseq([1, 1/2, 1, 1/2, 1/2, 1/4, 1/4], inf),
	);
).play(~tempoClock);

Pdef(
	\snareDrum,
	Pbind(
		\instrument, \snareDrum,
		\dur, Pseq([Rest(1), 1, Rest(1), 1, Rest(1), 1, Rest(1), 1/2, 1/2], inf),
	);
).play(~tempoClock);

Pdef(
	\bassDrum,
	Pbind(
		\instrument, \bassDrum,
		\dur, Pseq([1], inf),
	);
).play(~tempoClock);


)

ServerMeter.new(s, 0, 2);
s.scope;

s.stopRecording;
