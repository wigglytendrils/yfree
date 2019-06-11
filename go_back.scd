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

//variables

(
~masterGain = 0.1;
~path = PathName(thisProcess.nowExecutingPath).parentPath; //path for buffers
)

//read buffers

(
~vox = Buffer.readChannel(s, ~path++"/yfree_buffers_stems/YFREE go back (vox).wav",0,-1,0);
~guitar = Buffer.readChannel(s, ~path++"/yfree_buffers_stems/YFREE go back (guitar).wav",0,-1,0);
)

//test buffers

~vox.play;
~guitar.play;

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

//pdefs

(
Pdef(\vox,
	Pbind(
	\instrument, \bufPlay,
	\bufnum, ~vox,
	\amp, 1.2*Pseq([1],1),
	)
).play;
)

(
Pdef(\guitar,
	Pbind(
	\instrument, \bufPlay,
	\bufnum, ~guitar,
	\amp, 3*Pseq([1],1),
	)
).play;
)

//testing sounds

(
	y = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~vox;
	    rate = [PinkNoise.kr(0.05,(-1)),PinkNoise.kr(0.05,(-1))];
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
	pos = BufDur.kr(buf)*0.66;//0.032 [if],0.05,0.08,0.108,0.11,0.114[clue],0.17,0.19,0.20,0.22,0.35,0.36,0.38,0.39,0.41,0.46,0.47,0.52,0.53,0.58,0.59,0.63[go],0.64,0.66,0.75[go],0.78,0.82[go],
		pan = 0.9;
	0.2*TGrains.ar(2, clk, buf, rate, pos, 0.333 * 120/115, pan, 0.05);
	}.play;
)

(
{
var trate, dur, clk, pos, pan, env;
    trate = Line.kr(1,4e2,3e1);
    dur = 8/trate;
    clk = Impulse.kr(trate);
    pos = BufDur.kr(~guitar)*0.01;
	pan = WhiteNoise.kr(0.8);
	EnvGen.kr(Env.new([0,0.8,1,0],[1,25,5],[1,-1]),doneAction:2)*Mix({|i|i=i+1;SinOsc.ar(0.1*(i+1),0,0.5**(i+1),0.5**(i+1))*TGrains.ar(2,clk, ~guitar,PinkNoise.kr(1e-4*(10**(i+1)),0.5*(-2**(i))),pos,PinkNoise.kr(1,2),pan,0.1)}!5);
}.scope(2,zoom:4);
)

(
{Mix.ar({|i|i=i+1;TGrains.ar(2,Impulse.ar(Line.kr(10,0,26)),~guitar,BrownNoise.kr(Line.kr(0.2,0,3),0.25)*(3**i),EnvGen.kr(Env.new([0,BufDur.kr(~guitar),0],[15,15],[1,-1])),PinkNoise.kr(9,10),0,PinkNoise.kr(0.2,0.2)**i)}!3)*EnvGen.kr(Env.new([0,0.4,0.5,0],[4,28,5]),doneAction: 2)}.scope;
)

(
{Mix.ar(TGrains.ar(2,Impulse.ar(EnvGen.kr(Env.new([0,20,0],[15,15],[1,-1]))),~guitar,[SinOsc.kr(0.2,0,2e-3,1),SinOsc.kr(2,0,2e-3,1)],EnvGen.kr(Env.new([BufDur.kr(~guitar),0,BufDur.kr(~guitar)],[15,15],[1,-1])),PinkNoise.kr(1,2),0,0.1,2)*EnvGen.kr(Env.new([0,0.8,1,0],[1,28,1],[1,-1]),doneAction:2))}.scope;
)




//tempoclock

(
v = Main.elapsedTime.ceil;
t = TempoClock(1, 0, v);

t.schedAbs(0, { //counting

(
Routine {arg z=122; var t=0;
	z.do({
	1.wait;
    t.postln;
	t = t+1;
	})
}.play;
)
	});

t.schedAbs(0, { //intro


x = {Mix.ar({|i|i=i+1;TGrains.ar(2,Impulse.ar(Line.kr(10,0,26)),~guitar,BrownNoise.kr(Line.kr(0.2,0,3),0.25)*(3**i),EnvGen.kr(Env.new([0,BufDur.kr(~guitar),0],[15,15],[1,-1])),PinkNoise.kr(9,10),0,PinkNoise.kr(0.2,0.2)**i)}!3)*EnvGen.kr(Env.new([0,0.4,0.5,0],[4,28,5]),doneAction: 2)}.play;

y = {Mix.ar({|i|i=i+1;TGrains.ar(2,Impulse.ar(Line.kr(10,0,26)),~guitar,BrownNoise.kr(Line.kr(0.2,0,3),0.25)*(3**i),EnvGen.kr(Env.new([0,BufDur.kr(~guitar),0],[15,15],[1,-1])),PinkNoise.kr(9,10),0,PinkNoise.kr(0.2,0.2)**i)}!3)*EnvGen.kr(Env.new([0,0.4,0.5,0],[4,28,5]),doneAction: 2)}.play;

	/*
y = {Mix.ar(TGrains.ar(2,Impulse.ar(EnvGen.kr(Env.new([0,20,0],[15,15],[1,-1]))),~guitar,[SinOsc.kr(0.2,0,2e-3,1),SinOsc.kr(2,0,2e-3,1)],EnvGen.kr(Env.new([BufDur.kr(~guitar),0,BufDur.kr(~guitar)],[15,15],[1,-1])),PinkNoise.kr(1,2),0,0.1,2)*EnvGen.kr(Env.new([0,0.8,1,0],[1,28,1],[1,-1]),doneAction:2))}.play;
	*/


});



t.schedAbs(10, { //intro
Pdef(\vox).play(quant: 0.1);
//Pdef(\guitar).play(quant: 0.1);
});

t.schedAbs(12.5, { //intro

	x.free;
	y.free;

	x={var trate, dur, clk, pos, pan, env, amp;
		trate =PinkNoise.kr(2,200);
		dur = 0.1;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(~vox)*EnvGen.kr(Env.new([0.5,0.5,0.025],[4,0.1],[1,-1]));
		pan = 0;
		amp = 0.1*EnvGen.kr(Env.new([1,1,0.4,0.1],[4,0.1,3.9],[1,-1]));

		[0.1,0.1]*TGrains.ar(2, clk, ~vox, [-1,1], BrownNoise.kr(2,pos), 0.1, pan, amp);

	}.play;

	y = {var buf, rate, trate, dur, clk, pos, pan, env;

		buf = ~guitar;
		rate = PinkNoise.kr(0.05,(-1));
		trate =PinkNoise.kr(2,XLine.kr(60,5,10));
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.032;//0.05,0.08,0.11
		pan = -1;

		[2,6]*TGrains.ar(2, clk, buf, rate, pos, [0.8,0.01] * 120/115, pan, 0.05);

	}.play;

	y.free;
	x.free;

});

t.schedAbs(14.8, { //else would
y.free;

x = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~vox;
	    rate = [PinkNoise.kr(0.05,(-0.5)),BrownNoise.kr(0.01,(-0.75))];
		trate =PinkNoise.kr(2,Line.kr(2,80,0.75));
		dur = 10;
		clk = Impulse.kr(trate);
		pos = [BufDur.kr(buf)*0.049,BufDur.kr(buf)*0.050];//0.05,0.08,0.11
		pan = 0;
		0.4*TGrains.ar(2, clk, buf, rate, pos, [0.2,0.6] * 120/115, pan, 0.05);
	}.play;

y = {//granular synth
		var buf, rate, trate, dur
		, clk, pos, pan, env;
		buf = ~guitar;
	    rate = [PinkNoise.kr(0.05,(-2)),PinkNoise.kr(0.05,(4))];
		trate =PinkNoise.kr(2,Line.kr(40,2,0.75));
		dur = 10;
		clk = Impulse.kr(trate);
		pos = [BufDur.kr(buf)*0.049,BufDur.kr(buf)*0.048];//0.05,0.08,0.11
		pan = 0;
	1*TGrains.ar(2, clk, buf, rate, pos,[0.2,0.6] * 120/115, pan, 0.05);
	}.play;


});

t.schedAbs(16.4, { //know, no one else had a

x.free;
y.free;

x = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~vox;
	    rate = [PinkNoise.kr(0.05,(-1)),PinkNoise.kr(0.05,(1))];
		trate =PinkNoise.kr(2,XLine.kr(2,120,4));
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.064;//0.05,0.08,0.11
		pan = 0;
		0.3*TGrains.ar(2, clk, buf, rate, pos, [0.03,0.05] * 120/115, pan, 0.05);
	}.play;

y = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~guitar;
	    rate = [PinkNoise.kr(0.05,(-1)),PinkNoise.kr(0.05,(-1))];
		trate =PinkNoise.kr(2,XLine.kr(120,2,4));
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.064;//0.05,0.08,0.11
		pan = 0;
	4*TGrains.ar(2, clk, buf, rate, pos, [0.2,0.25] * 120/115, pan, 0.05);
	}.play;


});

t.schedAbs(21, { //clue
x.free;
y.free;

x = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~vox;
	    rate = [PinkNoise.kr(0.05,(-1)),PinkNoise.kr(0.05,(1))];
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.114;//0.05,0.08,0.11
		pan = 0;
		0.9*TGrains.ar(2, clk, buf, rate, pos, [0.06,0.06] * 120/115, pan, 0.05);
	}.play;

y = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~guitar;
	    rate = [PinkNoise.kr(0.05,(-1)),PinkNoise.kr(0.05,(-1))];
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.114;//0.05,0.08,0.11
		pan = 0;
	0.8*TGrains.ar(2, clk, buf, rate, pos, 0.333 * 120/115, pan, 0.05);
	}.play;


});


t.schedAbs(24.3, { //if no one
x.free;
y.free;

x = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~vox;
	    rate = [PinkNoise.kr(0.05,(-1)),PinkNoise.kr(0.05,(1))];
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*Line.kr(0.033,0.035,1);//0.05,0.08,0.11
		pan = 0;
		0.2*TGrains.ar(2, clk, buf, rate, pos, [0.01,0.06] * 120/115, pan, 0.05);
	}.play;

y = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~guitar;
	    rate = [PinkNoise.kr(0.05,(-1)),PinkNoise.kr(0.05,(-1))];
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.032;//0.05,0.08,0.11
		pan = 0;
	0.8*TGrains.ar(2, clk, buf, rate, pos, 0.4 * 120/115, pan, 0.05);
	}.play;

});

t.schedAbs(27.5, { //else would
	x.free;
	y.free;

	x = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~vox;
		rate = [PinkNoise.kr(0.05,(-0.5)),PinkNoise.kr(0.05,(0.75))];
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.049;//0.05,0.08,0.11
		pan = 0;
		0.1*TGrains.ar(2, clk, buf, rate, pos, XLine.kr(0,0.4,0.2) * 120/115, pan, 0.05);
	}.play;

	y = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~guitar;
	    rate = [PinkNoise.kr(0.05,(-1)),PinkNoise.kr(0.05,(2))];
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.049;//0.05,0.08,0.11
		pan = 0;
	0.4*TGrains.ar(2, clk, buf, rate, pos, 0.4 * 120/115, pan, 0.05);
	}.play;

});

t.schedAbs(29, { //know, tell me what would you

x.free;
y.free;

x = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~vox;
	    rate = [PinkNoise.kr(0.05,(-1)),PinkNoise.kr(0.05,(1))];
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.064;//0.05,0.08,0.11
		pan = 0;
		0.2*TGrains.ar(2, clk, buf, rate, pos, [0.2,0.6] * 120/115, pan, 0.05);
	}.play;

y = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~guitar;
	    rate = [PinkNoise.kr(0.05,(-1)),PinkNoise.kr(0.05,(1))];
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.064;//0.05,0.08,0.11
		pan = 0;
	0.8*TGrains.ar(2, clk, buf, rate, pos, [0.42,0.6] * 120/115, pan, 0.05);
	}.play;


});

t.schedAbs(34, { //do, with the
x.free;
y.free;

x = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~vox;
	    rate = [PinkNoise.kr(0.05,(-1)),PinkNoise.kr(0.05,(1))];
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.114;//0.05,0.08,0.11
		pan = 0;
		0.2*TGrains.ar(2, clk, buf, rate, pos, [0.06,0.06] * 120/115, pan, 0.05);
	}.play;

y = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~guitar;
	    rate = [PinkNoise.kr(0.05,(-1)),PinkNoise.kr(0.05,(1))];
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.114;//0.05,0.08,0.11
		pan = 0;
	0.8*TGrains.ar(2, clk, buf, rate, pos, 0.333 * 120/115, pan, 0.05);
	}.play;


});

t.schedAbs(36.1, { //...
x.free;
y.free;

x = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~vox;
	    rate = [PinkNoise.kr(0.05,(-1)),PinkNoise.kr(0.05,(1))];
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.064;//0.05,0.08,0.11
		pan = 0;
		0.2*TGrains.ar(2, clk, buf, rate, pos, [0.2,0.6] * 120/115, pan, 0.05);
	}.play;

y = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~guitar;
	    rate = [PinkNoise.kr(0.05,(-1)),PinkNoise.kr(0.05,(1))];
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.064;//0.05,0.08,0.11
		pan = 0;
	0.8*TGrains.ar(2, clk, buf, rate, pos, [0.42,0.6] * 120/115, pan, 0.05);
	}.play;



});

t.schedAbs(37, { //with the
x.free;
y.free;

x={
    var trate, dur, clk, pos, pan, env, amp;
	trate =PinkNoise.kr(2,200);
    dur = 0.1;
    clk = Impulse.kr(trate);
	pos = BufDur.kr(~guitar)*0.26;
    pan = 0;
	amp = 0.5*EnvGen.kr(Env.new([1,1,0.8,0.5],[4,0.1,3.9],[1,-1]));
		[0.1,0.1]*TGrains.ar(2, clk, ~guitar, [-1,1], BrownNoise.kr(2,pos), 0.1, pan, amp);
}.play;

y = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~guitar;
	    rate = PinkNoise.kr(0.05,(-1));
		trate =PinkNoise.kr(2,XLine.kr(30,295,1));
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.26;//0.05,0.08,0.11
		pan = -1;
		[3,4]*TGrains.ar(2, clk, buf, rate, pos, [0.8,0.01] * 120/115, pan, 0.05);
	}.play;

});

t.schedAbs(40, { //truth
x.free;
y.free;

x={
    var trate, dur, clk, pos, pan, env, amp;
	trate =PinkNoise.kr(2,200);
    dur = 0.1;
    clk = Impulse.kr(trate);
	pos = BufDur.kr(~guitar)*0.32;
    pan = 0;
	amp = 0.5*EnvGen.kr(Env.new([1,1,0.8,0.5],[4,0.1,3.9],[1,-1]));
		[Line.kr(0.02,0.1,1),Line.kr(0.02,0.1,1)]*TGrains.ar(2, clk, ~guitar, [-1,1], BrownNoise.kr(2,pos), 0.2, pan, amp);
}.play;

y = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~guitar;
	    rate = PinkNoise.kr(0.05,(-1));
		trate =10;
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.31;//0.05,0.08,0.11
		pan = -1;
		[Line.kr(1,6,1),Line.kr(20,2,1)]*TGrains.ar(2, clk, buf, rate, pos, [0.8,0.01] * 120/115, pan, 0.05);
	}.play;

});

t.schedAbs(43, { //you got it
x.free;
y.free;

x={
    var trate, dur, clk, pos, pan, env, amp;
	trate =PinkNoise.kr(2,200);
    dur = 0.1;
    clk = Impulse.kr(trate);
	pos = BufDur.kr(~vox)*EnvGen.kr(Env.new([0.5,0.5,0.025],[4,0.1],[1,-1]));
    pan = 0;
	amp = 0.1*EnvGen.kr(Env.new([1,1,0.8,0.5],[4,0.1,3.9],[1,-1]));
		[0.1,0.1]*TGrains.ar(2, clk, ~vox, [-1,1], BrownNoise.kr(2,pos), 0.1, pan, amp);
}.play;

y = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~guitar;
	    rate = PinkNoise.kr(0.05,(-1));
		trate =PinkNoise.kr(2,XLine.kr(60,5,10));
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.032;//0.05,0.08,0.11
		pan = -1;
		[2,6]*TGrains.ar(2, clk, buf, rate, pos, [0.8,0.01] * 120/115, pan, 0.05);
	}.play;

});

t.schedAbs(46, { //locked
x.free;
y.free;

x = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~vox;
	    rate = [PinkNoise.kr(0.05,(-0.5)),BrownNoise.kr(0.01,(-0.75))];
		trate =PinkNoise.kr(2,Line.kr(2,80,0.75));
		dur = 10;
		clk = Impulse.kr(trate);
		pos = [BufDur.kr(buf)*0.049,BufDur.kr(buf)*0.050];//0.05,0.08,0.11
		pan = 0;
		0.4*TGrains.ar(2, clk, buf, rate, pos, [0.2,0.6] * 120/115, pan, 0.05);
	}.play;

y = {//granular synth
		var buf, rate, trate, dur
		, clk, pos, pan, env;
		buf = ~guitar;
	    rate = [PinkNoise.kr(0.05,(-2)),PinkNoise.kr(0.05,(4))];
		trate =PinkNoise.kr(2,Line.kr(40,2,0.75));
		dur = 10;
		clk = Impulse.kr(trate);
		pos = [BufDur.kr(buf)*0.049,BufDur.kr(buf)*0.048];//0.05,0.08,0.11
		pan = 0;
	1*TGrains.ar(2, clk, buf, rate, pos,[0.2,0.6] * 120/115, pan, 0.05);
	}.play;

});

t.schedAbs(47.5, { //away, you got it

	x.free;
	y.free;

	x = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~vox;
	    rate = [PinkNoise.kr(0.05,(-1)),PinkNoise.kr(0.05,(1))];
		trate =PinkNoise.kr(2,XLine.kr(2,120,4));
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.064;//0.05,0.08,0.11
		pan = 0;
		0.3*TGrains.ar(2, clk, buf, rate, pos, [0.03,0.05] * 120/115, pan, 0.05);
	}.play;

	y = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~guitar;
	    rate = [PinkNoise.kr(0.05,(-1)),PinkNoise.kr(0.05,(-1))];
		trate =PinkNoise.kr(2,XLine.kr(120,2,4));
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.064;//0.05,0.08,0.11
		pan = 0;
	4*TGrains.ar(2, clk, buf, rate, pos, [0.2,0.25] * 120/115, pan, 0.05);
	}.play;

});

t.schedAbs(53, { //sanitized

	x.free;
	y.free;

	x = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~vox;
	    rate = [PinkNoise.kr(0.05,(-1)),PinkNoise.kr(0.05,(1))];
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.114;//0.05,0.08,0.11
		pan = 0;
		0.9*TGrains.ar(2, clk, buf, rate, pos, [0.06,0.06] * 120/115, pan, 0.05);
	}.play;

y = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~guitar;
	    rate = [PinkNoise.kr(0.05,(-1)),PinkNoise.kr(0.05,(-1))];
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.114;//0.05,0.08,0.11
		pan = 0;
	0.8*TGrains.ar(2, clk, buf, rate, pos, 0.333 * 120/115, pan, 0.05);
	}.play;

});

t.schedAbs(56, { //you won't

	x.free;
	y.free;

	x={
		var trate, dur, clk, pos, pan, env, amp;
		trate =PinkNoise.kr(2,200);
		dur = 0.1;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(~vox)*EnvGen.kr(Env.new([0.5,0.5,0.025],[4,0.1],[1,-1]));
		pan = 0;
		amp = 0.1*EnvGen.kr(Env.new([1,1,0.4,0.1],[4,0.1,3.9],[1,-1]));
		[0.1,0.1]*TGrains.ar(2, clk, ~vox, [-1,1], BrownNoise.kr(2,pos), 0.1, pan, amp);
}.play;

	y = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~guitar;
	    rate = PinkNoise.kr(0.05,(-1));
		trate =PinkNoise.kr(2,XLine.kr(60,5,10));
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.032;//0.05,0.08,0.11
		pan = -1;
		[2,6]*TGrains.ar(2, clk, buf, rate, pos, [0.8,0.01] * 120/115, pan, 0.05);
	}.play;

});

t.schedAbs(59, { //admit

	x.free;
	y.free;

	x = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~vox;
	    rate = [PinkNoise.kr(0.05,(-0.5)),BrownNoise.kr(0.01,(-0.75))];
		trate =PinkNoise.kr(2,Line.kr(2,80,0.75));
		dur = 10;
		clk = Impulse.kr(trate);
		pos = [BufDur.kr(buf)*0.049,BufDur.kr(buf)*0.050];//0.05,0.08,0.11
		pan = 0;
		0.4*TGrains.ar(2, clk, buf, rate, pos, [0.2,0.6] * 120/115, pan, 0.05);
	}.play;

y = {//granular synth
		var buf, rate, trate, dur
		, clk, pos, pan, env;
		buf = ~guitar;
	    rate = [PinkNoise.kr(0.05,(-2)),PinkNoise.kr(0.05,(4))];
		trate =PinkNoise.kr(2,Line.kr(40,2,0.75));
		dur = 10;
		clk = Impulse.kr(trate);
		pos = [BufDur.kr(buf)*0.049,BufDur.kr(buf)*0.048];//0.05,0.08,0.11
		pan = 0;
	1*TGrains.ar(2, clk, buf, rate, pos,[0.2,0.6] * 120/115, pan, 0.05);
	}.play;


});

t.schedAbs(60.5, { //mistakes, it's all rationalized

	x.free;
	y.free;

	x = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~vox;
	    rate = [PinkNoise.kr(0.05,(-1)),PinkNoise.kr(0.05,(1))];
		trate =PinkNoise.kr(2,XLine.kr(2,120,4));
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.064;//0.05,0.08,0.11
		pan = 0;
		0.3*TGrains.ar(2, clk, buf, rate, pos, [0.03,0.05] * 120/115, pan, 0.05);
	}.play;

	y = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~guitar;
	    rate = [PinkNoise.kr(0.05,(-1)),PinkNoise.kr(0.05,(-1))];
		trate =PinkNoise.kr(2,XLine.kr(120,2,4));
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.064;//0.05,0.08,0.11
		pan = 0;
	4*TGrains.ar(2, clk, buf, rate, pos, [0.2,0.25] * 120/115, pan, 0.05);
	}.play;

});

t.schedAbs(65, { //rationalized

	x.free;
	y.free;

	x = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~vox;
	    rate = [PinkNoise.kr(0.05,(-1)),PinkNoise.kr(0.05,(1))];
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.114;//0.05,0.08,0.11
		pan = 0;
		0.9*TGrains.ar(2, clk, buf, rate, pos, [0.06,0.06] * 120/115, pan, 0.05);
	}.play;

	y = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~guitar;
	    rate = [PinkNoise.kr(0.05,(-1)),PinkNoise.kr(0.05,(-1))];
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.114;//0.05,0.08,0.11
		pan = 0;
	0.8*TGrains.ar(2, clk, buf, rate, pos, 0.333 * 120/115, pan, 0.05);
	}.play;

});


t.schedAbs(66.5, { //...

	x.free;
	y.free;

x = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~vox;
	    rate = [PinkNoise.kr(0.05,(-1)),PinkNoise.kr(0.05,(1))];
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.064;//0.05,0.08,0.11
		pan = 0;
		0.2*TGrains.ar(2, clk, buf, rate, pos, [0.2,0.6] * 120/115, pan, 0.05);
	}.play;

y = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~guitar;
	    rate = [PinkNoise.kr(0.05,(-1)),PinkNoise.kr(0.05,(1))];
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.064;//0.05,0.08,0.11
		pan = 0;
	0.8*TGrains.ar(2, clk, buf, rate, pos, [0.42,0.6] * 120/115, pan, 0.05);
	}.play;

});

t.schedAbs(67, { //there in your

	x.free;
	y.free;

x={
    var trate, dur, clk, pos, pan, env, amp;
	trate =PinkNoise.kr(2,200);
    dur = 0.1;
    clk = Impulse.kr(trate);
	pos = BufDur.kr(~guitar)*0.26;
    pan = 0;
	amp = 0.5*EnvGen.kr(Env.new([1,1,0.8,0.5],[4,0.1,3.9],[1,-1]));
		[0.1,0.1]*TGrains.ar(2, clk, ~guitar, [-1,1], BrownNoise.kr(2,pos), 0.1, pan, amp);
}.play;

y = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~guitar;
	    rate = PinkNoise.kr(0.05,(-1));
		trate =PinkNoise.kr(2,XLine.kr(30,295,1));
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.26;//0.05,0.08,0.11
		pan = -1;
		[3,4]*TGrains.ar(2, clk, buf, rate, pos, [0.8,0.01] * 120/115, pan, 0.05);
	}.play;

});

t.schedAbs(71, { //eyes
x.free;
y.free;

	x={
		var trate, dur, clk, pos, pan, env, amp;
		trate =PinkNoise.kr(2,200);
		dur = 0.1;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(~guitar)*0.32;
		pan = 0;
		amp = 0.5*EnvGen.kr(Env.new([1,1,0.8,0.5],[4,0.1,3.9],[1,-1]));
		[Line.kr(0.02,0.1,1),Line.kr(0.02,0.1,1)]*TGrains.ar(2, clk, ~guitar, [-1,1], BrownNoise.kr(2,pos), 0.2, pan, amp);
	}.play;

y = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~guitar;
	    rate = PinkNoise.kr(0.05,(-1));
		trate =10;
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.31;//0.05,0.08,0.11
		pan = -1;
		[Line.kr(1,6,1),Line.kr(20,2,1)]*TGrains.ar(2, clk, buf, rate, pos, [0.8,0.01] * 120/115, pan, 0.05);
	}.play;

});


//74 go

t.schedAbs(74.5, { //go
x.free;
y.free;

	y = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~vox;
	    rate = [PinkNoise.kr(0.05,(-1)),PinkNoise.kr(0.05,(-1))];
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
	pos = BufDur.kr(buf)*0.63;
		pan = 0.9;
	0.2*TGrains.ar(2, clk, buf, rate, pos, 0.333 * 120/115, pan, 0.05);
	}.play;

	x = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~vox;
	    rate = [PinkNoise.kr(0.05,(-1)),PinkNoise.kr(0.05,(-1))];
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
	pos = BufDur.kr(buf)*0.63;
		pan = 0.9;
	0.2*TGrains.ar(2, clk, buf, rate, pos, 0.333 * 120/115, pan, 0.05);
	}.play;

	});


t.schedAbs(79, { //mon
x.free;
y.free;

x = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~vox;
	    rate = [PinkNoise.kr(0.05,(-1.333)),PinkNoise.kr(0.05,(1.333))];
		trate =PinkNoise.kr(2,XLine.kr(2,120,4));
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.064;//0.05,0.08,0.11
		pan = 0;
		0.3*TGrains.ar(2, clk, buf, rate, pos, [0.03,0.05] * 120/115, pan, 0.05);
	}.play;

y = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~guitar;
	    rate = [PinkNoise.kr(0.05,(-1.333)),PinkNoise.kr(0.05,(-1.333))];
		trate =PinkNoise.kr(2,XLine.kr(120,2,4));
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.064;//0.05,0.08,0.11
		pan = 0;
	4*TGrains.ar(2, clk, buf, rate, pos, [0.2,0.25] * 120/115, pan, 0.05);
	}.play;

	});

t.schedAbs(79.5, { //-ey
x.free;
y.free;

x = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~vox;
	    rate = [PinkNoise.kr(0.05,(-1)),PinkNoise.kr(0.05,(1))];
		trate =PinkNoise.kr(2,XLine.kr(2,120,4));
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.064;//0.05,0.08,0.11
		pan = 0;
		0.3*TGrains.ar(2, clk, buf, rate, pos, [0.03,0.05] * 120/115, pan, 0.05);
	}.play;

y = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~guitar;
	    rate = [PinkNoise.kr(0.05,(-1)),PinkNoise.kr(0.05,(-1))];
		trate =PinkNoise.kr(2,XLine.kr(120,2,4));
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.064;//0.05,0.08,0.11
		pan = 0;
	4*TGrains.ar(2, clk, buf, rate, pos, [0.2,0.25] * 120/115, pan, 0.05);
	}.play;

	});

t.schedAbs(83.8, { //stray
x.free;
y.free;

	y = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~vox;
	    rate = [PinkNoise.kr(0.05,(-0.66)),PinkNoise.kr(0.05,(-0.66))];
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
	pos = BufDur.kr(buf)*0.63;
		pan = 0.9;
	0.2*TGrains.ar(2, clk, buf, rate, pos, 0.333 * 120/115, pan, 0.05);
	}.play;

	x = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~vox;
	    rate = [PinkNoise.kr(0.05,(-0.66)),PinkNoise.kr(0.05,(-0.66))];
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
	pos = BufDur.kr(buf)*0.63;
		pan = 0.9;
	0.2*TGrains.ar(2, clk, buf, rate, pos, 0.333 * 120/115, pan, 0.05);
	}.play;

	});

t.schedAbs(87, { //go

	x.free;
	y.free;

	y = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~vox;
	    rate = [PinkNoise.kr(0.05,(-1)),PinkNoise.kr(0.05,(-1))];
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
	pos = BufDur.kr(buf)*0.63;
		pan = 0.9;
	0.2*TGrains.ar(2, clk, buf, rate, pos, 0.333 * 120/115, pan, 0.05);
	}.play;

	x = {//granular synth
		var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~vox;
	    rate = [PinkNoise.kr(0.05,(-1)),PinkNoise.kr(0.05,(-1))];
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
	pos = BufDur.kr(buf)*0.63;
		pan = 0.9;
	0.2*TGrains.ar(2, clk, buf, rate, pos, 0.333 * 120/115, pan, 0.05);
	}.play;

	});


t.schedAbs(91.5, { //sor-

	x.free;
	y.free;

	x = {var buf, rate, trate, dur, clk, pos, pan, env;
		buf = ~vox;
	    rate = [PinkNoise.kr(0.05,(-1.333)),PinkNoise.kr(0.05,(1.333))];
		trate =PinkNoise.kr(2,XLine.kr(2,120,4));
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.064;//0.05,0.08,0.11
		pan = 0;

		0.3*TGrains.ar(2, clk, buf, rate, pos, [0.03,0.05] * 120/115, pan, 0.05);

	}.play;

	y = {var buf, rate, trate, dur, clk, pos, pan, env;

		buf = ~guitar;
	    rate = [PinkNoise.kr(0.05,(-1.333)),PinkNoise.kr(0.05,(-1.333))];
		trate =PinkNoise.kr(2,XLine.kr(120,2,4));
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.064;//0.05,0.08,0.11
		pan = 0;

		4*TGrains.ar(2, clk, buf, rate, pos, [0.2,0.25] * 120/115, pan, 0.05);

	}.play;

});

t.schedAbs(92, { //-ry

	x.free;
	y.free;

	x = {var buf, rate, trate, dur, clk, pos, pan, env;

		buf = ~vox;
		rate = [PinkNoise.kr(0.05,(-1)),PinkNoise.kr(0.05,(1))];
		trate =PinkNoise.kr(2,XLine.kr(2,120,4));
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.064;//0.05,0.08,0.11
		pan = 0;

		0.3*TGrains.ar(2, clk, buf, rate, pos, [0.03,0.05] * 120/115, pan, 0.05);

	}.play;

	y = {var buf, rate, trate, dur, clk, pos, pan, env;

		buf = ~guitar;
	    rate = [PinkNoise.kr(0.05,(-1)),PinkNoise.kr(0.05,(-1))];
		trate =PinkNoise.kr(2,XLine.kr(120,2,4));
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.064;//0.05,0.08,0.11
		pan = 0;

		4*TGrains.ar(2, clk, buf, rate, pos, [0.2,0.25] * 120/115, pan, 0.05);

	}.play;

});

t.schedAbs(100, { //late

	x.free;
	y.free;

	x={var trate, dur, clk, pos, pan, env, amp;
		trate =PinkNoise.kr(2,200);
		dur = 0.1;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(~vox)*EnvGen.kr(Env.new([0.5,0.5,0.025],[4,0.1],[1,-1]));
		pan = 0;
		amp = 0.1*EnvGen.kr(Env.new([1,1,0.4,0.1],[4,0.1,3.9],[1,-1]));

		[0.1,0.1]*TGrains.ar(2, clk, ~vox, [-1,1], BrownNoise.kr(2,pos), 0.1, pan, amp);

	}.play;

	y = {var buf, rate, trate, dur, clk, pos, pan, env;

		buf = ~guitar;
		rate = PinkNoise.kr(0.05,(-1));
		trate =PinkNoise.kr(2,XLine.kr(60,5,10));
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.032;//0.05,0.08,0.11
		pan = -1;

		[2,6]*TGrains.ar(2, clk, buf, rate, pos, [0.8,0.01] * 120/115, pan, 0.05);

	}.play;

});

)






