
//maybe something for spinner
(

x.free;
x = {

	var env, sig, big_env ;

	env = EnvGen.kr(Env.perc(0.001, 0.02), LFPulse.kr(12));
	big_env = EnvGen.kr(Env.asr(0.01,1,0.1),MouseButton.kr(0,1,lag:0));
	sig = LFDNoise0.ar(MouseX.kr(100,3000)) * env;
	sig = BPeakEQ.ar(sig, MouseY.kr(4000,200), 0.2, 15)!2;
	sig  = sig * big_env;
}.play;

)

//anything from dub bass to motorised shit

(
x.free;
x= {
	var gliss, sig, outer_env, decay, freq, detune;

	freq = MouseY.kr(1000,50);
	decay = 0.5;
	detune = MouseX.kr(0.01,0.1);
	gliss = EnvGen.kr(Env.asr(0.5,1,decay),MouseButton.kr(0,1,0), levelScale: 0.25, levelBias: 0.75);

	sig = Mix.fill(2, {|count| Pan2.ar(LFSaw.ar(freq * (1 + (detune * count)) * gliss),-0.75 + (0.3 * count))});

	sig = sig.distort;

	outer_env = EnvGen.kr(Env.asr(0.01,1,decay),MouseButton.kr(0,1,lag:0));

	sig * outer_env
}.play;
)




(
x.free;
x= {
	var gliss, sig, outer_env, decay, freq;

	freq = MouseY.kr(100,50);
	decay = 0.1;
	gliss = EnvGen.kr(Env.asr(0.5,1,decay),MouseButton.kr(0,1,0), levelScale: 0.25, levelBias: 0.75);

	sig = [LFCub.ar(freq * gliss), LFCub.ar(freq * 1.02 * gliss)];
	sig = sig + (sig * LFSaw.ar(freq));
	outer_env = EnvGen.kr(Env.asr(0.01,1,decay),MouseButton.kr(0,1,lag:0));

	sig * outer_env
}.play;
)


(
{
    var local;

    local = LocalIn.ar(2); // read feedback,
	local = local + 1
    LocalOut.ar(local);

    local
}.play;
)



//



//buzzy swelly thing
(

x.free;
x = {

	var sig, env, freq;

	freq = 100;
	env = EnvGen.kr(Env.perc(2,0.01,curve: 4),1,doneAction:2);
	sig = InsideOut.ar(SinOsc.ar(LFNoise2.kr(100,10,freq)) + PinkNoise.ar(0.9), 0.5)!2 * env;
}.play;

)

(

x.free;
x = {

	var sig, env;
	sig = InsideOut.ar(
		SinOsc.ar(
			SinOsc.kr(
				LFNoise2.kr(1/3,5,10)
				,0,20,MouseY.kr(10,4000)
			)
			,0,
			Gbman2DC.ar(MouseX.kr(20, SampleRate.ir*0.25), MouseX.kr(80, SampleRate.ir), 0.1);
		)
	)!2 * 0.2;

	env = EnvGen.kr(Env.asr(0.01,1,1),MouseButton.kr(0,1,lag:0));
	sig * env

}.play
)

//motorish

(
x.free;
x = {
	var sig, env;

	env = EnvGen.kr(Env.perc(0.01,3),1,doneAction:2);
	sig = Decay2.ar(Impulse.ar(30), 0.001, 0.1)
	* (InsideOut.ar(
		LFPar.ar(MouseY.kr(5,200) + LFNoise0.kr(100,3),0,0.1), 1)
	);

	sig!2 * env;

	}.play;
)



//aftermath


(

{
	BPF.ar(WhiteNoise.ar, 6000, 0.2) * EnvGen.kr(Env.perc(0.01,3))
}.play;

)


//quite silly
(

x.free;
x = {

	var chaos_sig, out_sig, env;
	chaos_sig = Gbman2DC.ar(2225, 22050, -0.7, -2.7, 0.1);
	out_sig = LFSaw.ar(50 + (chaos_sig * MouseY.kr(5000,4000)),0, 0.2)!2;
	env = EnvGen.kr(Env.asr(0.01,1,0.01),MouseButton.kr(0,1,lag:0));
	out_sig * env

}.play;

)

//probably best with fixed vals
(
{

	var chaos_sig, out_sig, env;

	out_sig = Gbman2DC.ar(MouseX.kr(20, SampleRate.ir*0.25), MouseX.kr(80, SampleRate.ir), 0.1);
	out_sig = BPF.ar(GrayNoise.ar,1000,0.01,out_sig * 10)!2;
	env = EnvGen.kr(Env.asr(0.01,1,1),MouseButton.kr(0,1,lag:0));
	out_sig * env
}.play(s);
)





b = Buffer.alloc(s,1,1);

(
	{
		var x, rate, sig, d;
		rate = MouseX.kr(50, SampleRate.ir/6);
		d = Dseries(0,1,15);
		x = Dbufrd(b);
		a = LFDNoise1.ar(1,0.25,1);
		c = MouseY.kr(0.1,0.2);
		m = 1.0;

		x = x * 1/ a + c % m;//
		y = Dbufwr(x ,b);
		sig = Duty.ar(1/rate,0,y) * 0.1;
	    sig!2;
	}.play;
)





(

x = {

	arg freq = 0.5, grainMul = 0.5, grainFreq = 0.5, att = 1.0, dec = 0.2, trig = 1, amp = 0.5, pan = 0, noiseAmp = 0.5, noiseFilFreq = 0.2, noiseFilRq = 0.1;

	var sig, freqSpec, filfreqSpec, panSpec, grainSpec, env, amps;

	freqSpec = ControlSpec(50,3000,\exp);
	filfreqSpec = ControlSpec(100,8000,\exp);
	panSpec = ControlSpec(-0.75,0.75,\linear);
	grainSpec = ControlSpec(10,300,\linear);
	amps = [0.5, noiseAmp].normalizeSum;


	    sig = InsideOut.ar(
		LFCub.ar(LFDNoise1.kr(grainSpec.map(grainFreq),grainMul * freqSpec.map(freq) * 0.5,freqSpec.map(freq)), mul: amps[0])
		+ HPF.ar(PinkNoise.ar(amps[1]),filfreqSpec.map(noiseFilFreq))
		, 0.5);



	env = EnvGen.kr(Env.asr(att,1,dec,3), MouseButton.kr(0,1,0)) * amp;

	sig = Pan2.ar(sig, panSpec.map(pan)) * env;


	}.play;

)



// Simplest version, no parent view, so a window is created
(

w = Window.new.front;
w.view.decorator = FlowLayout( w.view.bounds, 10@10, 20@5 );

g = EZSlider(w, label:" freq ");
g.action_({ |ez|

	x.set(\freq, ez.value);

});

h = EZSlider(w, label:" grainFreq ");
h.action_({ |ez|

	x.set(\grainFreq, ez.value);

});

i = EZSlider(w, label:" grainMul ");
i.action_({ |ez|

	x.set(\grainMul, ez.value);

});

j = EZSlider(w, label:" noiseAmp ");
j.action_({ |ez|

	x.set(\noiseAmp, ez.value);

});

k = EZSlider(w, label:" noiseFilFreq ");
k.action_({ |ez|

	x.set(\noiseFilFreq, ez.value);

});

l = EZSlider(w, label:" noiseFilRq ");
l.action_({ |ez|

	x.set(\noiseFilRq, ez.value);

});

)




