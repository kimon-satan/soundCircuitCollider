
// maybe nice for bottom end ..
//what could go with this ?

(
x.free;
x= {
	var gliss, sig, outer_env, decay, freq;

	freq = MouseY.kr(100,40);
	decay = 0.1;
	gliss = EnvGen.kr(Env.asr(0.2,1,decay),MouseButton.kr(0,1,0), levelScale: 0.5, levelBias: 0.5);

	sig = [LFCub.ar(freq * gliss), LFCub.ar(freq * 1.02 * gliss)];
	sig = sig * 0.5  + ((sig * Saw.ar(freq * 3/2).clip) * 0.5);
	sig = HPF.ar(sig ,MouseX.kr(0,1000));

	outer_env = EnvGen.kr(Env.asr(0.2,1,decay),MouseButton.kr(0,1,lag:0));

	sig * outer_env
}.play;
)

//pretty much the same as swell
(

{
	arg width, freq;

	width = MouseX.kr(0.5,0.01);
	freq = MouseY.kr(30,200);

	[VarSaw.ar(freq,0,width,0.5), VarSaw.ar(freq * 1.02,0,width,0.5)]

}.play

)


//maybe better for slider
(
x.free;
x = {
	arg base_freq = 100, att = 0.05, sus = 0.2, dec = 0.05, rel = 0.5;
	var sig, outer_env , freq_env, trig;

	att = MouseX.kr(0.05,1.5);
	rel = MouseY.kr(1.5,0.5);
	trig = MouseButton.kr(0,1,lag:0);
	freq_env = EnvGen.kr(Env.adsr(att, dec, sus, rel), trig, levelScale: 2000, levelBias: base_freq);
	sig = Mix.fill(5,{|count| Pan2.ar(LFTri.ar(freq_env * (1 +  Rand(-0.1,0.1)), mul:0.2),Rand(-1,1))});
	outer_env = EnvGen.kr(Env.asr(att,1,rel),trig);
	sig * outer_env


}.play
)


(

x.free;
x = {
	arg pulse = 500, att = 0.25, dec = 0.25, freq = 800, c_dec = 0.95;
	var sig, outer_env , trig, c_env;

	trig = MouseButton.kr(0,1,lag:0);
	c_env = EnvGen.kr(Env.asr(att,1,dec, 'lin'),trig,levelScale: 10, levelBias: 2);
	sig = VOSIM.ar(Impulse.ar(pulse),
		freq,
		c_env,
		c_dec)!2;

	outer_env = EnvGen.kr(Env.asr(att,1,dec),trig);
	sig * outer_env

}.play;

)



(

x.free;
x = {
	arg pulse = 100, att = 0.25, dec = 0.25, freq = 100, c_dec = 0.99;
	var sig, outer_env , trig, c_env;

	trig = MouseButton.kr(0,1,lag:0);
	c_env = EnvGen.kr(Env.asr(att,1,dec, 'lin'),trig,levelScale: 20, levelBias: 2);
	sig = VOSIM.ar(Impulse.ar(pulse),
		LFNoise2.kr(10).range(freq, freq * 1.1),
		c_env,
		c_dec)!2;

	outer_env = EnvGen.kr(Env.asr(att,1,dec),trig);
	sig * outer_env

}.play;

)






