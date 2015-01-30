#ifndef SERIALIZE_DATA
#define SERIALIZE_DATA
#include <stdio.h>
#include <stdlib.h>
void write_scalar(FILE *O,double i_scalar);
void write_float(FILE *O,float i_float);
double read_scalar();
float read_float();
void get_float(float *f);
void write_ordinal(FILE *O,ordinal i_ordinal);
ordinal read_ordinal();
void write_string(FILE *O,char *i_string);
char *copy_string();
void read_string(char *new_string);
void open_to_read(char *i_filename);
int more_to_read();
void done_reading();
ordinal file_size_countdown;
FILE *OpenFileForReading;
FILE *OpenFileForWriting;


FC *bytecode_buffer;
ordinal bytecode_buffer_index;
ordinal bytecode_buffer_size;
void bc_start(unsigned char *bc_buff);
ordinal bc_count_float(ordinal num);
ordinal bc_count_int(ordinal num);
ordinal bc_count_byte(ordinal num);
void bc_put_byte(unsigned char c);
void bc_put_scalar(float f);
void bc_put_int(int32_t i);
unsigned char bc_byte();
float bc_float();
int32_t bc_int();
int32_t bc_full_int();
double bc_get_half_scalar();
ordinal bc_get_ordinal();
unsigned char bc_get_byte();
inline void bc_step();
inline void bc_jump();

#endif


