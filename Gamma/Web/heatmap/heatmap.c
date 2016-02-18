#include "ramspice_types.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <tcl.h>
#include "Gamma/Web/bmp/bmp.h"
#include "heatmap.h"
#define HEATMAP_RESOLUTION 256
#define HEATMAP_Z_RESOLUTION 1000000
#define HEATMAP_AREA HEATMAP_RESOLUTION*HEATMAP_RESOLUTION
#define HEATMAP_BLUR_FACTOR 50
#define HEATMAP_BLUR (HEATMAP_RESOLUTION/HEATMAP_BLUR_FACTOR)*(HEATMAP_RESOLUTION/HEATMAP_BLUR_FACTOR)
#define HEATMAP_TEST 400
heatmap *new_heatmap(int i_length,int i_width,int i_lengthpx,int i_widthpx,int *i_pallete,int i_pallete_length) {
    heatmap *h=(heatmap *)malloc(sizeof(heatmap));
    h->lengthpx=i_lengthpx;
    h->widthpx=i_widthpx;
    h->length=i_length;
    h->width=i_width;
    h->content=(float *)malloc(sizeof(float)*i_length*i_width);
    h->pallete_length=i_pallete_length;
    h->pallete_th=(float *)malloc(sizeof(float)*(i_pallete_length+1));
    h->pallete=(int *)malloc(sizeof(int)*i_pallete_length);
    int i,j;
    for (i=0;i<i_pallete_length;i++) h->pallete[i]=i_pallete[i];
    for (i=0;i<i_pallete_length;i++) h->pallete_th[i]=0;
    h->color_map=(int *)malloc(sizeof(int)*i_length*i_width);
    h->polygon_map=(int *)malloc(sizeof(int)*i_length*i_width);
    h->draw_border=0;
    h->border=NULL;
    return(h);
}
void set_heatmap_pixel(heatmap *i_heatmap,int x, int y, float i_value) {
    i_heatmap->content[x+y*i_heatmap->width]=i_value;
}
int is_nan(float i_val) {
    if (i_val==NAN) return(1);
    return(0);
}
void heatmap_thresholds(heatmap *h,int i_mode,float i_th) {
    int i,j,k,x,y;
    int w=h->width;
    int l=h->length;
    float highest_value=h->content[0];
    float lowest_value=h->content[0];
    int total_num_of_pixels=0;
    for (i=0;i<w;i++) for (j=0;j<l;j++) if (highest_value<h->content[i+j*w]) highest_value=h->content[i+j*w];
    for (i=0;i<w;i++) for (j=0;j<l;j++) if (lowest_value>h->content[i+j*w]) lowest_value=h->content[i+j*w];
    for (i=0;i<w;i++) for (j=0;j<l;j++) if (!is_nan(h->content[i+j*w])) total_num_of_pixels++;
    if ((i_mode==HM_TH_MODE_FLAT)||(i_mode==HM_TH_MODE_SNAP)) {
        h->pallete_th[0]=lowest_value;
        h->pallete_th[h->pallete_length]=highest_value;
        for (i=1;i<h->pallete_length;i++) {
            float min_th=lowest_value;
            float max_th=highest_value;
            float th=(max_th+min_th)/2;
            int target_num_of_pixels=total_num_of_pixels*i/h->pallete_length;
            int num_of_pixels=0;
            for (k=0;k<15;k++) {
                num_of_pixels=0;
                for (x=0;x<w;x++) for (y=0;y<l;y++) if (!is_nan(h->content[x+y*w])) if (th>h->content[x+y*w]) num_of_pixels++;
                if (num_of_pixels>target_num_of_pixels) max_th=th; else min_th=th;
                th=(max_th+min_th)/2;
            }
            h->pallete_th[i]=th;
        }
    }
    if (i_mode==HM_TH_MODE_FLAT) return;
    h->draw_border=1;
    h->border_th=i_th;
    int closest=h->pallete_length/2;
    if (i_mode==HM_TH_MODE_SNAP) {
        // If it's not half mode, find the closest threshold to the given one
        float closeness=highest_value-lowest_value;
        for (i=1;i<h->pallete_length;i++) if (fabs(h->pallete_th[i]-i_th)<closeness) {
            closeness=fabs(h->pallete_th[i]-i_th);
            closest=i;
        }
    }
    float orig_highest_value=highest_value;
    highest_value=i_th;
    h->pallete_th[closest]=i_th;
    int lower_num_of_pixels=0;
    for (i=0;i<w;i++) for (j=0;j<l;j++) if (!is_nan(h->content[i+j*w])) if (h->content[i+j*w]<i_th) lower_num_of_pixels++;
    for (i=1;i<closest;i++) {
        float min_th=lowest_value;
        float max_th=highest_value;
        float th=(max_th+min_th)/2;
        int target_num_of_pixels=lower_num_of_pixels*i/closest;
        int num_of_pixels=0;
        for (k=0;k<15;k++) {
            num_of_pixels=0;
            for (x=0;x<w;x++) for (y=0;y<l;y++) if (!is_nan(h->content[x+y*w])) if (th>h->content[x+y*w]) num_of_pixels++;
            if (num_of_pixels>target_num_of_pixels) max_th=th; else min_th=th;
            th=(max_th+min_th)/2;
        }
        h->pallete_th[i]=th;
    }
    int upper_num_of_pixels=total_num_of_pixels-lower_num_of_pixels;
    lowest_value=highest_value;
    highest_value=orig_highest_value;
    for (i=closest+1;i<h->pallete_length;i++) {
        float min_th=lowest_value;
        float max_th=highest_value;
        float th=(max_th+min_th)/2;
        int target_num_of_pixels=lower_num_of_pixels+upper_num_of_pixels*(i-closest)/(h->pallete_length-closest);
        int num_of_pixels=0;
        for (k=0;k<15;k++) {
            num_of_pixels=0;
            for (x=0;x<w;x++) for (y=0;y<l;y++) if (!is_nan(h->content[x+y*w])) if (th>h->content[x+y*w]) num_of_pixels++;
            if (num_of_pixels>target_num_of_pixels) max_th=th; else min_th=th;
            th=(max_th+min_th)/2;
        }
        h->pallete_th[i]=th;
    }
}
int heatmap_next_dir(int dir) {
    int next_dir=dir+1;
    if (next_dir>=4) next_dir-=4;
    return(next_dir);
}
int heatmap_last_dir(int dir) {
    int next_dir=dir-1;
    if (next_dir<0) next_dir+=4;
    return(next_dir);
}
void heatmap_get_border_point(heatmap *h,int X,int Y,int nextX,int nextY,int *gonX,int *gonY) {
    float w1;
    float w2;
    int w=h->width;
    int l=h->length;
    if (h->content[X+Y*w]>h->content[nextX+nextY*w]) {
        w1=h->content[X+Y*w]-h->pallete_th[h->color_map[X+Y*w]];
        w2=h->pallete_th[h->color_map[nextX+nextY*w]+1]-h->content[nextX+nextY*w];
    } else {
        w2=h->content[nextX+nextY*w]-h->pallete_th[h->color_map[nextX+nextY*w]];
        w1=h->pallete_th[h->color_map[X+Y*w]+1]-h->content[X+Y*w];
    }
    *gonX=(int)(w2*X+w1*nextX)*(h->widthpx/(h->width-1))/(w1+w2);
    *gonY=(int)(w2*Y+w1*nextY)*(h->lengthpx/(h->length-1))/(w1+w2);
}
void heatmap_add_gon(heatmap *h,int p,gon **last_gon,int X,int Y,int tileX1,int tileY1,int tileX2,int tileY2) {
    gon *new_gon=(gon *)malloc(sizeof(gon));
    new_gon->x=X;
    new_gon->y=Y;
    new_gon->next=NULL;
    new_gon->border=0;
    if (*last_gon==NULL) {
	h->polygons[p]=new_gon;
    } else {
	(*last_gon)->next=new_gon;
    }
    *last_gon=new_gon;
    if (!h->draw_border) return;
    int index1=tileX1+h->width*tileY1;
    int index2=tileX2+h->width*tileY2;
    if ((h->content[index1]>h->border_th)&&(h->content[index2]>h->border_th)) return;
    if ((h->content[index1]<h->border_th)&&(h->content[index2]<h->border_th)) return;
    new_gon->border=1;
}		
void plot_heatmap(heatmap *h,int originX,int originY,FILE *OUT) {
    int i,j,k,x,y;
    int w=h->width;
    int l=h->length;
    for (i=0;i<w;i++) for (j=0;j<l;j++) h->color_map[i+j*w]=-1;
    for (i=0;i<w;i++) for (j=0;j<l;j++) h->polygon_map[i+j*w]=-1;
    // Assign color per pixel
    for (x=0;x<w;x++) for (y=0;y<l;y++) {
        float value=h->content[x+y*w];
        if (is_nan(value)) continue;
        int min_color=0;
        int max_color=h->pallete_length;
        int color=(max_color+min_color)/2;
        while (max_color-min_color>1) {
            if (value<h->pallete_th[color]) max_color=color; else min_color=color; 
            color=(max_color+min_color)/2;
        }
        h->color_map[x+y*w]=min_color;
    }
    // Identify polygons
    h->polygon_map[0]=0;
    int poly_num=0;
    int go_again=1;
    while (go_again) {
        go_again=0;
        for (y=0;y<l;y++) for (x=0;x<w-1;x++) {
            if (h->polygon_map[x+y*w]!=poly_num) continue;
            if (h->polygon_map[x+1+y*w]!=-1) continue;
            if (h->color_map[x+1+y*w]!=h->color_map[x+y*w]) continue;
            h->polygon_map[x+1+y*w]=h->polygon_map[x+y*w];
            go_again++;
        }
        for (x=0;x<w;x++) for (y=0;y<l-1;y++) {
            if (h->polygon_map[x+y*w]!=poly_num) continue;
            if (h->polygon_map[x+y*w+w]!=-1) continue;
            if (h->color_map[x+y*w+w]!=h->color_map[x+y*w]) continue;
            h->polygon_map[x+y*w+w]=h->polygon_map[x+y*w];
            go_again++;
        }
        for (y=l-1;y>=0;y--) for (x=w-1;x>0;x--) {
            if (h->polygon_map[x+y*w]!=poly_num) continue;
            if (h->polygon_map[x-1+y*w]!=-1) continue;
            if (h->color_map[x-1+y*w]!=h->color_map[x+y*w]) continue;
            h->polygon_map[x-1+y*w]=h->polygon_map[x+y*w];
            go_again++;
        }
        for (x=w-1;x>=0;x--) for (y=l-1;y>0;y--) {
            if (h->polygon_map[x+y*w]!=poly_num) continue;
            if (h->polygon_map[x+y*w-w]!=-1) continue;
            if (h->color_map[x+y*w-w]!=h->color_map[x+y*w]) continue;
            h->polygon_map[x+y*w-w]=h->polygon_map[x+y*w];
            go_again++;
        }
        if (go_again) continue;
        // If the latest polygon is fully detected, try to find another one
        for (i=0;i<l*w;i++) if (h->polygon_map[i]==-1) {
            poly_num++;
            h->polygon_map[i]=poly_num;
            go_again++;
            break;
        }
    }
    h->polygons=(gon **)malloc(sizeof(gon *)*(poly_num+1));
    h->poly2color=(int *)malloc(sizeof(int)*(poly_num+1));
    
    // Walk around each color area and assemble a polygon
    // Direction step definitions in clockwise order: W N E S
    int Sx[]={-1,0,1,0};
    int Sy[]={0,-1,0,1};
    int p=0;
    for (p=0;p<=poly_num;p++) {
        gon *last_gon=NULL;
        // Find the first tile of the color area
        int X=-1;
        int Y=-1;
        // Scan line by line. The first tile is bordering on the west side.
        for (y=0;y<l;y++) {
            for (x=0;x<w;x++) if (h->polygon_map[x+y*w]==p) {
                X=x;
                Y=y;
                break;
            }
            if (X!=-1) break;
        }  
        h->poly2color[p]=h->pallete[h->color_map[X+Y*w]];
        // Start the walk around the polygon. The first direction to look for is west
        int dir=0;
        int origX=X;
        int origY=Y;
        while (1) {
            int nextX=X+Sx[dir];
            int nextY=Y+Sy[dir];
            // If the next step is the starting point, stop walking
            if ((nextX<0)||(nextY<0)||(nextX>=w)||(nextY>=l)) {
                // Add the point itself
		heatmap_add_gon(h,p,&last_gon,(int)X*(h->widthpx/(h->width-1)),(int)Y*(h->lengthpx/(h->length-1)),X,Y,X,Y);
                gon *new_gon=(gon *)malloc(sizeof(gon));
                dir=heatmap_next_dir(dir);
                if ((X==origX)&&(Y==origY)&&(dir==0)) break;
                continue;
            } 
            if (h->polygon_map[nextX+nextY*w]!=p) {
                // Detect a corner
                int last_dir=heatmap_last_dir(dir);
                int lastX=X+Sx[last_dir];
                int lastY=Y+Sy[last_dir];
                int opX=lastX+Sx[dir];
                int opY=lastY+Sy[dir];
		// A corner can only happen inside a full square
                if ((lastX>=0)&&(lastY>=0)&&(lastX<w)&&(lastY<l)) if (h->polygon_map[lastX+lastY*w]!=p) {
                    if ((h->polygon_map[lastX+lastY*w]==h->polygon_map[opX+opY*w])&&(h->polygon_map[nextX+nextY*w]!=h->polygon_map[opX+opY*w])) {
		        int Nx,Ny,Lx,Ly;
			heatmap_get_border_point(h,opX,opY,nextX,nextY,&Nx,&Ny);
			heatmap_get_border_point(h,X,Y,lastX,lastY,&Lx,&Ly);		
			heatmap_add_gon(h,p,&last_gon,(Nx+Lx)/2,(Ny+Ly)/2,X,Y,nextX,nextY);
                    } else if ((h->polygon_map[nextX+nextY*w]==h->polygon_map[opX+opY*w])&&(h->polygon_map[lastX+lastY*w]!=h->polygon_map[opX+opY*w])) {
		        int Nx,Ny,Lx,Ly;
			heatmap_get_border_point(h,opX,opY,lastX,lastY,&Lx,&Ly);
			heatmap_get_border_point(h,X,Y,nextX,nextY,&Nx,&Ny);
			heatmap_add_gon(h,p,&last_gon,(Nx+Lx)/2,(Ny+Ly)/2,X,Y,nextX,nextY);
                    } else if ((h->polygon_map[nextX+nextY*w]!=h->polygon_map[opX+opY*w])&&(h->polygon_map[lastX+lastY*w]!=h->polygon_map[opX+opY*w])) {
			// Intersection
		        int x1,y1,x2,y2,x3,y3,x4,y4;
			heatmap_get_border_point(h,X,Y,nextX,nextY,&x2,&y2);
			heatmap_get_border_point(h,X,Y,lastX,lastY,&x4,&y4);
			heatmap_get_border_point(h,opX,opY,nextX,nextY,&x3,&y3);
			heatmap_get_border_point(h,opX,opY,lastX,lastY,&x1,&y1);
			int cornerX=((x1*y2-y1*x2)*(x3-x4)-(x1-x2)*(x3*y4-y3*x4))/((x1-x2)*(y3-y4)-(y1-y2)*(x3-x4));
			int cornerY=((x1*y2-y1*x2)*(y3-y4)-(y1-y2)*(x3*y4-y3*x4))/((x1-x2)*(y3-y4)-(y1-y2)*(x3-x4));
			heatmap_add_gon(h,p,&last_gon,cornerX,cornerY,X,Y,nextX,nextY);
		    }
                }
                // Calculate and add border point
 		int borderX,borderY;
		heatmap_get_border_point(h,X,Y,nextX,nextY,&borderX,&borderY);
 	        heatmap_add_gon(h,p,&last_gon,borderX,borderY,X,Y,nextX,nextY);
                dir=heatmap_next_dir(dir);
                if ((X==origX)&&(Y==origY)&&(dir==0)) break;
                continue;
            }
            // Crawl to the next tile
            X=nextX;
            Y=nextY;
            // The next tile should repeat the last successful direction
            dir=heatmap_last_dir(dir);
            if ((nextX==origX)&&(nextY==origY)&&(dir==0)) break;
        }  
    }
#ifdef TEST_HEATMAP
    fprintf(OUT,"<html><body>\n");
    fprintf(OUT,"<svg width=\"%d\" height=\"%d\">\n",h->widthpx+originX,h->lengthpx+originY);
#endif    
    fprintf(OUT,"<defs><clipPath id=\"heatmap_window\"> <rect x=\"%d\" y=\"%d\" width=\"%d\" height=\"%d\" /></clipPath></defs>",originX,originY,h->widthpx,h->lengthpx);
    fprintf(OUT,"<g id=\"HeatMapWindow\" clip-path=\"url(#heatmap_window)\">\n",originX,originY);
    fprintf(OUT,"<g id=\"HeatMapContent\" transform=\"translate(%d,%d)\">\n",originX,originY);
    // Plot polygons in SVG
    for (p=0;p<=poly_num;p++) {
        fprintf(OUT,"    <polygon points=\" ");
        gon *g=h->polygons[p];
        while(g) {
            fprintf(OUT,"%d,%d ",g->x,g->y);
            g=g->next;
        }
        fprintf(OUT,"\" fill=\"#%6x\"/>\n",h->poly2color[p]);
    }
    // Plot border(s)
    int border_state=0;
    for (p=0;p<=poly_num;p++) {
        gon *g=h->polygons[p];
        while(g) {
	    if ((g->border)&&(!border_state)) {
	        fprintf(OUT,"    <polyline points=\"");
		border_state=1;
	    }
            if (g->border) fprintf(OUT,"%d,%d ",g->x,g->y);
	    if ((!g->border)&&(border_state)) {
	        fprintf(OUT,"\" stroke-width=\"3\" fill=\"none\" stroke=\"black\"/>\n");
		border_state=0;
	    }
            g=g->next;
        }
    }
    fprintf(OUT,"</g></g>\n");
#ifdef TEST_HEATMAP
    fprintf(OUT,"</svg>\n");
    fprintf(OUT,"</body></html>\n");
#endif    
    // Cleanup
    for (p=0;p<=poly_num;p++) {
        gon *g=h->polygons[p];
        while(g->next) {
            gon *next=g->next;
            free(g);
            g=next;
        }
        free(g);
    }	
    free(h->polygons);
    free(h->poly2color);
}


// BMP-based heatmap Deprecated!!! 
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
    //    float x_belt=0.05*(xmax-xmin);
    //    xmin-=x_belt;
    //    xmax+=x_belt;
    //    float y_belt=0.05*(ymax-ymin);
    //    ymin-=y_belt;
    //    ymax+=y_belt;
    
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
            for (k=0;k<count*3;k+=3) { //loop through the scaled inputs and calculate xdelta and ydelta
                
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
    //    for (i=0;i<count*3;i=i+3) if (input_scaled[i+2]==-1) set_BMP_pixel_html(bmp,input_scaled[i],input_scaled[i+1],0x000000); else set_BMP_pixel_html(bmp,input_scaled[i],input_scaled[i+1],0xFFFFFF);	
    FILE *O=fopen(filename,"w+");
    save_BMP(O,bmp);
    fclose(O);
}//endof create_heatmap
#ifdef TEST_HEATMAP
// Example for generating bitmap with a pallet
void main() {
    int i,j;
    int pal[]={
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
    int pal1[]= {
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
    int test_size=99;
    heatmap *hm=new_heatmap(test_size,test_size,800,800,pal,11);
    
    for (i=0;i<test_size;i++) for (j=0;j<test_size;j++) set_heatmap_pixel(hm,i,j,i*(98-j));
    heatmap_thresholds(hm,HM_TH_MODE_SNAP,450);
    plot_heatmap(hm,100,100,stdout);
}
#endif

