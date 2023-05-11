// Starta servern
s.boot; // en rad kod körs med <Shift> och <Enter>
// Stop server
s.quit;
// Start oscilloscope
s.scope;

// När servern är igång skickar man över en eller flera synth definitioner till serven.
(
// Kod inom parenteser körs med <cmd> och <Enter> på Mac eller <ctrl> och <Enter> i Windows

SynthDef(\dataSonification, { arg freq;
	var output = LFTri.ar(freq);

	// C, Eb, F, G, Bb
~originalTones = [12, 15, 17, 19, 22];
~quantTones = ~originalTones;
for (0, 7) { arg index;
	~originalTones = ~originalTones + 12;
	~quantTones = ~quantTones.addAll(~originalTones);
};
	Out.ar(0, {output}!2);
}).add;

SynthDef(\levelSonification, { arg level;
	var output;
	var sine;
	var amMod;

	if(level == 0) {
		sine = SinOsc.ar(1020) * 0.0;
		output = sine;
	};

	if(level != 0) {
		sine = SinOsc.ar(1020 + (200 * level) );

		amMod = LFPulse.ar(1 + (level * 2), width: 0.1).range(0, 1);

		output = sine * EnvGen.ar(Env.perc(0.01, 1.0), gate: amMod);
	};




	output = output * 0.2;

	Out.ar(0, {output}!2);
}).add;

SynthDef(\errorSonification, { arg msg;


	var output = LFSaw.ar(freq: 440.0, width: 0.5) * 0.3 * EnvGen(Env.perc);


	Out.ar(0, {output}!2);
}).add;

)


(
// Följande registrerar dataSonification synthdefinitionen på servern
~dataSynth = Synth.new(\dataSonification).register;
~levelSynth = Synth.new(\levelSonification).register;
~errorSynth = Synth.new(\errorSonification).register;

// Följande är en OSC-lyssnare för level-meddelanden
OSCdef(\levelListener, { arg inputmsg;
	if (inputmsg.size > 1) {
		// Ta hand om meddelandet om det inte är samma som förra
		if (inputmsg[1].asInteger != ~statusLevel) {
			// Detta plockar ut level ur meddelandet som ett heltal
			// och sparar i environment-variabeln

			~statusLevel = inputmsg[1].asInteger;

			//skicka level värde till synthdefinition
			~levelSynth.set(\level, ~statusLevel);
		};
	};
}, 'level');

// Följande är en OSC-lyssnare för data-meddelanden
OSCdef(\dataListener, { arg inputmsg;
	if (inputmsg.size > 1) {
		// Ta hand om meddelandet om det inte är samma som förra
		if (inputmsg[1].asInteger != ~currentData) {
			var frequency;
			// Detta plockar ut datavärdet ur meddelandet som ett heltal
			// och sparar i environment-variabeln
			~currentData = inputmsg[1].asInteger;
			// Följande skickar data-nivån (som en int) till en mapp-funktion
			// som returnerar värdet och sparar det i frequency-variabelna
			frequency = ~mapTones.value(~currentData);
			//frequency = ~mapHarmony.value(~currentData);

			// Följande skickar värdet, frekvensen, till synthdefinitionen
			~dataSynth.set(\freq, frequency);
		};
	};
}, 'data');

// Följande är en OSC-lyssnare för fel-meddelanden
OSCdef(\errorListener, { arg inputmsg;
	if (inputmsg.size > 1) {
		// Detta plockar ut felmeddelandet ur meddelandet
		// och sparar i environment-variabeln
		~errorMessage = inputmsg[1];
		~errorMessage.postln;

		~errorSynth.set(\msg, ~errorMessage);
	};
}, 'error');

/*~handleLevel = { arg level;
	//olika ljud med stor skillnad för varje level

	if(

};*/

~mapPitch = { arg freq;
	// Först görs en linjär till linjär mappning av värdet till frekvens (i Hz)
	var frequency = linlin(freq, 0, 300, 220, 880) ;
	// returnerar värdet
	frequency.value;
};

~mapTones = { arg freq;
	var incomingNote = freq.cpsmidi;
	var comparisonValue;
	var notePosition;
	var mappedFreq;
	for (0, ~quantTones.size-1){ arg index;
		var tempValue = (~quantTones[index] - incomingNote).abs;
		if (comparisonValue.isNumber == false) {
			comparisonValue = tempValue;
		};
		if (tempValue < comparisonValue) {
			comparisonValue = tempValue;
			notePosition = index;
		};
	};
	mappedFreq = ~quantTones[notePosition].midicps;
	mappedFreq.value;
};
)

// Följande rad kollar vilken lokal address som OSC-lyssnaren använder. Denna måste
// vara samma i båda programmen, så att "monitorGUIt" skickar på rätt address.
NetAddr.localAddr;