#include "ramspice_types.h"
#include "Data/serialize.h"
#include <sys/stat.h>
#include <math.h>
void write_scalar(FILE *O,double i_scalar) {
    if (O==NULL) {
        O=OpenFileForWriting;
    }
    so_union sob;
    sob.s=i_scalar;
    int i=0;
    for(;i<BYTES_PER_SCALAR;i++) fprintf(O,"%c",sob.b[i]);
    fflush(O);
}
void write_float(FILE *O,float i_float) {
    if (O==NULL) {
        O=OpenFileForWriting;
    }
    FC F;
    F.F=i_float;
    int i=0;
    for(;i<BYTES_PER_FLOAT;i++) fprintf(O,"%c",F.C[i]);
    // #Info: "Writing Float %g" F.F
    fflush(O);
}
void write_double(FILE *O,double i_double) {
    if (O==NULL) {
        O=OpenFileForWriting;
    }
    DC F;
    F.F=i_double;
    int i=0;
    for(;i<BYTES_PER_DOUBLE;i++) fprintf(O,"%c",F.C[i]);
    // #Info: "Writing double %g" F.F
    fflush(O);
}
double read_scalar() {
    so_union sob;
    int i=0;
    for(;i<BYTES_PER_SCALAR;i++) sob.b[i]=fgetc(OpenFileForReading);
    file_size_countdown-=BYTES_PER_SCALAR;
    return sob.s; 
}
float read_float() {
    FC F;
    float R;
    int i=0;
    for(;i<BYTES_PER_FLOAT;i++) F.C[i]=fgetc(OpenFileForReading);
    file_size_countdown-=BYTES_PER_FLOAT;
    R=F.F;
    // #Info: "Reading Float %g (%ld)" F.F file_size_countdown
    
    return(R); 
}
double read_double() {
    DC F;
    double R;
    int i=0;
    for(;i<BYTES_PER_DOUBLE;i++) F.C[i]=fgetc(OpenFileForReading);
    file_size_countdown-=BYTES_PER_DOUBLE;
    R=F.F;
    // #Info: "Reading double %g (%ld)" F.F file_size_countdown
    
    return(R); 
}
void get_float(float *f) {
    FC F;
    int i=0;
    for(;i<BYTES_PER_FLOAT;i++) F.C[i]=fgetc(OpenFileForReading);
    file_size_countdown-=BYTES_PER_FLOAT;
    *f=fabs(F.F);
}
void write_int(FILE *O,int i_int) {
    if (O==NULL) {
        O=OpenFileForWriting;
    }
    so_union sob;
    sob.o=i_int;
    int i=0;
    for(;i<4;i++) fprintf(O,"%c",sob.b[i]);
    // #Info: "Writing Integer %ld" i_int
}
void write_ordinal(FILE *O,ordinal i_ordinal) {
    if (O==NULL) {
        O=OpenFileForWriting;
    }
    so_union sob;
    sob.o=i_ordinal;
    int i=0;
    for(;i<4;i++) fprintf(O,"%c",sob.b[i]);
    // #Info: "Writing Integer %ld" i_ordinal
}
int read_int() {
    so_union sob;
    int i=0;
    for(;i<4;i++) sob.b[i]=fgetc(OpenFileForReading);
    file_size_countdown-=4;
    // #Info: "Reading Integer %ld (%ld)" sob.o file_size_countdown
    return sob.o; 
}
ordinal read_ordinal() {
    so_union sob;
    int i=0;
    for(;i<4;i++) sob.b[i]=fgetc(OpenFileForReading);
    file_size_countdown-=4;
    // #Info: "Reading Integer %ld (%ld)" sob.o file_size_countdown
    return sob.o; 
}
void write_string(FILE *O,char *i_string) {
    // #Info: "Writing String:"
    if (O==NULL) {
        O=OpenFileForWriting;
    }
    ordinal length=strlen(i_string);
    write_ordinal(O,length);
    int i=0;
    for(;i<length;i++) fprintf(O,"%c",i_string[i]);
    // #Info: "Writing String %s" i_string
}
void write_pointer_char(FILE *O,char *i_string) {
    // #Info: "Writing String:"
    if (O==NULL) {
        O=OpenFileForWriting;
    }
    ordinal length=strlen(i_string);
    write_ordinal(O,length);
    int i=0;
    for(;i<length;i++) fprintf(O,"%c",i_string[i]);
    // #Info: "Writing String %s" i_string
}
char *copy_string() {
    // #Info: "Reading String:" 
    ordinal length=read_ordinal();
    char *new_string=(char *)malloc(sizeof(char)*length+1);
    int i=0;
    for(;i<length;i++) new_string[i]=fgetc(OpenFileForReading);
    new_string[i]=0;
    // #Info: "Reading String %s" new_string
    file_size_countdown-=length;
    return new_string;
}
char *read_pointer_char() {
    // #Info: "Reading String:" 
    ordinal length=read_ordinal();
    char *new_string=(char *)malloc(sizeof(char)*length+1);
    int i=0;
    for(;i<length;i++) new_string[i]=fgetc(OpenFileForReading);
    new_string[i]=0;
    // #Info: "Reading String %s" new_string
    file_size_countdown-=length;
    return new_string;
}
void read_string(char *new_string) {
    // #Info: "Reading String:" 
    ordinal length=read_ordinal();
    int i=0;
    for(;i<length;i++) new_string[i]=fgetc(OpenFileForReading);
    // #Info: "Reading String %s" new_string
    file_size_countdown-=length;
    new_string[i]=0;
}

void open_to_read(char *i_filename) {
    OpenFileForReading=fopen(i_filename,"r");
    if (OpenFileForReading==NULL) {
        #Error: "Couldn't open file %s" i_filename
        exit(1);
    }
    struct stat st;
    stat(i_filename, &st);
    file_size_countdown = st.st_size;
}
void open_to_write(char *i_filename) {
    OpenFileForWriting=fopen(i_filename,"w");
    if (OpenFileForWriting==NULL) {
        #Error: "Couldn't open file %s" i_filename
        exit;
    }
}
void done_reading() {
    // #Info: "Done Reading"
    fclose(OpenFileForReading);
}
int more_to_read() {
    // #Info: "Checking File End: %ld" file_size_countdown
    if (file_size_countdown>0) return 1;
    return 0;
}

///  Some bytecode support
void bc_start(unsigned char *bc_buff) {
    bytecode_buffer=bc_buff;
    bytecode_buffer_index=0;
}
ordinal bc_count_float(ordinal num) {
    bytecode_buffer_index+=4*num;
    if (bytecode_buffer_size<bytecode_buffer_index) bytecode_buffer_size=bytecode_buffer_index;
    return bytecode_buffer_index;
}
ordinal bc_count_int(ordinal num) {
    bytecode_buffer_index+=4*num;
    if (bytecode_buffer_size<bytecode_buffer_index) bytecode_buffer_size=bytecode_buffer_index;
    return bytecode_buffer_index;
}
ordinal bc_count_byte(ordinal num) {
    bytecode_buffer_index+=num;
    if (bytecode_buffer_size<bytecode_buffer_index) bytecode_buffer_size=bytecode_buffer_index;
    return bytecode_buffer_index;
}
unsigned char bc_byte() {
    return(bytecode_buffer[bytecode_buffer_index].C[0]);
}
float bc_float() {
    return(bytecode_buffer[bytecode_buffer_index].F);
}
int32_t bc_int() {
    return(bytecode_buffer[bytecode_buffer_index].I>>8);
}
int32_t bc_full_int() {
    return(bytecode_buffer[bytecode_buffer_index].I);
}
void bc_put_byte(unsigned char c) {
    bytecode_buffer[bytecode_buffer_index].C[0]=c;
}
void bc_put_scalar(float f) {
    unsigned char c=bytecode_buffer[bytecode_buffer_index].C[0];
    bytecode_buffer[bytecode_buffer_index].F=f;
    bytecode_buffer[bytecode_buffer_index].C[0]=c;
}
void bc_put_int(int32_t i) {
    unsigned char c=bytecode_buffer[bytecode_buffer_index].C[0];
    bytecode_buffer[bytecode_buffer_index].I=i<<8;
    bytecode_buffer[bytecode_buffer_index].C[0]=c;
}
void bc_put_full_int(int32_t i) {
    bytecode_buffer[bytecode_buffer_index].I=i;
}

inline void bc_step() {
   bytecode_buffer_index++;
} 
inline void bc_jump() {
    bytecode_buffer_index+=(bytecode_buffer[bytecode_buffer_index].I);
}

