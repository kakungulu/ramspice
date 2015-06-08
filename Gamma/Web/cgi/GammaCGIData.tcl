array set DATA {foreach net tile_size 50 10.1.20.40,V_OS%28V%29 12 10.1.20.40,CMMR%28dB%29 6 10.1.20.40,Z_OUT%28Ohm%29 5 10.1.20.40,A_DC%28dB%29 4 10.1.20.40,p_ref 2 unit,PSRR dB 10.1.20.40,f_CORNER {} 10.1.20.40,t_s {} 10.1.20.40,vdd 1.8 10.1.20.40,in 1 unit,BW Hz 10.1.20.40,A_DC 40 10.1.20.40,CMMR {} 10.1.20.40,V_OS {} 10.1.20.40,out 3 10.1.20.40,last_query {} schematic,diffpairnmos {
    blank 0 0 {}
    blank 0 0 {}
	vdd   0 0 vdd
    blank 0 0 {}
	vdd   0 0 vdd
    blank 0 0 {}
    nl 0 0 {}
   
	blank 0 0 {}
    blank 0 0 {}
	pmos 1 90 p_1
	twire 0 0 outm
	pmos 0 270 p_2
	blank 0 0 {}
    nl 0 0 {}
	
	vdd 0 0 vdd
	blank 0 0 {}
	twire 0 270 outm
	corner 0 270 outm
	twire 0 270 outp
	terminal 0 90 outp
	nl 0 0 {}
	
	csrc 0 180 vbias
	terminal 0 270 inp
	nmos 1 270 nin_1
	blank 0 0 {}
	nmos 0 90 nin_2
	terminal 0 90 inn
	nl 0 0 {}
	
	twire 0 270 vbias
	corner 0 180 vbias
	corner 0 0 tail
	twire 0 0 tail
	corner 0 270 tail
	blank 0 0 {}
	nl 0 0 {}
	
	nmos 0 90 n_ref
	twire 0 180 vbias
	line 0 90 vbias
	nmos 1 270 n_tail
	blank  0 0 {}
	blank  0 0 {}
	nl 0 0 {}
	
	gnd  0 0 {}
	blank  0 0 {}
	blank  0 0 {}
	gnd  0 0 {}
	blank  0 0 {}
	blank  0 0 {}	
} 10.1.20.40,schematic pmos 10.1.20.40,Z_OUT {} 10.1.20.40,BW%28Hz%29 8 10.1.20.40,Nt {} schematic,diffpairpmos {
		vdd 0 0 vdd
		blank 0 0 {}
		blank 0 0 {}
		vdd 0 0 vdd
		blank 0 0 {}
		blank 0 0 {}
		nl 0 0 {}
		
		pmos 1 90 p_ref
		line 0 90 {}
		line 0 90 {}
		pmos 0 270 p_tail
		blank 0 0 {}
		blank 0 0 {}
		nl 0 0 {}

		csrc 0 180 vbias
		blank 0 0 {}
		corner 0 90 tail
		twire 0 180 tail
		corner 0 180 tail
		blank 0 0 {}
		nl 0 0 {}
		
		gnd 0 0 {}
		terminal 0 270 inp
		pmos 0 270 pin_1
		blank 0 0 {}
		pmos 1 90 pin_2
		terminal 0 90 inn
		nl 0 0 {}
		
		blank 0 0 {}
		blank 0 0 {}
		twire 0 270 outm
		corner 0 180 outm
		twire 0 270 outp
		terminal 0 90 outp
		nl 0 0 {}
		
		blank 0 0 {}
		blank 0 0 {}
		nmos 0 90 n_1
		twire 0 180 outm
		nmos 1 270 n_2
		blank 0 0 {}
		nl 0 0 {}
		
		blank 0 0 {}
		blank 0 0 {}
		gnd 0 0 {}
		blank 0 0 {}
		gnd 0 0 {}
		blank 0 0 {}	
} 10.1.20.40,Nt%28A%5E2%29 10 schematic,nmos {
	blank 0 0 {}
	vdd 0 0 vdd
	blank 0 0 {}
	nl 0 0 {}
	
	blank 0 0 {}
	csrc 0 180 out
	blank 0 0 {}
	nl 0 0 {}
	
	blank 0 0 {}
	twire 0 270 out
	terminal 0 90 out
	nl 0 0 {}
	
	terminal 0 270 inx
	nmos 1 270 n_ref
	blank 0 0 {}
	nl 0 0 {}
	
	blank 0 0 {}
	gnd 0 0 {}
	blank 0 0 {}
} 10.1.20.40,last_schematic pmos 10.1.20.40,PSRR%28dB%29 7 unit,t_s sec unit,f_CORNER Hz unit,A_DC dB 10.1.20.40,last_access 1431724620 unit,CMMR dB unit,V_OS V schematic,pmos {
	blank 0 0 {}
	vdd 0 0 vdd
	blank 0 0 {}
	nl 0 0 {}
	
	terminal 0 270 inx
	pmos 0 270 p_ref
	blank 0 0 {}
	nl 0 0 {}

	blank 0 0 {}
	twire 0 270 out
	terminal 0 90 out
	nl 0 0 {}

	blank 0 0 {}
	csrc 0 180 out
	blank 0 0 {}
	nl 0 0 {}
	
	blank 0 0 {}
	gnd 0 0 {}
	blank 0 0 {}
} 10.1.20.40,f_CORNER%28Hz%29 11 unit,Z_OUT Ohm 10.1.20.40,PSRR {} allproperties {A_DC Z_OUT CMMR PSRR BW t_s Nt f_CORNER V_OS} 10.1.20.40,t_s%28sec%29 9 unit,Nt A^2 {$all_nets} {
		unit,$net V
		} 10.1.20.40,BW {}}
