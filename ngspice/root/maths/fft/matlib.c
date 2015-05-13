#include "ramspice_types.h"
/* a few routines from a vector/matrix library */
#include "matlib.h"

void xpose(double *indata, long iRsiz, double *outdata, long oRsiz, long Nrows, long Ncols)
{
    /* not in-place matrix transpose	*/
    /* INPUTS */
    /* *indata = input data array	*/
    /* iRsiz = offset to between rows of input data array	*/
    /* oRsiz = offset to between rows of output data array	*/
    /* Nrows = number of rows in input data array	*/
    /* Ncols = number of columns in input data array	*/
    /* OUTPUTS */
    /* *outdata = output data array	*/

    double	*irow; 		/* pointer to input row start */
    double	*ocol; 		/* pointer to output col start */
    double	*idata; 	/* pointer to input data */
    double	*odata; 	/* pointer to output data */
    long 	RowCnt;		/* row counter */
    long 	ColCnt;		/* col counter */
    double	T0; 		/* data storage */
    double	T1; 		/* data storage */
    double	T2; 		/* data storage */
    double	T3; 		/* data storage */
    double	T4; 		/* data storage */
    double	T5; 		/* data storage */
    double	T6; 		/* data storage */
    double	T7; 		/* data storage */
    const long inRsizd1 = iRsiz;
    const long inRsizd2 = 2*iRsiz;
    const long inRsizd3 = inRsizd2+iRsiz;
    const long inRsizd4 = 4*iRsiz;
    const long inRsizd5 = inRsizd3+inRsizd2;
    const long inRsizd6 = inRsizd4+inRsizd2;
    const long inRsizd7 = inRsizd4+inRsizd3;
    const long inRsizd8 = 8*iRsiz;

    ocol = outdata;
    irow = indata;
    for (RowCnt=Nrows/8; RowCnt>0; RowCnt--) {
        idata = irow;
        odata = ocol;
        for (ColCnt=Ncols; ColCnt>0; ColCnt--) {
            T0 = *idata;
            T1 = *(idata+inRsizd1);
            T2 = *(idata+inRsizd2);
            T3 = *(idata+inRsizd3);
            T4 = *(idata+inRsizd4);
            T5 = *(idata+inRsizd5);
            T6 = *(idata+inRsizd6);
            T7 = *(idata+inRsizd7);
            *odata = T0;
            *(odata+1) = T1;
            *(odata+2) = T2;
            *(odata+3) = T3;
            *(odata+4) = T4;
            *(odata+5) = T5;
            *(odata+6) = T6;
            *(odata+7) = T7;
            idata++;
            odata += oRsiz;
        }
        irow += inRsizd8;
        ocol += 8;
    }
    if (Nrows%8 != 0) {
        for (ColCnt=Ncols; ColCnt>0; ColCnt--) {
            idata = irow++;
            odata = ocol;
            ocol += oRsiz;
            for (RowCnt=Nrows%8; RowCnt>0; RowCnt--) {
                T0 = *idata;
                *odata++ = T0;
                idata += iRsiz;
            }
        }
    }
}

void cxpose(double *indata, long iRsiz, double *outdata, long oRsiz, long Nrows, long Ncols)
{
    /* not in-place complex double matrix transpose	*/
    /* INPUTS */
    /* *indata = input data array	*/
    /* iRsiz = offset to between rows of input data array	*/
    /* oRsiz = offset to between rows of output data array	*/
    /* Nrows = number of rows in input data array	*/
    /* Ncols = number of columns in input data array	*/
    /* OUTPUTS */
    /* *outdata = output data array	*/

    double	*irow; 		/* pointer to input row start */
    double	*ocol; 		/* pointer to output col start */
    double	*idata; 	/* pointer to input data */
    double	*odata; 	/* pointer to output data */
    long 	RowCnt;		/* row counter */
    long 	ColCnt;		/* col counter */
    double	T0r; 		/* data storage */
    double	T0i; 		/* data storage */
    double	T1r; 		/* data storage */
    double	T1i; 		/* data storage */
    double	T2r; 		/* data storage */
    double	T2i; 		/* data storage */
    double	T3r; 		/* data storage */
    double	T3i; 		/* data storage */
    const long inRsizd1 = 2*iRsiz;
    const long inRsizd1i = 2*iRsiz + 1;
    const long inRsizd2 = 4*iRsiz;
    const long inRsizd2i = 4*iRsiz + 1;
    const long inRsizd3 = inRsizd2+inRsizd1;
    const long inRsizd3i = inRsizd2+inRsizd1 + 1;
    const long inRsizd4 = 8*iRsiz;

    ocol = outdata;
    irow = indata;
    for (RowCnt=Nrows/4; RowCnt>0; RowCnt--) {
        idata = irow;
        odata = ocol;
        for (ColCnt=Ncols; ColCnt>0; ColCnt--) {
            T0r = *idata;
            T0i = *(idata +1);
            T1r = *(idata+inRsizd1);
            T1i = *(idata+inRsizd1i);
            T2r = *(idata+inRsizd2);
            T2i = *(idata+inRsizd2i);
            T3r = *(idata+inRsizd3);
            T3i = *(idata+inRsizd3i);
            *odata = T0r;
            *(odata+1) = T0i;
            *(odata+2) = T1r;
            *(odata+3) = T1i;
            *(odata+4) = T2r;
            *(odata+5) = T2i;
            *(odata+6) = T3r;
            *(odata+7) = T3i;
            idata+=2;
            odata += 2*oRsiz;
        }
        irow += inRsizd4;
        ocol += 8;
    }
    if (Nrows%4 != 0) {
        for (ColCnt=Ncols; ColCnt>0; ColCnt--) {
            idata = irow;
            odata = ocol;
            for (RowCnt=Nrows%4; RowCnt>0; RowCnt--) {
                T0r = *idata;
                T0i = *(idata+1);
                *odata = T0r;
                *(odata+1) = T0i;
                odata+=2;
                idata += 2*iRsiz;
            }
            irow+=2;
            ocol += 2*oRsiz;
        }
    }
}

void cvprod(double *a, double *b, double *out, long N)
{
    /* complex vector product, can be in-place */
    /* product of complex vector *a times complex vector *b */
    /* INPUTS */
    /* N vector length */
    /* *a complex vector length N complex numbers */
    /* *b complex vector length N complex numbers */
    /* OUTPUTS */
    /* *out complex vector length N */

    long	OutCnt;		/* output counter */
    double	A0R; 		/* A storage */
    double	A0I; 		/* A storage */
    double	A1R; 		/* A storage */
    double	A1I; 		/* A storage */
    double	A2R; 		/* A storage */
    double	A2I; 		/* A storage */
    double	A3R; 		/* A storage */
    double	A3I; 		/* A storage */
    double	B0R; 		/* B storage */
    double	B0I; 		/* B storage */
    double	B1R; 		/* B storage */
    double	B1I; 		/* B storage */
    double	B2R; 		/* B storage */
    double	B2I; 		/* B storage */
    double	B3R; 		/* B storage */
    double	B3I; 		/* B storage */
    double	T0R; 		/* TMP storage */
    double	T0I; 		/* TMP storage */
    double	T1R; 		/* TMP storage */
    double	T1I; 		/* TMP storage */
    double	T2R; 		/* TMP storage */
    double	T2I; 		/* TMP storage */
    double	T3R; 		/* TMP storage */
    double	T3I; 		/* TMP storage */

    if (N>=4) {
        A0R = *a;
        B0R = *b;
        A0I = *(a +1);
        B0I = *(b +1);
        A1R = *(a +2);
        B1R = *(b +2);
        A1I = *(a +3);
        B1I = *(b +3);
        A2R = *(a +4);
        B2R = *(b +4);
        A2I = *(a +5);
        B2I = *(b +5);
        A3R = *(a +6);
        B3R = *(b +6);
        A3I = *(a +7);
        B3I = *(b +7);
        T0R = A0R * B0R;
        T0I = (A0R * B0I);
        T1R = A1R * B1R;
        T1I = (A1R * B1I);
        T2R = A2R * B2R;
        T2I = (A2R * B2I);
        T3R = A3R * B3R;
        T3I = (A3R * B3I);
        T0R -= (A0I * B0I);
        T0I = A0I * B0R + T0I;
        T1R -= (A1I * B1I);
        T1I = A1I * B1R + T1I;
        T2R -= (A2I * B2I);
        T2I = A2I * B2R + T2I;
        T3R -= (A3I * B3I);
        T3I = A3I * B3R + T3I;
        for (OutCnt=N/4-1; OutCnt > 0; OutCnt--) {
            a += 8;
            b += 8;
            A0R = *a;
            B0R = *b;
            A0I = *(a +1);
            B0I = *(b +1);
            A1R = *(a +2);
            B1R = *(b +2);
            A1I = *(a +3);
            B1I = *(b +3);
            A2R = *(a +4);
            B2R = *(b +4);
            A2I = *(a +5);
            B2I = *(b +5);
            A3R = *(a +6);
            B3R = *(b +6);
            A3I = *(a +7);
            B3I = *(b +7);
            *out = T0R;
            *(out +1) = T0I;
            *(out +2) = T1R;
            *(out +3) = T1I;
            *(out +4) = T2R;
            *(out +5) = T2I;
            *(out +6) = T3R;
            *(out +7) = T3I;
            T0R = A0R * B0R;
            T0I = (A0R * B0I);
            T1R = A1R * B1R;
            T1I = (A1R * B1I);
            T2R = A2R * B2R;
            T2I = (A2R * B2I);
            T3R = A3R * B3R;
            T3I = (A3R * B3I);
            T0R -= (A0I * B0I);
            T0I = A0I * B0R + T0I;
            T1R -= (A1I * B1I);
            T1I = A1I * B1R + T1I;
            T2R -= (A2I * B2I);
            T2I = A2I * B2R + T2I;
            T3R -= (A3I * B3I);
            T3I = A3I * B3R + T3I;
            out += 8;
        }
        a += 8;
        b += 8;
        *out = T0R;
        *(out +1) = T0I;
        *(out +2) = T1R;
        *(out +3) = T1I;
        *(out +4) = T2R;
        *(out +5) = T2I;
        *(out +6) = T3R;
        *(out +7) = T3I;
        out += 8;
    }
    for (OutCnt=N%4; OutCnt > 0; OutCnt--) {
        A0R = *a++;
        B0R = *b++;
        A0I = *a++;
        B0I = *b++;
        T0R = A0R * B0R;
        T0I = (A0R * B0I);
        T0R -= (A0I * B0I);
        T0I = A0I * B0R + T0I;
        *out++ = T0R;
        *out++ = T0I;
    }
}


