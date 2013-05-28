

(

~masterBus = Bus.audio(s,2);
~subBus = Bus.audio(s,1);

SynthDef(\master,{arg amp = 1, outBus = 0;

	var sig;

	sig = In.ar(~masterBus,2);
	//sig = Compander.ar(sig,sig, 0.8, 1,1/3, 0.01, 0.01);
	sig = Limiter.ar(sig * 0.75,0.9,0.01);

	sig = MulAdd(sig,amp,0);

	Out.ar(0, sig);
}).send(s);

SynthDef.new(\basicDecay,{arg freq = 0, att = 0.01, dec = 0.2, amp = 0.5, pan = 0;

	var sig, freqSpec, panSpec;

	freqSpec = ControlSpec(100,2000,\exp);
	panSpec = ControlSpec(-0.75,0.75,\linear);

	sig = LFCub.ar(freqSpec.map(freq),0,0.5) + LFCub.ar(freqSpec.map(freq) + 2,0,0.5);
	sig = sig * EnvGen.kr(Env.perc(att, dec,1,-2),1, doneAction: 2) * amp;

	sig = Pan2.ar(sig, panSpec.map(pan));

	Out.ar(~masterBus,sig);

}).send(s);


SynthDef.new(\basicSustain,{arg freq = 0, att = 0.01, dec = 0.2, trig = 1, amp = 0.5, pan = 0;

	var sig, freqSpec, panSpec;

	freqSpec = ControlSpec(50,3000,\exp);
	panSpec = ControlSpec(-0.75,0.75,\linear);

	sig = LFCub.ar(freqSpec.map(freq),0,0.5) + LFCub.ar(freqSpec.map(freq) + 2,0,0.5);
	sig = sig * EnvGen.kr(Env.asr(att,1,dec,3),trig, doneAction: 2) * amp;		sig = Pan2.ar(sig, panSpec.map(pan));

	Out.ar(~masterBus,sig);

}).send(s);



SynthDef.new(\buzzSustain,{arg freq = 0.5, grainMul = 0.5, grainFreq = 0.5, att = 1.0, dec = 0.2, trig = 1, amp = 0.5, pan = 0, noiseAmp = 0.5;

	var sig, freqSpec, panSpec, grainSpec, env, amps;

	freqSpec = ControlSpec(50,3000,\exp);
	panSpec = ControlSpec(-0.75,0.75,\linear);
	grainSpec = ControlSpec(10,300,\linear);
	amps = [0.5, noiseAmp].normalizeSum;


	sig = InsideOut.ar(
		LFPar.ar(LFDNoise1.kr(grainSpec.map(grainFreq),grainMul * freqSpec.map(freq) * 0.5,freqSpec.map(freq)), 0, mul: amps[0])
		+ PinkNoise.ar(amps[1])
		, 0.5);

	env = EnvGen.kr(Env.asr(att,1,dec,3),trig, doneAction: 2) * amp;
	sig = Pan2.ar(sig, panSpec.map(pan)) * env;
	Out.ar(~masterBus, sig);

}).send(s);


SynthDef.new(\softSustain,{arg freq = 0, att = 0.01, dec = 0.2, trig = 1, amp = 0.5, pan = 0;

	var sig, freqSpec, panSpec;

	freqSpec = ControlSpec(50,3000,\exp);
	panSpec = ControlSpec(-0.75,0.75,\linear);

	sig = LFCub.ar(freqSpec.map(freq),0,1);
	sig = sig * EnvGen.kr(Env.asr(att,1,dec,3),trig, doneAction: 2) * amp;		sig = Pan2.ar(sig, panSpec.map(pan));

	Out.ar(~masterBus,sig);

}).send(s);


SynthDef.new(\clipSustain,{arg trig = 1, freq = 0.1, clip = 0.5, att = 0.01, dec = 0.2, amp = 1, pan = 0;

	var sig, freqSpec, panSpec;

	freqSpec = ControlSpec(5,30,\exp);
	panSpec = ControlSpec(-0.75,0.75,\linear);

	freq = freqSpec.map(freq);
	sig = Saw.ar(freq,1).clip(clip);
	sig = Pan2.ar(sig, panSpec.map(pan)) * amp;
	sig = sig * EnvGen.kr(Env.asr(att,1,dec),trig, doneAction: 2);
	Out.ar(~masterBus,sig);

}).send(s);


SynthDef.new(\clipDecay,{arg trig = 1, freq = 0.1, filFreqH = 0, filFreqL = 1, att = 0.01, dec = 0.2, amp = 1, pan = 0;

	var sig, freqSpec, filFreqSpec, panSpec;
	freqSpec = ControlSpec(5,30,\exp);
	filFreqSpec =  ControlSpec(100,5000, \exp);
	panSpec = ControlSpec(-0.75,0.75,\linear);

	freq = freqSpec.map(freq);
	sig = LFSaw.ar(freq,0,1);
	sig = HPF.ar(sig, filFreqSpec.map(filFreqH));
	sig = LPF.ar(sig, filFreqSpec.map(filFreqL));
	sig = Pan2.ar(sig, panSpec.map(pan)) * amp;
	sig = sig * EnvGen.kr(Env.perc(att, dec,1,-2),1, doneAction: 2);
	Out.ar(~masterBus,sig);

}).send(s);







SynthDef.new(\elecSustain, {arg trig = 1, freq = 0.1, att = 0.01, dec = 0.01, amp = 1,
	separate =  0.1, speed = 0.5, filFreq= 0.5, pan = 0;

	var sig, env, freqSpec, speedSpec, filFreqSpec, trig2, panSpec;
	freqSpec = ControlSpec(50,200,\exp);
	speedSpec = ControlSpec(3,10, \linear);
	filFreqSpec = ControlSpec(100,2000, \exp);
	panSpec = ControlSpec(-0.75,0.75,\linear);

	speed = speedSpec.map(speed);
	freq = freqSpec.map(freq);

	trig2 = LFPulse.kr(speed);
	env = EnvGen.kr(Env.linen(0,1/(speed * (1+separate)),0),trig2);
	sig = LFNoise0.ar(freq) * env * amp;
	sig = HPF.ar(sig, filFreqSpec.map(filFreq));
	sig = Pan2.ar(sig * env, panSpec.map(pan));
	sig = sig * EnvGen.kr(Env.asr(att,1,dec),trig, doneAction: 2);
	Out.ar(~masterBus,sig);

}).send(s);


SynthDef.new(\brownGlitchDecay, {arg trig = 1, freq = 0.1, filFreq = 0, gAtt = 0, amp = 1, pan = 0;

	var sig, env, freqSpec, attSpec, filFreqSpec, panSpec;
	freqSpec = ControlSpec(50,4000,\exp);
	filFreqSpec = ControlSpec(10,10000,\exp);
	attSpec = ControlSpec(0.005,0.1, \linear);
	freq = freqSpec.map(freq);
	gAtt = attSpec.map(gAtt);
	panSpec = ControlSpec(-0.75,0.75,\linear);

	env = EnvGen.kr(Env.linen(gAtt,0.001,0),1, doneAction:2);
	sig = RLPF.ar(BrownNoise.ar(1),freq,0.01) * env * amp;
	sig= HPF.ar(sig, filFreqSpec.map(filFreq));
	sig = Pan2.ar(sig, panSpec.map(pan));
	Out.ar(~masterBus,sig);

}).send(s);



SynthDef.new(\swellSustain, {arg trig = 1, att = 0.01, dec = 0.01,  amp = 1,
	freq = 0.1, sm1 = 0.33, sm2 = 0.33, sm3 = 0.33, width = 0.5, pan = 0;

	var widthEnv,freqSpec, sig, sig1, sig2, sig3, vols, panSpec;

	vols = [sm1,sm2,sm3].normalizeSum;
	freqSpec = ControlSpec(40,250,\exp);
	panSpec = ControlSpec(-0.75,0.75,\linear);
	freq = freqSpec.map(freq);

	widthEnv = EnvGen.kr(Env.new([0,width,0],[att,0.001],1),trig);

	sig1 = VarSaw.ar(freq,1,0.5 + widthEnv,10);
	sig2 = VarSaw.ar(freq * 3/2,1,0.5 + widthEnv,10);
	sig3 = VarSaw.ar(freq * 4/3,1,0.5 + widthEnv,10);
	sig = (sig1 * vols[0]) + (sig2 * vols[1]) + (sig3 * vols[2]) * amp * 0.2;

	sig = sig * EnvGen.kr(Env.asr(att,1,0.001,5),trig, doneAction: 2);

	sig = Pan2.ar(sig, panSpec.map(pan));

	Out.ar(~masterBus,sig);

}).send(s);


SynthDef.new(\servoDecay, {arg trig = 1, att = 0.5, dec = 1.0,  amp = 1,
	start = 0.25, top = 0.5, end = 0, sus = 0.25, filFreq = 0.25, detune = 0.05, pan = 0;

	var sig, env, p_env, a_env, panSpec, freqSpec, filFreqSpec;

	freqSpec = ControlSpec(25,4000,\exp);
	filFreqSpec = ControlSpec(500,5000,\exp);
	panSpec = ControlSpec(-0.75,0.75,\linear);

	env = Env.linen(att,dec* sus, dec * 1-sus,1, 'sine');

	p_env = EnvGen.kr(Env.new([start,top, top, end],[att,dec* sus, dec * 1-sus], [2,'lin',-2]),trig);
	p_env = freqSpec.map(p_env);
	a_env = EnvGen.kr(env,trig, doneAction:2);

	sig = Array.fill(2, {|count| SawDPW.ar(p_env + (count * detune * p_env),0,0.5) * a_env});

	sig = HPF.ar(sig, filFreqSpec.map(filFreq));

	sig = Splay.ar(sig, 0.25, 1, panSpec.map(pan));

	Out.ar(~masterBus,sig);

}).send(s);

SynthDef.new(\triDecay, {

	arg att = 0.3, dec = 0.5, a_prop = 0.33, sus = 0.8,
	av1 = 0.25, av2 = 0.8, sv = 0.5, dv = 0.25, pan = 0;

	var sig, outer_env , freq_env,  panSpec, freqSpec;

	panSpec = ControlSpec(-0.75,0.75,\linear);
	freqSpec = ControlSpec(50,4000,\exp);

	freq_env = EnvGen.kr(
		Env.new([av1,av2,sv,sv,dv],
			[att * a_prop,1-a_prop * att,dec*sus, 1-sus *dec]
	), 1);

	freq_env = freqSpec.map(freq_env);

	sig = Array.fill(4,{|count| LFTri.ar(freq_env * (0.02 * (count + 1) + 1), mul:0.2)});
	sig = Splay.ar(sig, 0.25, center: pan);
	outer_env = EnvGen.kr(Env.linen(att,dec*sus,1-sus*dec, 1, 'sine'),1, doneAction:2);
	sig = sig * outer_env;
	Out.ar(~masterBus,sig);

}).send(s);


SynthDef.new(\shaperDecay, {

	arg att = 0.5, sus = 0.2, dec = 0.5, amp = 0.5, freq = 0, c_freq = 0, detune, pan = 0;
	var sig, f_env, outer_env, freqSpec, panSpec;

	panSpec = ControlSpec(-0.75,0.75,\linear);
	freqSpec = ControlSpec(50,4000,\exp);

	f_env = EnvGen.kr(Env.linen(att,sus * dec,1-sus *dec,1,'sine'),1).range(0.02,0.15);
	sig = SineShaper.ar(SinOsc.ar([freqSpec.map(freq), freqSpec.map(freq * (1 + detune))], 0, 0.2), 0.17 - f_env);
	sig = LFCub.ar(freqSpec.map(c_freq)) * sig * 10 * amp;
	sig = Splay.ar(sig, 0.25,1,panSpec.map(pan));
	outer_env = EnvGen.kr(Env.linen(att, sus * dec ,1-sus * dec, 1, 'welch'),1,doneAction:2 );
	sig = sig * outer_env;

	Out.ar(0,sig);


}).send(s)


)





//---osc starts here
(

~ini.remove;
~ini=nil;
~ini = OSCresponderNode(nil, '/init', {|i, r, msg|

	var vals;
	msg.postln;
	~sustainSynths.do{|reader|
		reader.do{|node|


			node.set(\trig, 0);
		};
	};



	~sustainSynths = MultiLevelIdentityDictionary.new;
	~master.free;
	~master = Synth.new(\master);

}).add;

~blipOn.remove;
~blipOn=nil;
~blipOn = OSCresponderNode(nil, '/blipOn', {|i, r, msg|



	// 1. index
	// 2. synthDef
	// 3. envType 0 = ASR, 1 = AR
	// 4. attack
	// 5. decay
	// 6 -10. userParams 0 - 4


	if(msg[3] == 'basic'){
		if(msg[4] == 0){
			~sustainSynths.put(msg[1], msg[2],  Synth.head(nil, \basicSustain,
				[\att, msg[5], \dec, msg[6],\freq, msg[7], \amp, msg[9], \pan, msg[10]]));

		}{
			x = Synth.head(nil, \basicDecay, [\att, msg[5], \dec, msg[6], \freq, msg[7], \amp, msg[9], \pan, msg[10]]);
		};
	};

	if(msg[3] == 'soft'){
		if(msg[4] == 0){
			~sustainSynths.put(msg[1], msg[2],  Synth.head(nil, \softSustain,
				[\att, msg[5], \dec, msg[6],\freq, msg[7], \amp, msg[9], \pan, msg[10]]));

		}{

		};
	};

	if(msg[3] == 'clip'){
		if(msg[4] == 0){
			~sustainSynths.put(msg[1], msg[2],
				Synth.head(nil, \clipSustain,
					[\att, msg[5], \dec, msg[6],\freq, msg[7], \clip, msg[8], \amp, msg[9], \pan, msg[10]])
			);

		}{

			x = Synth.head(nil, \clipDecay,
				[\att, msg[5], \dec, msg[6],\freq, msg[7], \filFreqL, msg[8], \filFreqH, msg[9], \amp, msg[10], \pan, msg[11]])

		};

	};

	if(msg[3] == 'elec'){
		if(msg[4] == 0){
			~sustainSynths.put(msg[1], msg[2],
				Synth.head(nil, \elecSustain,
					[\att, msg[5], \dec, msg[6],\freq, msg[7], \filFreq, msg[8],\speed, msg[9],\separate, msg[10], \amp, msg[11], \pan, msg[12]])
			);
		}{


		};

	};

	if(msg[3] == 'brownGlitch'){

		if(msg[4] == 0){

		}{
			x = Synth.head(nil, \brownGlitchDecay,[\freq, msg[7], \filFreq, msg[8], \gAtt, msg[9], \amp, msg[10], \pan, msg[11]])
		};

	};

	if(msg[3] == 'swell'){


		if(msg[4] == 0){

			~sustainSynths.put(msg[1], msg[2],
				Synth.head(nil, \swellSustain,
					[\att, msg[5],\freq, msg[7], \amp, msg[8], \sm1, msg[9], \sm2, msg[10], \sm3, msg[11], \width, msg[12], \pan, msg[13]])
			);
		}{

		};

	};

	if(msg[3] == 'buzz'){


		if(msg[4] == 0){


			~sustainSynths.put(msg[1], msg[2],
				Synth.head(nil, \buzzSustain,
					[\att, msg[5], \dec, msg[6], \freq, msg[7], \amp, msg[8], \grainMul, msg[9], \grainFreq, msg[10], \noiseAmp, msg[11], \pan, msg[12]])
			);
		}{

		};

	};

	if(msg[3] == 'servo'){


		if(msg[4] == 0){

		}{

			x = Synth.head(nil, \servoDecay,[\att, msg[5], \dec, msg[6], \sus, msg[7], \amp, msg[8], \start, msg[9], \top, msg[10], \end, msg[11], \filFreq, msg[12], \detune, msg[13],\pan, msg[14]])
		};

	};

	if(msg[3] == 'tri'){


		if(msg[4] == 0){

		}{

			x = Synth.head(nil, \triDecay,[\att, msg[5], \dec, msg[6], \amp, msg[7], \a_prop, msg[8], \sus, msg[9],
				\av1, msg[10], \av2, msg[11], \sv, msg[12], \dv, msg[13], \pan, msg[14]])
		};

	};

	if(msg[3] == 'shaper'){


		if(msg[4] == 0){

		}{

			x = Synth.head(nil, \shaperDecay,[\att, msg[5], \dec, msg[6], \sus, msg[7], \freq, msg[8], \c_freq, msg[9], \detune, msg[10], \amp, msg[11], \pan, msg[12]])
		};

	};



}).add;

~blipOff.remove;
~blipOff=nil;
~blipOff = OSCresponderNode(nil, '/blipOff', {|i, r, msg|

	//1. Readerindex
	//2. BlipIndex
	//3. NameIndex
	~sustainSynths.at(msg[1],msg[2]).set(\trig, 0);
	~sustainSynths.removeAt(msg[1],msg[2]);

}).add;

)
