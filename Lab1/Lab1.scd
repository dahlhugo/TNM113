// Starta servern
s.boot; // en rad kod körs med <Shift> och <Enter>
// Stop server
s.quit;
// Start oscilloscope
s.scope;


// När servern är igång skickar man över en eller flera synth definitioner till serven.
(
// Kod inom parenteser körs med <cmd> och <Enter> på Mac eller <ctrl> och <Enter> i Windows

SynthDef(\samplePlayer, {
	arg bufnum = 0, rateMod = 1, volumeMod = 1;
    var sound = PlayBuf.ar(
		numChannels: 2,
		bufnum: bufnum,
		rate: BufRateScale.kr(bufnum) * rateMod,
		trigger: 1,
		startPos: 0,
		loop: 1,
		doneAction: 0,
	);

	var envelope = EnvGen.kr(Env.perc(attackTime: 0.5, releaseTime: 2,
		level: 1.0, curve: -4.0));

	var envelope2 = EnvGen.kr(Env.perc(attackTime: 2, releaseTime: 2,
level: 1.0, curve: -1.0).range(100,10000));

	var output = sound * volumeMod * envelope2;
	//output = RLPF.ar(output, 440.0, 0.1);
	//output = HPF.ar(output, 5440.0);
	//output = BPF.ar(output, 440.0, 0.1);

	Out.ar(0, [output, output]);
}).add;

)




// Klientside skript
(
// Kod inom parenteser körs med <cmd> och <Enter> på Mac eller <ctrl> och <Enter> i Windows

var soundSample = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/bosse.wav");

~samplePlayer = Synth.new(\samplePlayer, [\bufnum, soundSample]);

~samplePlayer.set(\volumeMod, 0.06);



)