#ifndef DATA_MARSHALLING
#define DATA_MARSHALLING
#define serial_BUFFER_SIZE 1024
#define HAVE_CXX_STDHEADERS
#include <stdlib.h>
#include <string.h>
char *serial_buffer;
long serial_rd_index;
long serial_wr_index;
int serial_size;
void init_serial();
void reset_serial();
void write_to_serial_buffer(char i_c);
void read_from_serial_buffer(char *o_c);
void serial_int(int i_int);
void serial_long(long i_long);
void serial_scalar(double i_scalar);
void serial_read_int(int *o_int);
void serial_read_long(long *o_long);
void serial_read_scalar(double *o_scalar);
void serial_string(char *i_string);
void serial_read_string(char **o_string);
void put_serial(char *key);
void get_serial(char *key);
#endif


