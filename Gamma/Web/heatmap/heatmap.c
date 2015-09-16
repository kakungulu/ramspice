#include "ramspice_types.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <tcl.h>
#include "Gamma/Web/bmp/bmp.h"
#include "Gamma/Web/heatmap/heatmap.h"
#define HEATMAP_RESOLUTION 512
#define HEATMAP_Z_RESOLUTION 1000000
#define HEATMAP_AREA HEATMAP_RESOLUTION*HEATMAP_RESOLUTION
#define HEATMAP_BLUR_FACTOR 50
#define HEATMAP_BLUR (HEATMAP_RESOLUTION/HEATMAP_BLUR_FACTOR)*(HEATMAP_RESOLUTION/HEATMAP_BLUR_FACTOR)
#define HEATMAP_TEST 400

void create_heatmap(float *input, int count, int *pal, int pal_size, float *key, char *filename) {
    float xmin=input[0];
    float xmax=input[0];
    float ymin=input[1];
    float ymax=input[1];
    float zmin=input[2];
    float zmax=input[2];
    int i,j,k,m;
    for (i=0;i<count*3;i=i+3){
        if (xmin>input[i]) xmin=input[i];
        if (xmax<input[i]) xmax=input[i];
        if (ymin>input[i+1]) ymin=input[i+1];
        if (ymax<input[i+1]) ymax=input[i+1];
        if (zmin>input[i+2]) zmin=input[i+2];
        if (zmax<input[i+2]) zmax=input[i+2];
    }
    int input_scaled[count*3];
    float x_belt=0.05*(xmax-xmin);
    xmin-=x_belt;
    xmax+=x_belt;
    float y_belt=0.05*(ymax-ymin);
    ymin-=y_belt;
    ymax+=y_belt;
    
    // Scale input
    for (i=0;i<count*3;i+=3) input_scaled[i]=(int)(((input[i] - xmin)/(xmax-xmin))*(HEATMAP_RESOLUTION-1));
    for (i=1;i<count*3;i+=3) input_scaled[i]=(int)(((input[i] - ymin)/(ymax-ymin))*(HEATMAP_RESOLUTION-1));
    for (i=2;i<count*3;i+=3) if (input[i]==-1) input_scaled[i]=-1; else input_scaled[i]=(int)(((input[i] - zmin)/(zmax-zmin))*(HEATMAP_Z_RESOLUTION-1));
    
    float z_map[HEATMAP_AREA];
    for (i=0;i<HEATMAP_RESOLUTION;i++){
        for (j=0;j<HEATMAP_RESOLUTION;j++){
	    int given=0;
	    for (k=0;k<count*3;k+=3) if ((i==(input_scaled[k]))&&(j==(input_scaled[k+1]))) given=1;
	    if (given) continue;
            float weight_sum=0.0;
            float weighted_sum=0.0;
            for (k=0;k<count*3;k+=3) { //loop through the scalled inputs and calculate xdelta and ydelta
	        if (input_scaled[k+2]==-1) continue;
                float weight=1.0/(HEATMAP_BLUR+(i-(input_scaled[k]))*(i-(input_scaled[k]))+(j-(input_scaled[k+1]))*(j-(input_scaled[k+1]))); // Square-Euclidean distance (round contures)
		weight*=weight;
                weight_sum+=weight;
                weighted_sum+=weight*input_scaled[k+2];
            }
            z_map[i+HEATMAP_RESOLUTION*j]=weighted_sum/weight_sum;
        }//endof j
    }//endof i
    /*
    for (i=0;i<HEATMAP_RESOLUTION;i++){
        for (j=0;j<HEATMAP_RESOLUTION;j++){
	    int given=0;
	    for (k=0;k<count*3;k+=3) if ((i==(input_scaled[k]))&&(j==(input_scaled[k+1]))) given=1;
	    if (given) continue;
            float dist=HEATMAP_AREA;
            float second_dist=HEATMAP_AREA;
	    int closest=0; 
	    int second_closest=0; 
	    for (k=0;k<count*3;k+=3) {
	    	int dist_to_this_input=sqrt((i-input_scaled[k])*(i-input_scaled[k])+(j-input_scaled[k+1])*(j-input_scaled[k+1]));
	    	if (dist_to_this_input<dist) {
		    second_dist=dist;
		    second_closest=closest;
	    	    dist=dist_to_this_input;
		    closest=k+2;
	    	}
	    }
	    z_map[i+HEATMAP_RESOLUTION*j]=(input_scaled[closest]*second_dist+input_scaled[second_closest]*dist)/(second_dist+dist);
	}
    }	    
    */
    // Draw given pixels
    for (i=0;i<count*3;i=i+3) z_map[input_scaled[i]+HEATMAP_RESOLUTION*input_scaled[i+1]] = input_scaled[i+2];	
    int approximations=0;
    int thresholdtest = 0;
    int last_thresholdtest = 0;
    int threshold = 0;
    int thresholds[pal_size];
    thresholds[0] = 0;
    thresholds[pal_size] = HEATMAP_RESOLUTION-1;
    key[0]=zmin;
    for (m=1;m<=pal_size;m++){
        int zlow = 0; //taken from given points initially
        int zhigh = HEATMAP_Z_RESOLUTION-1; //taken from given points initially
        int zmid = HEATMAP_Z_RESOLUTION/2; //always the average of low and high
        while (zhigh-zlow>1) {
            thresholdtest = 0;
            threshold = 0;
            //test_thresh:
            for (i=0;i<HEATMAP_RESOLUTION;i++){
                for (j=0;j<HEATMAP_RESOLUTION;j++){
                    if (z_map[i+HEATMAP_RESOLUTION*j] <zmid){
                        thresholdtest++;
                    }
                }
            }
            if (thresholdtest<m*(HEATMAP_AREA/pal_size)) {//thresholdtest is low
                zlow=zmid;
            } else {//thresholdtest is high
                zhigh=zmid;
            }
            zmid=(zlow+zhigh)/2;//always update zmid
        }//endof approximations loop
        thresholds[m]=zmid;
         printf("%d %g %d\n",m,zmid*(zmax-zmin)/HEATMAP_Z_RESOLUTION+zmin,thresholdtest-last_thresholdtest);
	 key[m]=zmid*(zmax-zmin)/HEATMAP_Z_RESOLUTION+zmin;
	 last_thresholdtest=thresholdtest;
    }
    key[pal_size]=zmax;
    BMP *bmp=new_BMP(HEATMAP_RESOLUTION,HEATMAP_RESOLUTION);
    int threshlow = 0;
    int threshmid = pal_size/2;
    int threshhigh = pal_size;
    
    for (i=0;i<HEATMAP_RESOLUTION;i++){
        for (j=0;j<HEATMAP_RESOLUTION;j++){
            threshlow = 0;
            threshmid = (0+pal_size)/2;
            threshhigh = pal_size;
            while (threshhigh-threshlow>1){
                if (z_map[i+HEATMAP_RESOLUTION*j]>thresholds[threshmid]) {
                    threshlow=threshmid;
                } else {
                    threshhigh=threshmid;
                }
                threshmid = (threshlow+threshhigh)/2;
            }
            //should know color, go to pal and put that color in the bitmap
            set_BMP_pixel_html(bmp,i,j,pal[threshlow]);
        }//endof j
    }//endof i
    // Draw given pixels
    for (i=0;i<count*3;i=i+3) if (input_scaled[i+2]==-1) set_BMP_pixel_html(bmp,input_scaled[i],input_scaled[i+1],0x000000); else set_BMP_pixel_html(bmp,input_scaled[i],input_scaled[i+1],0xFFFFFF);	
    FILE *O=fopen(filename,"w+");
    save_BMP(O,bmp);
    fclose(O);
}//endof create_heatmap

/*
// Example for generating bitmap with a pallet
void main() {
    int i,j;
    int pal1[]={
        0xa50026,
        0xd73027,
        0xf46d43,
        0xfdae61,
        0xfee090,
        0xffffbf,
        0xe0f3f8,
        0xabd9e9,
        0x74add1,
        0x4575b4,
        0x313695
    };
    int pal[]= {
        0x9e0142,
        0xd53e4f,
        0xf46d43,
        0xfdae61,
        0xfee08b,
        0xffffbf,
        0xe6f598,
        0xabdda4,
        0x66c2a5,
        0x3288bd,
        0x5e4fa2
    };
    float input[3*HEATMAP_TEST];
    
    for (i=0;i<3*HEATMAP_TEST;i+=3) {
        input[i]=rand()/1000000.0;
        input[i+1]=rand()/1000000.0;
        input[i+2]=input[i+1]*input[i+1]+input[i]*input[i];
    }	
    create_heatmap(input, HEATMAP_TEST, pal, sizeof(pal)/sizeof(int), "test.bmp");
}
*/
