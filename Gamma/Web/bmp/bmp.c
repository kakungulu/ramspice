#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "bmp.h"

BMP *new_BMP(int width,int length) {
    BMP *bmp=(BMP *)malloc(sizeof(BMP));
    bmp->array=(bmp_pixel *)malloc(sizeof(bmp_pixel)*width*length);
    bmp->width=width;
    bmp->length=length;
    return(bmp);
}

void save_BMP(FILE *O,BMP *bmp) {
    int i,j;
    int size = bmp->width * bmp->length * 3 + 14 + 40;
    // Save header
    putc('B',O);
    putc('M',O);
    putc((size)%256,O);
    putc((size/256)%256,O);
    putc((size/65536)%256,O);
    putc((size/16777216),O);
    putc(0,O);putc(0,O);
    putc(0,O);putc(0,O);
    putc(14+40,O);putc(0,O);putc(0,O);putc(0,O); 
    putc(0x28,O);putc(0,O);putc(0,O);putc(0,O);
    putc((bmp->width)%256,O);
    putc((bmp->width/256)%256,O);
    putc((bmp->width/65536)%256,O);
    putc((bmp->width/16777216),O);
    putc((bmp->length)%256,O);
    putc((bmp->length/256)%256,O);
    putc((bmp->length/65536)%256,O);
    putc((bmp->length/16777216),O);
    putc(1,O);putc(0,O);
    putc(24,O);putc(0,O);
    putc(0,O);putc(0,O);putc(0,O);putc(0,O);
    size=bmp->width*bmp->length*3;
    putc((size)%256,O);
    putc((size/256)%256,O);
    putc((size/65536)%256,O);
    putc((size/16777216),O);
    putc(1,O);putc(0,O);putc(0,O);putc(0,O);
    putc(1,O);putc(0,O);putc(0,O);putc(0,O);
    putc(0,O);putc(0,O);putc(0,O);putc(0,O);
    putc(0,O); putc(0,O); putc(0,O); putc(0,O); 
    // Save content
    for (j=0;j<bmp->length;j++) {
        for (i=0;i<bmp->width;i++) {
            long index=j*bmp->width+i;
            putc(bmp->array[index].b,O);
            putc(bmp->array[index].g,O);
            putc(bmp->array[index].r,O);
        }
    }
}

int set_BMP_pixel(BMP *bm, int x, int y, int r, int g, int b) {
    if (x < 0 || y < 0 || x >= bm->width || y >= bm->length) return(0);
    long index= y * bm->width + x;
    bm->array[index].r = r;
    bm->array[index].g = g;
    bm->array[index].b = b;
    return(1);
}
int set_BMP_pixel_html(BMP *bm, int x, int y, int rgb) {
    int r=0xFF&(rgb>>16);
    int g=0xFF&(rgb>>8);
    int b=0xFF&(rgb);
    if (x < 0 || y < 0 || x >= bm->width || y >= bm->length) return(0);
    long index= y * bm->width + x;
    bm->array[index].r = r;
    bm->array[index].g = g;
    bm->array[index].b = b;
    return(1);
}
/*
  // Example for generating bitmap with a pallet
void main() {
    int i,j;
    
    // 1. Create the bitmap container
    BMP *bmp=new_BMP(800,800);
    
    // 2. Define a pallet as an array. 
    // Use 0x and then HTML-style hex format and don't worry about bits above the 24lsb's (6 hex chars).
    // Example pallet:
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
    
    // 3. calculate the number of colors in the pallet
    int num_of_colors=sizeof(pal)/sizeof(int);
    
    // Draw the picture
    for (i=0;i<800;i++) for  (j=0;j<800;j++) {
        // Diagonal stripes pattern. 
	// Limit index to the number colors in the bitmap
        int c=((i+j)/100)%num_of_colors;
	// Use the entry in pal
        set_BMP_pixel_html(bmp,i,j,pal[c]);
    }
    // Save it to file
    FILE *O=fopen("first.bmp","w+");
    save_BMP(O,bmp);
    fclose(O);
}
*/
/*
  // Example for generating bitmap with a random RGB pixels
void main() {
    int i,j;
    // Create the bitmap container
    BMP *bmp=new_BMP(800,800);
    // Draw the picture
    for (i=0;i<800;i++) for  (j=0;j<800;j++) {
        int r=rand()%256;
        int g=rand()%256;
        int b=rand()%256;
	// Use the entry in pal
        set_BMP_pixel(bmp,i,j,r,g,b);
    }
    // Save it to file
    FILE *O=fopen("first.bmp","w+");
    save_BMP(O,bmp);
    fclose(O);
}
*/
