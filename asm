Info: Assembly 0: 
Info: Assembly 0: 
Info: Assembly 0: ------- ::function(Ids_p,calculation) ------- 
Info: Assembly 0: 
Info: # Assembly Compiling expression interpolate(&{/look_up_tables/pch/Ids/ss},{V/mid}-1.8,{V/mid}-1.8,1.8-1.8,{Geometry/Lp})*({Geometry/Wp}/{Geometry/Lp}) 
Info: # Assembly Compiling expression interpolate(@1,{V/mid}-1.8,{V/mid}-1.8,1.8-1.8,{Geometry/Lp})*({Geometry/Wp}/{Geometry/Lp}) 
Info: # Assembly Compiling expression interpolate(@1,{V/mid}-1.8,{V/mid}-1.8,1.8-1.8,{Geometry/Lp})*({Geometry/Wp}/@2) 
Info: # Assembly Compiling expression interpolate(@1,{V/mid}-1.8,{V/mid}-1.8,1.8-1.8,{Geometry/Lp})*(@3/@2) 
Info: # Assembly Compiling expression interpolate(@1,{V/mid}-1.8,{V/mid}-1.8,1.8-1.8,@4)*(@3/@2) 
Info: # Assembly Compiling expression interpolate(@1,{V/mid}-1.8,@5-1.8,1.8-1.8,@4)*(@3/@2) 
Info: # Assembly Compiling expression interpolate(@1,@6-1.8,@5-1.8,1.8-1.8,@4)*(@3/@2) 
Info: # Assembly Compiling expression interpolate(@1,@6-1.8,@5-1.8,1.8-1.8,@4)*@7 
Info: # Assembly Compiling expression @8*@7 
Info: # Assembly Compiling expression @7 
Info: # Assembly Compiling expression @3/@2 
Info: # Assembly Compiling expression @2 
Info: # Assembly push Geometry/Lp 
Info: Assembly 0: 6dc020 PushVar 4a87c136 
Info: # Assembly Compiling expression @3 
Info: # Assembly push Geometry/Wp 
Info: Assembly 2: 6dc020 PushVar 4a87c136 
Info: Assembly 4: 6db9f0 Div 
Info: # Assembly Compiling expression @8 
Info: # Assembly Compiling expression @1,@6-1.8,@5-1.8,1.8-1.8,@4 
Info: # Assembly Compiling expression @4 
Info: # Assembly push Geometry/Lp 
Info: Assembly 5: 6dc020 PushVar 4a87c136 
Info: # Assembly Compiling expression @1,@6-1.8,@5-1.8,1.8-1.8 
Info: # Assembly Compiling expression 1.8-1.8 
Info: # Assembly push 0 
Info: Assembly 7: 6dc320 Push 0 
Info: # Assembly Compiling expression @1,@6-1.8,@5-1.8 
Info: # Assembly Compiling expression @5-1.8 
Info: # Assembly Compiling expression 1.8 
Info: # Assembly push 1.8 
Info: Assembly 9: 6dc320 Push 1.8 
Info: # Assembly Compiling expression @5 
Info: # Assembly push V/mid 
Info: Assembly 11: 6dc020 PushVar 4a87c136 
Info: Assembly 13: 6dbb30 Minus 
Info: # Assembly Compiling expression @1,@6-1.8 
Info: # Assembly Compiling expression @6-1.8 
Info: # Assembly Compiling expression 1.8 
Info: # Assembly push 1.8 
Info: Assembly 14: 6dc320 Push 1.8 
Info: # Assembly Compiling expression @6 
Info: # Assembly push V/mid 
Info: Assembly 16: 6dc020 PushVar 4a87c136 
Info: Assembly 18: 6dbb30 Minus 
Info: # Assembly Compiling expression @1 
Info: # Assembly push &/look_up_tables/pch/Ids/ss 
Info: Assembly 19: 6dbf40 PushPointer 0 
Info: Assembly 21: 6dbc70 Interpolate 
Info: Assembly 22: 6dba90 Mult 
Info: Assembly 23: 6dcf90 Return 0 
Info: Assembly 25: 
Info: Assembly 25: 
Info: Assembly 25: ------- ::function(Ids_n,calculation) ------- 
Info: Assembly 25: 
Info: # Assembly Compiling expression interpolate(&{/look_up_tables/nch/Ids/ss},{V/vin}-0,{V/mid}-0,0-0,{Geometry/Ln})*({Geometry/Wn}/{Geometry/Ln}) 
Info: # Assembly Compiling expression interpolate(@28,{V/vin}-0,{V/mid}-0,0-0,{Geometry/Ln})*({Geometry/Wn}/{Geometry/Ln}) 
Info: # Assembly Compiling expression interpolate(@28,{V/vin}-0,{V/mid}-0,0-0,{Geometry/Ln})*({Geometry/Wn}/@29) 
Info: # Assembly Compiling expression interpolate(@28,{V/vin}-0,{V/mid}-0,0-0,{Geometry/Ln})*(@30/@29) 
Info: # Assembly Compiling expression interpolate(@28,{V/vin}-0,{V/mid}-0,0-0,@31)*(@30/@29) 
Info: # Assembly Compiling expression interpolate(@28,{V/vin}-0,@32-0,0-0,@31)*(@30/@29) 
Info: # Assembly Compiling expression interpolate(@28,@33-0,@32-0,0-0,@31)*(@30/@29) 
Info: # Assembly Compiling expression interpolate(@28,@33-0,@32-0,0-0,@31)*@34 
Info: # Assembly Compiling expression @35*@34 
Info: # Assembly Compiling expression @34 
Info: # Assembly Compiling expression @30/@29 
Info: # Assembly Compiling expression @29 
Info: # Assembly push Geometry/Ln 
Info: Assembly 25: 6dc020 PushVar 4a87c136 
Info: # Assembly Compiling expression @30 
Info: # Assembly push Geometry/Wn 
Info: Assembly 27: 6dc020 PushVar 4a87c136 
Info: Assembly 29: 6db9f0 Div 
Info: # Assembly Compiling expression @35 
Info: # Assembly Compiling expression @28,@33-0,@32-0,0-0,@31 
Info: # Assembly Compiling expression @31 
Info: # Assembly push Geometry/Ln 
Info: Assembly 30: 6dc020 PushVar 4a87c136 
Info: # Assembly Compiling expression @28,@33-0,@32-0,0-0 
Info: # Assembly Compiling expression 0-0 
Info: # Assembly push 0 
Info: Assembly 32: 6dc320 Push 0 
Info: # Assembly Compiling expression @28,@33-0,@32-0 
Info: # Assembly Compiling expression @32-0 
Info: # Assembly Compiling expression @32 
Info: # Assembly push V/mid 
Info: Assembly 34: 6dc020 PushVar 4a87c136 
Info: # Assembly Compiling expression @28,@33-0 
Info: # Assembly Compiling expression @33-0 
Info: # Assembly Compiling expression @33 
Info: # Assembly push V/vin 
Info: Assembly 36: 6dc020 PushVar 4a87c136 
Info: # Assembly Compiling expression @28 
Info: # Assembly push &/look_up_tables/nch/Ids/ss 
Info: Assembly 38: 6dbf40 PushPointer 0 
Info: Assembly 40: 6dbc70 Interpolate 
Info: Assembly 41: 6dba90 Mult 
Info: Assembly 42: 6dcf90 Return 0 
Info: Assembly 44: 
Info: Assembly 44: 
Info: Assembly 44: ------- ::function(kcl_step,calculation) ------- 
Info: Assembly 44: 
Info: # Assembly Compiling expression +(0-{V/vin})/r_in+(1.8-{V/vin})/(100-r_in) 
Info: # Assembly Compiling expression +(0-{V/vin})/r_in+(1.8-@53)/(100-r_in) 
Info: # Assembly Compiling expression +(0-@54)/r_in+(1.8-@53)/(100-r_in) 
Info: # Assembly Compiling expression +(0-@54)/r_in+(1.8-@53)/@55 
Info: # Assembly Compiling expression +(0-@54)/r_in+@56/@55 
Info: # Assembly Compiling expression +@57/r_in+@56/@55 
Info: # Assembly Compiling expression @56/@55 
Info: # Assembly Compiling expression @55 
Info: # Assembly Compiling expression 100-r_in 
Info: # Assembly Compiling expression r_in 
Info: # Assembly push r_in 
Info: Assembly 44: 6dc020 PushVar 4a87c136 
Info: # Assembly Compiling expression 100 
Info: # Assembly push 100 
Info: Assembly 46: 6dc320 Push 100 
Info: Assembly 48: 6dbb30 Minus 
Info: # Assembly Compiling expression @56 
Info: # Assembly Compiling expression 1.8-@53 
Info: # Assembly Compiling expression @53 
Info: # Assembly push V/vin 
Info: Assembly 49: 6dc020 PushVar 4a87c136 
Info: # Assembly Compiling expression 1.8 
Info: # Assembly push 1.8 
Info: Assembly 51: 6dc320 Push 1.8 
Info: Assembly 53: 6dbb30 Minus 
Info: Assembly 54: 6db9f0 Div 
Info: # Assembly Compiling expression +@57/r_in 
Info: # Assembly Compiling expression @57/r_in 
Info: # Assembly Compiling expression r_in 
Info: # Assembly push r_in 
Info: Assembly 55: 6dc020 PushVar 4a87c136 
Info: # Assembly Compiling expression @57 
Info: # Assembly Compiling expression 0-@54 
Info: # Assembly Compiling expression @54 
Info: # Assembly push V/vin 
Info: Assembly 57: 6dc020 PushVar 4a87c136 
Info: # Assembly Compiling expression 0 
Info: # Assembly push 0 
Info: Assembly 59: 6dc320 Push 0 
Info: Assembly 61: 6dbb30 Minus 
Info: Assembly 62: 6db9f0 Div 
Info: Assembly 63: 6dbbd0 Plus 
Info: Assembly 64: 6dbe30 PopVar 1242a3b0 
Info: # Assembly Compiling expression V/vin+CONSTVALUE_0 
Info: # Assembly Compiling expression CONSTVALUE_0 
Info: # Assembly push CONSTVALUE_0 
Info: Assembly 66: 6dc320 Push 0.001 
Info: # Assembly Compiling expression V/vin 
Info: # Assembly Compiling expression vin 
Info: # Assembly push vin 
Info: Assembly 68: 6dc020 PushVar 4a87c136 
Info: # Assembly Compiling expression V 
Info: # Assembly push V 
Info: Assembly 70: 6dc020 PushVar 12362ce0 
Info: Assembly 72: 6db9f0 Div 
Info: Assembly 73: 6dbbd0 Plus 
Info: Assembly 74: 6dbe30 PopVar 12471570 
Info: # Assembly Compiling expression +(0-{V/vin})/r_in+(1.8-{V/vin})/(100-r_in) 
Info: # Assembly Compiling expression +(0-{V/vin})/r_in+(1.8-@80)/(100-r_in) 
Info: # Assembly Compiling expression +(0-@81)/r_in+(1.8-@80)/(100-r_in) 
Info: # Assembly Compiling expression +(0-@81)/r_in+(1.8-@80)/@82 
Info: # Assembly Compiling expression +(0-@81)/r_in+@83/@82 
Info: # Assembly Compiling expression +@84/r_in+@83/@82 
Info: # Assembly Compiling expression @83/@82 
Info: # Assembly Compiling expression @82 
Info: # Assembly Compiling expression 100-r_in 
Info: # Assembly Compiling expression r_in 
Info: # Assembly push r_in 
Info: Assembly 76: 6dc020 PushVar 4a87c136 
Info: # Assembly Compiling expression 100 
Info: # Assembly push 100 
Info: Assembly 78: 6dc320 Push 100 
Info: Assembly 80: 6dbb30 Minus 
Info: # Assembly Compiling expression @83 
Info: # Assembly Compiling expression 1.8-@80 
Info: # Assembly Compiling expression @80 
Info: # Assembly push V/vin 
Info: Assembly 81: 6dc020 PushVar 12471570 
Info: # Assembly Compiling expression 1.8 
Info: # Assembly push 1.8 
Info: Assembly 83: 6dc320 Push 1.8 
Info: Assembly 85: 6dbb30 Minus 
Info: Assembly 86: 6db9f0 Div 
Info: # Assembly Compiling expression +@84/r_in 
Info: # Assembly Compiling expression @84/r_in 
Info: # Assembly Compiling expression r_in 
Info: # Assembly push r_in 
Info: Assembly 87: 6dc020 PushVar 4a87c136 
Info: # Assembly Compiling expression @84 
Info: # Assembly Compiling expression 0-@81 
Info: # Assembly Compiling expression @81 
Info: # Assembly push V/vin 
Info: Assembly 89: 6dc020 PushVar 12471570 
Info: # Assembly Compiling expression 0 
Info: # Assembly push 0 
Info: Assembly 91: 6dc320 Push 0 
Info: Assembly 93: 6dbb30 Minus 
Info: Assembly 94: 6db9f0 Div 
Info: Assembly 95: 6dbbd0 Plus 
Info: Assembly 96: 6dbe30 PopVar 1246fcd0 
Info: # Assembly Compiling expression {V/vin}-CONSTVALUE_0*k2/(k2-k1) 
Info: # Assembly Compiling expression @102-CONSTVALUE_0*k2/(k2-k1) 
Info: # Assembly Compiling expression @102-CONSTVALUE_0*k2/@103 
Info: # Assembly Compiling expression CONSTVALUE_0*k2/@103 
Info: # Assembly Compiling expression k2/@103 
Info: # Assembly Compiling expression @103 
Info: # Assembly Compiling expression k2-k1 
Info: # Assembly Compiling expression k1 
Info: # Assembly push k1 
Info: Assembly 98: 6dc020 PushVar 1242a3b0 
Info: # Assembly Compiling expression k2 
Info: # Assembly push k2 
Info: Assembly 100: 6dc020 PushVar 1246fcd0 
Info: Assembly 102: 6dbb30 Minus 
Info: # Assembly Compiling expression k2 
Info: # Assembly push k2 
Info: Assembly 103: 6dc020 PushVar 1246fcd0 
Info: Assembly 105: 6db9f0 Div 
Info: # Assembly Compiling expression CONSTVALUE_0 
Info: # Assembly push CONSTVALUE_0 
Info: Assembly 106: 6dc320 Push 0.001 
Info: Assembly 108: 6dba90 Mult 
Info: # Assembly Compiling expression @102 
Info: # Assembly push V/vin 
Info: Assembly 109: 6dc020 PushVar 12471570 
Info: Assembly 111: 6dbb30 Minus 
Info: Assembly 112: 6dbe30 PopVar 12471570 
Info: # Assembly Compiling expression -Ids_p()+Ids_n() 
Info: # Assembly Compiling expression Ids_n() 
Info: # Assembly push Ids_n() 
Info: Assembly 114: 6dc020 PushVar 4a87c136 
Info: # Assembly Compiling expression -Ids_p() 
Info: # Assembly Compiling expression Ids_p() 
Info: # Assembly push Ids_p() 
Info: Assembly 116: 6dc020 PushVar 4a87c136 
Info: # Assembly Compiling expression 0 
Info: # Assembly push 0 
Info: Assembly 118: 6dc320 Push 0 
Info: Assembly 120: 6dbb30 Minus 
Info: Assembly 121: 6dbbd0 Plus 
Info: Assembly 122: 6dbe30 PopVar 1242a3b0 
Info: # Assembly Compiling expression V/mid+CONSTVALUE_0 
Info: # Assembly Compiling expression CONSTVALUE_0 
Info: # Assembly push CONSTVALUE_0 
Info: Assembly 124: 6dc320 Push 0.001 
Info: # Assembly Compiling expression V/mid 
Info: # Assembly Compiling expression mid 
Info: # Assembly push mid 
Info: Assembly 126: 6dc020 PushVar 4a87c136 
Info: # Assembly Compiling expression V 
Info: # Assembly push V 
Info: Assembly 128: 6dc020 PushVar 12362ce0 
Info: Assembly 130: 6db9f0 Div 
Info: Assembly 131: 6dbbd0 Plus 
Info: Assembly 132: 6dbe30 PopVar 12362d20 
Info: # Assembly Compiling expression -Ids_p()+Ids_n() 
Info: # Assembly Compiling expression Ids_n() 
Info: # Assembly push Ids_n() 
Info: Assembly 134: 6dc020 PushVar 4a87c136 
Info: # Assembly Compiling expression -Ids_p() 
Info: # Assembly Compiling expression Ids_p() 
Info: # Assembly push Ids_p() 
Info: Assembly 136: 6dc020 PushVar 4a87c136 
Info: # Assembly Compiling expression 0 
Info: # Assembly push 0 
Info: Assembly 138: 6dc320 Push 0 
Info: Assembly 140: 6dbb30 Minus 
Info: Assembly 141: 6dbbd0 Plus 
Info: Assembly 142: 6dbe30 PopVar 1246fcd0 
Info: # Assembly Compiling expression {V/mid}-CONSTVALUE_0*k2/(k2-k1) 
Info: # Assembly Compiling expression @129-CONSTVALUE_0*k2/(k2-k1) 
Info: # Assembly Compiling expression @129-CONSTVALUE_0*k2/@130 
Info: # Assembly Compiling expression CONSTVALUE_0*k2/@130 
Info: # Assembly Compiling expression k2/@130 
Info: # Assembly Compiling expression @130 
Info: # Assembly Compiling expression k2-k1 
Info: # Assembly Compiling expression k1 
Info: # Assembly push k1 
Info: Assembly 144: 6dc020 PushVar 1242a3b0 
Info: # Assembly Compiling expression k2 
Info: # Assembly push k2 
Info: Assembly 146: 6dc020 PushVar 1246fcd0 
Info: Assembly 148: 6dbb30 Minus 
Info: # Assembly Compiling expression k2 
Info: # Assembly push k2 
Info: Assembly 149: 6dc020 PushVar 1246fcd0 
Info: Assembly 151: 6db9f0 Div 
Info: # Assembly Compiling expression CONSTVALUE_0 
Info: # Assembly push CONSTVALUE_0 
Info: Assembly 152: 6dc320 Push 0.001 
Info: Assembly 154: 6dba90 Mult 
Info: # Assembly Compiling expression @129 
Info: # Assembly push V/mid 
Info: Assembly 155: 6dc020 PushVar 12362d20 
Info: Assembly 157: 6dbb30 Minus 
Info: Assembly 158: 6dbe30 PopVar 12362d20 
Info: Assembly 160: 6dcf90 Return 0 
