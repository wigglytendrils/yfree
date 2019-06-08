s.boot;
s.record;
s.stopRecording;

//time and tuning

(
~bpm=135;
~swing=0.1; // -1 to 1, (0) is straight, (+) is swing, (-) is wack

~step = (60/1)*(1/~bpm)*(1/3); //~step = (sec/step) =(sec/min)*(min/beat)*(beats/step)
~tick = ~step+(~swing*~step); //strong side of the swing beat
~tock = ~step-(~swing*~step); //weak side of the swing beat
//lag in seconds. (0) is on top of the beat, (+) is behind, (-) is ahead
~masterGain = 0.1;
~masterTune = 0.9;

~scale = Scale.phrygian(\just);

~path = PathName(thisProcess.nowExecutingPath).parentPath; //path for buffers
)

//Dictionary and Buffers

(
~vox =
Buffer.readChannel(s,~path++"yfree buffers stems/PLANETS color of mars (01 vox 135 34).wav",0,-1,0);
)


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
	arg freq=110, atk=0.01, rel=2, amp=1, dur=0.1, pan = 0, out = -1;
	var sig, env;
	freq = freq*(565/250)*PinkNoise.kr(0.01,1)*BrownNoise.kr(0.00,1)*0.36*~masterTune;
	sig = LPF.ar(CombC.ar(Decay.ar(Impulse.ar(0), 0.2, BrownNoise.ar), 4/(BrownNoise.kr(XLine.kr(10,1,0.2),freq)), 4/(PinkNoise.kr(XLine.kr(10,1,0.2),freq)), 3, 0.4),4000);
	env = EnvGen.kr(Env.new([0,1,0],[atk,rel],[1,-1]),doneAction:2);
	//env = env**2;
	//sig = sig + PinkNoise.ar(0.1);
	//sig = LPF.ar(sig, XLine.kr(500,16000,rel/6));
	//sig = HPF.ar(sig, XLine.kr(1,2000,rel/6));
	sig = ~masterGain *(sig*env*amp)*0.7;
	sig = Pan2.ar(sig,pan);
	Out.ar(out, sig);
}).add;
)

//Pdefs

(
Pdef(\vocals,
	Pbind(
	\instrument, \vox,
	\amp, 10*Pseq([1],1),
	)
).play;

Pdef(\kick,
	Pbind(
	//\instrument, \kick2,
	\instrument, \bufPlay,
	\bufnum, Prand(d[\kickLoud],inf),
	\dur, Pseq([~tick,~tock],inf),
	//\rate, 1.1,
	\lag, 0.02,
	\amp, 6*Pseq([
		1,0,0, 0,0,0, 0,0,0,
		1,0,0, 0,0,0, 0,0,1,
		1,0,0, 0,0,0, 0,0,0,
		1,0,0, 0,0,0, 1,1,0,
		1,0,0, 0,0,0, 0,0,0,
		1,0,0, 0,0,0, 0,0,1,
		1,0,0, 0,0,0, 0,0,0,
		1,1,0, 0,0,1, 0,0,0,

		1,0,0, 0,0,0, 0,0,0,
		1,0,0, 0,0,0, 0,0,1,
		1,0,0, 0,0,0, 0,0,0,
		1,0,0, 0,0,0, 1,1,0,
		1,0,0, 0,0,0, 0,0,0,
		1,0,0, 0,0,0, 0,0,1,
		1,0,0, 0,0,0, 0,0,0,
		1,1,0, 1,0,1, 0,1,0,
	], inf)*Pseq([1],inf),
	)
).play;

Pdef(\snare,
	Pbind(
	//\instrument, \kick2,
	\instrument, \bufPlay,
	\bufnum, Prand(d[\snareDead],inf),
	\dur, Pseq([~tick,~tock],inf),
	\lag, 0.02,
	//\rate, 1.15,
	\amp, 2*Pseq([
		0,0,0, 0,0,0, 0,0,0,
		1,0,0, 0,0,0, 0,0,0,
		0,0,0, 0,0,0, 0,0,0,
		1,0,0, 0,0,0, 0,0,0,
		0,0,0, 0,0,0, 0,0,0,
		1,0,0, 0,0,0, 0,0,0,
		0,0,0, 0,0,0, 0,0,0,
		1,0,0, 0,0,0, 1,0,0,

		0,0,0, 0,0,0, 0,0,0,
		1,0,0, 0,0,0, 0,0,0,
		0,0,0, 0,0,0, 0,0,0,
		1,0,0, 0,0,0, 0,0,0,
		0,0,0, 0,0,0, 0,0,0,
		1,0,0, 0,0,0, 0,0,0,
		0,0,0, 0,0,0, 0,0,0,
		1,0,0, 0,0,0, 0,0,1,
	], inf)*Pseq([1],inf),
	)
).play;

Pdef(\hat,
	Pbind(
	//\instrument, \kick2,
	\instrument, \bufPlay,
		\bufnum, Pwrand([Prand(d[\rideBell],1),Prand(d[\ride],1)],[0.99,0.01],inf),
	//\rate, 1.03,
	\dur, Pseq([~tick,~tock],inf)/Pwrand([1,Pseq([2,2,2,2],1)/*,Pseq([3,3,3,3,3,3],1)*/,Pseq([4,4,4,4],1)],[0.94,0.2,0.2,0.2],inf),
	\lag, 0.02,
	\amp, 3*Pseq([
		1,1,1,
		], inf)*Pseq([Prand([0.5,0.3,0.1],[0.5,0.1],1),1],inf)*Pwrand([1,0],[0.99,0.01],inf),
		\pan, 0.5,
	)
).play;

Pdef(\hatFoot,
	Pbind(
	//\instrument, \kick2,
	\instrument, \bufPlay,
	\bufnum, Prand(d[\hatFoot],inf),
	\dur, Pseq([~tick,~tock],inf),
	\lag, 0.02,
	\pan, -0.5,
	\amp, 6*Pseq([
		0,0,0, 0,0,0, 1,0,0,
		0,0,0, 0,0,0, 0,0,0,
		0,0,0, 0,0,0, 1,0,0,
		0,0,0, 0,0,0, 0,0,0,
	], inf)*Pseq([1],inf),
	)
).play;

/*
Pdef(\ride,
	Pbind(
	//\instrument, \kick2,
	\instrument, \bufPlay,
	\bufnum, Prand(d[\ride],inf),
	\dur, Pseq([~tick,~tock],inf),
	\lag, 0.02,
	\amp, 4*Pseq([
		1,1,1, 1,1,0, 1,1,0,
	], inf)*Pseq([0.2,1],inf),
	\pan, -0.5,
	)
).play;
*/

Pdef(\arpegio,
	Pbind(
	//\instrument, \clap,
	\instrument, \Colleen3,
		\octave, Prand([6,5,6],inf)+[0,1],
		\dur, Pseq([~tick,~tock],inf),
	\degree, Pseq([0,0,0, 2,2,2, 4,4,4, 7,7,7, 4,4,4, 2,2,2,],inf)+
		Pseq([
			Pseq([0],18*4),

			Pseq([0],18*2),
			Pseq([1],18*2),
			Pseq([0],18*2),
			Pseq([2],18*1),
			Pseq([1],18*1),

			Pseq([0],18*2),
			Pseq([1],18*2),
			Pseq([0],18*2),
			Pseq([2],18*1),
			Pseq([1],18*1),

			Pseq([1],27),
			Pseq([1],3),
			Pseq([2],3),
			Pseq([0],3),
			Pseq([1],18*2),
			Pseq([0],18*1),
			Pseq([3],18*1),
			Pseq([2],18*2),

			Pseq([1],27),
			Pseq([1],3),
			Pseq([2],3),
			Pseq([0],3),
			Pseq([1],18*2),
			Pseq([0],18*1),
			Pseq([3],18*1),
			Pseq([2],18*2),

			Pseq([0],18*2),
			Pseq([1],18*2),
			Pseq([0],18*2),
			Pseq([2],18*1),
			Pseq([1],18*1),

			Pseq([0],18*4),
		],1),
	\scale, ~scale,
	\lag, 0.02,
	\amp, 1.3*Pseq([
			1,1,1,
		], inf),
		\pan, [-1,1],
	)
).play;


)

//TempoClock

(
v = Main.elapsedTime.ceil;
t = TempoClock(~bpm/60, 0, v);

t.schedAbs(0, {//
	Pdef(\vocals).play(quant: 0.1);
	Pdef(\kick).play(quant: 0.1);
	Pdef(\snare).play(quant: 0.1);
	Pdef(\hat).play(quant: 0.1);
	Pdef(\hatFoot).play(quant: 0.1);
	Pdef(\arpegio).play(quant: 0.1);
});
)

