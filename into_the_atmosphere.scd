s.boot;

//variables
(
~bpm=70;
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

~masterGain = 0.2;

~scale = Scale.ionian(\just);

~path = PathName(thisProcess.nowExecutingPath).parentPath; //path for buffers
)

//loading vocal stem buffer

(
~intoTheAtmosphereVox = Buffer.readChannel(s,~path++"yfree_buffers_stems/YFREE into the atmosphere (01) vox.wav",0,-1,1);
)

//loading synth sample buffers

(
~sk1 = Buffer.readChannel(s,~path++"yfree_buffers_samples/yfree laew sk1.wav",0,-1,1);

~deirdreOoo = Buffer.readChannel(s,~path++"yfree_buffers_samples/yfree (deirdre ooo vowel).wav",0,-1,1);

~emilyEee = Buffer.readChannel(s,~path++"yfree_buffers_samples/yfree (emily e vowel).wav",0,-1,1);

~saraOw = Buffer.readChannel(s,~path++"yfree_buffers_samples/yfree (sara ow).wav",0,-1,1);
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

//synthdef

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
SynthDef(\intoTheAtmosphereVox, {
	arg out = 0, amp=1;
	var sig, env;
	b = ~intoTheAtmosphereVox;
	sig = 5*PlayBuf.ar(1, b, 1, doneAction:2)*amp*2*~masterGain;
	Out.ar(out, [sig,sig])
}).play;
)



(
SynthDef(\deirdre, {
	arg out = 0, bufnum = 0, amp=0.5, atk=0.01, rel=2, freq=440, pan=0.0;
	var scaledRate, sig, env;
	env = EnvGen.kr(Env.new([0,1,0],[atk,rel],[1,-1]),doneAction:2);
	b = ~deirdreOoo;
	rel= BufDur.kr(b);
	scaledRate = BufRateScale.kr(b)*(freq/620);
	amp = amp*(log2(440)/log2(freq))*0.5;
	sig = PlayBuf.ar(1, b, scaledRate, doneAction:0)*amp*2;
	sig = sig * env;
	sig = Pan2.ar(sig,pan);
	Out.ar(out, sig)
}).play;
)

(
SynthDef(\emily, {
	arg out = 0, bufnum = 0, amp=0.5, atk=0.01, rel=2, freq=440, pan=0.0;
	var scaledRate, sig, env;
	env = EnvGen.kr(Env.new([0,1,0],[atk,rel],[1,-1]),doneAction:2);
	b = ~emilyEee;
	rel= BufDur.kr(b);
	scaledRate = BufRateScale.kr(b)*(freq/750);
	amp = amp*(log2(440)/log2(freq))*0.5;
	sig = PlayBuf.ar(1, b, scaledRate, doneAction:0)*amp*1.5;
	sig = sig * env;
	sig = Pan2.ar(sig,pan);
	Out.ar(out, sig)
}).play;
)

(
SynthDef(\sara, {
	arg out = 0, bufnum = 0, amp=0.5, atk=0.01, rel=2, freq=440, pan=0.0;
	var scaledRate, sig, env;
	env = EnvGen.kr(Env.new([0,1,0],[atk,rel],[1,-1]),doneAction:2);
	b = ~saraOw;
	rel= BufDur.kr(b);
	scaledRate = BufRateScale.kr(b)*(freq/595);
	amp = amp*(log2(440)/log2(freq))*0.5;
	sig = PlayBuf.ar(1, b, scaledRate, doneAction:0)*amp;
	sig =
	sig = sig * env;
	sig = Pan2.ar(sig,pan);
	Out.ar(out, sig)
}).play;
)

(
SynthDef(\sk1, {
	arg out = 0, bufnum = 0, amp=0.5, atk=0.01, rel=2, freq=440, pan=0.0;
	var scaledRate, sig, env;
	env = EnvGen.kr(Env.new([0,1,0],[atk,rel],[1,-1]),doneAction:2);
	b = ~sk1;
	rel= BufDur.kr(b);
	scaledRate = BufRateScale.kr(b)*(freq/440);
	amp = amp*(log2(440)/log2(freq));
	sig = PlayBuf.ar(1, b, scaledRate, doneAction:0)*amp;
	sig = sig * env;
	sig = Pan2.ar(sig,pan);
	Out.ar(out, sig)
}).play;
)





//Patterns

(

Pdef(\intoTheAtmosphereVox,
	Pbind(
		\instrument, \intoTheAtmosphereVox,
		//\lag, ~lagKick+0.15,
		\amp, ~masterGain*2*Pseq([1],1),
	)
).play;

Pdef(\leadR,
	Pbind(
	\instrument, \emily,
	\dur, Pseq([~tick,~tock],inf),
	\octave, 6,
	\degree, Pseq([
			7,7,7,7, 6,6,6,6, 6,6,6,6, 5,5,5,5,
			5,5,5,5, 4,4,4,4, 4,4,4,4, 3,3,3,3,
			7,7,7,7, 6,6,6,6, 6,6,6,6, 5,5,5,5,
			5,5,7,5, 4,4,4,4, 4,4,4,4, 3,3,3,3,

		],inf)+1,
	\amp, 0.2*Pseq([
			1,0,1,0, 0,0,1,0, 0,0,1,0, 0,0,1,0,
			0,0,1,0, 0,0,1,0, 0,0,1,0, 0,0,1,0,
		],inf),
	\pan, -1,
	)
).play;

Pdef(\leadL,
	Pbind(
	\instrument, \deirdre,
	\dur, Pseq([~tick,~tock],inf),
	\octave, 6,
	\degree, Pseq([
			7,7,7,7, 6,6,6,6, 6,6,6,6, 5,5,5,5,
			5,5,5,5, 4,4,4,4, 4,4,4,4, 3,3,3,3,
			7,7,7,7, 6,6,6,6, 6,6,6,6, 5,5,5,5,
			5,5,7,5, 4,4,4,4, 4,4,4,4, 3,3,3,3,

		],inf)+1,
	\amp, 0.2*Pseq([
			1,0,1,0, 0,0,1,0, 0,0,1,0, 0,0,1,0,
			0,0,1,0, 0,0,1,0, 0,0,1,0, 0,0,1,0,
		],inf),
	\pan, 1,
	)
).play;

Pdef(\kick,
	Pbind(
		//\instrument, Pseq([\rootsKick,\gabeKick,],inf),
		\instrument, \bufPlay,
		\bufnum, Prand(d[\kickLoud],inf),
		//\lag, ~lagKick,
		\dur, Pseq([~tick,~tock],inf),
		\amp, 5*Pseq([1,0,0,0,0,0,0,1,Pshuf([1,0,],1),0,0,0,Pshuf([0,1,0,],1),0,0,1,0, Pshuf([0,0,0,1,],1), 1,0,1,0,Pshuf([0,1,0,0,],1),], inf)*
		Pseq([1,1,1,1, 0,1,1,1, 1,1,1,1, 0,1,1,1,
			1,1,1,1, 0,1,1,1, 1,1,1,1, 0,1,1,1,
			1,1,1,1, 0,1,1,1, 1,1,1,1, 0,1,1,1,
			1,1,1,1, 0,1,1,1, 1,1,1,1, 0,0,1,1,
		],inf)*Pseq([1,0.6],inf),
	)
).play;

Pdef(\hatFoot,
	Pbind(
		//\instrument, Pseq([\gabeSnare,\rootsSnare],inf),
		\instrument, \bufPlay,
		\bufnum, Prand(d[\hatFoot],inf),
		\dur, Pseq([~tick,~tock],inf),
		//\lag, ~lagSnare,
		\pan, -0.5,
		\amp, 4*Pseq([
			0,0,0,0, 0,0,1,0,
			0,0,0,0, 0,0,0,0,
			0,0,0,0, 0,0,0,0,
			0,0,0,0, 0,0,1,0,
		],inf),
	)
).play;

Pdef(\ride,
	Pbind(
	//\instrument, Pseq([\rootsHat,\gabeHat,],inf),
	\instrument, \bufPlay,
		\bufnum, Pseq([Prand(d[\ride],17),Prand(d[\rideBell],1)],inf),
	//\lag, ~lagHat,
	\dur, Pseq([~tick,~tock],inf),
	\pan, 0.8,
	\amp, 8*Pseq([
		0,0,1,0, 0,0,1,0, 0,0,1,0, 0,1,0,1,
		1,1,0,1, 0,1,1,0, 0,1,0,1, Pshuf([0,0,1,1,],1),
		0,0,1,0, 0,0,1,0, 0,0,1,0, 0,1,0,1,
			1,1,0,1, 0,1,1,0, Pshuf([0,0,1,1,],2)*Pseq([0.3,1],inf),
	], inf),
	)
).play;

Pdef(\snareDead,
	Pbind(
	//\instrument, \rootsRim,
	\instrument, \bufPlay,
	\bufnum, Prand(d[\snareDead],inf),
	//\lag, ~lagClap,
	\dur, Pseq([~tick,~tock],inf),
	\amp, 3*Pseq([
		0,0,0,0, 1,0,0,0, 0,0,0,0, 1,0,0,0,
		0,0,0,0, 1,0,0,0, 0,0,0,0, 1,0,0,0,
		0,0,0,0, 1,0,0,0, 0,0,0,0, 1,0,0,0,
		0,0,0,0, 1,0,0,0, 0,0,0,Pshuf([0, 1,0,],1),0,0,
	], inf),
	)
).play;

Pdef(\deirdre,
	Pbind(
	\instrument, \deirdre,
	\lag, ~lagSnare,
	\dur, Pseq([~tick,~tock],inf),
	\octave, Pseq([5,6,],inf),
	\degree, Pseq([0,2,4,6,8],inf),
		\amp, 0.2*Pseq([0.5,1.5],inf)*Pseq([
		1,0,0,0, 0,0,0,1, Pshuf([1,0,],1),0,0, 0,0,1,0,
		0,0,1,0, Pshuf([0,0,0,1,],1), 1,0,1,0, 0,1,0,0,
	], inf),
	\pan, 1,
	\detune, Pbrown(0,10,10,inf),
	)
).play;

Pdef(\emily,
	Pbind(
	\instrument, \emily,
	\lag, ~lagKick,
	\dur, Pseq([~tick,~tock],inf),
	\octave, Pseq([5,6],inf),
	\degree, Pseq([0,2,4,6,8],inf),
	\amp, 0.1*Pseq([0.5,1],inf)*Pseq([
		1,0,0,0, 0,0,0,1, Pshuf([1,0,],1),0,0, 0,0,1,0,
		0,0,1,0, Pshuf([0,0,0,1,],1), 1,0,1,0, 0,1,0,0,
	], inf),
	\pan, -1,
	)
).play;

Pdef(\saraL,
	Pbind(
	\instrument, \sara,
	\dur, ~step*32,
	\lag, ~lagSnare,
	\octave, 4,
	\degree, Pseq([4,0],inf),
	\amp, 0.8,
	\pan, 1,
	)
).play;

Pdef(\saraR,
	Pbind(
	\instrument, \sara,
	\dur, ~step*32,
	\octave, 4,
	\lag, -0.1,
	\degree, Pseq([4,0],inf),
	\amp, 0.8,
	\pan, -1,
	)
).play;

Pdef(\sk1,
	Pbind(
	\instrument, \sk1,
	\dur, ~step*32,
		\octave, [3,4],
	\lag, -0.1,
	\degree, Pseq([4,0],inf),
	\amp, 0.8,
	\pan, 0,
	)
).play;
)

//tempo clock

(
v = Main.elapsedTime.ceil;
t = TempoClock(~bpm/60, 0, v);

t.schedAbs(0, { //intro

	Pdef(\intoTheAtmosphereVox).play(quant: 0.1);
	Pdef(\intoTheAtmosphereVox).play(quant: 0.1);

	Pdef(\saraR).play(quant: 0.1);
	Pdef(\saraL).play(quant: 0.1);
	Pdef(\sk1).play(quant: 0.1);

	Pdef(\kick).play(quant: 0.1);
	Pdef(\snareDead).play(quant: 0.1);
	Pdef(\hatFoot).play(quant: 0.1);
	Pdef(\ride).play(quant: 0.1);

	Pdef(\emily).play(quant: 0.1);
	Pdef(\deirdre).play(quant: 0.1);

	Pdef(\leadR).play(quant: 0.1);
	Pdef(\leadL).play(quant: 0.1);

});

t.schedAbs(0.5*8, { //intro

	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~intoTheAtmosphereVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.32;//0.13,0.17,0.21,0.29,0.32,0.33,0.44,0.45,0.56,0.6,0.68,0.81,0.83,0.84,0.87,0.88,0.89,0.95,0.96,0.97,0.99,
		pan = 0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.1,(1)), pos, 2 * 120/70, pan, 0.6);
	}.play;

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~intoTheAtmosphereVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.32;//
		pan = -0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.1,(1)), pos, 2 * 120/70, pan, 0.6);
	}.play;

});

t.schedAbs(1*8, { //intro

	x.free;
	y.free;

});

t.schedAbs(1.5*8-0.5, { //intro

	x.free;
	y.free;

	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~intoTheAtmosphereVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.3205;//0.13,0.17,0.21,0.29,0.32,0.33,0.44,0.45,0.56,0.6,0.68,0.81,0.83,0.84,0.87,0.88,0.89,0.95,0.96,0.97,0.99,
		pan = 0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.1,(-1)), pos, 2 * 120/70, pan, 0.6);
	}.play;

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~intoTheAtmosphereVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.3205;//0.21
		pan = -0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.1,(-1)), pos, 2 * 120/70, pan, 0.6);
	}.play;

});

t.schedAbs(2*8, { //they turned the corner

	Pdef(\leadR).stop;
	Pdef(\leadL).stop;

	Pdef(\emily).stop;
	Pdef(\deirdre).stop;

	x.free;
	y.free;

});

t.schedAbs(3*8, { //and nearly collided

});

t.schedAbs(3.5*8, { //...

	x.free;
	y.free;

	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~intoTheAtmosphereVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.44;//0.13,0.17,0.21,0.29,0.32,0.33,0.44,0.45,0.56,0.6,0.68,0.81,0.83,0.84,0.87,0.88,0.89,0.95,0.96,0.97,0.99,
		pan = 0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.1,(1)), pos, 2 * 120/70, pan, 0.6);
	}.play;

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~intoTheAtmosphereVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.44;//0.21
		pan = -0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.1,(1)), pos, 2 * 120/70, pan, 0.6);
	}.play;

});

t.schedAbs(4*8, { //apologies flew

	x.free;
	y.free;

});


t.schedAbs(4.4*8, { //...

	x.free;
	y.free;

});

t.schedAbs(5*8, { //but just one stepped over

	x.free;
	y.free;

});

t.schedAbs(5.5*8, { //...

	x.free;
	y.free;

	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~intoTheAtmosphereVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.21;//0.13,0.17,0.21,0.29,0.32,0.33,0.44,0.45,0.56,0.6,0.68,0.81,0.83,0.84,0.87,0.88,0.89,0.95,0.96,0.97,0.99,
		pan = 0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.1,(1)), pos, 2 * 120/70, pan, 0.6);
	}.play;

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~intoTheAtmosphereVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.21;//over
		pan = -0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.1,(1)), pos, 2 * 120/70, pan, 0.6);
	}.play;

});

t.schedAbs(6*8, { //they both kept walking

	Pdef(\emily).play(quant: 0.1);
	Pdef(\deirdre).play(quant: 0.1);

	x.free;
	y.free;

});

t.schedAbs(7*8, { //and neither looked backwards

});


t.schedAbs(7.5*8-2, { //...

	Pdef(\emily).stop;
	Pdef(\deirdre).stop;

	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~intoTheAtmosphereVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.13;//0.13,0.17,0.21,0.29,0.32,0.33,0.44,0.45,0.56,0.6,0.68,0.81,0.83,0.84,0.87,0.88,0.89,0.95,0.96,0.97,0.99,
		pan = 0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.1,(Line.kr(-1,-0.25,0.5))), pos, 2 * 120/70, pan, 0.6);
	}.play;

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~intoTheAtmosphereVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.13;//0.21
		pan = -0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.1,(Line.kr(-1,-0.25,0.5))), pos, 2 * 120/70, pan, 0.6);
	}.play;

});

t.schedAbs(8*8, { //but one now worried

	x.free;
	y.free;

});

t.schedAbs(9*8, { //the other was bothered

});

t.schedAbs(9.5*8, { //...

});

t.schedAbs(10*8, { //they turned the corner

	x.free;
	y.free;

});

t.schedAbs(11*8, { //and nearly collided

});

t.schedAbs(11.5*8, { //...

	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~intoTheAtmosphereVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.127;//0.13,0.17,0.21,0.29,0.32,0.33,0.44,0.45,0.56,0.6,0.68,0.81,0.83,0.84,0.87,0.88,0.89,0.95,0.96,0.97,0.99,
		pan = 0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.1,(1)), pos, 2 * 120/70, pan, 0.6);
	}.play;

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~intoTheAtmosphereVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.127;//0.21
		pan = -0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.1,(1)), pos, 2 * 120/70, pan, 0.6);
	}.play;

});


t.schedAbs(12*8, { //apologies flew

	x.free;
	y.free;

});

t.schedAbs(12.5*8, { //...

});


t.schedAbs(13*8, { //but just two feet stayed planted

	x.free;
	y.free;

});

t.schedAbs(13.5*8, { //...

	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~intoTheAtmosphereVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.95;//0.13,0.17,0.21,0.29,0.32,0.33,0.44,0.45,0.56,0.6,0.68,0.81,0.83,0.84,0.87,0.88,0.89,0.95,0.96,0.97,0.99,
		pan = 0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,(1)), pos, 2 * 120/70, pan, 0.6);
	}.play;

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~intoTheAtmosphereVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.95;//0.21
		pan = -0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,(1)), pos, 2 * 120/70, pan, 0.6);
	}.play;

});

t.schedAbs(14*8, { //they both kept walking

	Pdef(\emily).play(quant: 0.1);
	Pdef(\deirdre).play(quant: 0.1);

	x.free;
	y.free;

});

t.schedAbs(15*8, { //and neither looked backwards

});

t.schedAbs(15.5*8-2, { //...

	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~intoTheAtmosphereVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.95;//0.13,0.17,0.21,0.29,0.32,0.33,0.44,0.45,0.56,0.6,0.68,0.81,0.83,0.84,0.87,0.88,0.89,0.95,0.96,0.97,0.99,
		pan = 0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,(Line.kr(-1,-0.25,0.5))), pos, 2 * 120/70, pan, 0.6);
	}.play;

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~intoTheAtmosphereVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.95;//0.21
		pan = -0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.05,(Line.kr(-1,-0.25,0.5))), pos, 2 * 120/70, pan, 0.6);
	}.play;

});

t.schedAbs(16*8, { //one didn't notice

	x.free;
	y.free;

});

t.schedAbs(17*8, { //what the other had granted

});

t.schedAbs(18*8, { //And he felt open space

	Pdef(\emily).stop;
	Pdef(\deirdre).stop;

	x.free;
	y.free;

	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~intoTheAtmosphereVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.2;//0.21
		pan = -0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.08,(-1.48)), pos, XLine.kr(0.1/70,100/70,3), pan, 0.6);
	}.play;

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~intoTheAtmosphereVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.2;//0.21
		pan = 0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.08,(-1.48)), pos, XLine.kr(0.1/70,100/70,2), pan, 0.6);
	}.play;

});

t.schedAbs(19*8, { //in need of taking up

	x.free;
	y.free;

	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~intoTheAtmosphereVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.2;//0.21
		pan = -0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.08,(-1.62)), pos, XLine.kr(0.01/70,100/70,3), pan, 0.6);
	}.play;

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~intoTheAtmosphereVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.2;//0.21
		pan = 0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.08,(-1.63)), pos, XLine.kr(0.001/70,100/70,2), pan, 0.6);
	}.play;

});

t.schedAbs(20*8, { //and she felt filled up space

	x.free;
	y.free;

	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~intoTheAtmosphereVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.2;//0.21
		pan = -0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.08,(-1.8)), pos, XLine.kr(0.001/70,100/70,2), pan, 0.6);
	}.play;

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~intoTheAtmosphereVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.2;//0.21
		pan = 0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.08,(-1.8)), pos, XLine.kr(0.01/70,100/70,3), pan, 0.6);
	}.play;

});

t.schedAbs(21*8, { //in need of clearing out

	x.free;
	y.free;

	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~intoTheAtmosphereVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.2;//0.21
		pan = -0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.03,(-2)), pos, XLine.kr(0.001/70,100/70,3), pan, 0.6);
	}.play;

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~intoTheAtmosphereVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.2;//0.21
		pan = 0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.04,(-2)), pos, XLine.kr(0.001/70,100/70,2), pan, 0.6);
	}.play;

});

t.schedAbs(22*8, { //and she was Trying hard to blend into the atmosphere

	x.free;
	y.free;

	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~intoTheAtmosphereVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.2;//0.21
		pan = -0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.03,(-1.5)), pos, XLine.kr(0.001/70,100000/70,7), pan, 0.6);
	}.play;

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~intoTheAtmosphereVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.2;//0.21
		pan = 0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.04,(-1.5)), pos, XLine.kr(0.001/70,100000/70,8), pan, 0.6);
	}.play;

});

t.schedAbs(23*8, { //

});

t.schedAbs(24*8, { //and he was Pushing clouds aside so he could fly

	x.free;
	y.free;

	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~intoTheAtmosphereVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.44;//0.21
		pan = -0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.03,(-1)), pos, XLine.kr(0.001/70,100000/70,7), pan, 0.6);
	}.play;

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~intoTheAtmosphereVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.44;//0.21
		pan = 0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.04,(-1)), pos, XLine.kr(0.001/70,100000/70,8), pan, 0.6);
	}.play;

});

t.schedAbs(26*8, { //

	x.free;
	y.free;

	Pdef(\leadR).play(quant: 0.1);
	Pdef(\leadL).play(quant: 0.1);

	Pdef(\emily).play(quant: 0.1);
	Pdef(\deirdre).play(quant: 0.1);

	x = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~intoTheAtmosphereVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.44;//0.21
		pan = -0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.03,(-1)), pos, XLine.kr(0.001/70,100000/70,7), pan, 0.6);
	}.play;

	y = {//granular synth
		var buf, trate, dur, clk, pos, pan, env;
		buf = ~intoTheAtmosphereVox;
		trate =PinkNoise.kr(2,200);
		dur = 10;
		clk = Impulse.kr(trate);
		pos = BufDur.kr(buf)*0.44;//0.21
		pan = 0.9;
		~masterGain*TGrains.ar(2, clk, buf, PinkNoise.kr(0.04,(1)), pos, XLine.kr(0.001/70,100000/70,8), pan, 0.6);
	}.play;

});

)

