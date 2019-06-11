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
~masterGain = 0.15;

~path = PathName(thisProcess.nowExecutingPath).parentPath; //path for buffers
)

//loading vocal stem

(
~vox =
Buffer.readChannel(s,~path++"yfree_buffers_stems/yfree space bike (vox).wav",0,-1,0);
)

//loading drum sample dictionary buffers

(
d = Dictionary.new;
d.add(\hatClosed ->	PathName(~path++"/aksel_drum_samples/hatClosed/").entries.collect({
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

//testing dictionary

d[\hatClosed].choose.play;
d[\hatFoot].choose.play;
d[\kickLoud].choose.play;
d[\kickSoft].choose.play;
d[\snareDead].choose.play;
d[\ride].choose.play;
d[\rideBell].choose.play;
d[\floorTom].choose.play;
d[\crash].choose.play;

//synths

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
SynthDef(\kick,{
	arg startFreq=60, endFreq=20, decay=4, lowpass=1000, amp=1, noiseAmp=0.01, gain=1, dur=0.8;
	var sig, env, freq;
	freq = XLine.kr(startFreq, endFreq, dur, 1, 0);
	env = EnvGen.kr(Env.perc(0.0014, dur, 1, -5), 1, doneAction:2);
	sig = {(LPF.ar(Ringz.ar(Impulse.ar(0), freq, decay), lowpass) * amp) ! 2};
	sig = sig + LPF.ar((noiseAmp*BrownNoise.ar(1)),lowpass);
	sig = 1 * sig * gain * ~masterGain;
	sig = sig.softclip * amp * env;
	Out.ar(0, [sig,sig]);
}).play;
)

(
SynthDef(\kick2,{
	arg startFreq=80, endFreq=15, decay=4, lowpass=800, amp=1, noiseAmp=0.0, gain=1, dur=6;
	var sig, env, freq;
	freq = Line.kr(PinkNoise.kr(6,startFreq), PinkNoise.kr(3,endFreq), dur, 1, 0);
	env = EnvGen.kr(Env.perc(0.014, dur, 1, -5), 1, doneAction:2);
	sig = {(LPF.ar(Ringz.ar(Impulse.ar(0), freq, decay), lowpass) * amp) ! 2};
	sig = LPF.ar(sig,BrownNoise.kr(500,1500))*0.3;
	sig = 2 * sig * gain * ~masterGain;
	sig = sig.softclip * amp * env;
	Out.ar(0, [sig,sig]);
}).play;
)

/*
(
SynthDef(\clap, {
	arg outBus=0, amp = 0.5, gain = 1.5;
	var env1, env2, sig, noise1, noise2;
	env1 = EnvGen.ar(Env.new([0, 1, 0, 1, 0, 1, 0, 1, 0], [0.001, 0.013, 0, 0.01, 0, 0.01, 0, 0.03], [0, -3, 0, -3, 0, -3, 0, -4]));
	env2 = EnvGen.ar(Env.new([0, 1, 0], [0.02, 0.3], [0, -4]), doneAction:2);
	noise1 = BPF.ar(HPF.ar(GrayNoise.ar(env1), 3000), 2000, 3);
	noise2 = BPF.ar(HPF.ar(GrayNoise.ar(env2), 4000), 1200, 0.7, 0.7);
	sig = noise1 + noise2;
	sig = 1.8 * sig * gain;
	sig = sig.softclip * amp * ~masterGain;
	Out.ar(0, [sig,sig]);
}).play;
)
*/

(
SynthDef(\clap, {
	arg outBus=0, amp = 0.5, gain = 1.5, rel = 0.15;
	var env1, env2, sig, noise1, noise2;
	env1 = EnvGen.ar(Env.new([0, 1, 0, 1, 0, 1, 0, 1, 0], [0.001, 0.013, 0, 0.01, 0, 0.01, 0, 0.03], [0, -3, 0, -3, 0, -3, 0, -4]));
	env2 = EnvGen.ar(Env.new([0, 1, 0], [0.02, rel], [0, -4]), doneAction:2);
	noise1 = BPF.ar(HPF.ar(GrayNoise.ar(env1), 1800), 2000, 3);
	noise2 = BPF.ar(HPF.ar(GrayNoise.ar(env2), 1900), 1200, 0.7, 0.7);
	sig = noise1 + noise2;
	sig = sig * gain;
	sig = LPF.ar(sig, 2000) * 4;
	sig = sig.softclip * amp *0.8* ~masterGain;
	Out.ar(0, [sig,sig]);
}).play;
)

(
SynthDef.new(\Colleen, {
	arg freq=110, atk=0.001, rel=0.4, amp=1, dur=2, pan = 0, out = -1;
	var sig, env;
	freq = 2*freq*(1.13)*PinkNoise.kr(0.02,1)*BrownNoise.kr(0.01,1)*1;
	sig = LPF.ar(CombC.ar(Decay.ar(Impulse.ar(0), 0.2, BrownNoise.ar), 4/(BrownNoise.kr(XLine.kr(10,1,0.2),freq)), 4/(PinkNoise.kr(XLine.kr(10,1,0.2),freq)), 3, 0.4),4000);
	env = EnvGen.kr(Env.new([0,1,0],[atk,rel],[1,-1]),doneAction:2);
	sig = sig + PinkNoise.ar(0.1);
	sig = LPF.ar(sig, XLine.kr(100,700,rel*0.1));
	sig = 1.1 * (sig*env*amp) * 0.8 * ~masterGain;
	sig = Pan2.ar(sig,pan);
	Out.ar(out, sig);
}).play;
)

(
SynthDef.new(\Oliver, {
	arg freq=440, atk=0.01, rel=1, harmonics=8, amp=0.1;
	var sig, env;
	freq = freq*(1.13)/2;
	sig = Blip.ar(freq*PinkNoise.kr(0.06,1)/2,Line.kr(WhiteNoise.kr(harmonics/2,harmonics),WhiteNoise.kr(harmonics/2,harmonics),PinkNoise.kr(atk*3,atk*4)),0.5)!64;
	sig = LPF.ar(sig,PinkNoise.kr(250,800))/2;
	env = EnvGen.kr(Env.new([0,1,0],[PinkNoise.kr(atk*0.8,atk),PinkNoise.kr(rel*0.8,rel)],[1,-1]),doneAction:2);
	sig = sig*env*amp*0.05* ~masterGain;
	Out.ar(0, [sig, sig]);
}).play;
)


(
SynthDef(\plong, {
	arg freq=420, amp=0.4, rel=2, pan=0.0, atk=0.001;
	var sig, env;
	env = EnvGen.ar(Env.perc(atk, rel), doneAction:2);
	freq = 4*freq;
	sig = Array.fill(8, {SinOsc.ar(freq+(420.rand), 0, 8.reciprocal)}) * env;
	sig = 0.4*Pan2.ar(sig, pan) * ~masterGain * amp;
	Out.ar(0, sig);
}).add;
)

(
SynthDef(\seaSick, {
	arg amp = 0.1;
	var sigL, sigR;
	sigL = 2*DynKlang.ar(`[[800.rand, 1000.rand, 1200.rand] + SinOsc.kr([2.rand, 3.rand, 5.rand], 0, [13, 24, 12]),[0.3, 0.3, 0.3],[pi,pi,pi]])* ~masterGain * amp;
	sigR = 2*DynKlang.ar(`[[800.rand, 1000.rand, 1200.rand] + SinOsc.kr([2.rand, 3.rand, 5.rand], 0, [13, 24, 12]),[0.3, 0.3, 0.3],[pi,pi,pi]])* ~masterGain * amp;
	Out.ar(0, [sigL,sigR]);
}).play;
)

(
SynthDef(\vox, {
	arg out = 0, bufnum = 0, amp=1, atk=0.01, rel=2, trate=120, pan=0;
	var scaledRate, sig, env, b;
	b = ~vox;
	rel= BufDur.kr(b);
	scaledRate = BufRateScale.kr(b);
	sig = 0.7 * PlayBuf.ar(1, b, scaledRate, doneAction:2)*amp*~masterGain;
	sig = Pan2.ar(sig,pan);
	Out.ar(out, sig)
}).play;
)


//testing synths

Synth.new(\bufPlay, [\bufnum, d[\kickLoud].choose.bufnum]);
Synth.new(\bufPlay, [\bufnum, d[\floorTom].choose.bufnum]);

//patterns

(
Pdef(\vocals,
	Pbind(
	\instrument, \vox,
	\amp, 1.2*Pseq([1],1),
	)
).play;

Pdef(\bassL,
	Pbind(
	\instrument, \Colleen,
		\octave, Pseq([4,5,6],inf),
	\dur, Pwrand([
			Pseq([1/8*1.1,1/8*(1-0.1)],16),
			Pseq([1/8*1.15,1/8*(1-0.15)],16),
			Pseq([1/8*1.2,1/8*(1-0.2)],16),
			Pseq([1/8],32),
		],[0.8,0.2],inf),
		\amp, 2*Pseq([Pseq([1,0.2],6),Pseq([0],4)],inf),
	\pan, 0.5,
	)
).play;

Pdef(\bassR,
	Pbind(
	\instrument, \Colleen,
		\octave, Pseq([4,5,6],inf),
	\dur, Pwrand([
			Pseq([1/8*1.1,1/8*(1-0.1)],16),
			Pseq([1/8*1.15,1/8*(1-0.15)],16),
			Pseq([1/8*1.2,1/8*(1-0.2)],16),
			Pseq([1/8],32),
		],[0.8,0.2],inf),
	\amp, 2*Pseq([Pseq([1,0.2],6),Pseq([0],4)],inf),
	\pan, -0.5,
	)
).play;

Pdef(\bossL,
	Pbind(
	\instrument, \Oliver,
		\octave, 4,
	\dur, Pwrand([
			Pseq([1/8*1.1,1/8*(1-0.1)],16),
			Pseq([1/8*1.15,1/8*(1-0.15)],16),
			Pseq([1/8*1.2,1/8*(1-0.2)],16),
			Pseq([1/8],32),
		],[0.8,0.2],inf),
		\amp, 0.3*Pseq([Pseq([1,0.2],6),Pseq([0],4)],inf),
	\pan, 0.5,
	)
).play;

Pdef(\bossR,
	Pbind(
	\instrument, \Oliver,
		\octave, 4,
	\dur, Pwrand([
			Pseq([1/8*1.1,1/8*(1-0.1)],16),
			Pseq([1/8*1.15,1/8*(1-0.15)],16),
			Pseq([1/8*1.2,1/8*(1-0.2)],16),
			Pseq([1/8],32),
		],[0.8,0.2],inf),
	\amp, 0.3*Pseq([Pseq([1,0.2],6),Pseq([0],4)],inf),
	\pan, -0.5,
	)
).play;

Pdef(\bassLC,
	Pbind(
	\instrument, \Colleen,
		\octave, 4,
	\dur, Pwrand([
			Pseq([1/8*1.1,1/8*(1-0.1)],16),
			Pseq([1/8*1.15,1/8*(1-0.15)],16),
			Pseq([1/8*1.2,1/8*(1-0.2)],16),
			Pseq([1/8],32),
		],[0.8,0.2],inf),
		\amp, 1*Pseq([Pseq([1,0],6),Pseq([0],4)],inf),
	\pan, 0.5,
	)
).play;

Pdef(\bassRC,
	Pbind(
	\instrument, \Colleen,
		\octave, 4,
	\dur, Pwrand([
			Pseq([1/8*1.1,1/8*(1-0.1)],16),
			Pseq([1/8*1.15,1/8*(1-0.15)],16),
			Pseq([1/8*1.2,1/8*(1-0.2)],16),
			Pseq([1/8],32),
		],[0.8,0.2],inf),
	\amp, 1*Pseq([Pseq([1,0],6),Pseq([0],4)],inf),
	\pan, -0.5,
	)
).play;


Pdef(\riff,
	Pbind(
	\instrument, \Colleen,
	\octave, [4,5,6,7],
	\atk, 0.00001,
	\rel, 0.3,
	\degree, Pseq([
			Pseq([0,0,3,0, 0,0,2,0, 2,0,0,0, 0,0,4,0],2),
			Pseq([0,0,3,0, 0,0,2,0, 2,0,0,0, 0,0,1,0],1),
			Pseq([1,0,1,0, 1,0,1,0, 1,0,2,0, 0,0,4,0],1),
		],inf),
	\dur, Pwrand([
			Pseq([1/8*1.3,1/8*(1-0.3)],16),
			Pseq([1/8*1.25,1/8*(1-0.25)],16),
			Pseq([1/8*1.35,1/8*(1-0.35)],16),
			Pseq([1/8],32),
		],[0.8,0.2],inf),
	\lag, 0,
	\amp, 2*Pseq([
			Pseq([0,0,1,0, 0,0,1,0, 1,0,0,0, 0,0,1,0,],3),
			Pseq([1,0,1,0, 1,0,1,0, 1,0,1,0, 0,0,1,0,],1),
		],inf),
	)
).play;

Pdef(\raff,
	Pbind(
	\instrument, \Oliver,
	\octave,6,
	\atk, 0.00001,
	\rel, 0.4,
	\degree, Pseq([
			Pseq([0,0,3,0, 0,0,2,0, 2,0,0,0, 0,0,4,0],2),
			Pseq([0,0,3,0, 0,0,2,0, 2,0,0,0, 0,0,1,0],1),
			Pseq([1,0,1,0, 1,0,1,0, 1,0,2,0, 0,0,4,0],1),
		],inf),
	\dur, Pwrand([
			Pseq([1/8*1.3,1/8*(1-0.3)],16),
			Pseq([1/8*1.25,1/8*(1-0.25)],16),
			Pseq([1/8*1.35,1/8*(1-0.35)],16),
			Pseq([1/8],32),
		],[0.8,0.2],inf),
	\lag, 0,
	\amp, 0.8*Pseq([
			Pseq([0,0,1,0, 0,0,1,0, 1,0,0,0, 0,0,1,0,],3),
			Pseq([1,0,1,0, 1,0,1,0, 1,0,1,0, 0,0,1,0,],1),
		],inf),
	)
).play;

Pdef(\plong,
	Pbind(
	\instrument, \plong,
	//\freq, Prand([420.rand,520.rand,620.rand,720.rand,720.rand],inf),
		\octave, [3,4],
	\degree, Pseq([
			Pseq([0,0,3,0, 0,0,2,0, 2,0,0,0, 0,0,4,0],2),
			Pseq([0,0,3,0, 0,0,2,0, 2,0,0,0, 0,0,1,0],1),
			Pseq([1,0,1,0, 1,0,1,0, 1,0,2,0, 0,0,4,0],1),
		],inf),//-Pseq([420.rand.cpsmidi,420.rand.cpsmidi,420.rand.cpsmidi,420.rand.cpsmidi,420.rand.cpsmidi,],inf),
	//\dur, Pseq([1/8],inf),
	\dur, Pwrand([
			Pseq([1/8*1.3,1/8*(1-0.3)],16),
			Pseq([1/8*1.25,1/8*(1-0.25)],16),
			Pseq([1/8*1.35,1/8*(1-0.35)],16),
			Pseq([1/8],32),
		],[0.8,0.2],inf),
	//\amp, 0.5*Pseq([1,0],inf),
	\amp,	Pseq([
			Pseq([0,0,1,0, 0,0,1,0, 1,0,0,0, 0,0,1,0,],3),
			Pseq([1,0,1,0, 1,0,1,0, 1,0,1,0, 0,0,1,0,],1),
		],inf),
	\pan, 0,
	)
).play;

Pdef(\clap,
	Pbind(
		\instrument, \clap,
		\dur, Pwrand([
			Pseq([1/8*1.1,1/8*(1-0.1)],16),
			Pseq([1/8],32),
		],[0.75,0.25],inf),
		\amp, Pseq([0,0,0,0, 0,0,0,0,
				0,0,0,0, 1,0,0,0,],inf),
		\rate, 1,
		\lag, Pwrand([0,0.01],[0.99,0.01],inf),
		\pan, 0,
	)
).play;

Pdef(\ekick,
	Pbind(
		\instrument, Pseq([
			Pseq([\kick2,],8),
			Pseq([\kick],8),
		],inf),
		\dur, Pwrand([
			Pseq([1/8*1.15,1/8*(1-0.15)],16),
			Pseq([1/8],32),
		],[0.8,0.2],inf),
		\amp, 0.5*Pseq([1,0,0,0, 0,0,0,0, 1,0,0,0, 0,0,0,0,],inf),
	)
).play;

Pdef(\rightFoot,
	Pbind(
		\instrument, \bufPlay,
		\bufnum, Pseq([
			Prand(d[\kickLoud],13),
			Prand(d[\kickSoft],3),
		],inf),
		\rate, 1,//0.85,
		\dur, Pwrand([
			Pseq([1/8*1.15,1/8*(1-0.15)],16),
			Pseq([1/8],32),
		],[0.8,0.2],inf),
		\amp, 1.5*Pseq([
			Pseq([1,0,0,0, 0,0,0,0,
				1,0,0,0, 0,Prand([1,0.2,0.1,0,0],2),0.5,],15),
			Pseq([1,0,0,0, 0,Prand([1,0,0,0],3),
				1,Prand([1,0.2,0.1,0,0,0],3), 0,0,0,0,],1),
		],inf)*Pwrand([1,0],[0.99,0.01],inf),
	)
).play;

Pdef(\leftHand,
	Pbind(
		\instrument, \bufPlay,
		\bufnum, Prand(d[\snareDead],inf),
		\dur, Pwrand([
			Pseq([1/8*1.1,1/8*(1-0.1)],16),
			Pseq([1/8],32),
		],[0.75,0.25],inf),
		\amp, Pseq([
			Pseq([0,0,0,0, 1,0,0,0,],31),
			Pseq([0,0,0,0, 1,Prand([1,0,],3)],1),
		],inf),
		\rate, 1,
		\lag, Pwrand([0,0.01],[0.99,0.01],inf),
		\pan, -0.1,
	)
).play;

Pdef(\rightHand,
	Pbind(
		\instrument, \bufPlay,
		\bufnum, Pseq([Prand(d[\hatClosed],1),Prand(d[\hatFoot],1)],inf),
		//\bufnum, Pwrand([Prand(d[\ride],1),Prand(d[\rideBell],1)],[0.95,0.05],inf),
		\dur, Pseq([1/8*1.3,1/8*(1-0.3)],inf),
		//\dur, Pseq([1/8*1.3,1/8*(1-0.3)],inf),
		\rate, 1.03*Pshuf([1.003,1.002,1.001,1.002,0,0.999,0.998,0.997,0.996,0.997,0.998,0.999,1,1.001,1.002],inf)*Pseq([1,1.002],inf),
		\amp, 2*Pseq([
			Pseq([1,0,1,0, 0,Pwrand([1,0],[0.02,0.98],1),Pwrand([1,0],[0.9,0.1],1),Prand([1,0],1)],31),
			Pseq([1,Prand([1,0],1),1,1, 1,Prand([1,0,],3)],1),
		],inf)*Pseq([0.4,1],inf)*Pwrand([1,0],[0.99,0.01],inf),
		/*\amp, 0*Pseq([
			Pseq([1,Pwrand([1,0],[0.4,0.6],1),1,Pwrand([1,0],[0.3,0.7],1), Pwrand([1,0],[0.3,0.7],1),Pwrand([1,0],[0.6,0.4],1),Pwrand([1,0],[0.9,0.1],1),Prand([1,0],1)],31),
			Pseq([1,Prand([1,0],1),1,1, 1,Prand([1,0,],3)],1),
		],inf)*Pseq([1,0.2,0.8,0.1],inf)*Pwrand([1,0],[0.99,0.01],inf),*/
		\lag, Pwrand([0,0.01],[0.99,0.01],inf),
		\pan, -0.2,
		//\pan, 0.5,
	)
).play;

Pdef(\ride,
	Pbind(
		\instrument, \bufPlay,
		\bufnum, Pwrand([Prand(d[\ride],1),Prand(d[\rideBell],1)],[0.95,0.05],inf),
		\dur, Pseq([1/8*1.35,1/8*(1-0.35)],inf),
		\rate, 1.03*Pshuf([1.003,1.002,1.001,1.002,0,0.999,0.998,0.997,0.996,0.997,0.998,0.999,1,1.001,1.002],inf)*Pseq([1,1.002],inf),
		\amp, 2*Pseq([
			1,Pwrand([1,0],[0.4,0.6],1),1,Pwrand([1,0],[0.3,0.7],1)],inf)*Pseq([1,0.2,0.8,0.1],inf)*Pwrand([1,0],[0.99,0.01],inf),
		\lag, Pwrand([0,0.01],[0.99,0.01],inf),
		\pan, 0.5,
	)
).play;

Pdef(\crash,
	Pbind(
		\instrument, \bufPlay,
		\bufnum, Pwrand([Prand(d[\crash],1),Prand(d[\rideBell],1)],[0.95,0.05],inf),
		\dur, Pseq([1/8*1.35,1/8*(1-0.35)],inf),
		\rate, 1.15*Pshuf([1.003,1.002,1.001,1.002,0,0.999,0.998,0.997,0.996,0.997,0.998,0.999,1,1.001,1.002],inf)*Pseq([1,1.002],inf),
		\amp, 2*Pseq([
			1,Pwrand([1,0],[0.4,0.6],1),1,Pwrand([1,0],[0.3,0.7],1)],inf)*Pseq([1,0.2,0.8,0.1],inf)*Pwrand([1,0],[0.99,0.01],inf),
		\lag, Pwrand([0,0.01],[0.99,0.01],inf),
		\pan, -0.8,
	)
).play;

)


//tempoclock

(
v = Main.elapsedTime.ceil;
t = TempoClock(2, 0, v);

t.schedAbs(0, { //intro
	Pdef(\ekick).play(quant: 0.1);
	Pdef(\rightFoot).play(quant: 0.1);
	Pdef(\leftHand).play(quant: 0.1);
	Pdef(\rightHand).play(quant: 0.1);
	Pdef(\ride).play(quant: 0.1);
	Pdef(\clap).play(quant: 0.1);
	Pdef(\vocals).play(quant: 0.1);
	Pdef(\bassR).play(quant: 0.1);
	Pdef(\bassL).play(quant: 0.1);
	Pdef(\bossR).play(quant: 0.1);
	Pdef(\bossL).play(quant: 0.1);
	});

t.schedAbs(1*16, { //intro

	y= Synth(\seaSick);

	});

t.schedAbs(2*16, { //verse1&2
	y.free;
	Pdef(\ride).stop;
	Pdef(\clap).stop;
	Pdef(\bossR).stop;
	Pdef(\bossL).stop;
});

t.schedAbs(6*16, { //chorus
	Pdef(\clap).play(quant: 0.1);
	Pdef(\ride).play(quant: 0.1);
	Pdef(\riff).play(quant: 0.1);
	Pdef(\raff).play(quant: 0.1);
	Pdef(\bossR).play(quant: 0.1);
	Pdef(\bossL).play(quant: 0.1);
});

t.schedAbs(8*16, { //verse4&5
	Pdef(\bossR).stop;
	Pdef(\bossL).stop;
	Pdef(\ride).stop;
	Pdef(\riff).stop;
	Pdef(\raff).stop;
	Pdef(\clap).stop;
});

t.schedAbs(12*16, { //chorus
	Pdef(\clap).play(quant: 0.1);
	Pdef(\ride).play(quant: 0.1);
	Pdef(\riff).play(quant: 0.1);
	Pdef(\raff).play(quant: 0.1);
	Pdef(\bossR).play(quant: 0.1);
	Pdef(\bossL).play(quant: 0.1);
});

t.schedAbs(14*16, { //bridge
	Pdef(\riff).stop;
	Pdef(\raff).stop;
	Pdef(\clap).stop;
	Pdef(\ride).stop;
	Pdef(\rightHand).stop;
});

t.schedAbs(16*16, { //instrumental
	Pdef(\bassR).stop;
	Pdef(\bassL).stop;
	Pdef(\bassRC).play(quant: 0.1);
	Pdef(\bassLC).play(quant: 0.1);

	{
		var time = 8;
		var freq = (40-12).midicps;
		var a = VarSaw.ar(freq/2, width:XLine.ar(0.5,1,time)).range(0,XLine.ar(1,1/1000,time));
		var tone = SinOsc.ar(freq).fold(-1*a,a)*0.3;
		Out.ar(0, tone.dup);
	}.play;//Chipper by Bjorn Westergard, found at https://sccode.org/1-K

//{ DynKlank.ar(`[[800.rand, 1071.rand, 1153.rand, 1723.rand], nil, [1, 1, 1, 1]], Impulse.ar(0.5, 0, 0.05))}.play;
});

t.schedAbs(16*16, { //instrumental
	Pdef(\plong).play(quant: 0.1);
});

t.schedAbs(17*16, { //instrumental
	Pdef(\clap).play(quant: 0.1);
	Pdef(\crash).play(quant: 0.1);
	y = Synth(\seaSick);
});

t.schedAbs(18*16, { //instrumental

{
loop({
    play({
        var mod = SinOsc.kr(Rand(0.1, 0.9), 0, Rand(5, 20));
        Pan2.ar(DynKlang.ar(`[ Array.rand(12, 500.0, 2000.0), 1, mod ]), 1.0.rand)
            * EnvGen.kr(Env.sine(4), 1, 0.002, doneAction: 2);
    });
    2.wait;
})
}.fork;

{
loop({
    play({
        var mod = SinOsc.kr(Rand(0.1, 0.9), 0, Rand(5, 20));
        Pan2.ar(DynKlang.ar(`[ Array.rand(12, 500.0, 4000.0), 1, mod ]), 1.0.rand)
            * EnvGen.kr(Env.sine(4), 1, 0.002, doneAction: 2);
    });
    2.wait;
})
}.fork;

});

t.schedAbs(20*16, { //chorus
	y.free;
	Pdef(\bassRC).stop;
	Pdef(\bassLC).stop;
	Pdef(\bassR).play(quant: 0.1);
	Pdef(\bassL).play(quant: 0.1);
	Pdef(\ride).play(quant: 0.1);
	Pdef(\riff).play(quant: 0.1);
	Pdef(\raff).play(quant: 0.1);
	Pdef(\plong).stop;

});

t.schedAbs(20*16, { //outro

});
)
