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

//boot server
s.boot;

//variables

(
~bpm=75;
~swing=0.02;
~scale = Scale.phrygian(\just);

~step = (60/1)*(1/~bpm)*(1/4);
~tick = ~step+(~swing*~step);
~tock = ~step-(~swing*~step);
~lagKick=(1)*~step/256;
~lagSnare=(1)*~step/256;
~lagHat=(1)*~step/1600;
~lagClap=(1)*~step/256;

~masterGain = 0.2;

~path = PathName(thisProcess.nowExecutingPath).parentPath; //path for buffers

TempoClock.default.tempo = 1;

s.latency = 0.2;
)

//loading stems buffers

(
~halawaVox = Buffer.readChannel(s,~path++"yfree_buffers_stems/180104 halawa vox.wav",0,-1,1);
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
SynthDef(\halawaVox, {
	arg out = 0, amp=1;
	var sig, env;
	b = ~halawaVox;
	sig = PlayBuf.ar(1, b, 1, doneAction:2)*amp*2*~masterGain;
	Out.ar(out, [sig,sig])
}).play;
)

(
SynthDef(\clap, {
	arg outBus=0, amp = 0.5, gain = 1.5;
	var env1, env2, sig, noise1, noise2;
	env1 = EnvGen.ar(Env.new([0, 1, 0, 1, 0, 1, 0, 1, 0], [0.001, 0.013, 0, 0.01, 0, 0.01, 0, 0.03], [0, -3, 0, -3, 0, -3, 0, -4]));
	env2 = EnvGen.ar(Env.new([0, 1, 0], [0.02, 0.3], [0, -4]), doneAction:2);
	noise1 = BPF.ar(HPF.ar(GrayNoise.ar(env1), 600), 2000, 3);
	noise2 = BPF.ar(HPF.ar(GrayNoise.ar(env2), 1000), 1200, 0.7, 0.7);
	sig = noise1 + noise2;
	sig = sig * gain;
	sig = 0.4 * sig.softclip * amp * ~masterGain;
	Out.ar(0, [sig,sig]);
}).play;
)

(
SynthDef(\kick,{
	arg startFreq=60, endFreq=10, decay=0.8, lowpass=500, amp=1, noiseAmp=0.00, gain=1, dur=0.8;
	var sig, env, freq;
	freq = XLine.kr(startFreq, endFreq, dur, 1, 0);
	env = EnvGen.kr(Env.perc(0.0014, dur, 1, -5), 1, doneAction:2);
	sig = {(LPF.ar(Ringz.ar(Impulse.ar(0), freq, decay), lowpass) * amp) ! 2};
	sig = sig + LPF.ar((noiseAmp*BrownNoise.ar(1)),lowpass);
	sig = sig * gain;
	sig = sig.softclip * amp * env * ~masterGain;
	Out.ar(0, [sig,sig]);
}).play;
)

(
SynthDef(\snare,{
	arg amp=0.75, freq=120, gain=1;
	var env, sig, snare;
	env = EnvGen.kr(Env.perc(0.001, 0.1, 1, -5), 1, doneAction:2);
	sig = (SinOsc.ar(freq) - WhiteNoise.ar(0.5, 0.5)) * env * amp;
	sig = sig * gain * 0.4;
	sig = sig.softclip * amp * ~masterGain;
	Out.ar(0, [sig,sig]);
}).play;
)

(
SynthDef(\hat,{
	arg amp=0.75;
	var env, sig;
	env = EnvGen.kr(Env.perc(0.001, 0.1, 1, -4), 1, doneAction:2);
	sig = HPF.ar((WhiteNoise.ar(0.5, 0.5) * env * amp * ~masterGain), 4000);
	Out.ar(0, [sig,sig]);
}).play;
)

(
SynthDef.new(\Klaus1000, {
	arg out = 0, freq=440, atk=0.001, rel=0.5, amp=1, dur=0.2, pan=0;
	var sig, env;
	freq = 2*freq*(395/500)*PinkNoise.kr(0.00,1);
	sig = Klank.ar(`[ (1..10)*freq, 1/(1..10), nil ], PinkNoise.ar(1));
	sig = LPF.ar(sig, 20000);
	env = EnvGen.kr(Env.new([0,1,0],[atk,rel],[1,-1]),doneAction:2)**1.8;
	sig = 0.9*(sig*env*amp*~masterGain)*0.05;
	sig = Pan2.ar(sig,pan);
	Out.ar(out, sig);
}).play;
)

(
SynthDef.new(\Colleen, {
	arg freq=110, atk=0.02, rel=0.5, amp=1, dur=1, pan = 0, out = -1;
	var sig, env;
	freq =0.5*freq*(395/250)*PinkNoise.kr(0.01,1)*BrownNoise.kr(0.01,1)*2;
	sig = LPF.ar(CombC.ar(Decay.ar(Impulse.ar(0), 0.2, BrownNoise.ar), 4/(BrownNoise.kr(XLine.kr(10,1,0.2),freq)), 4/(PinkNoise.kr(XLine.kr(10,1,0.2),freq)), 3, 0.4),4000);
	env = EnvGen.kr(Env.new([0,1,0],[atk,rel],[1,-1]),doneAction:2)**2;
	//sig = sig + PinkNoise.ar(0.1);
	sig = LPF.ar(sig, XLine.kr(500,1000,rel*0.1));
	sig = (sig*env*amp*~masterGain)*1;
	sig = Pan2.ar(sig,pan);
	Out.ar(out, sig);
}).add;
)

(
SynthDef.new(\Colleen2, {
	arg freq=110, atk=0.1, rel=0.6, amp=1, dur=0.2, pan = 0, out = -1;
	var sig, env;
	freq = freq*(395/250)*PinkNoise.kr(0.01,1);
	sig = LPF.ar(CombC.ar(Decay.ar(Impulse.ar(0), 0.2, BrownNoise.ar), 4/(BrownNoise.kr(XLine.kr(10,1,0.2),freq)), 4/(PinkNoise.kr(XLine.kr(10,1,0.2),freq)), 3, 0.4),4000);
	env = EnvGen.kr(Env.new([0,1,0],[atk,rel],[1,-1]),doneAction:2);
	//sig = sig + PinkNoise.ar(0.1);
	sig = LPF.ar(sig, XLine.kr(50,1000,rel*0.1));
	sig = 0.8*(sig*env*amp);
	sig = Pan2.ar(sig,pan);
	Out.ar(out, sig);
}).play;
)

//Pdefs
(
Pdef(\vox,
	Pbind(
		\instrument, \halawaVox,
		\lag, ~lagKick,
		\amp, ~masterGain*1*Pseq([1],1),
	)
).play;

Pdef(\kick,
	Pbind(
		//\instrument, \kick,
		\instrument, \bufPlay,
		\bufnum, Pseq([
			Prand(d[\kickLoud],1),
			Prand(d[\kickSoft],1),
		],inf),
		\lag, 0,
		\dur, Pseq([~tick,~tock],inf),
		\amp, ~masterGain*12*
		Pseq([
			1,0,0,0, 1,0,0,0, 1,0,0,0, 1,0,0,0,
			1,0,0,0, 1,Prand([1,0],3), 1,0,0,0, 1,0,0,0,
			1,0,0,0, 1,0,0,0, 1,0,0,0, 1,0,0,0,
			1,0,0,0, 1,0,0,0, 1,0,0,0, 1,Prand([1,0],3)
		], 1),
	)
).play;


Pdef(\ekick,
	Pbind(
		\instrument, \kick,
		\lag, 0,
		\dur, Pseq([~tick,~tock],inf),
		\amp, ~masterGain*4*
		Pseq([
			1,0,0,0, 0,0,0,0,
		], inf),
	)
).play;

Pdef(\clap,
	Pbind(
		\instrument, \clap,
		\lag, 0,
		\dur, Pseq([~tick,~tock],inf),
		\amp, ~masterGain*6*
		Pseq([
			0,0,0,0, 0,0,0,0,
			0,0,0,0, 1,0,0,0,
		], 4),
	)
).play;

Pdef(\snare,
	Pbind(
		//\instrument, \snare,
		\instrument, \bufPlay,
		\bufnum, Prand(d[\snareDead],inf),
		\lag, 0,
		\dur, Pseq([~tick,~tock],inf),
		\amp, ~masterGain*6*
		Pseq([
			0,0,0,0, 1,0,0,0,
		], 8),
	)
).play;

Pdef(\hat,
	Pbind(
		\instrument, \bufPlay,
		\bufnum, Pseq([Prand(d[\hatFoot],1)],inf),
		//\bufnum, Pwrand([Prand(d[\ride],1),Prand(d[\rideBell],1)],[0.95,0.05],inf),
		\dur, Pseq([~tick,~tock],inf),
		//\rate, 1.03*Pshuf([1.003,1.002,1.001,1.002,0,0.999,0.998,0.997,0.996,0.997,0.998,0.999,1,1.001,1.002],inf)*Pseq([1,1.002],inf),
		\amp, Pseq([0,0,1,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
		0,0,1,0, 0,0,0,0, 0,0,0,0, 0,0,0,0],inf),
		\lag, 0.02,
		\pan, -0.2,
		//\pan, 0.5,
	)
).play;

Pdef(\ride,
	Pbind(
		\instrument, \bufPlay,
		\bufnum, Pseq([Prand(d[\rideBell],1)],inf),
		//\bufnum, Pwrand([Prand(d[\ride],1),Prand(d[\rideBell],1)],[0.95,0.05],inf),
		\dur, Pseq([~tick,~tock],inf),
		//\rate, 1.03*Pshuf([1.003,1.002,1.001,1.002,0,0.999,0.998,0.997,0.996,0.997,0.998,0.999,1,1.001,1.002],inf)*Pseq([1,1.002],inf),
		\amp, Pseq([0,0.8,0.4,1],inf),
		\lag, 0.02,
		\pan, -0.2,
		//\pan, 0.5,
	)
).play;

Pdef(\bassL,
	Pbind(
		\instrument, \Colleen,
		\lag, 0,
		\dur, Pseq([~tick,~tock],inf),
		\degree,Pseq([
			0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
			0,0,0,0, 0,0,0,0, -1,-1,-1,-1, -1,-1,-1,-1,
			-2,-2,-2,-2, -2,-2,-2,-2, -2,-2,-2,-2, -2,-2,-2,-2,
			-4,-4,-4,-4, -4,-4,-4,-4, -4,-4,-4,-4, -4,-4,-4,-4,
		], 1),//+[0,4],
		\octave, [4,5],
		//\strum, 0.03,
		\atk, Pseq([0.04,0.001],inf),
		\amp,  ~masterGain*6*Pseq([Pseq([1], 126),Pseq([0],2),],inf)*Pseq([0.6,0,1,0],inf),
	\pan, -1,
	)
).play;

Pdef(\bassR,
	Pbind(
		\instrument, \Colleen,
		\lag, Pseq([0.001,0.002],inf),
		\dur, Pseq([~tick,~tock],inf),
		\degree,Pseq([
			0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
			0,0,0,0, 0,0,0,0, -1,-1,-1,-1, -1,-1,-1,-1,
			-2,-2,-2,-2, -2,-2,-2,-2, -2,-2,-2,-2, -2,-2,-2,-2,
			-4,-4,-4,-4, -4,-4,-4,-4, -4,-4,-4,-4, -4,-4,-4,-4,
		], 1),//+[0,4],
		\octave, [4,5],
		\amp,  ~masterGain*6*Pseq([Pseq([1], 126),Pseq([0],2),],inf)*Pseq([0.6,0,1,0],inf),
		//\strum, 0.05,
		\atk, Pseq([0.06,0.001],inf),
		\pan, 1,
	)
).play;

Pdef(\chordsL,
	Pbind(
		\instrument, \Colleen2,
		\lag, Pseq([0.001,0.002],inf),
		\dur, ~step*8,
		\degree, [0,2,4,7]+Pseq([0,0,0,-1,-2,-2,-4,-4],1),
		\octave, [3,4,5]+2,
		\amp, ~masterGain*Pseq([0,0,1,1,1,0,0,0,],1),
		\pan, -1,
		\strum, 0.06,
		\atk, 0.03,
		//\strum, 0.03,
		\rel, 2,
	)
).play;

Pdef(\chordsR,
	Pbind(
		\instrument, \Colleen2,
		\lag, 0,
		\dur, ~step*8,
		\degree, [0,2,4,7]+Pseq([0,0,0,-1,-2,-2,-4,-4],1),
		\octave, [4,5,6]+2,
		\amp, ~masterGain*Pseq([0,0,1,1,1,0,0,0,],1),
		\pan, 1,
		\strum, 0.06,
		\atk, 0.03,
		//\strum, 0.05,
		\rel, 2,
	)
).play;

Pdef(\arpegioL,
	Pbind(
		\instrument, \Colleen2,
		\lag, 0,
		\dur, Pseq([~tick,~tock],inf),
		\degree, Pseq([
			0,8,4,0, 8,4,0,8, 4,0,8,4, Pshuf([0,8,4,0,],1),
			8,4,0,8, 4,0,8,4, 0,8,4,0, Pshuf([8,4,0,8,],1),
			0,8,2,0, 8,2,0,8, 2,0,8,2, Pshuf([0,8,2,0,],1),
			0,5,11,0, 5,11,0,5, Pshuf([11,0,5,11, 0,5,11,0,],1),
		],1),
		\octave, Pseq([5,6],inf),
		\amp, ~masterGain*1*Pseq([0.2,1],inf),
		\pan, 1,
		\atk, 0.1,
		\rel, 0.1,
	)
).play;

Pdef(\arpegioR,
	Pbind(
		\instrument, \Colleen2,
		\lag, 0,
		\dur, Pseq([~tick,~tock],inf),
		\degree, Pseq([
			4,5,9,4, 5,9,4,5, 9,4,5,9, Pshuf([4,5,9,4],1),
			4,5,9,4, 5,9,4,5, 9,4,5,9, Pshuf([4,5,9,4],1),
			4,5,9,4, 5,9,4,5, 9,4,5,9, Pshuf([4,5,9,4],1),
			4,5,9,4, 5,9,4,5, Pshuf([4,5,9,4, 5,9,4,5,],1),
		],1),
		\octave, Pseq([5,6],inf),
		\amp, ~masterGain*1*Pseq([0.5,1],inf),
		\pan, -1,
		\atk, 0.1,
		\rel, 0.1,
	)
).play;
)

//tempo clock

(
v = Main.elapsedTime.ceil;
t = TempoClock(~bpm/60, 0, v);

t.schedAbs(0, {//verse 1
	Pdef(\kick).play(quant: 0.1);
	Pdef(\ekick).play(quant: 0.1);
	Pdef(\snare).play(quant: 0.1);
	Pdef(\clap).play(quant: 0.1);
	Pdef(\bassR).play(quant: 0.1);
	Pdef(\bassL).play(quant: 0.1);
	Pdef(\vox).play(quant: 0.1);
	});

t.schedAbs(16, {//verse 2
	Pdef(\kick).stop;
	Pdef(\snare).stop;
	Pdef(\clap).stop;
	Pdef(\bassR).stop;
	Pdef(\bassL).stop;
	Pdef(\kick).play(quant: 0.1);
	Pdef(\snare).play(quant: 0.1);
	Pdef(\clap).play(quant: 0.1);
	Pdef(\bassR).play(quant: 0.1);
	Pdef(\bassL).play(quant: 0.1);
	Pdef(\hat).play(quant: 0.1);
});

t.schedAbs(2*16, {//chorus
	Pdef(\kick).stop;
	Pdef(\snare).stop;
	Pdef(\clap).stop;
	Pdef(\bassR).stop;
	Pdef(\bassL).stop;
	Pdef(\hat).stop;
	Pdef(\kick).play(quant: 0.1);
	Pdef(\bassR).play(quant: 0.1);
	Pdef(\bassL).play(quant: 0.1);
	Pdef(\chordsL).play(quant: 0.1);
	Pdef(\chordsR).play(quant: 0.1);
});

t.schedAbs(2*16+15, {//verse 3 pickup
	Pdef(\bassR).stop;
	Pdef(\bassL).stop;
});

t.schedAbs(2*16+15.25, {//verse 3 pickup
	Pdef(\kick).stop;
	Pdef(\hat).stop;
});

t.schedAbs(3*16, {//verse 3
	Pdef(\kick).stop;
	Pdef(\bassR).stop;
	Pdef(\bassL).stop;
	Pdef(\chordsL).stop;
	Pdef(\chordsR).stop;
	Pdef(\hat).play(quant: 0.1);
	Pdef(\kick).play(quant: 0.1);
	Pdef(\snare).play(quant: 0.1);
	Pdef(\clap).play(quant: 0.1);
	Pdef(\bassR).play(quant: 0.1);
	Pdef(\bassL).play(quant: 0.1);
});

t.schedAbs(4*16, {//verse 4
	Pdef(\kick).stop;
	Pdef(\snare).stop;
	Pdef(\clap).stop;
	Pdef(\bassR).stop;
	Pdef(\bassL).stop;
	Pdef(\hat).play(quant: 0.1);
	Pdef(\kick).play(quant: 0.1);
	Pdef(\snare).play(quant: 0.1);
	Pdef(\clap).play(quant: 0.1);
	Pdef(\bassR).play(quant: 0.1);
	Pdef(\bassL).play(quant: 0.1);
});

t.schedAbs(5*16, {//chorus
	Pdef(\kick).stop;
	Pdef(\snare).stop;
	Pdef(\clap).stop;
	Pdef(\bassR).stop;
	Pdef(\bassL).stop;
	Pdef(\hat).stop;
	Pdef(\kick).play(quant: 0.1);
	Pdef(\bassR).play(quant: 0.1);
	Pdef(\bassL).play(quant: 0.1);
	Pdef(\chordsL).play(quant: 0.1);
	Pdef(\chordsR).play(quant: 0.1);
});

t.schedAbs(5*16+15.25, {//bridge pickup
	Pdef(\kick).stop;
	Pdef(\bassR).stop;
	Pdef(\bassL).stop;
	Pdef(\hat).stop;
});

t.schedAbs(6*16, {//bridge
	Pdef(\kick).stop;
	Pdef(\bassR).stop;
	Pdef(\bassL).stop;
	Pdef(\chordsL).stop;
	Pdef(\chordsR).stop;
	Pdef(\hat).play(quant: 0.1);
	Pdef(\ride).play(quant: 0.1);
	Pdef(\kick).play(quant: 0.1);
	Pdef(\snare).play(quant: 0.1);
	Pdef(\clap).play(quant: 0.1);
	Pdef(\bassR).play(quant: 0.1);
	Pdef(\bassL).play(quant: 0.1);
	Pdef(\arpegioL).play(quant: 0.1);
	Pdef(\arpegioR).play(quant: 0.1);
});

t.schedAbs(7*16, {
	Pdef(\kick).stop;
	Pdef(\bassR).stop;
	Pdef(\bassL).stop;
	Pdef(\snare).stop;
	Pdef(\clap).stop;
	Pdef(\arpegioL).stop;
	Pdef(\arpegioR).stop;
	Pdef(\kick).play(quant: 0.1);
	Pdef(\snare).play(quant: 0.1);
	Pdef(\clap).play(quant: 0.1);
	Pdef(\bassR).play(quant: 0.1);
	Pdef(\bassL).play(quant: 0.1);
	Pdef(\arpegioL).play(quant: 0.1);
	Pdef(\arpegioR).play(quant: 0.1);
});

t.schedAbs(8*16, {
	Pdef(\kick).stop;
	Pdef(\snare).stop;
	Pdef(\clap).stop;
	Pdef(\bassR).stop;
	Pdef(\bassL).stop;
	Pdef(\ride).stop;
	Pdef(\ekick).stop;
	Pdef(\hat).stop;
	Pdef(\arpegioL).stop;
	Pdef(\arpegioR).stop;
	Pdef(\kick).play(quant: 0.1);
	Pdef(\bassR).play(quant: 0.1);
	Pdef(\bassL).play(quant: 0.1);
	Pdef(\chordsL).play(quant: 0.1);
	Pdef(\chordsR).play(quant: 0.1);
});
)

