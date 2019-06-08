s.boot;
s.record;
s.stopRecording;

//variables

(
~bpm=115/2;
~swing=0.05;

~step = (60/1)*(1/~bpm)*(1/4);
~tick = ~step+(~swing*~step);
~tock =
~step-(~swing*~step);
~lagKick=(0)*~step/256;
~lagSnare=(0)*~step/256;
~lagHat=(1)*~step/1600;
~lagClap=(0)*~step/256;

~masterGain = 0.1;

~scale = Scale.chromatic;

~path = PathName(thisProcess.nowExecutingPath).parentPath; //path for buffers
)

//loading stem buffers

(
~bridgeTooFar = Buffer.readChannel(s,~path++"yfree buffers stems/180210 bridge too far (vox).wav",0,-1,1);
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

//SynthDefs

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
SynthDef(\bridgeTooFarVox, {
	arg out = 0, amp=1;
	var sig, env;
	b = ~bridgeTooFar;
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
	sig = sig * gain * 2;
	sig = sig.softclip * amp;
	Out.ar(0, [sig,sig]);
}).play;
)

(
SynthDef(\kick,{
	arg startFreq=60, endFreq=20, decay=4, lowpass=1000, amp=1, noiseAmp=0.01, gain=1, dur=0.8;
	var sig, env, freq;
	freq = XLine.kr(startFreq, endFreq, dur, 1, 0);
	env = EnvGen.kr(Env.perc(0.0014, dur, 1, -5), 1, doneAction:2);
	sig = {(LPF.ar(Ringz.ar(Impulse.ar(0), freq, decay), lowpass) * amp) ! 2};
	sig = sig + LPF.ar((noiseAmp*BrownNoise.ar(1)),lowpass);
	sig = sig * gain;
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
	sig = sig * gain;
	sig = sig.softclip * amp * env;
	Out.ar(0, [sig,sig]);
}).play;
)

(
SynthDef(\snare,{
	arg amp=0.75, freq=120, gain=0.5, dur=0.3;
	var env, sig, snare;
	env = EnvGen.kr(Env.perc(0.001, dur, 1, -9), 1, doneAction:2);
	sig = {(SinOsc.ar(freq) - WhiteNoise.ar(0.5, 0.5))!2};
	sig = sig * gain;
	sig = sig.softclip * amp * env;
	Out.ar(0, [sig,sig]);
}).play;
)

(
SynthDef(\hat,{
	arg amp=2, rel=0.24;
	var env, sig;
	env = EnvGen.kr(Env.perc(0.001, rel, 1, -4), 1, doneAction:2);
	sig = HPF.ar((PinkNoise.ar(1, 0) * env * amp), 4000);
	Out.ar(0, [sig,sig]);
}).play;
)

(
SynthDef.new(\Colleen, {
	arg freq=110, atk=0.2, rel=0.2, amp=1, dur=2, pan = 0, out = -1;
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


//Pdefs

(
Pdef(\bridgeTooFarVox,
	Pbind(
		\instrument, \bridgeTooFarVox,
		\lag, ~lagKick+0.15,
		\amp, ~masterGain*5*Pseq([1],1),
	)
).play;

Pdef(\kick,
	Pbind(
		//\instrument, \kick,
		\instrument, \bufPlay,
		\bufnum, Prand(d[\kickLoud],inf),
		\rate, 1,//0.85,
		\lag, ~lagKick,
		\dur, Pseq([~tick,~tock],inf),
		\amp, ~masterGain*30*Pseq([
			1,0,0,0, 0,0,0,1, 0,0,1,0, 0,0,0,0,
			1,0,0,0, 0,0,1,0, 0,0,0,0, 0,Pshuf([0,Prand([1,0],1),1,],1),
	], inf)*Pseq([1],inf)*Pwrand([Pseq([1],4),Pseq([0],4),],[0.9,0.1],inf),
		\pan, 0,
	)
).play;

Pdef(\ekick,
	Pbind(
		\instrument, \kick,
		\lag, ~lagKick,
		\dur, Pseq([~tick,~tock],inf),
		\amp, ~masterGain*3*Pseq([
			1,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,],inf),
		\pan, 0,
	)
).play;

Pdef(\snare,
	Pbind(
		//\instrument, \snare,
		\instrument, \bufPlay,
		\bufnum, Prand(d[\snareDead],inf),
		\rate, 1,//0.85,
		\lag, ~lagSnare,
		\dur, Pseq([~tick,~tock],inf),
		\amp, ~masterGain*16*Pseq([
			0,0,0,1, 0,0,0,0, 0,0,0,0, 1,0,0,0,
		], inf),
	)
).play;

Pdef(\clap,
	Pbind(
		\instrument, \clap,
		//\instrument, \bufPlay,
		//\bufnum, Prand(d[\snareRing],inf),
		//\rate, 0.72,
		//\freq, 120,
		\lag, ~lagClap,
		\dur, Pseq([~tick,~tock],inf),
		\amp, ~masterGain*1*Pseq([
			0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
			0,0,0,0, 0,0,0,0, 0,0,0,0, 1,0,0,0,
		], inf),
	)
).play;

Pdef(\hat,
	Pbind(
		//\instrument, \hat,
		\instrument, \bufPlay,
		\bufnum, Prand(d[\hatClosed],inf),
		//\freq, 120,
		\lag, ~lagHat,
		\dur, Pseq([~tick,~tock],inf),
		\pan, 0.5,
		\amp, ~masterGain*30*Pseq([
			1,1,1,0, 1,1,1,1, 1,1,1,1, 0,1,1,1,
		], inf)*Pseq([0.6,0.8,0.7,1],inf),
	)
).play;

Pdef(\hatFoot,
	Pbind(
		//\instrument, \hat,
		\instrument, \bufPlay,
		\bufnum, Prand(d[\hatFoot],inf),
		//\freq, 120,
		\lag, ~lagHat,
		\dur, Pseq([~tick,~tock],inf),
		\pan, 0.5,
		\amp, ~masterGain*40*Pseq([0,0,1,0, 0,0,1,0],inf),
	)
).play;

Pdef(\ride,
	Pbind(
		//\instrument, \hat,
		\instrument, \bufPlay,
		\bufnum, Pseq([Prand(d[\ride],5),Prand(d[\rideBell],1)],inf),
		//\freq, 120,
		\lag, ~lagHat,
		\dur, Pseq([~tick,~tock],inf)/2,
		\pan, -0.5,
		\amp, ~masterGain*35*Pseq([
			1,1,1,0, 1,Prand([1,0],1),1,Prand([1,0],1), 1,Prand([1,0],1),1,Prand([1,0],1), 0,Prand([1,0],1),1,1,
		], inf)*Pseq([0.5,1],inf),
	)
).play;

Pdef(\crash,
	Pbind(
		//\instrument, \hat,
		\instrument, \bufPlay,
		\bufnum, Pseq([Prand(d[\crash],5),Prand(d[\rideBell],1)],inf),
		//\freq, 120,
		\lag, ~lagHat,
		\dur, Pseq([~tick,~tock],inf)/2,
		\pan, -0.5,
		\amp, ~masterGain*35*Pseq([
			1,1,1,0, 1,Prand([1,0],1),1,Prand([1,0],1), 1,Prand([1,0],1),1,Prand([1,0],1), 0,Prand([1,0],1),1,1,
		], inf)*Pseq([0.8,0.2],inf),
	)
).play;

Pdef(\bass,
	Pbind(
		\instrument, \Colleen,
		\dur, Pseq([~tick,~tock],inf),
		\lag, 0,
		\scale, ~scale,
		\strum, 0.15,
		\octave, [3,5],
		\degree, Pseq([Pseq([0],16),Pseq([-5],16),],inf)+3,
		\amp, ~masterGain*0.6*Pseq([
			1,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
			1,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
		], inf),
		\pan, 0,
	)
).play;
)


//tempo clock

(
v = Main.elapsedTime.ceil;
t = TempoClock(~bpm/60, 0, v);

t.schedAbs(0, { //verse

	Pbindf(Pdef(\bass),\pan, -0.5, \octave, [2,4,1]).play(quant: 0.1);//[2,3,4,5,6,5,4,3,2]
	Pbindf(Pdef(\bass),\pan, 0.5, \octave, [2,3,2]).play(quant: 0.1);//[2,3,4,5,6,5,4,3,2]

	Pdef(\ekick).play(quant: 0.1);
	Pdef(\kick).play(quant: 0.1);
	Pdef(\snare).play(quant: 0.1);
	Pdef(\hat).play(quant: 0.1);
	Pdef(\hatFoot).play(quant: 0.1);

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~bridgeTooFar;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.429;//0.429,0.735
		pan = 0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,(-1)), pos, 4 * 120/115, pan, 0.05);
	}.play;

	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~bridgeTooFar;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.429;//0.429,0.735
		pan = -0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,(-1)), pos, 4 * 120/115, pan, 0.05);
	}.play;

});


t.schedAbs(1*8, { //chorus pick-up
	Pdef(\bridgeTooFarVox).play(quant: 0.1);
});


t.schedAbs(9*8-2, { //chorus pick-up

	Pdef(\hat).stop;
	Pdef(\hatFoot).stop;
	Pdef(\snare).stop;
	Pdef(\kick).stop;
	x.free;
	y.free;
});

t.schedAbs(9*8, { //chorus

	Pdef(\ekick).stop;
	Pdef(\ekick).play(quant: 0.1);
	Pdef(\kick).play(quant: 0.1);
	Pdef(\ride).play(quant: 0.1);
	Pdef(\hat).play(quant: 0.1);
	Pdef(\hatFoot).play(quant: 0.1);
	Pdef(\snare).play(quant: 0.1);
	Pdef(\clap).play(quant: 0.1);

	w = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~bridgeTooFar;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.739;//0.429,0.735
		pan = 0.8;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.1,(-2)), pos, 8 * 120/115, pan, 0.05);
	}.play;

	v = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~bridgeTooFar;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.739;//0.429,0.735
		pan = -0.8;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.1,(-2)), pos, 8 * 120/115, pan, 0.05);
	}.play;
});

t.schedAbs(13*8, { //verse
	Pdef(\ride).stop;
	Pdef(\clap).stop;
});

t.schedAbs(15*8, { //verse

});

t.schedAbs(17*8, { //verse

});

t.schedAbs(19*8-5, { //chorus pick-up
	Pdef(\ekick).stop;
	Pdef(\hat).stop;
	Pdef(\hatFoot).stop;
	Pdef(\snare).stop;
	Pdef(\kick).stop;
	w.free;
	v.free;
});

t.schedAbs(19*8, { //chorus
	Pdef(\ekick).play(quant: 0.1);
	Pdef(\kick).play(quant: 0.1);
	Pdef(\crash).play(quant: 0.1);
	Pdef(\hat).play(quant: 0.1);
	Pdef(\hatFoot).play(quant: 0.1);
	Pdef(\snare).play(quant: 0.1);
	Pdef(\clap).play(quant: 0.1);

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~bridgeTooFar;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.429;//0.429,0.735
		pan = 0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,(-1)), pos, 4 * 120/115, pan, 0.05);
	}.play;

	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~bridgeTooFar;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.429;//0.429,0.735
		pan = -0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,(-1)), pos, 4 * 120/115, pan, 0.05);
	}.play;

});

t.schedAbs(23*8, { //chorus

	w = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~bridgeTooFar;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.739;//0.429,0.735
		pan = 0.5;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.1,(-2)), pos, 8 * 120/115, pan, 0.045);
	}.play;

	v = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~bridgeTooFar;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.739;//0.429,0.735
		pan = -0.5;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.1,(-2)), pos, 8 * 120/115, pan, 0.045);
	}.play;

});
)