s.boot;
s.record;
s.stopRecording;

//variables

(
~scale = Scale.mixolydian(\just);

~melody = 8.collect{12.rand};//[ 10, 5, 2, 7, 9, 11, 10, 8 ],[ 3, 7, 0, 10, 4, 1, 1, 11 ],[ 2, 9, 4, 0, 4, 4, 10, 5 ]

~root = 728;

~path = PathName(thisProcess.nowExecutingPath).parentPath; //path for buffers
)

//loading buffers and sample dictionary

(
d = Dictionary.new;
d.add(\hatClosed -> PathName(~path++"aksel drum samples/hatClosed/").entries.collect({
arg sf;
Buffer.read(s, sf.fullPath);
});
);
d.add(\hatFoot -> PathName(~path++"aksel drum samples/hatFoot/").entries.collect({
arg sf;
Buffer.read(s, sf.fullPath);
});
);
d.add(\kickLoud -> PathName(~path++"aksel drum samples/kickLoud/").entries.collect({
arg sf;
Buffer.read(s, sf.fullPath);
});
);
d.add(\kickSoft -> PathName(~path++"aksel drum samples/kickSoft/").entries.collect({
arg sf;
Buffer.read(s, sf.fullPath);
});
);
d.add(\snareDead -> PathName(~path++"aksel drum samples/snareDead/").entries.collect({
arg sf;
Buffer.read(s, sf.fullPath);
});
);
d.add(\snareRing -> PathName(~path++"aksel drum samples/snareRing/").entries.collect({
arg sf;
Buffer.read(s, sf.fullPath);
});
);
d.add(\ride ->	PathName(~path++"aksel drum samples/ride/").entries.collect({
arg sf;
Buffer.read(s, sf.fullPath);
});
);
d.add(\rideBell -> PathName(~path++"aksel drum samples/rideBell/").entries.collect({
arg sf;
Buffer.read(s, sf.fullPath);
});
);
d.add(\floorTom -> PathName(~path++"aksel drum samples/floorTom/").entries.collect({
arg sf;
Buffer.read(s, sf.fullPath);
});
);
d.add(\crash -> PathName(~path++"aksel drum samples/crash/").entries.collect({
arg sf;
Buffer.read(s, sf.fullPath);
});
);
)


//synths

(
SynthDef.new(\bufPlay, {
arg bufnum, rate=1, amp=1, pan=0;
var sig;
sig = PlayBuf.ar(1, bufnum, BufRateScale.ir(bufnum) * rate, doneAction:2);
sig = sig * amp;// * ~masterGain;
sig = Pan2.ar(sig, pan);
Out.ar(0, sig);
}).add;
)

(
SynthDef.new(\Shai, {
arg freq=440, atk=1, rel=8, amp=0.1, dur=0.2, beats=1;
var sig, env;
freq = freq * (~root/440);
sig = Mix.new(
Array.fill(99, { SinOsc.ar(freq + Line.kr(1536.0.rand,freq*1.5,8), 0, 0.05) })
);
env = EnvGen.kr(Env.new([0,1,0],[atk,rel],[1,-1]),doneAction:2);
sig = sig*env*amp;
Out.ar(0, [sig, sig]);
}).play;
)

(
SynthDef.new(\Zeynep, {
arg freq=440, atk=1, rel=4, amp=1, dur=0.2, beats=1;
var sig, env;
freq = freq*(~root/440);
sig = Resonz.ar(WhiteNoise.ar(0.5), freq, XLine.kr(0.1, 0.001, dur*beats))*50;
env = EnvGen.kr(Env.new([0,0.03,0.1,5,0],[atk,atk,dur,rel],[1,-1]),doneAction:2);
sig = (sig*env*amp).tanh;
Out.ar(0, [sig, sig]);
}).add;
)

(
SynthDef.new(\Oliver, {
arg freq=432, pan=0, atk=0.01, rel=2.66, harmonics=4, dur=0.2, beats=3, amp=1;
var sig, env;
freq = freq * (~root/440);
sig = Blip.ar(freq,Line.kr(1,harmonics,dur*beats),0.5);
env = EnvGen.kr(Env.new([0,1,0],[atk,rel],[1,-1]),doneAction:2);
sig = sig*env*amp;
sig = Pan2.ar(sig,pan);
Out.ar(0, sig)
//Out.ar(0, [sig, sig]);
}).add;
)

(
SynthDef.new(\Russ, {
arg freq=440, atk=1, rel=8, amp=1, dur=0.2, beats=1;
var sig, env;
freq = freq * (~root/440);
sig = Mix({|k|k=k+1/2;2/k*Mix({|i|i=i+1;Blip.ar(i*((freq/2)+LFNoise2.kr(2)*k),XLine.kr(120,2,0.6),1/(i/a=1)/9)}!3)}!15)!2*a;
env = EnvGen.kr(Env.new([0,1,0],[atk,rel],[1,-1]),doneAction:2);
sig = sig*env*amp;
Out.ar(0, [sig, sig]);
}).add;
)

(
SynthDef(\kickBoom,{
arg amp=1, gain=1.1, dur=0.4;
var env, sig;
env = EnvGen.kr(Env.perc(0.0014, dur, 1, -5), 1, doneAction:2);
sig = (SinOsc.ar(180/4) + SinOsc.ar(330/4) + LFTri.ar(175/4) + LFTri.ar(224/4) + BrownNoise.ar(0.1)) * env * amp;
sig = LPF.ar(sig, 500);
sig = sig + HPF.ar(EnvGen.ar(Env.perc(0.001,0.001,0.5)),500);
sig = sig * gain;
sig = sig.softclip * 1;
Out.ar(0, [sig,sig]);
}).add;
)

//paterns

(
Pdef(\thousand,
Pbind(
\instrument, \Shai,
\scale, ~scale,
\octave, Pseq([3,4,5],inf),
\degree, Pseq([0,0],inf),
\atk, 1,
\dur, 16,
\rel, 8,
\amp, 0.5*Prand([0.03,0.02,0.04,0.01],inf),
\pan, Prand([-1,1],inf),
)
).play;

Pdef(\thousand2,
Pbind(
\instrument, \Shai,
\scale, ~scale,
\octave, Pseq([3,4,5],inf),
\degree, Pseq([0,0],inf),
\atk, 1,
\dur, 16,
\rel, 8,
\amp, 0.5*Prand([0.03,0.02,0.04,0.01],inf),
\pan, Prand([-1,1],inf),
)
).play;

Pdef(\command,
Pbind(
\instrument, \Oliver,
\scale, ~scale,
\octave, [3,3.6,4,5],
\degree, Pseq(~melody,inf),
\atk, 1,
\dur, 8,
\rel, 4,
\amp, Prand([0.1,0.05,0.15,0.2],inf),
\pan, -1,
)
).play;

Pdef(\pure,
Pbind(
\instrument, \Oliver,
\degree, Pseq(~melody,inf),
\dur, Pseq([5,1,5,1],inf),
\strum, Pkey(\dur)/4,
\amp, Prand([0.1,0.05,0.15,0.2],inf),
\pan, Prand([-1,1],inf),
)
).play;

Pdef(\unstuck,
Pbind(
\instrument, \Oliver,
\scale, ~scale,
\octave, [3,4,4.6,5],
\degree, Pseq([4,0],inf),
\atk, 1,
\dur, 8,
\rel, 4,
\pan, 1,
\amp, Prand([0.03,0.02,0.04,0.01],inf),
)
).play;

Pdef(\jewel,
Pbind(
\instrument, \Oliver,
\scale, ~scale,
\octave, [3],
\degree, Pseq([4,0],inf),
\atk, 1,
\dur, 8,
\rel, 8,
\amp, 2*Prand([0.03,0.02,0.04,0.01],inf),
\pan, Prand([-1,1],inf),
)
).play;

Pdef(\bass,
Pbind(
\instrument, \Oliver,
\octave, [2],
\degree, Pseq(~melody,inf),
\dur, Pseq([4,4,4,4,1,1,1,1],inf),
\strum, Pkey(\dur)/4,
\amp, 1/(Pseq(~melody,inf)+1),
)
).play;

Pdef(\root,
Pbind(
//\instrument, \kickBoom,
\instrument, \bufPlay,
\bufnum, Prand(d[\kickLoud],inf),
\dur, 4/3,
\amp, 0.6,
)
).play;

Pdef(\snare,
Pbind(
//\instrument, \kickBoom,
\instrument, \bufPlay,
\bufnum, Prand(d[\snareDead],inf),
\dur, 8/3,
\lag, 4/3,
\amp, 0.4,
)
).play;

Pdef(\hatFoot,
Pbind(
//\instrument, \kickBoom,
\instrument, \bufPlay,
\bufnum, Prand(d[\hatFoot],inf),
\dur, 8/3,
\lag, 2/3,
\pan, -0.5,
\amp, 0.4,
)
).play;

Pdef(\ride,
Pbind(
//\instrument, \kickBoom,
\instrument, \bufPlay,
\bufnum, Prand(d[\ride],inf),
\dur, 1/6*Pseq([1.1,0.9],inf),
\lag, 0,
\pan, 0.5,
\amp, 0.7*Pseq([0.4,0.1],inf),
)
).play;
)

//tempoclock

(
v = Main.elapsedTime.ceil;
t = TempoClock(1/6, 0, v);

t.schedAbs(0, {
Pdef(\thousand).play(quant: 0.1);
Pdef(\root).play(quant: 0.1);

});

t.schedAbs(4, {
Pdef(\thousand2).play(quant: 0.1);
Pdef(\snare).play(quant: 0.1);
Pdef(\command).play(quant: 0.1);
});

t.schedAbs(2*4, {
Pdef(\hatFoot).play(quant: 0.1);
Pdef(\pure).play(quant: 0.1);
});

t.schedAbs(3*4, {
Pdef(\jewl).play(quant: 0.1);
Pdef(\unstuck).play(quant: 0.1);
});

t.schedAbs(4*4, {
Pdef(\ride).play(quant: 0.1);
Pdef(\bass).play(quant: 0.1);
});

t.schedAbs(5*4, {
Pdef(\thousand).stop;
});

t.schedAbs(6*4, {
Pdef(\command).stop;
});

t.schedAbs(7*4, {
Pdef(\ride).stop;
Pdef(\snare).stop;
Pdef(\unstuck).stop;
});

t.schedAbs(8*4, {
Pdef(\jewel).stop;
Pdef(\bass).stop;
Pdef(\root).stop;
});

t.schedAbs(9*4, {
Pdef(\hatFoot).stop;
Pdef(\thousand2).stop;
Pdef(\pure).stop;
});
)
