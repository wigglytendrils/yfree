/*
Attribution-NonCommercial-ShareAlike 3.0 Unported (CC BY-NC-SA 3.0) https://creativecommons.org/licenses/by-nc-sa/3.0/
*/

s.boot;
s.record;
s.stopRecording;

//variables

(
~bpm=135;
~swing=0.15;

~step = (60/1)*(1/~bpm)*(1/4);
~tick = ~step+(~swing*~step);
~tock = ~step-(~swing*~step);
~lagKick=(-1)*~step/128;
~lagSnare=~step/16;
~lagHat=~step/16;
~lagClap=~step/8;
~lagBass=0;
~lagHook=~step/128;

~masterGain = 0.3;

~scale = Scale.ionian(\just);

~path = PathName(thisProcess.nowExecutingPath).parentPath; //path for buffers
)

//loading stem buffers

(
~dklandAnythingCouldHappen = Buffer.readChannel(s,~path++"yfree_buffers_stems/dkland anything could happen.wav",0,-1,1);

~anythingCouldHappenVox = Buffer.readChannel(s,~path++"yfree_buffers_stems/YFREE anything could happen (03 vox).wav",0,-1,1);
)

//loading synth sample buffers

(
~flute = Buffer.readChannel(s,~path++"yfree_buffers_samples/yfree (flute).wav",0,-1,1);
~trumpet = Buffer.readChannel(s,~path++"yfree_buffers_samples/yfree (trumpet).wav",0,-1,1);
~laew = Buffer.readChannel(s,~path++"yfree_buffers_samples/yfree laew flute.wav",0,-1,1);
)

//loading drum sample dictionary buffers

(
d = Dictionary.new;
d.add(\hatClosed ->	PathName(~path++"aksel_drum_samples/hatClosed/").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	});
);
d.add(\hatFoot ->	PathName(~path++"aksel_drum_samples/hatFoot/").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	});
);
d.add(\kickLoud ->	PathName(~path++"aksel_drum_samples/kickLoud/").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	});
);
d.add(\kickSoft ->	PathName(~path++"aksel_drum_samples/kickSoft/").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	});
);
d.add(\snareDead ->	PathName(~path++"aksel_drum_samples/snareDead/").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	});
);
d.add(\snareRing ->	PathName(~path++"aksel_drum_samples/snareRing/").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	});
);
d.add(\ride ->	PathName(~path++"aksel_drum_samples/ride/").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	});
);
d.add(\rideBell ->	PathName(~path++"aksel_drum_samples/rideBell/").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	});
);
d.add(\floorTom ->	PathName(~path++"aksel_drum_samples/floorTom/").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	});
);
d.add(\crash ->	PathName(~path++"aksel_drum_samples/crash/").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	});
);
)

//synthdefs

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
SynthDef(\trumpet, {
	arg out = 0, bufnum = 0, amp=0.5, atk=0.01, rel=2, freq=440, pan=0.0;
	var scaledRate, sig, env;
	env = EnvGen.kr(Env.new([0,1,0],[atk,rel],[1,-1]),doneAction:2);
	b = ~trumpet;
	freq = 1.4*freq;
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
SynthDef(\laew, {
	arg out = 0, bufnum = 0, amp=0.5, atk=0.01, rel=2, freq=440, pan=0.0;
	var scaledRate, sig, env;
	env = EnvGen.kr(Env.new([0,1,0],[atk,rel],[1,-1]),doneAction:2);
	b = ~laew;
	freq = 1.6*freq*XLine.kr(1,0.98,2);
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
SynthDef(\anythingCouldHappenVox, {
	arg out = 0, amp=1;
	var sig, env;
	b = ~anythingCouldHappenVox;
	sig = 0.5*PlayBuf.ar(1, b, 1, doneAction:2)*amp*2;
	Out.ar(out, [sig,sig])
}).add;
)

//pdefs

(

Pdef(\anythingCouldHappenVox,
	Pbind(
		\instrument, \anythingCouldHappenVox,
		//\lag, 0.1,
		\amp, ~masterGain*4*Pseq([1],1),
	)
).play;

Pdef(\flute,
	Pbind(
		\instrument, \laew,
		\octave, Pseq([5,6],inf),
		\lag, 0,
		\degree, Pseq([
			0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
			0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
			0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
			0,0,0,0, 0,0,0,0, 0,0,0,0, -1.1,-1.1,-1.1,-1.1,
			0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
			0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
			0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
			0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
		],inf),
		\dur, Pseq([~tick,~tock],inf),
		\amp, Pseq([1,0.2],inf)*Pseq([
			0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
			0.5,0.6,0.7,1, 0,0,0,0, 0,0,0,0, 0,0,0,0,
			0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
			0,0,0,0, 0,0,0,0, 0,0,0,0, 0.5,0.6,0.7,1,
			0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
			0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
			0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
			0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
		],inf),
		\pan, Pseq([-0.5,0.5],inf),
	)
).play;

/*
Pdef(\fluteChorus,
	Pbind(
		//\instrument, Pseq([\rootsKick,\gabeKick,],inf),
		\instrument, \laew,
		\octave, [2],
		\lag, 1.8,
		\degree, Pseq([
			7,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
			0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
			3,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
			0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
			-1.1,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
			0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
			-1.1,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
			0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
		],1),
		\dur, Pseq([~tick,~tock],inf),
		\amp, 4*Pseq([
			1,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
			0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
		],inf),
	)
).play;
*/

Pdef(\fluteChorus,
	Pbind(
		\instrument, \laew,
		\octave, [2],
		//\lag, 1.8,
		\degree, Pseq([
			7,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
			0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
			3,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
			0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
			-1.1,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
			0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
			-1.1,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
			0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
		],1),
		\dur, Pseq([~tick,~tock],inf),
		\amp, 4*Pseq([
			1,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
			0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
		],inf),
	)
).play;

Pdef(\kick,
	Pbind(
		\instrument, \bufPlay,
		\bufnum, Prand(d[\kickLoud],inf),
		//\lag, ~lagKick,
		\dur, Pseq([~tick,~tock],inf),
		//\rate, 0.85,
		\amp, 2*Pseq([
			1,0,0,0, 0,0,1,0, 0,0,0.1,0, 0.1,1,0,0,
			1,0,0,1, 0,0,1,0.1, 0,0,0,0, 0,0,0.1,0.1,
			1,0,0,0, 0,0,1,0, 0,0,0.1,0.1, 0.1,1,0,0,
			1,0,0,1, 0,0,1,0, 0,0,0,0, 0,0,0,0,
		],inf)*Pseq([1,0.6],inf),
	)
).play;

Pdef(\hatFoot,
	Pbind(
		\instrument, \bufPlay,
		\bufnum, Prand(d[\hatFoot],inf),
		\dur, Pseq([~tick,~tock],inf),
		//\lag, ~lagSnare,
		\pan, 1,
		\amp, 4*Pseq([
			0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,1,0,
			0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
			0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,1,0,
			0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
		],inf),
	)
).play;

Pdef(\ride,
	Pbind(
	\instrument, \bufPlay,
		\bufnum, Pseq([Prand(d[\ride],12),Prand(d[\rideBell],1)],inf),
	//\lag, ~lagHat,
		\dur, Pseq([~tick,~tock],inf),
	\pan, -1,
		\amp, 2.5*Pseq([

			0,1,1,1, 1,0,0,1, 0,1,1,0, 0,1,1,0,
			0,1,1,0, 1,0,0,1, 0,0,0,0, 0,0,0,0,
			0,1,1,1, 1,0,0,1, 0,1,1,0, 0,1,1,0,
			0,1,1,0, 1,0,0,1, 0,0,0,0, 0,0,0,0,
			0,1,1,1, 1,0,0,1, 0,1,1,0, 0,1,1,0,
			0,1,1,0, 1,0,0,1, 0,0,0,0, 0,0,0,0,
			0,1,1,1, 1,0,0,1, 0,1,1,0, 0,1,1,0,
			0,1,1,0, 1,0,0,1, 0,0,0,0, 0,0,0,0,

		],inf)*Pseq([0.7,1],inf),
	)
).play;

Pdef(\hat,
	Pbind(
	\instrument, \bufPlay,
		\bufnum, Pseq([Prand(d[\hatClosed],15),Prand(d[\rideBell],1)],inf),
	//\lag, ~lagHat,
	\dur, Pseq([~tick,~tock],inf),
	//\rate, 1.05,
	\pan, 1,
		\amp, 2.5*Pseq([
			1,1,1,1, 1,1,1,1, 0,1,1,1, 1,1,1,1,
			1,1,1,1, 1,1,1,1, 0,0,0,0, 0,0,0,0,
			1,1,1,1, 1,1,1,1, 0,1,1,1, 1,1,1,1,
			1,1,1,1, 1,1,1,1, 0,0,0,0, Pshuf([1,0,0,0,],1),
		],inf)*Pseq([1,0.2],inf),
	)
).play;

Pdef(\bellQuarters,
	Pbind(
	\instrument, \bufPlay,
		\bufnum, Prand([Prand(d[\ride],3),Prand(d[\rideBell],1)],inf),
	//\lag, ~lagHat,
	\dur, Pseq([~tick,~tock],inf),
	//\rate, 1.05,
	\pan, -1,
		\amp, 3*Pseq([
			1,0,0,0, 0.5,0,0,0, 0.5,0,0,0, 0.5,0,0,0,
		],inf),
	)
).play;

Pdef(\snareDead,
	Pbind(
	\instrument, \bufPlay,
	\bufnum, Prand(d[\snareDead],inf),
	//\lag, ~lagClap,
	\dur, Pseq([~tick,~tock],inf),
	//\rate, 0.85,
	\amp, 2*Pseq([
			0,0,0,0, 0,0,0,0, 1,0,0,0, 0,0,0,0,
			0,0,0,0, 0,0,0,0, 1,0,0,0, 0,0,0,0,
			0,0,0,0, 0,0,0,0, 1,0,0,0, 0,0,0,0,
			0,0,0,0, 0,0,0,0, 1,0,0,0, Pshuf([0.0,0,0.5,1,],1),
		],inf),
	)
).play;
)

//tempo clock

(
v = Main.elapsedTime.ceil;
t = TempoClock(~bpm/60, 0, v);

t.schedAbs(0, { //intro

	Pdef(\anythingCouldHappenVox).play(quant: 0.2);

	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~dklandAnythingCouldHappen;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*EnvGen.kr(Env([0,0.398,0.401,0],[1,13.4,0.1]*(60/135),-1));//0.21
		pan = 0.9;
		~masterGain*1*TGrains.ar(2, clk, buf, SinOsc.kr(0.1,1), pos, 2 * 20/135, pan, 4);
	}.play;

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~dklandAnythingCouldHappen;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*EnvGen.kr(Env([0,0.4,0.402,0],[1,13.4,0.1]*(60/135),-2));//0.21
		pan = -0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,[1,0.5]), pos, 2 * 20/135, pan, 2);
	}.play;


});


t.schedAbs(2*8-1.5, { //intro
	x.free;
	y.free;
});

t.schedAbs(2*8, { //intro

	x.free;
	y.free;

	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~dklandAnythingCouldHappen;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*EnvGen.kr(Env([0,0.4,0.405,0],[1,13.4,0.1]*(60/135),-5));//0.21
		pan = 0.9;
		~masterGain*1*TGrains.ar(2, clk, buf, SinOsc.kr(0.1,1), pos, 2 * 20/135, pan, 4);
	}.play;

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~dklandAnythingCouldHappen;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*EnvGen.kr(Env([0,0.4,0.403,0],[1,13.4,0.1]*(60/135),-2));//0.21
		pan = -0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,[1,0.5]), pos, 2 * 20/135, pan, 2);
	}.play;

});

t.schedAbs(4*8-1.5, { //intro

	x.free;
	y.free;

});

t.schedAbs(4*8, { //the sun didn't

	Pdef(\flute).play(quant: 0.1);

	"the sun didn't rise this morning".postln;

	Pdef(\kick).play(quant: 0.1);
	Pdef(\snareDead).play(quant: 0.1);
	//Pdef(\hatFoot).play(quant: 0.1);
	//Pdef(\ride).play(quant: 0.1);
	//Pdef(\bellQuarters).play(quant: 0.1);

	x.free;
	y.free;

	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~dklandAnythingCouldHappen;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.4;//0.21
		pan = 0.9;
		~masterGain*[0.25,0.4]*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,[2,1])*EnvGen.kr(Env([0, 1,0.89,0.89,1, 1,0.89,0.89,1],[8,8,8,8, 8,8,8,8]*(60/135),-25)), pos, 2 * 20/135, pan, 2.5);
	}.play;

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~dklandAnythingCouldHappen;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.4;//0.21
		pan = -0.9;
		~masterGain*[0.4,0.25]*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,[1,2])*EnvGen.kr(Env([0, 1,0.89,0.89,1, 1,0.89,0.89,1],[8,8,8,8, 8,8,8,8]*(60/135),-20)), pos, 2 * 20/135, pan, 2.5);
	}.play;

	/*

	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~dklandAnythingCouldHappen;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*EnvGen.kr(Env(
			[0,0.075,0.090,0.105,0.128,0.1352,0.145,0.16,0.173,0.187,0.196,0.207,0.217,],
			[8,8,8,8,8,8,8,8,8,8,8,8,]*(60/135),
			EnvGen.kr(Env([-50,-10],[64,32]*60/135))
		));//0.21
		pan = 0.9;
		~masterGain*0.3*TGrains.ar(2, clk, buf, SinOsc.kr(4,0,
			EnvGen.kr(Env([0.008,0.008,0,0,0.1,0,1],[63,1,8,8,8,8]*60/135,-5)),
			[1,0.5]), pos, 2 * 20/135, pan, 0.8, [0.1,0.1]);
	}.play;

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~dklandAnythingCouldHappen;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*EnvGen.kr(Env(
			[0,0.075,0.090,0.105,0.128,0.1352,0.145,0.16,0.173,0.187,0.196,0.207,0.217],
			[8,8,8,8,8,8,8,8,8,8,8,8,]*(60/135),
			EnvGen.kr(Env([-50,-10],[64,32]*60/135))));//0.21
		pan = -0.9;
		~masterGain*0.3*TGrains.ar(2, clk, buf, SinOsc.kr(7,0,
			EnvGen.kr(Env([0.008,0.008,0,0,0.1,0,1],[63,1,8,8,8,8]*60/135,-5)),
			[0.5,2]), pos, 2 * 20/135, pan, 0.8, [0.1,0.05]);
	}.play;

	*/


});

t.schedAbs(12*8, { //and it turned to you and touched your face and felt


	x.free;
	y.free;

	Pdef(\flute).stop;
	Pdef(\kick).stop;
	Pdef(\snareDead).stop;
	Pdef(\hatFoot).stop;
	Pdef(\hat).stop;
	Pdef(\ride).stop;
	Pdef(\bellQuarters).stop;

});

t.schedAbs(16*8, { //and it turned to you and touched your face and felt

	x.free;
	y.free;

	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~dklandAnythingCouldHappen;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*Line.kr(0.229,0.232,12);//0.21
		pan = 0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,1), pos, 2 * 20/135, pan, 0.5);
	}.play;

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~dklandAnythingCouldHappen;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*Line.kr(0.228,0.23,12);//0.21
		pan = -0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,1), pos, 2 * 20/135, pan, 0.5);
	}.play;

});

t.schedAbs(20*8-4, { //...
	x.free;
	y.free;

	Pdef(\hat).stop;
	Pdef(\snareDead).stop;
	Pdef(\hatFoot).stop;
	Pdef(\ride).stop;
});

t.schedAbs(20*8-3.5, { //...

	Pdef(\kick).stop;

});

t.schedAbs(21*8, { //we catch falling stars

	Pdef(\bellQuarters).stop;
	Pdef(\kick).play(quant: 0.1);
	Pdef(\snareDead).play(quant: 0.1);
	Pdef(\hat).play(quant: 0.1);
	Pdef(\hatFoot).play(quant: 0.1);
	//Pdef(\ride).play(quant: 0.1);
	Pdef(\fluteChorus).play(quant: 0.1);

	x.free;
	y.free;


	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~dklandAnythingCouldHappen;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*EnvGen.kr(Env(
			[0,0.26,0.305,0.37,0.391,0.4],
			[8,8,8,8,8,]*(60/135),
			EnvGen.kr(Env([-50,-10],[64,32]*60/135))
		));//0.21
		pan = 0.9;
		pan = 0.9;
		//~masterGain*0.3*TGrains.ar(2, clk, buf, SinOsc.kr(4,0,
			//EnvGen.kr(Env([0.008,0.008,0,0,0.1,0,1],[63,1,8,8,8,8]*60/135,-5)),
			//[1,0.5]), pos, 2 * 20/135, pan, 0.8, [0.1,0.1]);
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,1), pos, 2 * 20/135, pan, 0.6);
	}.play;

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~dklandAnythingCouldHappen;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = pos = BufDur.kr(buf)*EnvGen.kr(Env(
			[0,0.26,0.315,0.37,0.389,0.4],
			[8,8,8,8,8,]*(60/135),
			EnvGen.kr(Env([-50,-10],[64,32]*60/135))
		));//0.21
		pan = -0.9;
		//~masterGain*0.3*TGrains.ar(2, clk, buf, SinOsc.kr(7,0,
			//EnvGen.kr(Env([0.008,0.008,0,0,0.1,0,1],[63,1,8,8,8,8]*60/135,-5)),
			//[0.5,2]), pos, 2 * 20/135, pan, 0.8, [0.1,0.05]);
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,1), pos, 2 * 20/135, pan, 0.6);
	}.play;

});

/*
t.schedAbs(22*8-1.5, { //intro

});

t.schedAbs(22*8, { //i crash my car

});

t.schedAbs(23*8-1.5, { //intro

});

t.schedAbs(23*8, { //you break my heart

});

t.schedAbs(24*8-1.5, { //intro

});

t.schedAbs(24*8, { //anything could happen

});

t.schedAbs(25*8-1.5, { //...

});

t.schedAbs(25*8, { //...

});
*/

t.schedAbs(4*8+200, { //the sun didn't

	x.free;
	y.free;

	Pdef(\hat).stop;
	Pdef(\hatFoot).stop;

	//Pdef(\flute).play(quant: 0.1);
	Pdef(\ride).play(quant: 0.1);
	//Pdef(\bellQuarters).play(quant: 0.1);

	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~dklandAnythingCouldHappen;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*EnvGen.kr(Env(
			[0,0.075,0.090,0.105,0.128,0.1352,0.145,0.16,0.173,0.187,0.196,0.207,0.217,],
			[8,8,8,8,8,8,8,8,8,8,8,8,]*(60/135),
			EnvGen.kr(Env([-50,-10],[64,32]*60/135))
		));//0.21
		pan = 0.9;
		~masterGain*1.6*TGrains.ar(2, clk, buf, SinOsc.kr(4,0,
			EnvGen.kr(Env([0.008,0.008,0,0,0.1,0,1],[63,1,8,8,8,8]*60/135,-5)),
			[1,0.5]), pos, 2 * 20/135, pan, 0.8, [0.1,0.1]);
	}.play;

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~dklandAnythingCouldHappen;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*EnvGen.kr(Env(
			[0,0.075,0.090,0.105,0.128,0.1352,0.145,0.16,0.173,0.187,0.196,0.207,0.217],
			[8,8,8,8,8,8,8,8,8,8,8,8,]*(60/135),
			EnvGen.kr(Env([-50,-10],[64,32]*60/135))));//0.21
		pan = -0.9;
		~masterGain*1.6*TGrains.ar(2, clk, buf, SinOsc.kr(7,0,
			EnvGen.kr(Env([0.008,0.008,0,0,0.1,0,1],[63,1,8,8,8,8]*60/135,-5)),
			[0.5,2]), pos, 2 * 20/135, pan, 0.8, [0.1,0.05]);
	}.play;

});

/*
t.schedAbs(5*8+200, { //rise this morning

});

t.schedAbs(6*8+200, { //but the earth con...

});

t.schedAbs(7*8+200, { //...tinued turning

});

t.schedAbs(8*8+200, { //no star shot a...

});

t.schedAbs(9*8+200, { //...cross the night sky

});

t.schedAbs(10*8+200, { //but a meteor caught on fire...

});

t.schedAbs(11*8+200, { //but a meteor caught on fire...

});

t.schedAbs(12*8+200, { //we saw it throught the

});

t.schedAbs(13*8+200, { //windsheild

});

t.schedAbs(14*8+200, { //as we cut across the

});

t.schedAbs(15*8+200, { //wheat field

});
*/

t.schedAbs(16*8+200, { //and it turned to you and touched your face and felt

	x.free;
	y.free;

	//Pdef(\flute).stop;
	Pdef(\ride).stop;
	Pdef(\bellQuarters).stop;
	Pdef(\hat).stop;

	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~dklandAnythingCouldHappen;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*Line.kr(0.229,0.232,12);//0.21
		pan = 0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,1), pos, 2 * 20/135, pan, 0.5);
	}.play;

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~dklandAnythingCouldHappen;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*Line.kr(0.228,0.23,12);//0.21
		pan = -0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,1), pos, 2 * 20/135, pan, 0.5);
	}.play;

});

t.schedAbs(20*8-4+200, { //...
	x.free;
	y.free;

	Pdef(\snareDead).stop;
	Pdef(\hatFoot).stop;
	Pdef(\ride).stop;
});

t.schedAbs(20*8-3.5+200, { //...

	Pdef(\kick).stop;

});

t.schedAbs(21*8+200, { //we catch falling stars

	Pdef(\ride).stop;

	Pdef(\kick).play(quant: 0.1);
	Pdef(\snareDead).play(quant: 0.1);
	Pdef(\hatFoot).play(quant: 0.1);
	Pdef(\hat).play(quant: 0.1);
	Pdef(\fluteChorus).play(quant: 0.1);

	x.free;
	y.free;

	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~dklandAnythingCouldHappen;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.26;//0.21
		pan = 0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,1), pos, 2 * 20/135, pan, 0.8);
	}.play;

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~dklandAnythingCouldHappen;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.25;//0.21
		pan = -0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,1), pos, 2 * 20/135, pan, 0.8);
	}.play;

});

t.schedAbs(22*8-1.5+200, { //intro
	x.free;
	y.free;
});

t.schedAbs(22*8+200, { //i crash my car

	x.free;
	y.free;

	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~dklandAnythingCouldHappen;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.305;//0.21
		pan = 0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,1), pos, 2 * 20/135, pan, 0.8);
	}.play;

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~dklandAnythingCouldHappen;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.315;//0.21
		pan = -0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,1), pos, 2 * 20/135, pan, 0.8);
	}.play;

});

t.schedAbs(23*8-1.5+200, { //intro
	x.free;
	y.free;
});

t.schedAbs(23*8+200, { //you break my heart

	x.free;
	y.free;

	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~dklandAnythingCouldHappen;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.37;//0.21
		pan = 0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,1), pos, 2 * 20/135, pan, 0.8);
	}.play;

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~dklandAnythingCouldHappen;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.37;//0.21
		pan = -0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,1), pos, 2 * 20/135, pan, 0.8);
	}.play;

});

t.schedAbs(24*8-1.5+200, { //intro
	x.free;
	y.free;
});

t.schedAbs(24*8+200, { //anything could happen

	x.free;
	y.free;

	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~dklandAnythingCouldHappen;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.391;//0.21
		pan = 0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,1), pos, 2 * 20/135, pan, 0.8);
	}.play;

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~dklandAnythingCouldHappen;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.389;//0.21
		pan = -0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,1), pos, 2 * 20/135, pan, 0.8);
	}.play;

});

t.schedAbs(25*8-1.5+200, { //intro
	x.free;
	y.free;
});

t.schedAbs(25*8+200, { //we catch falling stars

	Pdef(\fluteChorus).stop;

	Pdef(\ride).play(quant: 0.1);
	Pdef(\fluteChorus).play(quant: 0.1);

	x.free;
	y.free;

	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~dklandAnythingCouldHappen;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*EnvGen.kr(Env(
			[0,0.26,0.305,0.37,0.391,0.4],
			[8,8,8,8,8,]*(60/135),
			EnvGen.kr(Env([-10,-50],[64,32]*60/135))
		));//0.21
		pan = 0.9;
		pan = 0.9;
		~masterGain*0.8*TGrains.ar(2, clk, buf, SinOsc.kr(4,0,
			EnvGen.kr(Env([0.008,0.008,0,0,0.1,0,1],[63,1,8,8,8,8]*60/135)),
			[1,0.5]), pos, 2 * 20/135, pan, 0.8, [0.1,0.1]);
		//~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,1), pos, 2 * 20/135, pan, 0.4);
	}.play;

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~dklandAnythingCouldHappen;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = pos = BufDur.kr(buf)*EnvGen.kr(Env(
			[0,0.26,0.315,0.37,0.389,0.4],
			[8,8,8,8,8,]*(60/135),
			EnvGen.kr(Env([-10,-50],[64,32]*60/135))
		));//0.21
		pan = -0.9;
		~masterGain*0.8*TGrains.ar(2, clk, buf, SinOsc.kr(7,0,
			EnvGen.kr(Env([0.008,0.008,0,0,0.1,0,1],[63,1,8,8,8,8]*60/135)),
			[0.5,2]), pos, 2 * 20/135, pan, 0.8, [0.1,0.05]);
		//~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,1), pos, 2 * 20/135, pan, 0.4);
	}.play;

});

t.schedAbs(33*8+200, { //out

	Pdef(\snareDead).stop;
	Pdef(\hatFoot).stop;
	Pdef(\ride).stop;
	Pdef(\hat).stop;
	Pdef(\kick).stop;

});

)

