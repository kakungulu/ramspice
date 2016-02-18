#ifndef HEATMAP_GENERATOR
#define HEATMAP_GENERATOR

void create_heatmap(float *input, int count, int *pal, int pal_size, float *key, char *filename);
static int tcl_heatmap(ClientData clientData,Tcl_Interp *interp,int argc,char *argv[]);
typedef struct gon gon;
struct gon {
    int x;
    int y;
    int border;
    gon *next;
};
typedef struct {
    int length;
    int width;
    int lengthpx;
    int widthpx;
    float *content;
    int *pallete;
    float *pallete_th;
    int pallete_length;
    int *color_map;
    int *polygon_map;
    gon **polygons;
    gon *border;
    float border_th;
    int draw_border;
    int *poly2color;
} heatmap;
heatmap *new_heatmap(int i_length,int i_width,int i_lengthpx,int i_widthpx,int *i_pallete,int i_pallete_length);
void set_heatmap_pixel(heatmap *i_heatmap,int x, int y, float value);
#define HM_TH_MODE_FLAT 0
#define HM_TH_MODE_SNAP 1
#define HM_TH_MODE_HALF 2
void heatmap_thresholds(heatmap *i_heatmap,int i_mode,float i_th);
void plot_heatmap(heatmap *i_heatmap,int originX,int originY,FILE *OUT);
char *heatmap_svg_buffer;
int heatmap_svg_buffer_size;
int is_nan(float i_val);




#endif
