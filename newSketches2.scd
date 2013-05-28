
//maybe better for bubbles
//SinGrainI is more flexible regarding textures
(
x.free;
x = {
	SinGrain.ar(Impulse.kr(20),0.01, WhiteNoise.kr.range(200,2000),0.5)!2;
}.play

)


nice bit of filter sweep - could work for slider

{SineShaper.ar(SinOsc.ar([400, 404], 0, 0.2), MouseX.kr(0, 1))}.play


//might be good for sprocket with some work
(

x = {
	var sig, f_env, outer_env, att = 0.5, sus = 0.5, dec = 0.1, freq = 200;

	freq = Rand(100,1000);
	f_env = EnvGen.kr(Env.linen(att,sus,dec,1,'sine'),1).range(0.02,0.15);
	sig = SineShaper.ar(SinOsc.ar([freq, freq * 1.03], 0, 0.2), 0.17-f_env);
	sig = LFCub.ar(100) * sig * 25;
	sig = Splay.ar(sig, 0.25,1,0);
	outer_env = EnvGen.kr(Env.linen(att, sus , dec),1, doneAction: 2);
	sig * outer_env;


}.play
)


(

x.free;
x = {arg gate = 1, amp = 0.5, index = 3;

	var sig, env, e1, e2;

	env = Env.linen(0.5,1,1,1, 'sine');
	e1 = EnvGen.kr(env , MouseButton.kr(lag: 0), levelScale: MouseX.kr(100,1000), levelBias: 25);
	e2 = EnvGen.kr(env , MouseButton.kr(lag: 0), levelScale: MouseY.kr(1000,100), levelBias: 25);

	sig =  FMGrain.ar(Impulse.kr(50), 0.1, e1, e2,
		LFNoise1.kr(10).range(1,10),
			EnvGen.kr(
				Env([0, 1, 0], [1, 1], \sin, 1),
				gate,
				levelScale: amp,
				doneAction: 2)
	)* EnvGen.kr(env , MouseButton.kr(lag: 0));


	sig = HPF.ar(sig, 500);
	sig!2;


	}.play


)


//higher and more like a servo

(

x.free;
x = {arg gate = 1, amp = 0.5, index = 3;

	var sig, env, e1, e2;

	env = Env.linen(0.5,1,1,1,-4);
	e1 = EnvGen.kr(env , MouseButton.kr(lag: 0), levelScale: MouseX.kr(100,4000), levelBias: 50);

	sig = Mix.fill(2, { arg count; SawDPW.ar(e1 + (count * 10),0,0.5) * EnvGen.kr(env , MouseButton.kr(lag: 0))});
	sig = HPF.ar(sig, 50);

	sig!2;


	}.play


)


//sprocket contender

//even more efficient; see BlitB3Saw help file
x = {MoogFF.ar(Mix(BlitB3Saw.ar(MouseX.kr(0.125,4)*[220,221,223,224], 0.99, 0.125)), MouseY.kr(200,10000,'exponential'),3) }.play;

{}.scope

//hmmm...
(
x = {
    MoogFF.ar(
        Pulse.ar([40,121], [0.3,0.7]),
		        [SinOsc.kr(1.0).range(10, 300),SinOsc.kr(3.0).range(100, 200) ],
		       SinOsc.kr(20.0).range(0.5,3.5))}.play(s);
)


