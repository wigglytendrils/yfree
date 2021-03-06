/*
    y.free an album of songs written in SuperCollider

    Copyright (C) 2019 The Wiggly Tendrils

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

s.boot;
s.record;
s.stopRecording;



//variables
(

~step = (60/1) * (1/90) * (1/4);

~bpm=60;
~swing=0.0;

~step = (60/1)*(1/~bpm)*(1/4);
~tick = ~step+(~swing*~step);
~tock = ~step-(~swing*~step);

~lagKick=(-1)*~step/128;
~lagSnare=~step/16;
~lagHat=~step/16;
~lagClap=~step/8;
~lagBass=0;
~lagHook=~step/128;
~masterGain = 0.2;

~scale = Scale.chromatic;

~path = PathName(thisProcess.nowExecutingPath).parentPath; //path for buffers
)



//loading vocal stem buffer

(
~marriedWomanVox = Buffer.readChannel(s,~path++"yfree_buffers_stems/Married Woman (vox).wav",0,-1,1);
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

//synthDefs

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
SynthDef(\marriedWomanVox, {
	arg out = 0, amp=1;
	var sig, env;
	b = ~marriedWomanVox;
	sig = 5*PlayBuf.ar(1, b, 1, doneAction:2)*amp*2*~masterGain;
	Out.ar(out, [sig,sig])
}).play;
)

(
SynthDef.new(\Oliver, {
	arg freq=432, pan=0, atk=0.02, rel=1, harmonics=1, dur=0.2, beats=1, amp=1;
	var sig, env;
	freq = 0.5*2.5764*freq * (440/440);
	sig = Blip.ar(freq,Line.kr(1,harmonics,dur*beats),0.5);
	env = EnvGen.kr(Env.new([0,1,0],[atk,rel],[1,-1]),doneAction:2);
	sig = sig*env*amp*1;
	sig = Pan2.ar(sig,pan);
	Out.ar(0, sig)
	//Out.ar(0, [sig, sig]);
}).play;
)

(
SynthDef.new(\Colleen, {
	arg freq=110, atk=0.35, rel=2, amp=1, dur=2, pan = 0, out = -1;
	var sig, env;
	freq = 1*freq*(320/250)*PinkNoise.kr(0.05,1)*BrownNoise.kr(0.01,1)*2;
	sig = LPF.ar(CombC.ar(Decay.ar(Impulse.ar(0), 0.2, BrownNoise.ar), 4/(BrownNoise.kr(XLine.kr(10,1,0.2),freq)), 4/(PinkNoise.kr(XLine.kr(10,1,0.2),freq)), 3, 0.4),4000);
	env = EnvGen.kr(Env.new([0,1,0],[atk,rel],[1,-1]),doneAction:2);
	sig = sig + PinkNoise.ar(0.1);
	sig = LPF.ar(sig, XLine.kr(100,700,rel*0.1));
	sig = (sig*env*amp)*4;
	sig = Pan2.ar(sig,pan);
	Out.ar(out, sig);
}).play;
)
)


//pdefs
(

Pdef(\marriedWomanVox,
	Pbind(
		\instrument, \marriedWomanVox,
		//\lag, ~lagKick+0.15,
		\amp, ~masterGain*5*Pseq([1],1),
	)
).play;

SynthDef(\marriedWomanVox, {
	arg out = 0, amp=1;
	var sig, env;
	b = ~marriedWomanVox;
	sig = 1.5*PlayBuf.ar(1, b, 1, doneAction:2)*amp*2*~masterGain;
	Out.ar(out, [sig,sig])
}).play;

Pdef(\chords,
	Pbind(
	\instrument, \Oliver,
	\dur, Pseq([~tick,~tock],inf),
	\scale, ~scale,
	\octave, [7,6,5,4,3,2]-1,
	\degree, [0,5,10,15,19,24]+
	Pseq([

		Pseq([[3,2,0,0,0,3]],64),

		Pseq([[3,2,0,0,0,3]],8),
		Pseq([[2,0,0,0,0,3]],8),
		Pseq([[0,2,2,0,0,0]],8),
		Pseq([[0,2,0,0,0,0]],8),
		Pseq([[3,3,2,0,1,3]],8),
		Pseq([[3,2,0,0,0,3]],8),
		Pseq([[0,0,2,2,1,0]],8),
		Pseq([[3,0,2,0,1,0]],8),
		Pseq([[2,0,0,2,3,2]],8),
		Pseq([[2,3,0,2,3,2]],8),
		Pseq([[3,2,0,0,3,3]],8),
		Pseq([[3,3,2,0,1,0]],8),
		Pseq([[3,2,0,0,3,3]],8),
		Pseq([[3,2,0,0,0,3]],8),
		Pseq([[2,0,0,2,3,2]],8),
		Pseq([[2,0,0,2,1,2]],8),

		Pseq([[3,2,0,0,0,3]],8),
		Pseq([[2,0,0,0,0,3]],8),
		Pseq([[0,2,2,0,0,0]],8),
		Pseq([[0,2,0,0,0,0]],8),
		Pseq([[3,3,2,0,1,3]],8),
		Pseq([[3,2,0,0,0,3]],8),
		Pseq([[0,0,2,2,1,0]],8),
		Pseq([[3,0,2,0,1,0]],8),
		Pseq([[2,0,0,2,3,2]],8),
		Pseq([[2,3,0,2,3,2]],8),
		Pseq([[3,2,0,0,3,3]],8),
		Pseq([[3,3,2,0,1,0]],8),
		Pseq([[3,2,0,0,3,3]],8),
		Pseq([[3,2,0,0,0,3]],8),
		Pseq([[2,0,0,2,3,2]],8),
		Pseq([[2,0,0,2,1,2]],8),

		Pseq([[0,2,2,0,0,0]],16),
		Pseq([[3,3,2,0,1,3]],16),
		Pseq([[3,2,0,0,0,3]],16),
		Pseq([[0,0,2,2,1,0]],8),
		Pseq([[3,0,2,0,1,0]],8),
		Pseq([[2,0,0,2,3,2]],8),
		Pseq([[2,3,0,2,3,2]],8),
		Pseq([[3,2,0,0,3,3]],8),
		Pseq([[3,3,2,0,1,0]],8),
		Pseq([[3,2,0,0,3,3]],8),
		Pseq([[3,2,0,0,0,3]],8),
		Pseq([[2,0,0,2,3,2]],8),
		Pseq([[2,0,0,2,1,2]],8),

		Pseq([[3,2,0,0,0,3]],8),
		Pseq([[2,0,0,0,0,3]],8),
		Pseq([[0,2,2,0,0,0]],8),
		Pseq([[0,2,0,0,0,0]],8),
		Pseq([[3,3,2,0,1,3]],8),
		Pseq([[3,2,0,0,0,3]],8),
		Pseq([[0,0,2,2,1,0]],8),
		Pseq([[3,0,2,0,1,0]],8),
		Pseq([[2,0,0,2,3,2]],8),
		Pseq([[2,3,0,2,3,2]],8),
		Pseq([[3,2,0,0,3,3]],8),
		Pseq([[3,3,2,0,1,0]],8),
		Pseq([[3,2,0,0,3,3]],8),
		Pseq([[3,2,0,0,0,3]],8),
		Pseq([[2,0,0,2,3,2]],8),
		Pseq([[2,0,0,2,1,2]],8),

		Pseq([[0,2,2,0,0,0]],16),
		Pseq([[3,3,2,0,1,3]],16),
		Pseq([[3,2,0,0,0,3]],16),
		Pseq([[0,0,2,2,1,0]],8),
		Pseq([[3,0,2,0,1,0]],8),
		Pseq([[2,0,0,2,3,2]],8),
		Pseq([[2,3,0,2,3,2]],8),
		Pseq([[3,2,0,0,3,3]],8),
		Pseq([[3,3,2,0,1,0]],8),
		Pseq([[3,2,0,0,3,3]],8),
		Pseq([[3,2,0,0,0,3]],8),
		Pseq([[2,0,0,2,3,2]],8),
		Pseq([[2,0,0,2,1,2]],8),

		Pseq([[0,2,2,0,0,0]],16),
		Pseq([[3,3,2,0,1,3]],16),
		Pseq([[3,2,0,0,0,3]],16),
		Pseq([[0,0,2,2,1,0]],8),
		Pseq([[3,0,2,0,1,0]],8),
		Pseq([[2,0,0,2,3,2]],8),
		Pseq([[2,3,0,2,3,2]],8),
		Pseq([[3,2,0,0,3,3]],8),
		Pseq([[3,3,2,0,1,0]],8),
		Pseq([[3,2,0,0,3,3]],8),
		Pseq([[3,2,0,0,0,3]],8),
		Pseq([[2,0,0,2,3,2]],8),
		Pseq([[2,0,0,2,1,2]],8),

	],inf),
	\amp, ~masterGain*0.5*Pseq([
		0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
			0,0,0,0, 1,0,0,0,
		],inf),
	//\lag, 2,
	\strum, 1/6,
	\pan, [-1,-0.5,-0.25,0.25,0.5,1],
	)
).play;

Pdef(\bass,
	Pbind(
		\instrument, \Colleen,
		\dur, Pseq([~tick,~tock],inf),
		\lag, 0,
		\scale, ~scale,
		\strum, 0.0,
		\octave, [6,5,4,3,2,1],
		\degree,  [0,5,10,15,19,24]+
	Pseq([

		Pseq([[3,2,0,0,0,3]],64),

		Pseq([[3,2,0,0,0,3]],8),
		Pseq([[2,0,0,0,0,3]],8),
		Pseq([[0,2,2,0,0,0]],8),
		Pseq([[0,2,0,0,0,0]],8),
		Pseq([[3,3,2,0,1,3]],8),
		Pseq([[3,2,0,0,0,3]],8),
		Pseq([[0,0,2,2,1,0]],8),
		Pseq([[3,0,2,0,1,0]],8),
		Pseq([[2,0,0,2,3,2]],8),
		Pseq([[2,3,0,2,3,2]],8),
		Pseq([[3,2,0,0,3,3]],8),
		Pseq([[3,3,2,0,1,0]],8),
		Pseq([[3,2,0,0,3,3]],8),
		Pseq([[3,2,0,0,0,3]],8),
		Pseq([[2,0,0,2,3,2]],8),
		Pseq([[2,0,0,2,1,2]],8),

		Pseq([[3,2,0,0,0,3]],8),
		Pseq([[2,0,0,0,0,3]],8),
		Pseq([[0,2,2,0,0,0]],8),
		Pseq([[0,2,0,0,0,0]],8),
		Pseq([[3,3,2,0,1,3]],8),
		Pseq([[3,2,0,0,0,3]],8),
		Pseq([[0,0,2,2,1,0]],8),
		Pseq([[3,0,2,0,1,0]],8),
		Pseq([[2,0,0,2,3,2]],8),
		Pseq([[2,3,0,2,3,2]],8),
		Pseq([[3,2,0,0,3,3]],8),
		Pseq([[3,3,2,0,1,0]],8),
		Pseq([[3,2,0,0,3,3]],8),
		Pseq([[3,2,0,0,0,3]],8),
		Pseq([[2,0,0,2,3,2]],8),
		Pseq([[2,0,0,2,1,2]],8),

		Pseq([[0,2,2,0,0,0]],16),
		Pseq([[3,3,2,0,1,3]],16),
		Pseq([[3,2,0,0,0,3]],16),
		Pseq([[0,0,2,2,1,0]],8),
		Pseq([[3,0,2,0,1,0]],8),
		Pseq([[2,0,0,2,3,2]],8),
		Pseq([[2,3,0,2,3,2]],8),
		Pseq([[3,2,0,0,3,3]],8),
		Pseq([[3,3,2,0,1,0]],8),
		Pseq([[3,2,0,0,3,3]],8),
		Pseq([[3,2,0,0,0,3]],8),
		Pseq([[2,0,0,2,3,2]],8),
		Pseq([[2,0,0,2,1,2]],8),

		Pseq([[3,2,0,0,0,3]],8),
		Pseq([[2,0,0,0,0,3]],8),
		Pseq([[0,2,2,0,0,0]],8),
		Pseq([[0,2,0,0,0,0]],8),
		Pseq([[3,3,2,0,1,3]],8),
		Pseq([[3,2,0,0,0,3]],8),
		Pseq([[0,0,2,2,1,0]],8),
		Pseq([[3,0,2,0,1,0]],8),
		Pseq([[2,0,0,2,3,2]],8),
		Pseq([[2,3,0,2,3,2]],8),
		Pseq([[3,2,0,0,3,3]],8),
		Pseq([[3,3,2,0,1,0]],8),
		Pseq([[3,2,0,0,3,3]],8),
		Pseq([[3,2,0,0,0,3]],8),
		Pseq([[2,0,0,2,3,2]],8),
		Pseq([[2,0,0,2,1,2]],8),

		Pseq([[0,2,2,0,0,0]],16),
		Pseq([[3,3,2,0,1,3]],16),
		Pseq([[3,2,0,0,0,3]],16),
		Pseq([[0,0,2,2,1,0]],8),
		Pseq([[3,0,2,0,1,0]],8),
		Pseq([[2,0,0,2,3,2]],8),
		Pseq([[2,3,0,2,3,2]],8),
		Pseq([[3,2,0,0,3,3]],8),
		Pseq([[3,3,2,0,1,0]],8),
		Pseq([[3,2,0,0,3,3]],8),
		Pseq([[3,2,0,0,0,3]],8),
		Pseq([[2,0,0,2,3,2]],8),
		Pseq([[2,0,0,2,1,2]],8),

		Pseq([[0,2,2,0,0,0]],16),
		Pseq([[3,3,2,0,1,3]],16),
		Pseq([[3,2,0,0,0,3]],16),
		Pseq([[0,0,2,2,1,0]],8),
		Pseq([[3,0,2,0,1,0]],8),
		Pseq([[2,0,0,2,3,2]],8),
		Pseq([[2,3,0,2,3,2]],8),
		Pseq([[3,2,0,0,3,3]],8),
		Pseq([[3,3,2,0,1,0]],8),
		Pseq([[3,2,0,0,3,3]],8),
		Pseq([[3,2,0,0,0,3]],8),
		Pseq([[2,0,0,2,3,2]],8),
		Pseq([[2,0,0,2,1,2]],8),

	],inf),
		\amp, ~masterGain*0.6*Pseq([
			0,0,1,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
			0,0,1,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
			0,0,1,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
			0,0,1,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
		], inf),
		\pan, [-1,1],
	)
).play;

Pdef(\kick,
	Pbind(
	\instrument, \bufPlay,
	\bufnum, Prand(d[\kickLoud],inf),
	\dur, 1/6,//Pseq([~tick,~tock],inf),
	\amp, ~masterGain*15*
	Pseq([
		1,0,0,0,0,0, 0,0,0,0,0,0,
			0,0,0,Prand([0,0.1,],2),1, 0,0,0,0,0,0,
	],inf),
	\rate, 0.9,
	)
).play;

Pdef(\snare,
	Pbind(
	\instrument, \bufPlay,
	\bufnum, Prand(d[\snareDead],inf),
	\dur, 1/6,
	\amp, ~masterGain * 8 * Pseq([
		0,0,0,0,0,0, 1,0,0,0,0,0,
		0,0,0,0,0,0, 1,0,0,0,0,0,
	], inf),
	\rate, 1.1,
	)
).play;

Pdef(\hatClosed,
	Pbind(
	\instrument, \bufPlay,
	\bufnum, Prand(d[\hatClosed],inf),
	\dur, 1/6,
	\amp, ~masterGain * 15 * Pseq([
		1,1,1, 1, 1,0, 1,0,
	], inf)*Pseq([0.5,1],inf)*Pseq([
		0,1,1, 1,1,1, 0,1,1, 1,1,1,
			1,1,1, 0,0,0, 0,1,1, 1,1,1,
	], inf),
	\pan, 0.8,
	\rate, 1.1,
	)
).play;

Pdef(\ride,
	Pbind(
	\instrument, \bufPlay,
		\bufnum, Prand(d[\ride],inf),
		\dur, 1/6,
	\amp, ~masterGain * 15 * Pseq([
		1,1,1, 1,0,1, 0,1,0,
	], inf)*Pseq([0.5,1],inf)*Pseq([
		0,1,1, 1,1,1, 0,1,1, 1,1,1,
			1,1,1, 0,0,0, 0,1,1, 1,1,1,
	], inf),/*Pseq([
		1,1,1,1,1,1, 0,1,1,1, 1,1,1,1,1,1,
	], inf),*/
	\pan, -0.8,
	\rate, 1.1,
	)
).play;

Pdef(\rideBell,
	Pbind(
	\instrument, \bufPlay,
		\bufnum, Prand(d[\rideBell],inf),
	\dur, 1/6,
	\amp, ~masterGain * 15 * Pseq([
		1,1,1,1, 1,0, 1,0,
	], inf)*Pseq([0.5,1],inf)*Pseq([
		0,1,1,1,1,1, 0,1,1,1,1,1,
			1,1,1,0,0,0, 0,1,1,1,1,1,
		], inf),
	\pan, -0.8,
	\rate, 1.1,
	)
).play;

Pdef(\crash,
	Pbind(
	\instrument, \bufPlay,
		\bufnum, Prand(d[\crash],inf),
	\dur, 1/6,
	\amp, ~masterGain * 15 * Pseq([
		1,1,1,1, 1,0, 1,0,
	], inf)*Pseq([0.5,1],inf)*Pseq([
		1,1,1,1,1,1, 0,1,1,1, 1,1,1,1,1,1,
		], inf)*Pwrand([0,1],[0.6,0.4],inf),
	\pan, 0.5,
	\rate, 1.1,
	)
).play;

Pdef(\hatFoot,
	Pbind(
	\instrument, \bufPlay,
	\bufnum, Prand(d[\hatFoot],inf),
	\dur, Pseq([~tick,~tock],inf),
	\amp, ~masterGain * 50 * Pseq([
		0,0,0,0, 0,0,0,0,
			0,0,0,0, 0,0,1,0,
	], inf)*Pseq([0.5,1],inf),
	\pan, 0.8,
	\rate, 1.1,
	)
).play;
)

//tempo clock

(
v = Main.elapsedTime.ceil;
t = TempoClock(~bpm/60, 0, v);

t.schedAbs(0, { //intro

	Pdef(\marriedWomanVox).play(quant: 0.1);

	Pdef(\chords).play(quant: 0.1);
	Pdef(\bass).play(quant: 0.1);
	Pdef(\kick).play(quant: 0.1);
	Pdef(\snare).play(quant: 0.1);
	//Pdef(\rideBell).play(quant: 0.1);
	Pdef(\ride).play(quant: 0.1);
/*
	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~marriedWomanVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.21;//0.21
		pan = 0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,(-1)), pos, 2 * 120/60, pan, 0.8);
	}.play;

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~marriedWomanVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.208;//0.21
		pan = -0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,(-1)), pos, 2 * 120/60, pan, 0.8);
	}.play;
*/

});

t.schedAbs(2*8, { //verse1

	Pdef(\ride).stop;

	Pdef(\hatFoot).play(quant: 0.1);

/*
	x.free;
	y.free;
*/

});

t.schedAbs(4*8, { //verse1

	x.free;
	y.free;

});

t.schedAbs(6*8-1, { //verse2 pick-up

	Pdef(\ride).stop;
	Pdef(\hatFoot).stop;

});

t.schedAbs(6*8, { //verse2

	Pdef(\hatFoot).play(quant: 0.1);
	//Pdef(\ride).play(quant: 1);
	Pdef(\rideBell).stop;

	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~marriedWomanVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.43;//0.21
		pan = 0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,(-1.5)), pos, 2 * 120/60, pan, 0.3);
	}.play;

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~marriedWomanVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.43;//0.21
		pan = -0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,(-1.5)), pos, 2 * 120/60, pan, 0.3);
	}.play;

});

t.schedAbs(8*8, { //verse2

	x.free;
	y.free;
	Pdef(\hatFoot).stop;

});

t.schedAbs(10*8-2, { //chorus pick-up
	//Pdef(\ride).stop;
	Pdef(\kick).stop;
	Pdef(\snare).stop;
	//Pdef(\chords).stop;
});

t.schedAbs(10*8, { //chorus

	Pdef(\kick).play(quant: 0.1);
	Pdef(\snare).play(quant: 0.1);
	Pdef(\hatClosed).play(quant: 0.1);

	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~marriedWomanVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.43;//0.21,0.41/-1.5 or 3,
		pan = -0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,(1.5)), pos, 2 * 120/60, pan, 0.35);
	}.play;

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~marriedWomanVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.43;//0.21,0.41/-1.5 or 3,
		pan = 0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,(1.5)), pos, 2 * 120/60, pan, 0.35);
	}.play;

});

t.schedAbs(12*8, { //chorus 2nd half

	x.free;
	y.free;

	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~marriedWomanVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.21;//0.21
		pan = 0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,(1)), pos, 2 * 120/60, pan, 0.8);
	}.play;

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~marriedWomanVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.208;//0.21
		pan = -0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,(1)), pos, 2 * 120/60, pan, 0.8);
	}.play;

});

t.schedAbs(12*8+4, {
	x.free;
	y.free;
});

t.schedAbs(13*8, { //chorus 3rd quarter

	Pdef(\crash).play(quant: 0.1);

	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~marriedWomanVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.43;//0.21,0.41/-1.5 or 3,
		pan = -0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,(-1.5)), pos, 2 * 120/60, pan, 0.35);
	}.play;

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~marriedWomanVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.43;//0.21,0.41/-1.5 or 3,
		pan = 0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,(-1.5)), pos, 2 * 120/60, pan, 0.35);
	}.play;

});

t.schedAbs(14*8, { //verse3

	Pdef(\hatClosed).stop;
	Pdef(\crash).stop;
	Pdef(\ride).play(quant: 0.1);

	x.free;
	y.free;

	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~marriedWomanVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.21;//0.21
		pan = 0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,(-1)), pos, 2 * 120/60, pan, 0.8);
	}.play;

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~marriedWomanVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.208;//0.21
		pan = -0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,(1)), pos, 2 * 120/60, pan, 0.8);
	}.play;

});

t.schedAbs(15*8, { //verse3

	x.free;
	y.free;

});

t.schedAbs(16*8, { //verse3

	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~marriedWomanVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.21;//0.21
		pan = 0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,(-1)), pos, 2 * 120/60, pan, 0.8);
	}.play;

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~marriedWomanVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.208;//0.21
		pan = -0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,(1)), pos, 2 * 120/60, pan, 0.8);
	}.play;

});

t.schedAbs(17*8, { //verse3

	x.free;
	y.free;

});

t.schedAbs(10*8-2+64, { //chorus2 pick-up

	Pdef(\crash).stop;
	Pdef(\kick).stop;
	Pdef(\snare).stop;
	//Pdef(\chords).stop;
});

t.schedAbs(10*8+64, { //chorus2

	Pdef(\kick).play(quant: 0.1);
	Pdef(\snare).play(quant: 0.1);
	Pdef(\hatClosed).play(quant: 0.1);

	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~marriedWomanVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.43;//0.21,0.41/-1.5 or 3,
		pan = -0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,(1.5)), pos, 2 * 120/60, pan, 0.35);
	}.play;

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~marriedWomanVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.43;//0.21,0.41/-1.5 or 3,
		pan = 0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,(1.5)), pos, 2 * 120/60, pan, 0.35);
	}.play;

});

t.schedAbs(12*8+64, { //chorus2 2nd half

	x.free;
	y.free;

	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~marriedWomanVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.21;//0.21
		pan = 0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,(1)), pos, 2 * 120/60, pan, 0.8);
	}.play;

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~marriedWomanVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.208;//0.21
		pan = -0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,(1)), pos, 2 * 120/60, pan, 0.8);
	}.play;

});

t.schedAbs(12*8+4+64, {
	x.free;
	y.free;
});

t.schedAbs(13*8+64, { //chorus2 3rd quarter

	Pdef(\crash).play(quant: 0.1);

	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~marriedWomanVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.43;//0.21,0.41/-1.5 or 3,
		pan = -0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,(-1.5)), pos, 2 * 120/60, pan, 0.35);
	}.play;

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~marriedWomanVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.43;//0.21,0.41/-1.5 or 3,
		pan = 0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,(-1.5)), pos, 2 * 120/60, pan, 0.35);
	}.play;

});

t.schedAbs(14*8+64, { //outro

	Pdef(\hatClosed).stop;
	Pdef(\crash).stop;
	Pdef(\ride).play(quant: 0.1);

	x.free;
	y.free;

	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~marriedWomanVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.21;//0.21
		pan = 0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,(-1)), pos, 2 * 120/60, pan, 0.8);
	}.play;

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~marriedWomanVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.208;//0.21
		pan = -0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,(1)), pos, 2 * 120/60, pan, 0.8);
	}.play;


});

)
