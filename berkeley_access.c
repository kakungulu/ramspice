#include "ramspice_types.h"
#include "data.h"
#include <stdlib.h>
#include <db.h>
DB *LUT;
char LUT_filename[128];
DBT LUT_key,LUT_data;

void init_serial() {
    serial_buffer=(char *)malloc(sizeof(char)*serial_BUFFER_SIZE);
    serial_wr_index=0;
    serial_rd_index=0;
    serial_size=serial_BUFFER_SIZE;
    db_create(&LUT,NULL,0);
    sprintf(LUT_filename,"ramspice%d.db",getpid());
    LUT->open(LUT,NULL,LUT_filename,"",DB_BTREE, DB_CREATE, 0664);
    int ret;
    if ((ret = LUT->open(LUT,NULL,LUT_filename,"",DB_BTREE, DB_CREATE, 0664)) != 0) {
        LUT->err(LUT, ret, "%s", LUT_filename);
	exit(1);
    }
}
void reset_serial() {
    serial_wr_index=0;
    serial_rd_index=0;
}
void put_serial(char *key) {
    memset(&LUT_key, 0, sizeof(LUT_key));
    memset(&LUT_data, 0, sizeof(LUT_data));
    LUT_key.data=strdup(key);
    LUT_key.size=strlen(key)+1;
    int size=serial_wr_index-serial_rd_index;
    char *databuf=(char *)malloc(sizeof(char)*(size+1));
    int i,ret;
    for (i=0;i<size;i++) read_from_serial_buffer(&(databuf[i]));
    databuf[size]=0;
    LUT_data.size=size+1;
    LUT_data.data=databuf;
    if ((ret = LUT->put(LUT, NULL, &LUT_key, &LUT_data, 0)) == 0) {
 //       printf("Info: %s stored\n",LUT_key.data);
    } else {
//        LUT->err(LUT, ret, "DB->put");
//	exit(1);
    }
    exit(0);
    reset_serial();
}
void get_serial(char *key) {
    int i,ret;
    LUT_key.data=strdup(key);
    LUT_key.size=strlen(key)+1;
    if ((ret = LUT->get(LUT, NULL, &LUT_key, &LUT_data, 0)) == 0) {
        for (i=0;i<LUT_data.size;i++) {
	    char c=((char *)LUT_data.data)[i];
	    write_to_serial_buffer(c);
	}
    } else {
        LUT->err(LUT, ret, "DB->get");
	exit(1);
    }
}
void write_to_serial_buffer(char i_c) {
    if (serial_wr_index+2>=serial_size) {
        printf("Warning: Overflow, increasing serialization buffer size from %d to %d\n",serial_size,serial_size*2);
        serial_size*=2;
        char *new_buffer=(char *)malloc(sizeof(char)*serial_size);
	int i;
	for (i=0;i<serial_wr_index;i++) {
	    new_buffer[i]=serial_buffer[i];
	}
	free(serial_buffer);
	serial_buffer=new_buffer;
    }
    printf("%d\n",serial_wr_index-serial_rd_index);
    if ((serial_wr_index-serial_rd_index)%1000==0) {
        printf("Info: serial buffer size: %d\n",serial_wr_index-serial_rd_index);
    }
    serial_buffer[serial_wr_index++]=i_c;
}
void read_from_serial_buffer(char *o_c) {
    if (serial_rd_index>=serial_wr_index) {
        printf("Error: serializing buffer underflow\n");
	exit(1);
    }
    o_c=serial_buffer[serial_rd_index++];
}
void serial_string(char *i_string) {
    int i;
    for (i=0;i_string[i];i++) {
        write_to_serial_buffer(i_string[i]);
    }
    write_to_serial_buffer(0);
}
void serial_read_string(char **o_string) {
    long i=serial_rd_index;
    while (serial_buffer[serial_rd_index]) serial_rd_index++;
    serial_rd_index++;
    *o_string=strdup(&(serial_buffer[i]));
}
void serial_int(int i_int) {
    typedef union {
        int i;
	char c[sizeof(int)/sizeof(char)];
    } ci;
    ci u;
    u.i=i_int;
    int i;
    for (i=0;i<sizeof(int)/sizeof(char);i++) {
        write_to_serial_buffer(u.c[i]);
    }
}
void serial_long(long i_long) {
    typedef union {
        long i;
	char c[sizeof(long)/sizeof(char)];
    } ci;
    ci u;
    u.i=i_long;
    int i;
    for (i=0;i<sizeof(long)/sizeof(char);i++) {
        write_to_serial_buffer(u.c[i]);
    }
}
void serial_scalar(double i_scalar) {
    typedef union {
        double i;
	char c[sizeof(scalar)/sizeof(char)];
    } ci;
    ci u;
    u.i=i_scalar;
    int i;
    for (i=0;i<sizeof(scalar)/sizeof(char);i++) {
        write_to_serial_buffer(u.c[i]);
    }
}
void serial_read_int(int *o_int) {
    typedef union {
        int i;
	char c[sizeof(int)/sizeof(char)];
    } ci;
    ci u;
    int i;
    for (i=0;i<sizeof(int)/sizeof(char);i++) {
        read_from_serial_buffer(u.c[i]);
    }
    *o_int=u.i;   
}
void serial_read_long(long *o_long) {
    typedef union {
        long i;
	char c[sizeof(long)/sizeof(char)];
    } ci;
    ci u;
    int i;
    for (i=0;i<sizeof(long)/sizeof(char);i++) {
        read_from_serial_buffer(u.c[i]);
    }
    *o_long=u.i;   
}
void serial_read_scalar(double *o_scalar) {
    typedef union {
        double i;
	char c[sizeof(scalar)/sizeof(char)];
    } ci;
    ci u;
    int i;
    for (i=0;i<sizeof(scalar)/sizeof(char);i++) {
        read_from_serial_buffer(u.c[i]);
    }
    *o_scalar=u.i;   
}




