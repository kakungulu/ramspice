#include "ramspice_types.h"
#include "look_up_table.h"

ordinal nan_tag(float i_scalar) {
    so_union nt_scalar;
    nt_scalar.s=i_scalar;
    if ((nt_scalar.o&NAN_MASK)!=NAN_VALUE) return 0;
    nt_scalar.o&=NAN_UNMASK;
    return nt_scalar.o;
}

void tag_nan(LUT *a,ordinal index,ordinal i_ordinal) {
    so_union nt_scalar;
    nt_scalar.o=i_ordinal;
    nt_scalar.o&=NAN_UNMASK;
    nt_scalar.o|=NAN_VALUE;
    a->content[index]=nt_scalar.s;
}


void LUT_coord_to_key(LUT *a,float *coord,ordinal **key,float **weight) {
    linear_interpolation_table *L=a->LIT;
    int i;
    for (i=0;i<L->dim;i++) (*key)[i]=s2o((coord[i]-L->baseline[i])*L->inv_step[i]);
    for (i=0;i<L->dim;i++) (*weight)[i]=(coord[i]-L->baseline[i])*L->inv_step[i]-(*key)[i];
    for (i=0;i<L->dim;i++) if ((*weight)[i]<0) (*key)[i]--;
    for (i=0;i<L->dim;i++) if ((*weight)[i]<0) (*weight)[i]+=1;
}
float lut_interpolation_reversed(LUT *a,float *coord,int reversed_dim) {
    // Find the hypercube
    ordinal step=a->neighbors[reversed_dim];
    ordinal i;
    for (i=0;i<reversed_dim;i++) step*=a->size[i];
    ordinal index=0;
    ordinal key[$::MAXDIM];
    float weight[$::MAXDIM];
    ordinal j=0;
    for (i=0;i<a->dim;i++) {
        if (i==reversed_dim) continue;
        float scaled_coord=(coord[j++]-a->legend[i][0])/(a->legend[i][1]-a->legend[i][0]);
        key[i]=s2o(scaled_coord);
        weight[i]=scaled_coord-key[i];
        if (weight[i]<0) {
            key[i]--;
            weight[i]+=1;
        }
        index+=key[i]*a->neighbors[i];
    }
    float target=coord[a->dim-1];
    for (i=0;i<a->size[reversed_dim]-1;i++) {
        if ((a->content[index+i*step]<=target)&&(a->content[index+i*step+step]>=target)) {
            key[reversed_dim]=i;
            index+=i*step;
            break;
        }
    }
    // Get interpolated value at the wall of found hypercube
    float right_interpolation_buffer[MAXCUBE];
    float left_interpolation_buffer[MAXCUBE];
    ordinal num_of_corners;
    num_of_corners=1<<a->dim;
    ordinal corner;
    ordinal right_corner_counter=0;
    ordinal left_corner_counter=0;
    for (corner=0;i<num_of_corners;i++) if (corner&(1<<reversed_dim)) {
        right_interpolation_buffer[right_corner_counter++]=a->content[index+a->neighbors[corner]];
    } else {
        left_interpolation_buffer[left_corner_counter++]=a->content[index+a->neighbors[corner]];
    }
    ordinal breadth=num_of_corners/2;
    ordinal weighing_dim=0;
    while (breadth>1) {
        if (weighing_dim==reversed_dim) weighing_dim++;
        int j=0;
        for (i=0;i<breadth;i+=2) {
            right_interpolation_buffer[j]=(right_interpolation_buffer[i+1]-right_interpolation_buffer[i])*weight[weighing_dim]+right_interpolation_buffer[i];
            left_interpolation_buffer[j++]=(left_interpolation_buffer[i+1]-left_interpolation_buffer[i])*weight[weighing_dim]+left_interpolation_buffer[i];
        }
        breadth/=2;
        weighing_dim++;
    }
    float left_interpolation=left_interpolation_buffer[0];
    float right_interpolation=right_interpolation_buffer[0];
    while (left_interpolation>target) {
        right_interpolation=left_interpolation;
        index-=i*step;
        key[reversed_dim]--;
        right_corner_counter=0;
        left_corner_counter=0;
        for (corner=0;i<num_of_corners;i++) if (!(corner&(1<<reversed_dim))) left_interpolation_buffer[left_corner_counter++]=a->content[index+a->neighbors[corner]];
        breadth=num_of_corners/2;
        weighing_dim=0;
        while (breadth>1) {
            if (weighing_dim==reversed_dim) weighing_dim++;
            int j=0;
            for (i=0;i<breadth;i+=2) left_interpolation_buffer[j++]=(left_interpolation_buffer[i+1]-left_interpolation_buffer[i])*weight[weighing_dim]+left_interpolation_buffer[i];
            breadth/=2;
            weighing_dim++;
        }
        left_interpolation=left_interpolation_buffer[0];
    }
    while (right_interpolation<target) {
        left_interpolation=right_interpolation;
        index+=i*step;
        key[reversed_dim]++;
        right_corner_counter=0;
        for (corner=0;i<num_of_corners;i++) if (corner&(1<<reversed_dim)) right_interpolation_buffer[right_corner_counter++]=a->content[index+a->neighbors[corner]];
        breadth=num_of_corners/2;
        weighing_dim=0;
        while (breadth>1) {
            if (weighing_dim==reversed_dim) weighing_dim++;
            int j=0;
            for (i=0;i<breadth;i+=2) right_interpolation_buffer[j++]=(right_interpolation_buffer[i+1]-right_interpolation_buffer[i])*weight[weighing_dim]+right_interpolation_buffer[i];
            breadth/=2;
            weighing_dim++;
        }
        right_interpolation=right_interpolation_buffer[0];
    }
    float final_weight=(target-left_interpolation)/(right_interpolation-left_interpolation);
    float left_coord=a->legend[reversed_dim][key[reversed_dim]];
    float right_coord=a->legend[reversed_dim][key[reversed_dim]+1];
    return ((right_coord-left_coord)*final_weight+left_coord);
}
#For: {set DIM 1} {$DIM<$::MAXDIM} {incr DIM} {
    float lut_interpolation_${DIM}_deprecated(LUT *a,float *coord) {
        #tcl set num_of_corners [expr 1<<$DIM]
        Tcl_Time start_time,end_time; 
        Tcl_GetTime(&start_time);
        linear_interpolation_table *L=a->LIT;
        ordinal i,j,end;
        // Find the hyper-cube 
        float retval=0;
        ordinal index=0;
        ordinal lit_index=0;
        ordinal sizer=1;
        ordinal lit_sizer=1;
        //////////////////////////////////////////////////
        /////   HAN interpolation
        //////////////////////////////////////////////////
        if ((a->hit)&&(hit_enabled)) {
            ordinal index=0;
            float cell_top[$::DIM]; 
            float cell_bottom[$::DIM];
            #For: {set i 0} {$i<$::DIM} {incr i} {
                cell_top[$i]=a->legend[$i][a->size[$i]-1];
                cell_bottom[$i]=a->legend[$i][0];
		 #Dinfo: "Dim $i: Coord=%g Bottom=%g Top=%g" coord[$i] cell_bottom[$i] cell_top[$i]
            }
            // Find the relevant cell first
            bytecode_buffer_index=0;
            unsigned char bc=bc_byte();
            // Find initial cell
            while (!(bc&HIT_CELL)) { 
                ordinal dim=bc;
                float c=coord[dim];
                float level=bytecode_buffer[bytecode_buffer_index].F;
	         #Dinfo: "<%ld> bc=%02x coord=%g level=%g %8X (%g)" bytecode_buffer_index bc c level bytecode_buffer[bytecode_buffer_index].I bytecode_buffer[bytecode_buffer_index].F
                // Here's where the branching in the tree happens
                if (c<level) {
                    bytecode_buffer_index+=(bytecode_buffer[bytecode_buffer_index+1].I);
                    cell_top[dim]=level;
                } else {
		    bytecode_buffer_index+=2;
                    cell_bottom[dim]=level;
                }
                bc=bc_byte();
//	        #Dinfo: "At <%ld>: level=%g cell_bottom(%d)=%g cell_top(%d)=%g Next:0x%x at <%ld>" last_split_per_dim[dim] level dim cell_bottom[dim] dim cell_top[dim] bc bytecode_buffer_index-1
            }
	    float interpolation_buffer0=bytecode_buffer[bytecode_buffer_index].F;
            float neighbor_coord[$DIM];
	    ordinal tree_base=0;
            #tcl set prev_corner -1
            #For: {set corner 1} {$corner<1<<$DIM} {incr corner} {
                bytecode_buffer_index=tree_base;
                bc=bc_byte();
                #For: {set i 0} {$i<$DIM} {incr i} {
                    #If: {($prev_corner==-1)||(($corner&(1<<$i))!=($prev_corner&(1<<$i)))} {
                        #If: {$corner&(1<<$i)} {
                            neighbor_coord[$i]=cell_top[$i];
                        } {
                            neighbor_coord[$i]=cell_bottom[$i];
                        }
                    }
                }
                #tcl set prev_corner $corner
                while (!(bc&HIT_CELL)) { 
                    ordinal dim=bc;
                    float level=bytecode_buffer[bytecode_buffer_index].F;
//		    if ((neighbor_coord[dim]==level)&&(tree_base==0)) tree_base=bytecode_buffer_index;
                    // Here's where the branching in the tree happens
                    if (neighbor_coord[dim]<level) {
                        bytecode_buffer_index+=(bytecode_buffer[bytecode_buffer_index+1].I);
                    } else {
		        bytecode_buffer_index+=2;
                    }
                    bc=bc_byte();
                }
                float interpolation_buffer$corner=bytecode_buffer[bytecode_buffer_index].F;
		 #Dinfo: "Form %ld: interpolation_buffer$corner=%g" bytecode_buffer_index interpolation_buffer$corner
            }
            float weight1,weight2;
            float volume=1;
            #tcl set weighing_dim 0
            #For: {set breadth $num_of_corners} {$breadth>1} {set breadth [expr $breadth/2]} {
                #tcl set j 0
                volume*=(cell_top[$weighing_dim]-cell_bottom[$weighing_dim]);
                weight1=coord[$weighing_dim]-cell_bottom[$weighing_dim];
                weight2=cell_top[$weighing_dim]-coord[$weighing_dim];
                #For: {set i 0} {$i<$breadth} {incr i 2} {
                    #tcl set k [expr $i+1]
                    interpolation_buffer$j=interpolation_buffer$i*weight2+interpolation_buffer$k*weight1;
                    #tcl incr j
                }
                #tcl incr weighing_dim
            }
            retval=interpolation_buffer0/volume;
            Tcl_GetTime(&end_time);
            get_Tcl_timer+=end_time.sec*1e6+end_time.usec-start_time.sec*1e6-start_time.usec;
            get_Tcl_counter++;
            return(retval);
            
            //// Older HIT	    
            // Remove the cell-indicating bit and identify the type of interpolation to be performed
            bc^=HIT_CELL;
            if (bc&HIT_LIN_INTERP) {
                bc_float(&retval);
                float slope;
                #Dinfo: "Intercept=%g" retval
                #For: {set i 0} {$i<$DIM} {incr i} {
                    bc_float(&slope);
                    retval+=slope*coord[$i];
                    #Dinfo: "Slope=%g Coord=%g => %g" slope coord[$i] retval
                }    
                Tcl_GetTime(&end_time);
                get_Tcl_timer+=end_time.sec*1e6+end_time.usec-start_time.sec*1e6-start_time.usec;
                get_Tcl_counter++;
                return(retval);
            }
            if (bc&HIT_FULL_INTERP) {
                float weight1,weight2;
                float volume=cell_top[0]-cell_bottom[0];
                #tcl set weighing_dim 0
                #tcl set breadth $num_of_corners
                weight1=coord[$weighing_dim]-cell_bottom[$weighing_dim];
                weight2=cell_top[$weighing_dim]-coord[$weighing_dim];
                float X;
                float Y;
                #For: {set i 0} {$i<$breadth/2} {incr i} {
                    bc_float(&X);
                    #Dinfo: "Corner=%g" X
                    bc_float(&Y);
                    #Dinfo: "Corner=%g" Y
                    float interpolation_buffer$i=Y*weight1+X*weight2;
                }
                #tcl incr weighing_dim
                #For: {set breadth [expr $breadth/2]} {$breadth>1} {set breadth [expr $breadth/2]} {
                    #tcl set j 0
                    volume*=(cell_top[$weighing_dim]-cell_bottom[$weighing_dim]);
                    weight1=coord[$weighing_dim]-cell_bottom[$weighing_dim];
                    weight2=cell_top[$weighing_dim]-coord[$weighing_dim];
                    #For: {set i 0} {$i<$breadth} {incr i 2} {
                        #tcl set k [expr $i+1]
                        interpolation_buffer$j=interpolation_buffer$i*weight2+interpolation_buffer$k*weight1;
                        #tcl incr j
                    }
                    #tcl incr weighing_dim
                }
                retval=interpolation_buffer0/volume;
                Tcl_GetTime(&end_time);
                get_Tcl_timer+=end_time.sec*1e6+end_time.usec-start_time.sec*1e6-start_time.usec;
                get_Tcl_counter++;
                return(retval);
            }
            if (bc&HIT_CFULL_INTERP) {
                float baseline;
                bc_float(&baseline);
                float resolution_step;
                bc_float(&resolution_step);
                float weight1,weight2;
                float volume=cell_top[0]-cell_bottom[0];
                #tcl set weighing_dim 0
                #tcl set breadth $num_of_corners
                weight1=coord[$weighing_dim]-cell_bottom[$weighing_dim];
                weight2=cell_top[$weighing_dim]-coord[$weighing_dim];
                unsigned char bottom_corner;
                unsigned char top_corner;
                #For: {set i 0} {$i<$breadth/2} {incr i} {
                    bottom_corner=bc_byte();
                    #Dinfo: "Corner 0x%X" bottom_corner
                    bc_byte();
                    #Dinfo: "Corner 0x%X" top_corner
                    float interpolation_buffer$i=top_corner*weight1+bottom_corner*weight2;
                }
                #tcl incr weighing_dim
                #For: {set breadth [expr $breadth/2]} {$breadth>1} {set breadth [expr $breadth/2]} {
                    #tcl set j 0
                    volume*=(cell_top[$weighing_dim]-cell_bottom[$weighing_dim]);
                    weight1=coord[$weighing_dim]-cell_bottom[$weighing_dim];
                    weight2=cell_top[$weighing_dim]-coord[$weighing_dim];
                    #For: {set i 0} {$i<$breadth} {incr i 2} {
                        #tcl set k [expr $i+1]
                        interpolation_buffer$j=interpolation_buffer$i*weight2+interpolation_buffer$k*weight1;
                        #tcl incr j
                    }
                    #tcl incr weighing_dim
                }
                retval=resolution_step*interpolation_buffer0/volume+baseline;
                Tcl_GetTime(&end_time);
                get_Tcl_timer+=end_time.sec*1e6+end_time.usec-start_time.sec*1e6-start_time.usec;
                get_Tcl_counter++;
                return(retval);
            }
        }
        ordinal key[$DIM];
        int I;
        #For: {set i 0} {$i<$DIM} {incr i} {
            end=a->size[$i]-1;
            if (a->legend[$i][end]>a->legend[$i][0]) {
                if (coord[$i]<=a->legend[$i][0]) {
                    key[$i]=0;
                    // #Warning: "Undershoot %g<%g" coord[$i] a->legend[$i][0]
                } else if (coord[$i]>=a->legend[$i][end]) {
                    key[$i]=end-1;
                    // #Warning: "Overshoot %g>%g" coord[$i] a->legend[$i][end]
                } else {
                    ordinal pre=0;
                    ordinal post=end;
                    while (post-pre>1) {
                        ordinal mid=(post+pre)/2;
                        if (coord[$i]>=a->legend[$i][mid]) {
                            pre=mid;
                        } else {
                            post=mid;
                        }
                    }
                    key[$i]=pre;
                }	
            } else {
                if (coord[$i]>=a->legend[$i][0]) {
                    key[$i]=0;
                    // #Warning: "Undershoot %g>%g" coord[$i] a->legend[$i][0]
                } else if (coord[$i]<=a->legend[$i][end]) {
                    key[$i]=end-1;
                    // #Warning: "Overshoot %g<%g" coord[$i] a->legend[$i][end]
                } else {
                    ordinal pre=0;
                    ordinal post=end;
                    while (post-pre>1) {
                        ordinal mid=(post+pre)/2;
                        if (coord[$i]<=a->legend[$i][mid]) {
                            pre=mid;
                        } else {
                            post=mid;
                        }
                    }
                    key[$i]=pre;
                }	
            }	
            index+=key[$i]*sizer;
            lit_index+=key[$i]*lit_sizer;
            sizer*=a->size[$i];
            lit_sizer*=(a->size[$i]-1);
        }
        if (L) {
            float *slopes=&(L->content[lit_index*($DIM+1)]);
            float intercept=slopes[$DIM];
            //       ordinal prom_dim=nan_tag(intercept);
            if (intercept!=0) {
                              #Dinfo: "Linear " 
                retval=intercept;
                #For: {set i 0} {$i<$DIM} {incr i} {
                    retval+=slopes[$i]*coord[$i];
                }    
                goto interpolation_time_$DIM;
            }
        }
            #Dinfo: "Full  " 
        // Full interpolation, refer back to the original array
        #For: {set corner 0} {$corner<$num_of_corners} {incr corner} {
            float interpolation_buffer$corner=a->content[index+a->neighbors[$corner]];
	    #Dinfo: "interpolation_buffer$corner=%g" interpolation_buffer$corner
        }
        #tcl set weighing_dim 0
        float weight;
        #For: {set breadth $num_of_corners} {$breadth>1} {set breadth [expr $breadth/2]} {
            #tcl set j 0
            weight=(coord[$weighing_dim]-a->legend[$weighing_dim][key[$weighing_dim]])/(a->legend[$weighing_dim][key[$weighing_dim]+1]-a->legend[$weighing_dim][key[$weighing_dim]]);
            #For: {set i 0} {$i<$breadth} {incr i 2} {
                #tcl set k [expr $i+1]
                interpolation_buffer$j=(interpolation_buffer$k-interpolation_buffer$i)*weight+interpolation_buffer$i;
                #tcl incr j
            }
            #tcl incr weighing_dim
        }
        retval=interpolation_buffer0;
        interpolation_time_$DIM:
        Tcl_GetTime(&end_time);
        get_Tcl_timer+=end_time.sec*1e6+end_time.usec-start_time.sec*1e6-start_time.usec;
        get_Tcl_counter++;
        return(retval);
    }
}
#For: {set DIM 1} {$DIM<$::MAXDIM} {incr DIM} {
    float lut_interpolation_$DIM(void *i_a,float *coord) {
        #tcl set num_of_corners [expr 1<<$DIM]
	LUT *a=(LUT *)i_a;
        Tcl_Time start_time,end_time; 
        Tcl_GetTime(&start_time);
   //     linear_interpolation_table *L=a->LIT;
        ordinal i,j,end;
        // Find the hyper-cube 
        float retval=0;
        ordinal index=0;
 //       ordinal lit_index=0;
//        ordinal sizer=1;
 //       ordinal lit_sizer=1;
    //    int I;
	/*
        #For: {set i 0} {$i<$DIM} {incr i} {
            end=a->size[$i]-1;
            if (a->legend[$i][end]>a->legend[$i][0]) {
                if (coord[$i]<=a->legend[$i][0]) {
                    key[$i]=0;
                    // #Warning: "Undershoot %g<%g" coord[$i] a->legend[$i][0]
                } else if (coord[$i]>=a->legend[$i][end]) {
                    key[$i]=end-1;
                    // #Warning: "Overshoot %g>%g" coord[$i] a->legend[$i][end]
                } else {
                    ordinal pre=0;
                    ordinal post=end;
                    while (post-pre>1) {
                        ordinal mid=(post+pre)/2;
                        if (coord[$i]>=a->legend[$i][mid]) {
                            pre=mid;
                        } else {
                            post=mid;
                        }
                    }
                    key[$i]=pre;
                }	
            } else {
                if (coord[$i]>=a->legend[$i][0]) {
                    key[$i]=0;
                    // #Warning: "Undershoot %g>%g" coord[$i] a->legend[$i][0]
                } else if (coord[$i]<=a->legend[$i][end]) {
                    key[$i]=end-1;
                    // #Warning: "Overshoot %g<%g" coord[$i] a->legend[$i][end]
                } else {
                    ordinal pre=0;
                    ordinal post=end;
                    while (post-pre>1) {
                        ordinal mid=(post+pre)/2;
                        if (coord[$i]<=a->legend[$i][mid]) {
                            pre=mid;
                        } else {
                            post=mid;
                        }
                    }
                    key[$i]=pre;
                }	
            }	
            index+=key[$i]*sizer;
            lit_index+=key[$i]*lit_sizer;
            sizer*=a->size[$i];
            lit_sizer*=(a->size[$i]-1);
        }
	*/
	float i_f;
        #For: {set i 0} {$i<$DIM} {incr i} {
	    i_f=(coord[$i]-a->legend[$i][0])*a->physical_factor[$i];
	     #Dinfo: "coord$i=%g base=%g next=%g factor=%g Key=%g" coord[$i] a->legend[$i][0] a->legend[$i][1] a->physical_factor[$i] i_f
	    int key${i}=(int)i_f;
	    if (key${i}<0) key${i}=0;
	    if (key${i}>=a->size[$i]-1) key${i}=a->size[$i]-2;
            index+=key${i}*a->sizer[$i];
	     #Dinfo: "key$i=%d/%d %d index=%ld" key${i} a->size[$i]  a->sizer[$i] index
//            lit_index+=key${i}*lit_sizer;
//            sizer*=a->size[$i];
//            lit_sizer*=(a->size[$i]-1);
	}    
	
	/*
        if (L) {
            float *slopes=&(L->content[lit_index*($DIM+1)]);
            float intercept=slopes[$DIM];
            //       ordinal prom_dim=nan_tag(intercept);
            if (intercept!=0) {
                //               #Dinfo: "Linear " 
                retval=intercept;
                #For: {set i 0} {$i<$DIM} {incr i} {
                    retval+=slopes[$i]*coord[$i];
                }    
                goto interpolation_time_$DIM;
            }
        }
	*/
        //     #Dinfo: "Full  " 
        // Full interpolation, refer back to the original array
	float *hypercube=&(a->content[index]);
        #For: {set corner 0} {$corner<$num_of_corners} {incr corner} {
            float interpolation_buffer$corner=hypercube[a->neighbors[$corner]];
	     #Dinfo: "Corner $corner=%g" interpolation_buffer$corner
        }
	float w1,w2;
        #tcl set weighing_dim 0
        #For: {set breadth $num_of_corners} {$breadth>1} {set breadth [expr $breadth/2]} {
	     #Dinfo: "Dim $weighing_dim: key=%d %x" key${weighing_dim} coord
	    w1=coord[$weighing_dim]-a->legend[$weighing_dim][key${weighing_dim}];
	    w2=a->legend[$weighing_dim][key${weighing_dim}+1]-coord[$weighing_dim];
            #tcl set j 0
	     #Dinfo: "Dim $weighing_dim: key=%d %g (%g,%g) (%g,%g)" key${weighing_dim}  coord[$weighing_dim] a->legend[$weighing_dim][key${weighing_dim}] a->legend[$weighing_dim][key${weighing_dim}+1] w1 w2
            #For: {set i 0} {$i<$breadth} {incr i 2} {
                #tcl set k [expr $i+1]
                interpolation_buffer$j=interpolation_buffer$k*w1+interpolation_buffer$i*w2;
		 #Dinfo: "interpolation_buffer$j=%g" interpolation_buffer$j
                #tcl incr j
            }
            #tcl incr weighing_dim
        }
        retval=interpolation_buffer0/a->hypercube_volume;
        interpolation_time_$DIM:
        Tcl_GetTime(&end_time);
        get_Tcl_timer+=end_time.sec*1e6+end_time.usec-start_time.sec*1e6-start_time.usec;
        get_Tcl_counter++;
        return(retval);
    }
} 
#For: {set DIM 1} {$DIM<$::MAXDIM} {incr DIM} {
    void lut_gamma_interpolation_$DIM(void *i_a) {
        #Dinfo: "Gamma machine's interpolation function for ${DIM}D  (Starting from %ld)" GammaVirtualMachineStackIndex
        #tcl set num_of_corners [expr 1<<$DIM]
	LUT *a=(LUT *)i_a;
        Tcl_Time start_time,end_time; 
        Tcl_GetTime(&start_time);
   //     linear_interpolation_table *L=a->LIT;
        ordinal i,j,end;
        // Find the hyper-cube 
        float retval=0;
        ordinal index=0;
	float i_f;
        #For: {set i 0} {$i<$DIM} {incr i} {
	    int key${i};
                i_f=(GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2+$i].F-a->legend[$i][0])*a->physical_factor[$i];
	    if (a->physical_factor[$i]>0) {
	        key${i}=(int)i_f;
	    } else {
	        key${i}=-((int)(-i_f));
	    }
	    #Dinfo: "coord$i=%g base=%g factor=%g Key=%g" GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2+$i].F a->legend[$i][0] a->physical_factor[$i] i_f
	    if (key${i}<0) key${i}=0;
	    if (key${i}>=a->size[$i]-1) key${i}=a->size[$i]-2;
            index+=key${i}*a->sizer[$i];
	    #Dinfo: "key$i=%d/%d %d index=%ld" key${i} a->size[$i]  a->sizer[$i] index
	}    
        // Full interpolation, refer back to the original array
	float *hypercube=&(a->content[index]);
        #For: {set corner 0} {$corner<$num_of_corners} {incr corner} {
            float interpolation_buffer$corner=hypercube[a->neighbors[$corner]];
	    #Dinfo: "Corner $corner=%g" interpolation_buffer$corner
        }
	float w1,w2;
        #tcl set weighing_dim 0
        #For: {set breadth $num_of_corners} {$breadth>1} {set breadth [expr $breadth/2]} {
	    #Dinfo: "Dim $weighing_dim: key=%d" key${weighing_dim} 
	    w1=GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2+$weighing_dim].F-a->legend[$weighing_dim][key${weighing_dim}];
	    w2=a->legend[$weighing_dim][key${weighing_dim}+1]-GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2+$weighing_dim].F;
            #tcl set j 0
	    #Dinfo: "Dim $weighing_dim: key=%d %g (%g,%g) (%g,%g)" key${weighing_dim}  GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2+$weighing_dim].F a->legend[$weighing_dim][key${weighing_dim}] a->legend[$weighing_dim][key${weighing_dim}+1] w1 w2
            #For: {set i 0} {$i<$breadth} {incr i 2} {
                #tcl set k [expr $i+1]
                interpolation_buffer$j=interpolation_buffer$k*w1+interpolation_buffer$i*w2;
		#Dinfo: "interpolation_buffer$j=%g" interpolation_buffer$j
                #tcl incr j
            }
            #tcl incr weighing_dim
        }
	GammaVirtualMachineStackIndex+=$DIM;
        GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F=interpolation_buffer0/a->hypercube_volume;
        interpolation_time_$DIM:
        Tcl_GetTime(&end_time);
        get_Tcl_timer+=end_time.sec*1e6+end_time.usec-start_time.sec*1e6-start_time.usec;
        get_Tcl_counter++;
    }
} 
#For: {set DIM 1} {$DIM<$::MAXDIM} {incr DIM} {
    float gamma_gcc_interpolate_$DIM(void *i_a
        #For: {set j 0} {$j<$DIM} {incr j} {
            ,float c$j
	}
    ) {
        #Dinfo: "Gamma machine's interpolation function for ${DIM}D " 
        #tcl set num_of_corners [expr 1<<$DIM]
	LUT *a=(LUT *)i_a;
        Tcl_Time start_time,end_time; 
        Tcl_GetTime(&start_time);
   //     linear_interpolation_table *L=a->LIT;
        ordinal i,j,end;
        // Find the hyper-cube 
        float retval=0;
        ordinal index=0;
	float i_f;
        #For: {set i 0} {$i<$DIM} {incr i} {
	    int key${i};
                i_f=(c$i-a->legend[$i][0])*a->physical_factor[$i];
	    if (a->physical_factor[$i]>0) {
	        key${i}=(int)i_f;
	    } else {
	        key${i}=-((int)(-i_f));
	    }
	    #Dinfo: "coord$i=%g base=%g factor=%g Key=%g" c$i a->legend[$i][0] a->physical_factor[$i] i_f
	    if (key${i}<0) key${i}=0;
	    if (key${i}>=a->size[$i]-1) key${i}=a->size[$i]-2;
            index+=key${i}*a->sizer[$i];
	    #Dinfo: "key$i=%d/%d %d index=%ld" key${i} a->size[$i]  a->sizer[$i] index
	}    
        // Full interpolation, refer back to the original array
	float *hypercube=&(a->content[index]);
        #For: {set corner 0} {$corner<$num_of_corners} {incr corner} {
            float interpolation_buffer$corner=hypercube[a->neighbors[$corner]];
	    #Dinfo: "Corner $corner=%g" interpolation_buffer$corner
        }
	float w1,w2;
        #tcl set weighing_dim 0
        #For: {set breadth $num_of_corners} {$breadth>1} {set breadth [expr $breadth/2]} {
	    #Dinfo: "Dim $weighing_dim: key=%d" key${weighing_dim} 
	    w1=c$weighing_dim-a->legend[$weighing_dim][key${weighing_dim}];
	    w2=a->legend[$weighing_dim][key${weighing_dim}+1]-c$weighing_dim;
            #tcl set j 0
	    #Dinfo: "Dim $weighing_dim: key=%d %g (%g,%g) (%g,%g)" key${weighing_dim}  c$weighing_dim a->legend[$weighing_dim][key${weighing_dim}] a->legend[$weighing_dim][key${weighing_dim}+1] w1 w2
            #For: {set i 0} {$i<$breadth} {incr i 2} {
                #tcl set k [expr $i+1]
                interpolation_buffer$j=interpolation_buffer$k*w1+interpolation_buffer$i*w2;
		#Dinfo: "interpolation_buffer$j=%g" interpolation_buffer$j
                #tcl incr j
            }
            #tcl incr weighing_dim
        }
        Tcl_GetTime(&end_time);
        get_Tcl_timer+=end_time.sec*1e6+end_time.usec-start_time.sec*1e6-start_time.usec;
        get_Tcl_counter++;
	#Dinfo: "Result=%g/%g=%g" interpolation_buffer0 a->hypercube_volume interpolation_buffer0/a->hypercube_volume
	return(interpolation_buffer0/a->hypercube_volume);
    }
} 
#For: {set DIM 1} {$DIM<$::MAXDIM} {incr DIM} {
    void lut_gamma_gradient_$DIM(void *i_a) {
     #Dinfo: "Gamma machine's gradient function for ${DIM}D  (Starting from %ld)" GammaVirtualMachineStackIndex
        #tcl set num_of_corners [expr 1<<$DIM]
	LUT *a=(LUT *)i_a;
        Tcl_Time start_time,end_time; 
        Tcl_GetTime(&start_time);
        ordinal i,j,end;
        // Find the hyper-cube 
        float retval=0;
        ordinal index=0;
	float i_f;
        #For: {set i 0} {$i<$DIM} {incr i} {
	    i_f=(GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2+$i].F-a->legend[$i][0])*a->physical_factor[$i];
	    #Dinfo: "coord$i=%g base=%g factor=%g Key=%g" GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2+$i].F a->legend[$i][0] a->physical_factor[$i] i_f
	    int key${i}=(int)i_f;
	    if (key${i}<0) key${i}=0;
	    if (key${i}>=a->size[$i]-1) key${i}=a->size[$i]-2;
            index+=key${i}*a->sizer[$i];
	    #Dinfo: "key$i=%d/%d %d index=%ld" key${i} a->size[$i]  a->sizer[$i] index
	}    
        // Full interpolation, refer back to the original array
	float *hypercube=&(a->content[index]);
        #For: {set corner 0} {$corner<$num_of_corners} {incr corner} {
            float interpolation_buffer$corner=hypercube[a->neighbors[$corner]];
	    #Dinfo: "Corner $corner=%g" interpolation_buffer$corner
        }
	float w1,w2;
        #tcl set weighing_dim 0
        #For: {set breadth $num_of_corners} {$breadth>1} {set breadth [expr $breadth/2]} {
	    #Dinfo: "Dim $weighing_dim: key=%d" key${weighing_dim} 
	    w1=GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2+$weighing_dim].F-a->legend[$weighing_dim][key${weighing_dim}];
	    w2=a->legend[$weighing_dim][key${weighing_dim}+1]-GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2+$weighing_dim].F;
            #tcl set j 0
	    #Dinfo: "Dim $weighing_dim: key=%d %g (%g,%g) (%g,%g)" key${weighing_dim}  GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2+$weighing_dim].F a->legend[$weighing_dim][key${weighing_dim}] a->legend[$weighing_dim][key${weighing_dim}+1] w1 w2
            #For: {set i 0} {$i<$breadth} {incr i 2} {
                #tcl set k [expr $i+1]
                interpolation_buffer$j=interpolation_buffer$k*w1+interpolation_buffer$i*w2;
		float gradient_buffer${weighing_dim}_$j=interpolation_buffer$k-interpolation_buffer$i;
		#For: {set l 0} {$l<$weighing_dim} {incr l} {
		    gradient_buffer${l}_$j=gradient_buffer${l}_$k*w1+gradient_buffer${l}_$i*w2;
		    #Dinfo: "grad_buffer${l}_$j=%g" gradient_buffer${l}_$j
		}
		#Dinfo: "interpolation_buffer$j=%g" interpolation_buffer$j
                #tcl incr j
            }
            #tcl incr weighing_dim
        }
	GammaVirtualMachineStackIndex+=$DIM;
	float *derivative;
	#For: {set i 0} {$i<$DIM} {incr i} { 
	    derivative=GammaVirtualMachineStack[GammaVirtualMachineStackIndex+2+$i].P;
	    #Dinfo: "Accessing %d/%d  %x=%g" GammaVirtualMachineStackIndex+2+$i GammaVirtualMachineStackSize derivative gradient_buffer${i}_0/a->hypercube_volume
	    if (derivative) {
                *derivative=gradient_buffer${i}_0/a->hypercube_volume;
	    }
	    #Dinfo: "Derivative %d: %g" $i *derivative
	}    
	GammaVirtualMachineStackIndex+=$DIM;
        GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F=interpolation_buffer0/a->hypercube_volume;
	#Dinfo: "Result: %g => %d" GammaVirtualMachineStack[GammaVirtualMachineStackIndex+1].F GammaVirtualMachineStackIndex+1
        interpolation_time_$DIM:
        Tcl_GetTime(&end_time);
        get_Tcl_timer+=end_time.sec*1e6+end_time.usec-start_time.sec*1e6-start_time.usec;
        get_Tcl_counter++;
    }
} 
#For: {set DIM 1} {$DIM<$::MAXDIM} {incr DIM} {
    float gamma_gcc_interpolateg_$DIM(
        void *i_a
        #For: {set j 0} {$j<$DIM} {incr j} {
            ,float c$j
	}
        #For: {set j 0} {$j<$DIM} {incr j} {
            ,float *p$j
	}
    ) {
     #Dinfo: "Gamma machine's gradient function for ${DIM}D LUT is %x" i_a
     #For: {set i 0} {$i<$DIM} {incr i} { 
    	#Dinfo: "Input $i is %g" c$i
	}
     #For: {set i 0} {$i<$DIM} {incr i} { 
    	#Dinfo: "Derivative $i goes back to (%x)" p$i
	}
        #tcl set num_of_corners [expr 1<<$DIM]
	LUT *a=(LUT *)i_a;
        Tcl_Time start_time,end_time; 
        Tcl_GetTime(&start_time);
        ordinal i,j,end;
        // Find the hyper-cube 
        float retval=0;
        ordinal index=0;
	float i_f;
        #For: {set i 0} {$i<$DIM} {incr i} {
	    i_f=(c$i-a->legend[$i][0])*a->physical_factor[$i];
	    #Dinfo: "coord$i=%g base=%g factor=%g Key=%g" c$i a->legend[$i][0] a->physical_factor[$i] i_f
	    int key${i}=(int)i_f;
	    if (key${i}<0) key${i}=0;
	    if (key${i}>=a->size[$i]-1) key${i}=a->size[$i]-2;
            index+=key${i}*a->sizer[$i];
	    #Dinfo: "key$i=%d/%d %d index=%ld" key${i} a->size[$i]  a->sizer[$i] index
	}    
        // Full interpolation, refer back to the original array
	float *hypercube=&(a->content[index]);
        #For: {set corner 0} {$corner<$num_of_corners} {incr corner} {
            float interpolation_buffer$corner=hypercube[a->neighbors[$corner]];
	    #Dinfo: "Corner $corner=%g" interpolation_buffer$corner
        }
	float w1,w2;
        #tcl set weighing_dim 0
        #For: {set breadth $num_of_corners} {$breadth>1} {set breadth [expr $breadth/2]} {
	    #Dinfo: "Dim $weighing_dim: key=%d" key${weighing_dim} 
	    w1=c$weighing_dim-a->legend[$weighing_dim][key${weighing_dim}];
	    w2=a->legend[$weighing_dim][key${weighing_dim}+1]-c$weighing_dim;
            #tcl set j 0
	    #Dinfo: "Dim $weighing_dim: key=%d %g (%g,%g) (%g,%g)" key${weighing_dim}  c$weighing_dim a->legend[$weighing_dim][key${weighing_dim}] a->legend[$weighing_dim][key${weighing_dim}+1] w1 w2
            #For: {set i 0} {$i<$breadth} {incr i 2} {
                #tcl set k [expr $i+1]
                interpolation_buffer$j=interpolation_buffer$k*w1+interpolation_buffer$i*w2;
		float gradient_buffer${weighing_dim}_$j=interpolation_buffer$k-interpolation_buffer$i;
		#For: {set l 0} {$l<$weighing_dim} {incr l} {
		    gradient_buffer${l}_$j=gradient_buffer${l}_$k*w1+gradient_buffer${l}_$i*w2;
		    #Dinfo: "grad_buffer${l}_$j=%g" gradient_buffer${l}_$j
		}
		#Dinfo: "Interpolation Buffer $j=%g" interpolation_buffer$j
                #tcl incr j
            }
            #tcl incr weighing_dim
        }
	#Dinfo: "Interpolation is DONE"
	#For: {set i 0} {$i<$DIM} {incr i} { 
	    #Dinfo: "Sending derivative back to p$i (%x)" p$i
	    if (p$i) *p$i=gradient_buffer${i}_0/a->hypercube_volume;
	    #Dinfo: "Derivative %d: %g" $i *p$i
	}    
	#Dinfo: "Result: %g" interpolation_buffer0/a->hypercube_volume
        interpolation_time_$DIM:
        Tcl_GetTime(&end_time);
        get_Tcl_timer+=end_time.sec*1e6+end_time.usec-start_time.sec*1e6-start_time.usec;
        get_Tcl_counter++;
         #Dinfo: "DONE: Gamma machine's gradient function for ${DIM}D" 
	return(interpolation_buffer0/a->hypercube_volume);
    }
} 
#For: {set DIM 1} {$DIM<$::MAXDIM} {incr DIM} {
    float lut_cluster_interpolation_$DIM(LUT *a,float *coord,cluster **i_cluster) {
        #tcl set num_of_corners [expr 1<<$DIM]
        float retval=0;
        if (*i_cluster) {
            #For: {set corner 0} {$corner<$num_of_corners} {incr corner} {
                float interpolation_buffer$corner=(*i_cluster)->interpolation_buffer[$corner];
	    }
            #tcl set weighing_dim 0
            #For: {set breadth $num_of_corners} {$breadth>1} {set breadth [expr $breadth/2]} {
                #tcl set j 0
                #For: {set i 0} {$i<$breadth} {incr i 2} {
                    #tcl set k [expr $i+1]
                    interpolation_buffer$j=interpolation_buffer$k*(coord[$weighing_dim]-(*i_cluster)->lower_margin[$weighing_dim])+interpolation_buffer$i*((*i_cluster)->upper_margin[$weighing_dim]-coord[$weighing_dim]);
                    #tcl incr j
                }
                #tcl incr weighing_dim
            }
            retval=interpolation_buffer0/(*i_cluster)->hyper_volume;
            return(retval);
	}
        Tcl_Time start_time,end_time; 
        Tcl_GetTime(&start_time);
        linear_interpolation_table *L=a->LIT;
        ordinal i,j,end;
        // Find the hyper-cube 
        ordinal index=0;
        ordinal lit_index=0;
        ordinal sizer=1;
        ordinal lit_sizer=1;
        ordinal key[$DIM];
	*i_cluster=(cluster *)malloc(sizeof(cluster)); 
	(*i_cluster)->interpolation_buffer=(float *)malloc(sizeof(float)*$num_of_corners);
        int I;
        #For: {set i 0} {$i<$DIM} {incr i} {
            end=a->size[$i]-1;
            if (a->legend[$i][end]>a->legend[$i][0]) {
                if (coord[$i]<=a->legend[$i][0]) {
                    key[$i]=0;
                    // #Warning: "Undershoot %g<%g" coord[$i] a->legend[$i][0]
                } else if (coord[$i]>=a->legend[$i][end]) {
                    key[$i]=end-1;
                    // #Warning: "Overshoot %g>%g" coord[$i] a->legend[$i][end]
                } else {
                    ordinal pre=0;
                    ordinal post=end;
                    while (post-pre>1) {
                        ordinal mid=(post+pre)/2;
                        if (coord[$i]>=a->legend[$i][mid]) {
                            pre=mid;
                        } else {
                            post=mid;
                        }
                    }
                    key[$i]=pre;
                }	
            } else {
                if (coord[$i]>=a->legend[$i][0]) {
                    key[$i]=0;
                    // #Warning: "Undershoot %g>%g" coord[$i] a->legend[$i][0]
                } else if (coord[$i]<=a->legend[$i][end]) {
                    key[$i]=end-1;
                    // #Warning: "Overshoot %g<%g" coord[$i] a->legend[$i][end]
                } else {
                    ordinal pre=0;
                    ordinal post=end;
                    while (post-pre>1) {
                        ordinal mid=(post+pre)/2;
                        if (coord[$i]<=a->legend[$i][mid]) {
                            pre=mid;
                        } else {
                            post=mid;
                        }
                    }
                    key[$i]=pre;
                }	
            }	
            index+=key[$i]*sizer;
            lit_index+=key[$i]*lit_sizer;
            sizer*=a->size[$i];
            lit_sizer*=(a->size[$i]-1);
            (*i_cluster)->lower_margin[$i]=a->legend[$i][key[$i]];
            (*i_cluster)->upper_margin[$i]=a->legend[$i][key[$i]+1];
        }
            #Dinfo: "Full  " 
        // Full interpolation, refer back to the original array
        #For: {set corner 0} {$corner<$num_of_corners} {incr corner} {
            float interpolation_buffer$corner=a->content[index+a->neighbors[$corner]];
	    (*i_cluster)->interpolation_buffer[$corner]=interpolation_buffer$corner;
        }
        #tcl set weighing_dim 0
        float weight;
        float hyper_volume=1;
        #For: {set breadth $num_of_corners} {$breadth>1} {set breadth [expr $breadth/2]} {
            #tcl set j 0
            weight=(coord[$weighing_dim]-a->legend[$weighing_dim][key[$weighing_dim]]);
	    hyper_volume*=(a->legend[$weighing_dim][key[$weighing_dim]+1]-a->legend[$weighing_dim][key[$weighing_dim]]);
            #For: {set i 0} {$i<$breadth} {incr i 2} {
                #tcl set k [expr $i+1]
                interpolation_buffer$j=(interpolation_buffer$k-interpolation_buffer$i)*weight+interpolation_buffer$i;
                #tcl incr j
            }
            #tcl incr weighing_dim
        }
	(*i_cluster)->hyper_volume=hyper_volume;
        retval=interpolation_buffer0/hyper_volume;
        interpolation_time_$DIM:
        Tcl_GetTime(&end_time);
        get_Tcl_timer+=end_time.sec*1e6+end_time.usec-start_time.sec*1e6-start_time.usec;
        get_Tcl_counter++;
        return(retval);
    }
}
float generate_lit(LUT *a,linear_interpolation_table *L,ordinal i_index) {
    int i;
    // Find the hyper-cube 
    ordinal key[$::MAXDIM];
    float retval=0;
    ordinal index=i_index*(a->dim+1);
    float *slopes=&(L->content[index]);
    ordinal tmp_index=i_index;
    for (i=a->dim-1;i>=0;i--) {
        key[i]=tmp_index/L->index_weight[i];
        	#Dinfo: "key(%d)=%d" i key[i]
        tmp_index%=L->index_weight[i];
    }
    // First, check lower-left-closest corner for possible pre-calculated slopes
    ordinal sizer=1;
    ordinal array_index=0;
    for (i=0;i<a->dim;i++) {
        array_index+=sizer*(key[i]);
        sizer*=a->size[i];
    }
        #Dinfo: "i_index=%d index=%d array_index=%d" i_index index array_index
    float constant=0;
    float midpoint[$::MAXDIM];
    ordinal l=1;
    for (i=0;i<a->dim;i++) {
        slopes[i]=0;
        l*=2;
        midpoint[i]=(a->legend[i][key[i]]+a->legend[i][key[i]+1])/2;
    }    
    l/=2;
    ordinal corner=0;
    ordinal num_of_corners;
    num_of_corners=1<<a->dim;
    for (corner=0;corner<num_of_corners;corner++) {
        ordinal corner_index=array_index+a->neighbors[corner];
        float corner_value=a->content[corner_index];
        // constant is pre-loaded with the average between all points
        constant+=corner_value;
        ordinal tmp_corner=corner;
        for (i=0;i<a->dim;i++) {
            if (tmp_corner&1) {
                slopes[i]+=corner_value;
            } else {
                slopes[i]-=corner_value;
            }
            // next bit
            tmp_corner>>=1;
        }
    } 
    // Normalizing constant to the average
    constant/=l;
    constant/=2;
    for (i=0;i<a->dim;i++) {
        // Normalizing each slope
        slopes[i]/=l;
        slopes[i]=slopes[i]/(a->legend[i][key[i]+1]-a->legend[i][key[i]]);
                #Dinfo: "slope(%d)=%g" i slopes[i]
        // subtracting the regression from the average -> the midpoint regression is now anchored to the average between hypercube's points.
        constant-=slopes[i]*midpoint[i];
    }  
    slopes[a->dim]=constant;
        #Dinfo: "intercept=%g" constant
    ////////////////////////////////////// Testing:
    float max_error=0;
    for (corner=0;corner<num_of_corners;corner++) {
        ordinal index=0;
        // scratch 'tmp' to roll the corner bits without destroying corner itself:
        ordinal tmp_corner=corner;
        float interpolated_value=slopes[a->dim];
        tmp_corner=corner;
        for (i=0;i<a->dim;i++) {
            interpolated_value+=slopes[i]*a->legend[i][key[i]+(tmp_corner&1)];
            tmp_corner>>=1;
        }  
        float original_value=a->content[array_index+a->neighbors[corner]];
        float error=100*fabs((original_value-interpolated_value)/original_value);
        	#Dinfo: "original_value=%g interpolated_value=%g" original_value interpolated_value
        if (fabs((original_value-interpolated_value))<1e-12) error=0.1;
        if (error>max_error) max_error=error;
    }
        #Dinfo: "max_error=%g" max_error
    if (max_error<1.0) return max_error;
    // Staying with full interpolation
    so_union sob;
    sob.o=$::MAXDIM;
    sob.o&=NAN_UNMASK;
    sob.o|=NAN_VALUE;
    slopes[a->dim]=sob.s;
    slopes[a->dim]=0;
    return 100.0;
}

void new_linear_interpolation_table(LUT *a) {
    linear_interpolation_table *L;
    L=(linear_interpolation_table *)malloc(sizeof(linear_interpolation_table));
    a->LIT=L;
    L->dim=a->dim;
    L->size=(ordinal *)malloc(sizeof(ordinal)*L->dim);
    L->index_weight=(ordinal *)malloc(sizeof(ordinal)*L->dim);
    L->baseline=(float *)malloc(sizeof(scalar)*L->dim);
    L->inv_step=(float *)malloc(sizeof(scalar)*L->dim);
    ordinal i;
    L->volume=1;
    for (i=0;i<a->dim;i++) {
        L->size[i]=-1;
        ordinal tmp=a->size[i];
        while (tmp) {
            L->size[i]++;
            tmp/=2;
        }
        L->index_weight[i]=L->volume;
        L->volume*=(a->size[i]-1);
        L->baseline[i]=a->legend[i][0];
        L->inv_step[i]=1/(a->legend[i][1]-a->legend[i][0]);
    }
    ordinal num_of_corners=1<<a->dim;
    ordinal offset;
    for (offset=0;offset<num_of_corners;offset++) {
        ordinal sizer=1;
        ordinal index=0;
        // scratch 'tmp' to roll the offset bits without destroying offset itself:
        ordinal tmp_offset=offset;
        for (i=0;i<a->dim;i++) {
            index+=sizer*(tmp_offset&1);
            sizer*=a->size[i];
            // next bit
            tmp_offset>>=1;
        }  
        a->neighbors[offset]=index;
    } 
    L->content=(float *)malloc(sizeof(scalar)*(1+a->dim)*L->volume);
    ordinal pass=0;
    float error_rms=0;
    float progress_index=1;
    #Dinfo: "LIT allocated (%ld entries). Calculating slopes" L->volume
    for (i=0;i<L->volume;i++) {
        if ((10.0*i/L->volume)>progress_index) {
            #Dinfo: "Linear Cells' Precentage=%d%%   %d%% left   potential=%d%%" 100*pass/i 100-100*i/L->volume 100*pass/L->volume+100-100*i/L->volume
            progress_index+=1;
        }
        float error=generate_lit(a,L,i);
        if(error<1.0) pass++;
        error_rms+=error*error;
    }
    error_rms/=L->volume;
    error_rms=sqrt(error_rms);
    #Dinfo: "%ld fit linear out of %ld entries (LCP: %d%%  RMS error=%e)" pass L->volume 100*pass/L->volume error_rms
}

float feasibility(
#Foreach: input $::sizer_inputs {
    float $input, 
}
#Foreach: parameter $::sizer_parameters {
    float *$parameter,
    LUT *${parameter}_LUT,
} 
float *Gain, float *Area, float *fc, float tolerance
) {
    float point_Area=W*L*1e12;
    #tcl set i 0
    #Foreach: input $::sizer_inputs {
        global_coord[$i]=${input};
        	#Dinfo: "$i) $input=%g" $input
        #tcl incr i
    }
    #Foreach: parameter $::sizer_parameters {
        float point_${parameter}=${parameter}_LUT->interpolate(${parameter}_LUT,global_coord);
    }
    #Foreach: parameter {Ids gm go} {
        point_${parameter}*=W/L;
    }
    point_Nth*=sqrt(point_gm);
    point_Nflicker*=point_gm/sqrt(W*L);
    point_sigmaVt*=(100/point_Vt);
    float point_Gain=20*log_ten(point_gm/point_go);
    float point_fc=(point_Nflicker*point_Nflicker)/(point_Nth*point_Nth);
    float distance=0;
    // Ids gets a special "tightening"
    if (!isnan(*Ids)) {
        float point_distance=(point_Ids/(*Ids))-1.0;
        #Dinfo: "Distance from Ids is %g/%g=%g tolerance=%g" point_Ids (*Ids) point_distance tolerance
        point_distance*=point_distance;
        if (point_distance<=tolerance*tolerance) point_distance=0;
        distance+=point_distance;
    }
    #Foreach: parameter [concat $::sizer_parameters_no_ids Gain Area fc] {
        if (!isnan(*$parameter)) {
            float point_distance=(point_$parameter/(*$parameter))-1.0;
                    #Dinfo: "Distance from $parameter is %g/%g=%g tolerance=%g" point_$parameter (*$parameter) point_distance tolerance
            point_distance*=point_distance;
            if (point_distance<=tolerance*tolerance) point_distance=0;
            distance+=point_distance;
        }
    }
    return distance;
}

float sizer(
#Foreach: input $::sizer_inputs {
    float *$input, float min_$input, float max_$input,
}
#Foreach: parameter $::sizer_parameters {
    float *$parameter,
    LUT *${parameter}_LUT,
} 
float *Gain, float *Area, float *fc, float tolerance
) {
    #Foreach: input $::sizer_inputs {
        float point_${input}=min_$input;
        if (!isnan(*$input)) point_${input}=*$input;
        #tcl set step $::sizer_steps($input)
        float step_$input=$step;
        float chosen_$input=point_${input};
    }
    float point_distance=feasibility(
    #Foreach: input $::sizer_inputs {
        point_${input},
    }
    #Foreach: parameter $::sizer_parameters {
        $parameter,${parameter}_LUT,
    }
    Gain,Area,fc,tolerance
    );
    float minimal_distance=point_distance;
    #Foreach: input $::sizer_inputs {
        int index_$input;
        int start_$input=-1;
        int stop_$input=2;
        if (!isnan(*$input)) {
            start_$input=0; 
            stop_$input=1;
        }
    }	 
    int continue_searching=1;
    ordinal watchdog=0;
    FILE *TRAIL=fopen("/tmp/trail.tcl","w+");
    float trail_L=point_L;
    float trail_W=point_W;
    fprintf(TRAIL,"set data \{\n    %g %g\n",point_L,point_W);
    #Foreach: search_dims [list $::sizer_voltage_inputs $::sizer_inputs] {
        continue_searching=1;
        while ((point_distance>0)&&(continue_searching)&&(watchdog++<10000000)) {
            if (((trail_L!=point_L)||(trail_W!=point_W))) {
                fprintf(TRAIL,"    %g %g\n",point_L,point_W);
                trail_L=point_L;
                trail_W=point_W;
            }
            continue_searching=0;
            minimal_distance=point_distance;
            #Foreach: input $::sizer_inputs {
                float chosen_step_$input=0;
            }
            #Foreach: input $search_dims {
                for (index_$input=start_$input;index_$input<stop_$input;index_$input++)
            }    
            { 
                #Foreach: input $::sizer_inputs {
                    float try_$input=point_$input;
                    if ((try_$input+step_$input*index_$input>max_$input)||(try_$input+step_$input*index_$input<min_$input)) continue;
                    try_$input+=step_$input*index_$input;
                }    
                #Foreach: input $::sizer_inputs {
                       #Dinfo: "Trying $input step=%g" step_$input
                }    
                float try_distance=feasibility(
                #Foreach: input1 $::sizer_inputs {
                    try_${input1},
                }
                #Foreach: parameter1 $::sizer_parameters {
                    $parameter1,${parameter1}_LUT,
                }
                Gain,Area,fc,tolerance
                ); 
                if (try_distance<minimal_distance) {
                    #Foreach: input $::sizer_inputs {
                        chosen_step_$input=step_$input*index_$input;
                    }
                    continue_searching=1;
                    minimal_distance=try_distance;
                }
            } 
            if (continue_searching) {
                #Foreach: input $::sizer_inputs {
                         #Dinfo: "Chosen $input step=%g" chosen_step_$input
                }    
                while (1) {
                    #Foreach: input $::sizer_inputs {
                        float try_$input=point_$input;
                        if ((try_$input+chosen_step_$input>max_$input)||(try_$input+chosen_step_$input<min_$input)) break;
                    }    
                    #Foreach: input $::sizer_inputs {
                        try_$input+=chosen_step_$input;
                    }    
                    float try_distance=feasibility(
                    #Foreach: input1 $::sizer_inputs {
                        try_${input1},
                    }
                    #Foreach: parameter1 $::sizer_parameters {
                        $parameter1,${parameter1}_LUT,
                    }
                    Gain,Area,fc,tolerance
                    ); 
                    if (try_distance>point_distance) break;
                    #Foreach: input $::sizer_inputs {
                        point_$input=try_$input;
                    }
                    #Foreach: input $::sizer_inputs {
                        chosen_step_$input*=2;
                    }
                    point_distance=try_distance;
                            #Dinfo: "Distance=%g" point_distance
                }
            }
        } 
    }
    fprintf(TRAIL,"    %g %g\n",point_L,point_W);
    fprintf(TRAIL,"\}",point_L,point_W,point_distance);
    fclose(TRAIL);
    #Foreach: input $::sizer_inputs {
        *$input=point_${input};
    }
    #tcl set i 0
    #Foreach: input $::sizer_inputs {
        global_coord[$i]=point_${input};
        #tcl incr i
    }
    #Foreach: parameter $::sizer_parameters {
        #tcl set dim $::sizer_parameter_dim($parameter)
        #tcl set start_dim [expr 4-$dim]
        *${parameter}=${parameter}_LUT->interpolate(${parameter}_LUT,&(global_coord[$start_dim]));
    }
    // Parameters scaled by W/L get corrected here
    #Foreach: parameter {Ids gm go} {
        *${parameter}*=point_W/point_L;
    }
    // Special parameters calculations
    *Nth*=sqrt(*gm);
    *Area=point_W*point_L*1e12;
    *Nflicker*=*gm/sqrt(point_W*point_L);
    *sigmaVt*=(100/(*Vt));
    *Gain=20*log_ten(*gm/(*go));
    *fc=((*Nflicker)*(*Nflicker))/((*Nth)*(*Nth));
    return(point_distance);
}


