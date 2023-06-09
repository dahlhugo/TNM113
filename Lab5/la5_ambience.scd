// Starta servern
s.boot; // en rad kod körs med <Shift> och <Enter>
// Stop server
s.quit;
// Start oscilloscope
s.scope;

// När servern är igång skickar man över en eller flera synth definitioner till serven.
(
// Kod inom parenteser körs med <cmd> och <Enter> på Mac eller <ctrl> och <Enter> i Windows

// Synthdefinitioner som skapar helt procedurella ljud
SynthDef(\chordSynth, { arg bus, freq, gate = 0, level = 0;
	var oscillator1 = LFTri.ar(freq, mul: 0.1);
	var filtered = RLPF.ar(oscillator1, 5000, 0.5);
	var envelope = EnvGen.ar(Env.adsr(attackTime: 2, decayTime: 2, sustainLevel: 0.25, releaseTime: 3, peakLevel: 0.5, curve: -4), gate);
	var output = filtered * envelope * level.lag(1);
	Out.ar(bus, {output}!2);
}).add;
SynthDef(\bassSynth, { arg bus, freq, gate = 0, level = 0;
	var sqrWave = LFPulse.ar(freq: freq / 2, width: 0.5, mul: 0.1);
	var filtered = LPF.ar(sqrWave, 500);
	var envelope = EnvGen.ar(Env.adsr(attackTime: 2, decayTime: 2, sustainLevel: 0.5, releaseTime: 3, peakLevel: 0.5 * level, curve: -6), gate);
	var output = filtered * envelope;
	Out.ar(bus, {output}!2);
}).add;


// Synthdefinitioner som spelar upp ljudsamplingar
SynthDef(\doorbellSamplePlayer, { arg bus, bufnum = 0, t_gate = 0, level = 0;
	var sound = PlayBuf.ar(
		numChannels: 2,
		bufnum: bufnum,
		rate: BufRateScale.kr(bufnum),
		trigger: t_gate,
		startPos: 0,
		loop: 0,
		doneAction: 2
	);
	var output = sound * 0.07 * level;
	Out.ar(bus, {output}!2);
}).add;
SynthDef(\bellSamplePlayer, { arg bus, bufnum = 0, level = 0;
	var sound = PlayBuf.ar(
		numChannels: 2,
		bufnum: bufnum,
		rate: BufRateScale.kr(bufnum),
		trigger: 1,
		startPos: 0,
		loop: 1,
		doneAction: 2
	);
	var output = sound * 0.02 * level;
	output = BHiShelf.ar(output, freq: 1000, rs: 0.5, db: 9);
	Out.ar(bus, {output}!2);
}).add;
SynthDef(\grindSamplePlayer, { arg bus, bufnum = 0, level = 0;
	var sound = PlayBuf.ar(
		numChannels: 2,
		bufnum: bufnum,
		rate: BufRateScale.kr(bufnum),
		trigger: 1,
		startPos: 0,
		loop: 0,
		doneAction: 2
	);
	var output = sound * 0.02 * level;
	output = BHiShelf.ar(output, freq: 1000, rs: 0.5, db: 9);
	Out.ar(bus, {output}!2);
}).add;

SynthDef(\songSamplePlayer, { arg bus, bufnum = 0, rate = 1.0, level = 0;
	var sound = PlayBuf.ar(
		numChannels: 2,
		bufnum: bufnum,
		rate: rate,
		trigger: 1,
		startPos: 0,
		loop: 1,
	);
	var output = sound * 0.02 * level;
	output = BHiShelf.ar(output, freq: 1000, rs: 0.5, db: 9);
	Out.ar(bus, {output}!2);
}).add;


// Effects and output
SynthDef(\outputEffects, {arg inputbus, bus;
	var input = In.ar(inputbus, numChannels: 2);
	var reverbed = FreeVerb.ar(in: input, mix: 1, room: 0.5, damp: 0.1, mul: 1.0);
	//var echo = Greyhole.ar(in: input, delayTime: 2.5, damp: 0.5, diff: 0.8, feedback: 0.5);
	var roomEffects = reverbed;
	var output = input + (roomEffects * 0.75);
	Out.ar(bus, output);
}).add;
SynthDef(\outputChannel, {arg inputbus, rate = 0.5;
	var output = In.ar(inputbus, numChannels: 2);


	Out.ar(0, output);
}).add;
)

// Klientside script
(
// Följande registrerar outputEffect synthdefinitionen på servern
~outputChannelBus = Bus.audio(s, numChannels: 2);
~outputChannel = Synth.new(\outputChannel, [\inputbus, ~outputChannelBus.index;]).register;
~outputEffectBus = Bus.audio(s, numChannels: 2);
~outputEffect = Synth.new(\outputEffects, [\inputbus, ~outputEffectBus.index, \bus, ~outputChannelBus.index;]).register;


// Toner i ackordet 0 = C, Eb, G; 1 = C, D, G; 2 = C, F, G; 3 = D, G, B
/*~chordDictionary = Dictionary[0 -> [60, 63, 67], 1 -> [60, 62, 67], 2 -> [60, 65, 67], 3 -> [62, 67, 71]];
~chordNumber = 0;
// Skapa ett dictionary för att stoppa ackordsyntarna i
~chordSynthDictionary = Dictionary.new;
// Fyll dictionaryt med syntarna och skicka med effektbussen
for (0, 2) { arg index;
	~chordSynthDictionary.add(index -> Synth.new(\chordSynth, [\bus, ~outputEffectBus.index;]).register);
};
~chordLevel = 0.25;*/


// Toner i basen C, C, F, G
/*~bassNoteNumbersToUse = [60, 50, 53, 55];
// Registera bassynten på servern och skicka med effektbussen
~bassSynth = Synth.new(\bassSynth, [~outputEffectBus.index;]).register;
~bassLevel = 0;*/

~songLevel = 0.25;
//~songSynth = Synth.new(\songSamplePlayer, [\bufnum, ~songSample, \bus, ~outputEffectBus.index, \level, ~songLevel;]);


// Läs in klockljudet, ni får se över sökvägen till de ljud ni använder
~bellSample = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/sounds/bell2.wav");
// Läs in dörrklockljudet
~doorbellSample = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/sounds/pour2.wav");
//Music sample
~songSample = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/sounds/song.wav");
~grindSample = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/sounds/grind.wav");

// En environmentvariabel som håller koll på antal personer i lobbyn
~numberOfPersons = 0;
// Detta förbereder en rutin som sequencerfunktionen använder senare
~startRoutine.play(AppClock);
~tempoInBPM = 75; // Detta är tempot i slag per minut (beats per minute)
~beatCounter = 1; // Detta är en variabel som håller koll på vilket slag i takten det är
~startFlag = true; // En flagga som används för att starta klockan (en gång) när det första OSC-meddelandet tas emot
~stopflag = false; // En flagga som används när dagen är slut och sedan stoppar uppspelningen
~oldHour = 0; // En variabel som används för att kolla om timmen som kommer via OSC är en ny timme eller inte


// Här följer sequencerfunktionen. Den anropas efter att det första OSC-meddelandet tagits emot och tempoklockan har startats. Sequencern räknar till 8 slag, dvs två takter, när det 9 slaget kommer ska syntarnas "tangenter" släppas (dvs gate sätts till 0), och uppspelningen börjar om från 1 men med nästa ackord. När det fjärde ackordet tas, dvs ~chordNumner är större än 3, ska ackordordningen börja om från det första ackordet. När allt är klart, dvs ~stopFlag har satts till true, ska ackorden gå klart och det första ackordet spelas upp igen s.å att "låten" avslutas med rätt ackord.
~sequencingFunction = {
	~tempoClock.schedAbs(0, {
		// Om ~beatCounter är på första slaget, 1, sätt rätt toner till syntarna
		if (~beatCounter == 1) {

		};
		// Räkna sedan upp ~beatCounter
		~beatCounter = ~beatCounter + 1;
		// Om ~beatCounter är 9 har de 8 taktslagen för ackordet gjorts
		// Släpp upp "tangenterna" för syntarna
		if (~beatCounter == 9) {

			// Kolla om ~stopFlag och första ackordet gäller, stoppa då uppspelningen
			if ((~stopflag)) {
				~tempoClock.stop;
				~songSynth.free;
			};

			// Och återställ ~beatCounter till 1
			~beatCounter = 1;
		};
		1.0; // 1.0 innebär att schedAbs klockas i fjärdedelar av en takt
	});
};




// Följande är en OSC-lyssnare för tids-meddelanden
OSCdef(\timeListener, { arg inputmsg;
	if (inputmsg.size > 1) {
		// Kolla om ~startFlag är true och i så fall starta klockan och ropa på sequencerfunktionen
		if (~startFlag) {
			~startFlag = false;
			~tempoClock = TempoClock.new(~tempoInBPM/60);
			~sequencingFunction.value();
			~songSynth = Synth.new(\songSamplePlayer, [\bufnum, ~songSample, \bus, ~outputEffectBus.index, \level, ~songLevel;]);

		};
		// Uppdatera ~hour med inkommande OSC-meddelande
		~hour = inputmsg[1];
		// Om det är en ny timme, ropa på ~hourSyncedStuff och uppdatera ~oldHour
		if (~hour != ~oldHour) {
			~hourSyncedStuff.value;
			~oldHour = ~hour;
		};
	};
}, 'time');


// Följande funktion anropas av OSC-lyssnaren som tar emot tidsinformationen
~hourSyncedStuff = {
	switch (~hour,
		8, { // Morning
			// Spela upp klockljudet som markerar de olika tidsdelarna
			~playbell.value;


			// Sätt ljudvolymen för de procedurella syntarna, vilken sedan sätts i sequencerfunktionen
			~songLevel = 0.25;
			//~bassLevel = 0;



		},
		11, { // Lunch
			~playbell.value;

			~songLevel = 0.5;
			~songSynth.set(\rate, 1.05);
			//~bassLevel = 0.25;
			//~songSynth.free;


		},
		13, { // Afternoon
			~playbell.value;

			~songSynth.set(\rate, 1.10);

			~bassLevel = 0.5;
			~tempoInBPM = 70;

		},
		17, { // Evening
			~playbell.value;

			~songSynth.set(\rate, 1.15);
			~bassLevel = 1;
			~tempoInBPM = 60;

		},
		20, { // Happy hour
			~playbell.value;

			~songLevel = 2;
			~bassLevel = 2;
			~tempoInBPM = 55;
			~playGrind.value;

		},
		23, { // Closed
			~playbell.value;

			// Sätt stoppflaggan för sequencerfunktionen
			~stopflag = true;
		},
	);
};


// Följande funktion spelar upp klockljudet, eftersom synthdefinitionen har en doneAction på 2 tas den syntinstansen bort från servern när samplingen har spelats upp. Därför kan vi bekvämt skapa en ny instans varje gång vi spelar upp ljudet.
~playGrind = {
	Synth.new(\grindSamplePlayer, [\bufnum, ~grindSample, \bus, ~outputEffectBus.index, \level, 1;]);
};



// Följande är en OSC-lyssnare för person-meddelanden. Meddelandet tas emot som en int (inputPerson) och om det värdet är större än ~numberOfPersons ska ett ljud spelas upp. Därefter uppdateras ~numberofPersons. Även denna synthdefinition har en doneAction på 2.
OSCdef(\personListener, { arg inputmsg;
	if (inputmsg.size > 1) {
		var inputPerson = inputmsg[1].asInteger;
		if (inputPerson > ~numberOfPersons) {
			Synth.new(\doorbellSamplePlayer, [\bufnum, ~doorbellSample, \bus, ~outputEffectBus.index, \level, 1;]);
		};
		~numberOfPersons = inputPerson;
	};
}, 'person');


// Följande är en OSC-lyssnare för temperatur-meddelanden. OSC-meddelandet tas emot som en float, och seadan mappas inkommande temperaturvärdet linjärt mot en ljudvolymförändring som är lagt på utgångskanalen och därmed förändrar ljudvolymen på alla syntar som spelar.
OSCdef(\temperatureListener, { arg inputmsg;
	if (inputmsg.size > 1) {
		var inputTemperature = inputmsg[1].asFloat;
		inputTemperature = linlin(inputTemperature, 19.7, 22.3, 0.5, 1.5);
		~songSynth.set(\level, inputTemperature);
	};
}, 'temperature');

)