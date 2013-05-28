{Pan2.ar(WhiteNoise.ar(0.2),0)}.play;

(

	~masterBus = Bus.audio(s,2);
	~subBus = Bus.audio(s,1);

	SynthDef(\master,{arg amp = 1, outBus = 0;

	var sig;

	sig = In.ar(~masterBus,2);
	//sig = Compander.ar(sig,sig, 0.8, 1,1/3, 0.01, 0.01);
	sig = Limiter.ar(sig * 0.5,0.9,0.01);

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

	SynthDef.new(\swellMidiSustain, {arg trig = 1, att = 0.01, dec = 0.01,  amp = 1,
									freq = 66, sm1 = 0.33, sm2 = 0.33, sm3 = 0.33, width = 0.5, pan = 0;

		var widthEnv,freqSpec, sig, sig1, sig2, sig3, vols, panSpec;

		vols = [sm1,sm2,sm3].normalizeSum;

		panSpec = ControlSpec(-0.75,0.75,\linear);
		freq = freq.midicps;

		widthEnv = EnvGen.kr(Env.new([0,width,0],[att,0.001],1),trig);

		sig1 = VarSaw.ar(freq,1,0.5 + widthEnv,10);
		sig2 = VarSaw.ar(freq * 3/2,1,0.5 + widthEnv,10);
		sig3 = VarSaw.ar(freq * 4/3,1,0.5 + widthEnv,10);
		sig = (sig1 * vols[0]) + (sig2 * vols[1]) + (sig3 * vols[2]) * amp * 0.2;

		sig = sig * EnvGen.kr(Env.asr(att,1,0.001,5),trig, doneAction: 2);

		sig = Pan2.ar(sig, panSpec.map(pan));

		Out.ar(~masterBus,sig);

	}).send(s);




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

		var bd = [7,9,7,12,11,11,7,9,7,14,12,12], freq;

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


		if(msg[3] == 'swellBD'){



			if(msg[4] == 0){


			freq = msg[7] * 12;
			freq = freq.floor;
			freq = bd[freq] + 30;


						~sustainSynths.put(msg[1], msg[2],
				Synth.head(nil, \swellMidiSustain,
				[\att, msg[5],\freq, freq, \amp, msg[8], \sm1, msg[9], \sm2, msg[10], \sm3, msg[11], \width, msg[12], \pan, msg[13]])
				);
				}{

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
		