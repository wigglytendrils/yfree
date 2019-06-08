s.boot;
s.record;
s.stopRecording;

//variables

(
~bpm=60;
~swing=0.1;

~step = (60/1)*(1/~bpm)*(1/4);
~tick = ~step+(~swing*~step);
~tock = ~step-(~swing*~step);
~lagKick=(0)*~step/256;
~lagSnare=(0)*~step/256;
~lagHat=(1)*~step/1600;
~lagClap=(0)*~step/256;

~masterGain = 0.1;
~masterTune = 0.9;

~path = PathName(thisProcess.nowExecutingPath).parentPath; //path for buffers
)

//buffer for \rec synth

(
~andbuf = Buffer.alloc(s, 8*s.sampleRate, 2);
)

//loading synth sample buffers

(
~ryanBass1 = Buffer.readChannel(s,~path++"yfree buffers samples/yfree (ryan bass1).wav",0,-1,1);
~flute = Buffer.readChannel(s,~path++"yfree buffers samples/yfree (flute).wav",0,-1,1);
~trumpet = Buffer.readChannel(s,~path++"yfree buffers samples/yfree (trumpet).wav",0,-1,1);
~laew = Buffer.readChannel(s,~path++"yfree buffers samples/yfree laew flute.wav",0,-1,1);
)

//loading vocal stem buffer

(
~vox =
Buffer.readChannel(s,~path++"yfree buffers stems/yfree double flame vox (01).wav",0,-1,0);
)

//loading drum sample dictionary buffers

(
d = Dictionary.new;
d.add(\hatClosed ->	PathName(~path++"aksel drum samples/hatClosed/").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	});
);
d.add(\hatFoot ->	PathName(~path++"aksel drum samples/hatFoot/").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	});
);
d.add(\kickLoud ->	PathName(~path++"aksel drum samples/kickLoud/").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	});
);
d.add(\kickSoft ->	PathName(~path++"aksel drum samples/kickSoft/").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	});
);
d.add(\snareDead ->	PathName(~path++"aksel drum samples/snareDead/").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	});
);
d.add(\snareRing ->	PathName(~path++"aksel drum samples/snareRing/").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	});
);
d.add(\ride ->	PathName(~path++"aksel drum samples/ride/").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	});
);
d.add(\rideBell ->	PathName(~path++"aksel drum samples/rideBell/").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	});
);
d.add(\floorTom ->	PathName(~path++"aksel drum samples/floorTom/").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	});
);
d.add(\crash ->	PathName(~path++"aksel drum samples/crash/").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	});
);
)

//Synths

(
SynthDef.new(\bufPlay, {
	arg bufnum, rate=1, amp=1, pan=0;
	var sig;
	sig = PlayBuf.ar(1, bufnum, BufRateScale.ir(bufnum) * rate, doneAction:2);
	sig = sig * amp * ~masterGain;
	sig = Pan2.ar(sig, pan);
	Out.ar(0, sig);
}).add;
)

(
SynthDef(\rec,{
	var rate = LFClipNoise.ar(1.5, 0.25, 0.75);
	var phase = Phasor.ar(1, rate, 0, inf);
	BufWr.ar(In.ar(0,2), ~andbuf, phase);
	FreeSelf.kr(A2K.kr(phase)>BufFrames.ir(~andbuf));
}).add;
)

(
SynthDef(\vox, {
	arg out = 0, bufnum = 0, amp=1, atk=0.01, rel=2, trate=120, pan=0;
	var scaledRate, sig, env, b;
	b = ~vox;
	rel= BufDur.kr(b);
	scaledRate = BufRateScale.kr(b);
	sig = 1 * PlayBuf.ar(1, b, scaledRate, doneAction:2)*amp*~masterGain;
	sig = Pan2.ar(sig,pan);
	Out.ar(out, sig)
}).play;
)

(
SynthDef.new(\Colleen3, {
	arg freq=110, atk=0.6, rel=12, amp=1, dur=0.1, pan = 0, out = -1;
	var sig, env;
	freq = freq*(565/250)*PinkNoise.kr(0.05,1)*BrownNoise.kr(0.01,1)*2*~masterTune;
	sig = LPF.ar(CombC.ar(Decay.ar(Impulse.ar(0), 0.2, BrownNoise.ar), 4/(BrownNoise.kr(XLine.kr(10,1,0.2),freq)), 4/(PinkNoise.kr(XLine.kr(10,1,0.2),freq)), 3, 0.4),4000);
	env = EnvGen.kr(Env.new([0,1,0],[atk,rel],[1,-1]),doneAction:2);
	//sig = sig + PinkNoise.ar(0.1);
	//sig = LPF.ar(sig, XLine.kr(10,10000,rel*0.45));
	sig = HPF.ar(sig, XLine.kr(1,500,rel*0.6));
	sig = ~masterGain *(sig*env*amp)*4;
	sig = Pan2.ar(sig,pan);
	Out.ar(out, sig);
}).add;
)

(
SynthDef(\flute, {
	arg out = 0, bufnum = 0, amp=0.5, atk=0.01, rel=2, freq=440, pan=0.0;
	var scaledRate, sig, env;
	env = EnvGen.kr(Env.new([0,1,0],[atk,rel],[1,-1]),doneAction:2);
	b = ~flute;
	freq = 1.8*freq;
	rel= BufDur.kr(b);
	scaledRate = BufRateScale.kr(b)*(freq/520);
	amp = amp*(log2(440)/log2(freq))*0.5;
	sig = PlayBuf.ar(1, b, scaledRate, doneAction:0)*amp;
	sig = sig * env;
	sig = Pan2.ar(sig,pan);
	Out.ar(out, sig)
}).play;
)

(
SynthDef(\trumpet, {
	arg out = 0, bufnum = 0, amp=0.5, atk=0.01, rel=2, freq=440, pan=0.0;
	var scaledRate, sig, env;
	env = EnvGen.kr(Env.new([0,1,0],[atk,rel],[1,-1]),doneAction:2);
	b = ~trumpet;
	freq = 1.8*freq;
	rel= BufDur.kr(b);
	scaledRate = BufRateScale.kr(b)*(freq/700);
	amp = amp*(log2(440)/log2(freq))*0.7;
	sig = PlayBuf.ar(1, b, scaledRate, doneAction:0)*amp;
	sig = sig * env;
	sig = Pan2.ar(sig,pan);
	Out.ar(out, sig)
}).play;
)

(
SynthDef(\laew, {
	arg out = 0, bufnum = 0, amp=0.5, atk=0.01, rel=2, freq=440, pan=0.0;
	var scaledRate, sig, env;
	env = EnvGen.kr(Env.new([0,1,0],[atk,rel],[1,-1]),doneAction:2);
	b = ~laew;
	freq = 1.6*freq;
	rel= BufDur.kr(b);
	scaledRate = BufRateScale.kr(b)*(freq/520);
	amp = amp*(log2(440)/log2(freq))*0.5;
	sig = PlayBuf.ar(1, b, scaledRate, doneAction:0)*amp;
	sig = sig * env;
	sig = Pan2.ar(sig,pan);
	Out.ar(out, sig)
}).play;
)

//Ndefs

(
Ndef(\player, {
	var phase = Phasor.ar(1, Ndef.ar(\rate), 0, BufFrames.ir(~andbuf));
	BufRd.ar(2, ~andbuf, phase, 1, 4);
}).add;
)

//Pdefs

(
Pdef(\vocals,
	Pbind(
	\instrument, \vox,
	\amp, 4*Pseq([1],1),
	)
).play;

Pdef(\player,
	Pbind(
		\instrument, \bufPlay,
		\bufnum, ~andbuf,
		\amp, 1*Pseq([1],1),
	)
).play;

Pdef(\kick,
	Pbind(
	//\instrument, \kick2,
	\instrument, \bufPlay,
	\bufnum, Prand(d[\kickLoud],inf),
	\lag, ~lagKick,
	\dur, Pseq([(~tick+~tock)/3],inf),
	\amp, 8*Pseq([
		1,0,0, 0,0,0, 0,0,0, 0,0,0,
		0,0.1,0.1, 1,0,0, 0,0,0, 0.5,0.2,0.1,
	], inf)*Pseq([1],inf),
	)
).play;

Pdef(\snare,
	Pbind(
	\instrument, \bufPlay,
	\bufnum, Prand(d[\snareDead],inf),
	//\freq, 120,
	\lag, ~lagClap,
	\dur, Pseq([~tick,~tock],inf),
	\amp, 3*Pseq([
		0,0,0,0, 1,0,0,0, 0,0,0,0, 1,0,0,0,
		0,0,0,0, 1,0,0,0, 0,0,0,0, 1,0,0,0,
	], inf),
	)
).play;

Pdef(\hat,
	Pbind(
	//\instrument, \clap,
	\instrument, \bufPlay,
		\bufnum, Pseq([Prand(d[\hatClosed],4)],inf),
	//\freq, 120,
	\lag, ~lagClap,
		\dur, Pseq([(~tick+~tock)/3],inf),
	\amp, 3*Pseq([
			1,1,1, 1,1,1, 1,1,1, 1,1,1,
			1,1,1, 1,1,1, 0,1,1, 1,1,1,
		], inf)*Pseq([0.2,1],inf),
	\pan, 0.5,
	)
).play;

Pdef(\ride,
	Pbind(
	//\instrument, \clap,
	\instrument, \bufPlay,
		\bufnum, Pseq([Prand(d[\ride],4)],inf),
	//\freq, 120,
	\lag, ~lagClap,
		\dur, Pseq([(~tick+~tock)/3],inf),
	\amp, 5*Pseq([
			1,1,1,
		], inf)*Pseq([0.2,1],inf),
	\pan, -0.5,
	)
).play;

Pdef(\crash,
	Pbind(
	//\instrument, \clap,
	\instrument, \bufPlay,
		\bufnum, Pseq([Prand(d[\crash],4)],inf),
	//\freq, 120,
	\lag, ~lagClap,
		\dur, Pseq([(~tick+~tock)/3],inf),
	\amp, 4*Pseq([
			1,1,1,
		], inf)*Pseq([0.2,1],inf),
	\pan, -0.5,
	)
).play;

Pdef(\flute,
	Pbind(
	\instrument, \flute,
	\dur, Pseq([~tick,~tock],inf),
	\strum, 0.4,
		\octave, [3,4],
	\degree, [0]+Pseq([
			Pseq([[00,02,04,07,09]],16),
			Prand([[00,03,05,07,09]],16),
			Prand([[-01,01,04,06,10]],16),
			Pseq([[00,02,04,07,09]],16),
		],inf)+[0,2,4],
	\amp, 0.15*Pseq([0,0,1,0.5, 0.25,0.1,0.7,0.5, 0.25,0.1,0.5,0.25, 0.1,0.1,0.1,0,],inf),
		\pan, Prand([-1,1],inf),
	)
).play;

Pdef(\laew,
	Pbind(
	\instrument, \laew,
	\dur, Pseq([~tick,~tock],inf),
	\strum, 0.4,
		\octave, [4,5],
	\degree, [0]+Pseq([
			Pseq([[00,02,04,07,09]],16),
			Prand([[00,03,05,07,09]],16),
			Prand([[-01,01,04,07,10]],16),
			Pseq([[00,02,04,07,09]],16),
		],inf)+[0,2,4],
	\amp, 0.35*Pseq([0,0,1,0.5, 0.25,0.1,0.7,0.5, 0.25,0.1,0.5,0.25, 0.1,0.1,0.1,0,],inf),
		\pan, Prand([-1,1],inf),
	)
).play;

Pdef(\trumpet,
	Pbind(
	\instrument, \trumpet,
	\dur, Pseq([~tick,~tock],inf),
	\strum, 0.3,
	\octave, [3,4],
	\degree, [0]+Pseq([
			Pseq([[00,02,04,07,09]],16),
			Prand([[00,03,05,07,09]],16),
			Pseq([[-01,01,04,06,10]],16),
			Prand([[00,02,05,07,09]],16),
		],inf)+[0,2,4,6],
	\amp, 0.15*Pseq([0,0,1,0.5, 0.25,0.1,0.7,0.5, 0.25,0.1,0.5,0.25, 0.1,0.1,0.1,0,],inf),
		\pan, Prand([-1,1],inf),
	)
).play;
)

//TempoClock

(
v = Main.elapsedTime.ceil;
t = TempoClock(~bpm/60, 0, v);

t.schedAbs(0, {//intro

	"the double Flame".postln;

	Pdef(\vocals).play(quant: 0.1);
	Pdef(\trumpet).play(quant: 0.1);
	Pdef(\flute).play(quant: 0.1);
	//Pdef(\snare).play(quant: 0.1);
	//Pdef(\kick).play(quant: 0.1);
	//Pdef(\ryanBass).play(quant: 0.1);
	//Pdef(\hat).play(quant: 0.1);

	~andbuf = Buffer.alloc(s, 8*s.sampleRate, 2);

	SynthDef(\rec,{
		var rate = LFClipNoise.ar(1.5, 0.25, 0.75);
		var phase = Phasor.ar(1, rate, 0, inf);
		BufWr.ar(In.ar(0,2), ~andbuf, phase);
		FreeSelf.kr(A2K.kr(phase)>BufFrames.ir(~andbuf));
	}).play;

	Synth(\rec, addAction:\addToTail);

	//Ndef(\rate, {DC.ar(-0.5)});
	Ndef(\rate, {SinOsc.ar(5.5,0,SinOsc.ar(0.25,0,2e-2,0),-1)});

	Ndef(\player, {
		var phase = Phasor.ar(1, Ndef.ar(\rate), 0, BufFrames.ir(~andbuf));
		BufRd.ar(2, ~andbuf, phase, 1, 4);
	});

	//Ndef(\player).play;

});

t.schedAbs(1*16-1, {

	//Ndef(\player).stop;

});

t.schedAbs(1*16, {//my evening star oh there you are but where am i

	"my evening star oh there you are but where am i".postln;

	Ndef(\player).stop;

});

t.schedAbs(2*16-4, {

	Synth(\rec, addAction:\addToTail);

});

t.schedAbs(2*16-3, {

	Pdef(\trumpet).stop;
	Pdef(\flute).stop;
	Pdef(\hat).stop;
	Pdef(\kick).stop;

	Pdef(\crash).play;

	Ndef(\rate, {SinOsc.ar(5.5,0,SinOsc.ar(0.25,0,2e-2,0),Line.kr(-1.5,-0.5))});
	Ndef(\player).play;

	Synth(\rec, addAction:\addToTail);

});

t.schedAbs(2*16-1, {

	Ndef(\player).stop;
	Pdef(\crash).stop;

});

t.schedAbs(2*16, {//i lost my way where i cannot say where i went awry

	"i lost my way where i cannot say where i went awry".postln;

	Pdef(\snare).stop;

	Pdef(\flute).play(quant: 0.1);
	//Pdef(\trumpet).play(quant: 0.1);
	Pdef(\snare).play(quant: 0.1);
	Pdef(\kick).play(quant: 0.1);
	Pdef(\hat).play(quant: 0.1);

});

t.schedAbs(3*16-3, {

	Pdef(\flute).stop;
	Pdef(\trumpet).stop;
	Pdef(\hat).stop;
	Pdef(\kick).stop;

	Pdef(\crash).play;

	Ndef(\rate, {SinOsc.ar(5.5,0,SinOsc.ar(0.25,0,2e-2,0),-1)});
	Ndef(\player).play;

	Synth(\rec, addAction:\addToTail);

});

t.schedAbs(3*16-0.75, {

	Ndef(\player).stop;
	Pdef(\crash).stop;

});

t.schedAbs(3*16, {//you were drawn to me i was drawn to what i could see i used to look to your light

	"you were drawn to me i was drawn to what i could see i used to look to your light".postln;

	Pdef(\snare).stop;

	Pdef(\flute).play(quant: 0.1);
	Pdef(\trumpet).play(quant: 0.1);
	Pdef(\snare).play(quant: 0.1);
	Pdef(\kick).play(quant: 0.1);
	Pdef(\hat).play(quant: 0.1);

});

t.schedAbs(4*16-3, {

	Pdef(\flute).stop;
	Pdef(\trumpet).stop;
	Pdef(\hat).stop;
	Pdef(\kick).stop;

	Pdef(\crash).play;

	Ndef(\rate, {SinOsc.ar(5.5,0,SinOsc.ar(0.25,0,2e-2,0),-1)});
	Ndef(\player).play;

	Synth(\rec, addAction:\addToTail);

});

t.schedAbs(4*16-0.75, {

	Ndef(\player).stop;
	Pdef(\crash).stop;

});

t.schedAbs(4*16, {//suddenly changed may the double flame burn again just as bright

	"suddenly changed may the double flame burn again just as bright".postln;

	Pdef(\snare).stop;

	Pdef(\flute).play(quant: 0.1);
	//Pdef(\trumpet).play(quant: 0.1);
	Pdef(\snare).play(quant: 0.1);
	Pdef(\kick).play(quant: 0.1);
	Pdef(\hat).play(quant: 0.1);

	Synth(\rec, addAction:\addToTail);

});

t.schedAbs(5*16-3, {

	Pdef(\flute).stop;
	Pdef(\trumpet).stop;
	Pdef(\hat).stop;
	Pdef(\kick).stop;

	Pdef(\crash).play;

	Ndef(\rate, {SinOsc.ar(5.5,0,SinOsc.ar(0.25,0,2e-2,0),-1)});
	Ndef(\player).play;

	Synth(\rec, addAction:\addToTail);

});

t.schedAbs(5*16-0.75, {

	Ndef(\player).stop;
	Pdef(\crash).stop;

});

t.schedAbs(5*16, {//may it light you may it light you may it light you home

	"may it light you may it light you may it light you home".postln;

	Pdef(\snare).stop;

	Pdef(\flute).play(quant: 0.1);
	Pdef(\trumpet).play(quant: 0.1);
	Pdef(\snare).play(quant: 0.1);
	Pdef(\kick).play(quant: 0.1);
	Pdef(\ride).play(quant: 0.1);
	Pdef(\ryanBass).play(quant: 0.1);

	Synth(\rec, addAction:\addToTail);

});

t.schedAbs(6*16-3, {

	Pdef(\flute).stop;
	Pdef(\trumpet).stop;
	Pdef(\ride).stop;
	Pdef(\kick).stop;

	Ndef(\rate, {SinOsc.ar(5.5,0,SinOsc.ar(0.25,0,2e-2,0),-1)});
	Ndef(\player).play;

	Synth(\rec, addAction:\addToTail);

});

t.schedAbs(6*16-0.75, {

	Ndef(\player).stop;

});

t.schedAbs(6*16, {//may it light you may it light you may it light you home

	"may it light you may it light you may it light you home".postln;

	Pdef(\snare).stop;

	Pdef(\flute).play(quant: 0.1);
	Pdef(\laew).play(quant: 0.1);
	Pdef(\snare).play(quant: 0.1);
	Pdef(\kick).play(quant: 0.1);
	Pdef(\ride).play(quant: 0.1);

	Synth(\rec, addAction:\addToTail);

});

t.schedAbs(7*16-3, {

	Pdef(\flute).stop;
	Pdef(\laew).stop;
	Pdef(\ride).stop;
	Pdef(\kick).stop;

	Ndef(\rate, {SinOsc.ar(5.5,0,SinOsc.ar(0.25,0,2e-2,0),-1)});
	Ndef(\player).play;

	Synth(\rec, addAction:\addToTail);

});

t.schedAbs(7*16-0.75, {

	Ndef(\player).stop;

});

t.schedAbs(7*16, {//my double flame i call your name i am calling your name

	"my double flame i call your name i am calling your name".postln;

	Pdef(\snare).stop;

	Pdef(\flute).play(quant: 0.1);
	Pdef(\laew).play(quant: 0.1);
	Pdef(\snare).play(quant: 0.1);
	Pdef(\kick).play(quant: 0.1);
	Pdef(\hat).play(quant: 0.1);

	Synth(\rec, addAction:\addToTail);

});

t.schedAbs(8*16-3, {

	Pdef(\flute).stop;
	Pdef(\laew).stop;
	Pdef(\hat).stop;
	Pdef(\kick).stop;

	Ndef(\rate, {SinOsc.ar(5.5,0,SinOsc.ar(0.25,0,2e-2,0),-1)});
	Ndef(\player).play;

	Synth(\rec, addAction:\addToTail);

});

t.schedAbs(8*16-0.75, {

	Ndef(\player).stop;

});

t.schedAbs(8*16, {//i'm in trouble shaking ailing aching i am suddenly changed

	"i'm in trouble shaking ailing aching i am suddenly changed".postln;

	Pdef(\snare).stop;

	Pdef(\flute).play(quant: 0.1);
	Pdef(\trumpet).play(quant: 0.1);
	Pdef(\snare).play(quant: 0.1);
	Pdef(\kick).play(quant: 0.1);
	Pdef(\hat).play(quant: 0.1);

	Synth(\rec, addAction:\addToTail);

});

t.schedAbs(9*16-3, {

	Pdef(\flute).stop;
	Pdef(\trumpet).stop;
	Pdef(\hat).stop;
	Pdef(\kick).stop;

	Ndef(\rate, {SinOsc.ar(5.5,0,SinOsc.ar(0.25,0,2e-2,0),-1)});
	Ndef(\player).play;

	Synth(\rec, addAction:\addToTail);

});

t.schedAbs(9*16-0.75, {

	Ndef(\player).stop;

});

t.schedAbs(9*16, {//i was drawn to you you were drawn to what i could do you used to look to my light

	"i was drawn to you you were drawn to what i could do you used to look to my".postln;

	Pdef(\snare).stop;

	Pdef(\flute).play(quant: 0.1);
	//Pdef(\trumpet).play(quant: 0.1);
	Pdef(\snare).play(quant: 0.1);
	Pdef(\kick).play(quant: 0.1);
	Pdef(\hat).play(quant: 0.1);

	Synth(\rec, addAction:\addToTail);

});

t.schedAbs(10*16-3, {

	Pdef(\flute).stop;
	Pdef(\trumpet).stop;
	Pdef(\hat).stop;
	Pdef(\kick).stop;

	Ndef(\rate, {SinOsc.ar(5.5,0,SinOsc.ar(0.25,0,2e-2,0),-1)});
	Ndef(\player).play;

	Synth(\rec, addAction:\addToTail);

});

t.schedAbs(10*16-0.75, {

	Ndef(\player).stop;

});

t.schedAbs(10*16, {//suddenly changed may the double flame burn again just as bright

	"suddenly changed may the double flame burn again just as bright".postln;

	Pdef(\snare).stop;

	Pdef(\flute).play(quant: 0.1);
	Pdef(\trumpet).play(quant: 0.1);
	Pdef(\snare).play(quant: 0.1);
	Pdef(\kick).play(quant: 0.1);
	Pdef(\hat).play(quant: 0.1);

	Synth(\rec, addAction:\addToTail);

});

t.schedAbs(11*16-3, {

	Pdef(\flute).stop;
	Pdef(\trumpet).stop;
	Pdef(\hat).stop;
	Pdef(\kick).stop;

	Ndef(\rate, {SinOsc.ar(5.5,0,SinOsc.ar(0.25,0,2e-2,0),-1)});
	Ndef(\player).play;

	Synth(\rec, addAction:\addToTail);

});

t.schedAbs(11*16-0.75, {

	Ndef(\player).stop;

});

t.schedAbs(11*16, {//may it light you may it light you may it light you home

	"may it light you may it light you may it light you home".postln;

	Pdef(\snare).stop;

	Pdef(\flute).play(quant: 0.1);
	Pdef(\laew).play(quant: 0.1);
	Pdef(\snare).play(quant: 0.1);
	Pdef(\kick).play(quant: 0.1);
	Pdef(\ride).play(quant: 0.1);

	Synth(\rec, addAction:\addToTail);

});

t.schedAbs(12*16-3, {

	Pdef(\flute).stop;
	Pdef(\laew).stop;
	Pdef(\ride).stop;
	Pdef(\kick).stop;

	Ndef(\rate, {SinOsc.ar(5.5,0,SinOsc.ar(0.25,0,2e-2,0),-1)});
	Ndef(\player).play;

	Synth(\rec, addAction:\addToTail);

});

t.schedAbs(12*16-0.75, {

	Ndef(\player).stop;

});

t.schedAbs(12*16, {//may it light you may it light you may it light you home

	"may it light you may it light you may it light you home".postln;

	Pdef(\snare).stop;

	Pdef(\flute).play(quant: 0.1);
	Pdef(\trumpet).play(quant: 0.1);
	Pdef(\snare).play(quant: 0.1);
	Pdef(\kick).play(quant: 0.1);
	Pdef(\ride).play(quant: 0.1);

	Synth(\rec, addAction:\addToTail);

});

t.schedAbs(13*16-3, {

	Pdef(\ride).stop;

	Ndef(\rate, {SinOsc.ar(5.5,0,SinOsc.ar(0.25,0,2e-2,0),-1)});
	Ndef(\player).play;

	Synth(\rec, addAction:\addToTail);
});
)