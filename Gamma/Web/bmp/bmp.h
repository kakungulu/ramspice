#ifndef BMP_GENERATOR
#define BMP_GENERATOR
typedef struct {
	unsigned char r,g,b;
} bmp_pixel;
typedef struct {
	long width,length;
	bmp_pixel *array;
} BMP;

BMP *new_BMP(int width,int length); 
int set_BMP_pixel(BMP *bm, int x, int y, int r, int g, int b);

void save_BMP(FILE *O,BMP *bmp);
#endif
