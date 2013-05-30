(
SynthDef.new(\servoDecay, {arg trig = 1, att = 0.5, dec = 1.0,  amp = 1,
	start = 0.25, top = 0.5, end = 0, sus = 0.25, filFreq = 0.25, detune = 0.05, pan = 0;

	var sig, env, p_env, a_env, panSpec, freqSpec, filFreqSpec;

	freqSpec = ControlSpec(25,4000,\exp);
	filFreqSpec = ControlSpec(500,5000,\exp);
	panSpec = ControlSpec(-0.75,0.75,\linear);

	env = Env.linen(att,dec - 0.05, 0.05,1, 'sine');

	p_env = EnvGen.kr(Env.new([start,top, top, end],[att,dec* sus, dec * 1-sus], [2,'lin',-2]),trig);
	p_env = freqSpec.map(p_env);
	a_env = EnvGen.kr(env,trig, doneAction:2);

	sig = Array.fill(2, {|count| SawDPW.ar(p_env + (count * detune * p_env),0,0.5) * a_env});

	sig = HPF.ar(sig, filFreqSpec.map(filFreq));

	sig = Splay.ar(sig, 0.25, 1, panSpec.map(pan));

	Out.ar(0,sig);

}).send(s);

)


Env.new([0,1, 1, 0],[0.2,0.8,0.2],[4,'lin',-4]).test.plot

x = Synth.new(\servoDecay, [\start, 0.2, \top, 0.7, \end, 0.5, \att, 0.2, \dec, 1.2, \sus, 0.8, \filFreq, 0.8, \detune, 0.01, \dir, 1 ])
x = Synth.new(\servoDecay, [\base, 0.7, \range, 0.2, \fall, -1, \att, 0.4, \dec, 0.6, \sus, 0.8, \filFreq, 0.5, \detune, 0.01, \dir, 1 ])


//maybe better for slider
(

SynthDef.new(\triDecay, {

	arg att = 0.3, a_prop = 0.33, sus = 0.8, dec = 0.5, trig = 1, pan = 0, av1 = 0.25, av2 = 0.8, sv = 0.5, dv = 0.25;

	var sig, outer_env , freq_env,  panSpec, freqSpec;

	panSpec = ControlSpec(-0.75,0.75,\linear);
	freqSpec = ControlSpec(50,4000,\exp);

	freq_env = EnvGen.kr(
		Env.new([av1,av2,sv,sv,dv],
			[att * a_prop,1-a_prop * att,dec*sus, 1-sus *dec]
	), trig);

	freq_env = freqSpec.map(freq_env);

	sig = Array.fill(4,{|count| LFTri.ar(freq_env * (0.02 * (count + 1) + 1), mul:0.2)});
	sig = Splay.ar(sig, 0.25, center: pan);
	outer_env = EnvGen.kr(Env.linen(att,dec*sus,1-sus*dec, 1, 'sine'),trig, doneAction:2);
	sig= sig * outer_env;
	Out.ar(0,sig);

}).send(s)

)

x = Synth.new(\triDecay, [ \att, 0.3, \dec, 1.0, \sus, 0.8, \av1,0.25, \av2, 0.8, \sv, 0.5, \dv, 0.25 ])



//might be better with a different blip from sprocket


(

SynthDef.new(\shaperDecay, {

	arg att = 0.5, sus = 0.2, dec = 0.5, amp = 0.5, freq = 0, pan = 0;
	var sig, f_env, outer_env, freqSpec, panSpec;

	panSpec = ControlSpec(-0.75,0.75,\linear);
	freqSpec = ControlSpec(50,4000,\exp);

	f_env = EnvGen.kr(Env.linen(att,sus,dec,1,'sine'),1).range(0.02,0.15);
	sig = SineShaper.ar(SinOsc.ar([freqSpec.map(freq), freqSpec.map(freq * 1.03)], 0, 0.2), 0.17 - f_env);
	sig = LFCub.ar(100) * sig * 10 * amp;
	sig = Splay.ar(sig, 0.25,1,panSpec.map(pan));
	outer_env = EnvGen.kr(Env.linen(att, sus , dec, 1, 'sine'),1,doneAction:2 );
	sig = sig * outer_env;

	Out.ar(0,sig);


}).send(s)

)


x = Synth.new(\shaperDecay, [\freq, 0.5, \att, 0.8, \sus, 0.5, \dec, 0.8])


(

SynthDef.new(\distortDecay, {

	arg att = 0.01, dec = 0.9, amp = 0.5, freq = 0.1, pan = 0, filFreq = 0.5, distort = 0.1, res = 0.4;
	var sig, outer_env, freqSpec, panSpec;

	panSpec = ControlSpec(-0.75,0.75,\linear);
	freqSpec = ControlSpec(50,4000,\exp);

	outer_env = EnvGen.kr(Env.new([0,1,1,0],[att,0,dec],4),1, doneAction:2);

	sig = LPF18.ar(SawDPW.ar([freqSpec.map(freq), freqSpec.map(freq*1.02)]),
		freqSpec.map(filFreq),res * 10,distort) * amp * outer_env;


	sig = Splay.ar(sig,0.25,center:panSpec.map(pan)) * outer_env;


	Out.ar(0,sig);

}).send(s);

)


x = Synth.new(\distortDecay,[\filFreq, 0.8, \freq, 0.2,  \att,0.01, \dec,0.9, \distort, 0.1, \res, 0.1])

