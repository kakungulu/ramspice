#ifndef ngspice_SPDEFS_H
#define ngspice_SPDEFS_H
/*
 *  DATA STRUCTURE AND MACRO DEFINITIONS for Sparse.
 *
 *  Author:                     Advising professor:
 *      Kenneth S. Kundert          Alberto Sangiovanni-Vincentelli
 *      UC Berkeley
 *
 *  This file contains common type definitions and macros for the sparse
 *  matrix routines.  These definitions are of no interest to the user.
 */


/*
 *  Revision and copyright information.
 *
 *  Copyright (c) 1985,86,87,88,89,90
 *  by Kenneth S. Kundert and the University of California.
 *
 *  Permission to use, copy, modify, and distribute this software and
 *  its documentation for any purpose and without fee is hereby granted,
 *  provided that the copyright notices appear in all copies and
 *  supporting documentation and that the authors and the University of
 *  California are properly credited.  The authors and the University of
 *  California make no representations as to the suitability of this
 *  software for any purpose.  It is provided `as is', without express
 *  or implied warranty.
 */




/*
 *  IMPORTS
 */

#include <stdio.h>

#undef  ABORT
#undef  MALLOC
#undef  FREE
#undef  REALLOC



/*
 *   MACRO DEFINITIONS
 *
 *   Macros are distinguished by using solely capital letters in their
 *   identifiers.  This contrasts with C defined identifiers which are
 *   strictly lower case, and program variable and procedure names
 *   which use both upper and lower case.  */

/* Begin macros. */

/* Boolean data type */
#define  BOOLEAN        int
#define  NO             0
#define  YES            1

#define  SPARSE_ID      0x772773        /* Arbitrary (is Sparse on phone). */
#define  IS_SPARSE(matrix)      ((matrix) != NULL &&            \
                                 (matrix)->ID == SPARSE_ID)
#define  IS_VALID(matrix)       ((matrix) != NULL &&            \
                                 (matrix)->ID == SPARSE_ID &&   \
                                 (matrix)->Error >= spOKAY &&   \
                                 (matrix)->Error < spFATAL)
#define  IS_FACTORED(matrix)    ((matrix)->Factored && !(matrix)->NeedsOrdering)

/* Macro commands */
/* Macro functions that return the maximum or minimum independent of type. */
#define  MAX(a,b)           ((a) > (b) ? (a) : (b))
#define  MIN(a,b)           ((a) < (b) ? (a) : (b))

/* Macro function that returns the absolute value of a floating point number. */
#define  ABS(a)             ((a) < 0 ? -(a) : (a))

/* Macro function that returns the square of a number. */
#define  SQR(a)             ((a)*(a))

/* Macro procedure that swaps two entities. */
#define  SWAP(type, a, b)   {type swapx; swapx = a; a = b; b = swapx;}



/* Real and Complex numbers definition */

#define spREAL  double

/* Begin `realNumber'. */
typedef  spREAL  RealNumber, *RealVector;

/* Begin `ComplexNumber'. */
typedef  struct
{   RealNumber  Real;
    RealNumber  Imag;
} ComplexNumber, *ComplexVector;

/* Macro function that returns the approx absolute value of a complex
   number. */
#define  ELEMENT_MAG(ptr)   (ABS((ptr)->Real) + ABS((ptr)->Imag))
 
#define  CMPLX_ASSIGN_VALUE(cnum, vReal, vImag)		\
{   (cnum).Real = vReal;	\
    (cnum).Imag = vImag;	\
}         

/* Complex assignment statements. */
#define  CMPLX_ASSIGN(to,from)  \
{   (to).Real = (from).Real;    \
    (to).Imag = (from).Imag;    \
}
#define  CMPLX_CONJ_ASSIGN(to,from)     \
{   (to).Real = (from).Real;            \
    (to).Imag = -(from).Imag;           \
}
#define  CMPLX_NEGATE_ASSIGN(to,from)   \
{   (to).Real = -(from).Real;           \
    (to).Imag = -(from).Imag;           \
}
#define  CMPLX_CONJ_NEGATE_ASSIGN(to,from)      \
{   (to).Real = -(from).Real;                   \
    (to).Imag = (from).Imag;                    \
}

#define  CMPLX_CONJ(a)  (a).Imag = -(a).Imag

#define  CONJUGATE(a)	(a).Imag = -(a).Imag

#define  CMPLX_NEGATE(a)        \
{   (a).Real = -(a).Real;       \
    (a).Imag = -(a).Imag;       \
}

#define  CMPLX_NEGATE_SELF(cnum)	\
{   (cnum).Real = -(cnum).Real;	\
    (cnum).Imag = -(cnum).Imag;	\
}

/* Macro that returns the approx magnitude (L-1 norm) of a complex number. */
#define  CMPLX_1_NORM(a)        (ABS((a).Real) + ABS((a).Imag))

/* Macro that returns the approx magnitude (L-infinity norm) of a complex. */
#define  CMPLX_INF_NORM(a)      (MAX (ABS((a).Real),ABS((a).Imag)))

/* Macro function that returns the magnitude (L-2 norm) of a complex number. */
#define  CMPLX_2_NORM(a)        (sqrt((a).Real*(a).Real + (a).Imag*(a).Imag))

/* Macro function that performs complex addition. */
#define  CMPLX_ADD(to,from_a,from_b)            \
{   (to).Real = (from_a).Real + (from_b).Real;  \
    (to).Imag = (from_a).Imag + (from_b).Imag;  \
}

/* Macro function that performs addition of a complex and a double. */
#define  CMPLX_ADD_SELF_SCALAR(cnum, double)      \
{   (cnum).Real += double;   \
}

/* Macro function that performs complex subtraction. */
#define  CMPLX_SUBT(to,from_a,from_b)           \
{   (to).Real = (from_a).Real - (from_b).Real;  \
    (to).Imag = (from_a).Imag - (from_b).Imag;  \
}

/* Macro function that is equivalent to += operator for complex numbers. */
#define  CMPLX_ADD_ASSIGN(to,from)      \
{   (to).Real += (from).Real;           \
    (to).Imag += (from).Imag;           \
}

/* Macro function that is equivalent to -= operator for complex numbers. */
#define  CMPLX_SUBT_ASSIGN(to,from)     \
{   (to).Real -= (from).Real;           \
    (to).Imag -= (from).Imag;           \
}
 
/* Macro function that multiplies a complex number by a double. */
#define  SCLR_MULT(to,sclr,cmplx)       \
{   (to).Real = (sclr) * (cmplx).Real;  \
    (to).Imag = (sclr) * (cmplx).Imag;  \
}

/* Macro function that multiply-assigns a complex number by a double. */
#define  SCLR_MULT_ASSIGN(to,sclr)      \
{   (to).Real *= (sclr);                \
    (to).Imag *= (sclr);                \
}

/* Macro function that multiplies two complex numbers. */
#define  CMPLX_MULT(to,from_a,from_b)           \
{   (to).Real = (from_a).Real * (from_b).Real - \
                (from_a).Imag * (from_b).Imag;  \
    (to).Imag = (from_a).Real * (from_b).Imag + \
                (from_a).Imag * (from_b).Real;  \
}
 
/* Macro function that multiplies a complex number and a double. */
#define  CMPLX_MULT_SCALAR(to,from, double)      \
{   (to).Real = (from).Real * double;   \
    (to).Imag = (from).Imag * double;   \
}
 
/* Macro function that implements *= for a complex and a double number. */
 
#define  CMPLX_MULT_SELF_SCALAR(cnum, double)      \
{   (cnum).Real *= double;   \
    (cnum).Imag *= double;   \
}

/* Macro function that multiply-assigns a complex number by a double. */
#define  SCLR_MULT_ASSIGN(to,sclr)      \
{   (to).Real *= (sclr);                \
    (to).Imag *= (sclr);                \
}

/* Macro function that implements to *= from for complex numbers. */
#define  CMPLX_MULT_ASSIGN(to,from)             \
{   RealNumber to_Real_ = (to).Real;            \
    (to).Real = to_Real_ * (from).Real -        \
                (to).Imag * (from).Imag;        \
    (to).Imag = to_Real_ * (from).Imag +        \
                (to).Imag * (from).Real;        \
}

/* Macro function that multiplies two complex numbers, the first of which is
 * conjugated. */
#define  CMPLX_CONJ_MULT(to,from_a,from_b)      \
{   (to).Real = (from_a).Real * (from_b).Real + \
                (from_a).Imag * (from_b).Imag;  \
    (to).Imag = (from_a).Real * (from_b).Imag - \
                (from_a).Imag * (from_b).Real;  \
}

/* Macro function that multiplies two complex numbers and then adds them
 * to another. to = add + mult_a * mult_b */
#define  CMPLX_MULT_ADD(to,mult_a,mult_b,add)                   \
{   (to).Real = (mult_a).Real * (mult_b).Real -                 \
                (mult_a).Imag * (mult_b).Imag + (add).Real;     \
    (to).Imag = (mult_a).Real * (mult_b).Imag +                 \
                (mult_a).Imag * (mult_b).Real + (add).Imag;     \
}

/* Macro function that subtracts the product of two complex numbers from
 * another.  to = subt - mult_a * mult_b */
#define  CMPLX_MULT_SUBT(to,mult_a,mult_b,subt)                 \
{   (to).Real = (subt).Real - (mult_a).Real * (mult_b).Real +   \
                              (mult_a).Imag * (mult_b).Imag;    \
    (to).Imag = (subt).Imag - (mult_a).Real * (mult_b).Imag -   \
                              (mult_a).Imag * (mult_b).Real;    \
}

/* Macro function that multiplies two complex numbers and then adds them
 * to another. to = add + mult_a* * mult_b where mult_a* represents mult_a
 * conjugate. */
#define  CMPLX_CONJ_MULT_ADD(to,mult_a,mult_b,add)              \
{   (to).Real = (mult_a).Real * (mult_b).Real +                 \
                (mult_a).Imag * (mult_b).Imag + (add).Real;     \
    (to).Imag = (mult_a).Real * (mult_b).Imag -                 \
                (mult_a).Imag * (mult_b).Real + (add).Imag;     \
}

/* Macro function that multiplies two complex numbers and then adds them
 * to another. to += mult_a * mult_b */
#define  CMPLX_MULT_ADD_ASSIGN(to,from_a,from_b)        \
{   (to).Real += (from_a).Real * (from_b).Real -        \
                 (from_a).Imag * (from_b).Imag;         \
    (to).Imag += (from_a).Real * (from_b).Imag +        \
                 (from_a).Imag * (from_b).Real;         \
}

/* Macro function that multiplies two complex numbers and then subtracts them
 * from another. */
#define  CMPLX_MULT_SUBT_ASSIGN(to,from_a,from_b)       \
{   (to).Real -= (from_a).Real * (from_b).Real -        \
                 (from_a).Imag * (from_b).Imag;         \
    (to).Imag -= (from_a).Real * (from_b).Imag +        \
                 (from_a).Imag * (from_b).Real;         \
}

/* Macro function that multiplies two complex numbers and then adds them
 * to the destination. to += from_a* * from_b where from_a* represents from_a
 * conjugate. */
#define  CMPLX_CONJ_MULT_ADD_ASSIGN(to,from_a,from_b)   \
{   (to).Real += (from_a).Real * (from_b).Real +        \
                 (from_a).Imag * (from_b).Imag;         \
    (to).Imag += (from_a).Real * (from_b).Imag -        \
                 (from_a).Imag * (from_b).Real;         \
}

/* Macro function that multiplies two complex numbers and then subtracts them
 * from the destination. to -= from_a* * from_b where from_a* represents from_a
 * conjugate. */
#define  CMPLX_CONJ_MULT_SUBT_ASSIGN(to,from_a,from_b)  \
{   (to).Real -= (from_a).Real * (from_b).Real +        \
                 (from_a).Imag * (from_b).Imag;         \
    (to).Imag -= (from_a).Real * (from_b).Imag -        \
                 (from_a).Imag * (from_b).Real;         \
}

/*
 * Macro functions that provide complex division.
 */

/* Complex division:  to = num / den */
#define CMPLX_DIV(to,num,den)                                           \
{   RealNumber  r_, s_;                                                 \
    if (((den).Real >= (den).Imag && (den).Real > -(den).Imag) ||       \
        ((den).Real < (den).Imag && (den).Real <= -(den).Imag))         \
    {   r_ = (den).Imag / (den).Real;                                   \
        s_ = (den).Real + r_*(den).Imag;                                \
        (to).Real = ((num).Real + r_*(num).Imag)/s_;                    \
        (to).Imag = ((num).Imag - r_*(num).Real)/s_;                    \
    }                                                                   \
    else                                                                \
    {   r_ = (den).Real / (den).Imag;                                   \
        s_ = (den).Imag + r_*(den).Real;                                \
        (to).Real = (r_*(num).Real + (num).Imag)/s_;                    \
        (to).Imag = (r_*(num).Imag - (num).Real)/s_;                    \
    }                                                                   \
}

/* Complex division and assignment:  num /= den */
#define CMPLX_DIV_ASSIGN(num,den)                                       \
{   RealNumber  r_, s_, t_;                                             \
    if (((den).Real >= (den).Imag && (den).Real > -(den).Imag) ||       \
        ((den).Real < (den).Imag && (den).Real <= -(den).Imag))         \
    {   r_ = (den).Imag / (den).Real;                                   \
        s_ = (den).Real + r_*(den).Imag;                                \
        t_ = ((num).Real + r_*(num).Imag)/s_;                           \
        (num).Imag = ((num).Imag - r_*(num).Real)/s_;                   \
        (num).Real = t_;                                                \
    }                                                                   \
    else                                                                \
    {   r_ = (den).Real / (den).Imag;                                   \
        s_ = (den).Imag + r_*(den).Real;                                \
        t_ = (r_*(num).Real + (num).Imag)/s_;                           \
        (num).Imag = (r_*(num).Imag - (num).Real)/s_;                   \
        (num).Real = t_;                                                \
    }                                                                   \
}

/* Complex reciprocation:  to = 1.0 / den */
#define CMPLX_RECIPROCAL(to,den)                                        \
{   RealNumber  r_;                                                     \
    if (((den).Real >= (den).Imag && (den).Real > -(den).Imag) ||       \
        ((den).Real < (den).Imag && (den).Real <= -(den).Imag))         \
    {   r_ = (den).Imag / (den).Real;                                   \
        (to).Imag = -r_*((to).Real = 1.0/((den).Real + r_*(den).Imag)); \
    }                                                                   \
    else                                                                \
    {   r_ = (den).Real / (den).Imag;                                   \
        (to).Real = -r_*((to).Imag = -1.0/((den).Imag + r_*(den).Real));\
    }                                                                   \
}






/* Allocation */

extern void * tmalloc(size_t);
extern void   txfree(void *);
extern void * trealloc(void *, size_t);

#define SP_MALLOC(type,number)  (type *) tmalloc((size_t)(number) * sizeof(type))
#define SP_REALLOC(ptr,type,number) \
           ptr = (type *) trealloc(ptr, (size_t)(number) * sizeof(type))
#define SP_FREE(ptr) { if ((ptr) != NULL) txfree(ptr); (ptr) = NULL; }



/* A new calloc */
#ifndef HAVE_LIBGC
#define SP_CALLOC(ptr,type,number)                           \
{ ptr = (type *) calloc((size_t)(number), sizeof(type));     \
}
#else /* HAVE_LIBCG */
#define SP_CALLOC(ptr,type,number)                           \
{ ptr = (type *) tmalloc((size_t)(number) * sizeof(type));   \
}
#endif

#include "ngspice/defines.h"


/*
 *  MATRIX ELEMENT DATA STRUCTURE
 *
 *  Every nonzero element in the matrix is stored in a dynamically allocated
 *  MatrixElement structure.  These structures are linked together in an
 *  orthogonal linked list.  Two different MatrixElement structures exist.
 *  One is used when only real matrices are expected, it is missing an entry
 *  for imaginary data.  The other is used if complex matrices are expected.
 *  It contains an entry for imaginary data.
 *
 *  >>> Structure fields:
 *  Real  (RealNumber)
 *      The real portion of the value of the element.  Real must be the first
 *      field in this structure.
 *  Imag  (RealNumber)
 *      The imaginary portion of the value of the element. If the matrix
 *      routines are not compiled to handle complex matrices, then this
 *      field does not exist.  If it exists, it must follow immediately after
 *      Real.
 *  Row  (int)
 *      The row number of the element.
 *  Col  (int)
 *      The column number of the element.
 *  NextInRow  (struct MatrixElement *)
 *      NextInRow contains a pointer to the next element in the row to the
 *      right of this element.  If this element is the last nonzero in the
 *      row then NextInRow contains NULL.
 *  NextInCol  (struct MatrixElement *)
 *      NextInCol contains a pointer to the next element in the column below
 *      this element.  If this element is the last nonzero in the column then
 *      NextInCol contains NULL.
 *  pInitInfo  (void *)
 *      Pointer to user data used for initialization of the matrix element.
 *      Initialized to NULL.
 *
 *  >>> Type definitions:
 *  ElementPtr
 *      A pointer to a MatrixElement.
 *  ArrayOfElementPtrs
 *      An array of ElementPtrs.  Used for FirstInRow, FirstInCol and
 *      Diag pointer arrays.
 */

/* Begin `MatrixElement'. */

struct  MatrixElement
{
    RealNumber   Real;
    RealNumber   Imag;
    int          Row;
    int          Col;
    struct MatrixElement  *NextInRow;
    struct MatrixElement  *NextInCol;
#if INITIALIZE
    void        *pInitInfo;
#endif
};

typedef  struct MatrixElement  *ElementPtr;
typedef  ElementPtr  *ArrayOfElementPtrs;








/*
 *  ALLOCATION DATA STRUCTURE
 *
 *  The sparse matrix routines keep track of all memory that is allocated by
 *  the operating system so the memory can later be freed.  This is done by
 *  saving the pointers to all the chunks of memory that are allocated to a
 *  particular matrix in an allocation list.  That list is organized as a
 *  linked list so that it can grow without a priori bounds.
 *
 *  >>> Structure fields:
 *  AllocatedPtr  (void *)
 *      Pointer to chunk of memory that has been allocated for the matrix.
 *  NextRecord  (struct  AllocationRecord *)
 *      Pointer to the next allocation record.
 */

/* Begin `AllocationRecord'. */
struct AllocationRecord
{
    void  *AllocatedPtr;
    struct  AllocationRecord  *NextRecord;
};

typedef  struct  AllocationRecord  *AllocationListPtr;









/*
 *  FILL-IN LIST DATA STRUCTURE
 *
 *  The sparse matrix routines keep track of all fill-ins separately from
 *  user specified elements so they may be removed by spStripFills().  Fill-ins
 *  are allocated in bunched in what is called a fill-in lists.  The data
 *  structure defined below is used to organize these fill-in lists into a
 *  linked-list.
 *
 *  >>> Structure fields:
 *  pFillinList  (ElementPtr)
 *      Pointer to a fill-in list, or a bunch of fill-ins arranged contiguously
 *      in memory.
 *  NumberOfFillinsInList  (int)
 *      Seems pretty self explanatory to me.
 *  Next  (struct  FillinListNodeStruct *)
 *      Pointer to the next fill-in list structures.
 */

/* Begin `FillinListNodeStruct'. */
struct FillinListNodeStruct
{
    ElementPtr  pFillinList;
    int         NumberOfFillinsInList;
    struct      FillinListNodeStruct  *Next;
};

/* Similar to above, but keeps track of the original Elements */
/* Begin `ElementListNodeStruct'. */
struct ElementListNodeStruct
{
    ElementPtr  pElementList;
    int         NumberOfElementsInList;
    struct      ElementListNodeStruct  *Next;
};










/*
 *  MATRIX FRAME DATA STRUCTURE
 *
 *  This structure contains all the pointers that support the orthogonal
 *  linked list that contains the matrix elements.  Also included in this
 *  structure are other numbers and pointers that are used globally by the
 *  sparse matrix routines and are associated with one particular matrix.
 *
 *  >>> Type definitions:
 *  MatrixPtr
 *      A pointer to MatrixFrame.  Essentially, a pointer to the matrix.
 *
 *  >>> Structure fields:
 *  AbsThreshold  (RealNumber)
 *      The absolute magnitude an element must have to be considered as a
 *      pivot candidate, except as a last resort.
 *  AllocatedExtSize  (int)
 *      The allocated size of the arrays used to translate external row and
 *      column numbers to their internal values.
 *  AllocatedSize  (int)
 *      The currently allocated size of the matrix; the size the matrix can
 *      grow to when EXPANDABLE is set true and AllocatedSize is the largest
 *      the matrix can get without requiring that the matrix frame be
 *      reallocated.
 *  Complex  (int)
 *      The flag which indicates whether the matrix is complex (true) or
 *      real.
 *  CurrentSize  (int)
 *      This number is used during the building of the matrix when the
 *      TRANSLATE option is set true.  It indicates the number of internal
 *      rows and columns that have elements in them.
 *  Diag  (ArrayOfElementPtrs)
 *      Array of pointers that points to the diagonal elements.
 *  DoCmplxDirect  (int *)
 *      Array of flags, one for each column in matrix.  If a flag is true
 *      then corresponding column in a complex matrix should be eliminated
 *      in spFactor() using direct addressing (rather than indirect
 *      addressing).
 *  DoRealDirect  (int *)
 *      Array of flags, one for each column in matrix.  If a flag is true
 *      then corresponding column in a real matrix should be eliminated
 *      in spFactor() using direct addressing (rather than indirect
 *      addressing).
 *  Elements  (int)
 *	The total number of elements present in matrix.
 *  Error  (int)
 *      The error status of the sparse matrix package.
 *  ExtSize  (int)
 *      The value of the largest external row or column number encountered.
 *  ExtToIntColMap  (int [])
 *      An array that is used to convert external columns number to internal
 *      external column numbers.  Present only if TRANSLATE option is set true.
 *  ExtToIntRowMap  (int [])
 *      An array that is used to convert external row numbers to internal
 *      external row numbers.  Present only if TRANSLATE option is set true.
 *  Factored  (int)
 *      Indicates if matrix has been factored.  This flag is set true in
 *      spFactor() and spOrderAndFactor() and set false in spCreate()
 *      and spClear().
 *  Fillins  (int)
 *      The number of fill-ins created during the factorization the matrix.
 *  FirstInCol  (ArrayOfElementPtrs)
 *      Array of pointers that point to the first nonzero element of the
 *      column corresponding to the index.
 *  FirstInRow  (ArrayOfElementPtrs)
 *      Array of pointers that point to the first nonzero element of the row
 *      corresponding to the index.
 *  ID  (unsigned long int)
 *      A constant that provides the sparse data structure with a signature.
 *      When DEBUG is true, all externally available sparse routines check
 *      this signature to assure they are operating on a valid matrix.
 *  Intermediate  (RealVector)
 *      Temporary storage used in the spSolve routines. Intermediate is an
 *      array used during forward and backward substitution.  It is
 *      commonly called y when the forward and backward substitution process is
 *      denoted  Ax = b => Ly = b and Ux = y.
 *  InternalVectorsAllocated  (int)
 *      A flag that indicates whether the Markowitz vectors and the
 *      Intermediate vector have been created.
 *      These vectors are created in spcCreateInternalVectors().
 *  IntToExtColMap  (int [])
 *      An array that is used to convert internal column numbers to external
 *      external column numbers.
 *  IntToExtRowMap  (int [])
 *      An array that is used to convert internal row numbers to external
 *      external row numbers.
 *  MarkowitzCol  (int [])
 *      An array that contains the count of the non-zero elements excluding
 *      the pivots for each column. Used to generate and update MarkowitzProd.
 *  MarkowitzProd  (long [])
 *      The array of the products of the Markowitz row and column counts. The
 *      element with the smallest product is the best pivot to use to maintain
 *      sparsity.
 *  MarkowitzRow  (int [])
 *      An array that contains the count of the non-zero elements excluding
 *      the pivots for each row. Used to generate and update MarkowitzProd.
 *  MaxRowCountInLowerTri  (int)
 *      The maximum number of off-diagonal element in the rows of L, the
 *      lower triangular matrix.  This quantity is used when computing an
 *      estimate of the roundoff error in the matrix.
 *  NeedsOrdering  (int)
 *      This is a flag that signifies that the matrix needs to be ordered
 *      or reordered.  NeedsOrdering is set true in spCreate() and
 *      spGetElement() or spGetAdmittance() if new elements are added to the
 *      matrix after it has been previously factored.  It is set false in
 *      spOrderAndFactor().
 *  NumberOfInterchangesIsOdd  (int)
 *      Flag that indicates the sum of row and column interchange counts
 *      is an odd number.  Used when determining the sign of the determinant.
 *  Originals  (int)
 *      The number of original elements (total elements minus fill ins)
 *      present in matrix.
 *  Partitioned  (int)
 *      This flag indicates that the columns of the matrix have been 
 *      partitioned into two groups.  Those that will be addressed directly
 *      and those that will be addressed indirectly in spFactor().
 *  PivotsOriginalCol  (int)
 *      Column pivot was chosen from.
 *  PivotsOriginalRow  (int)
 *      Row pivot was chosen from.
 *  PivotSelectionMethod  (char)
 *      Character that indicates which pivot search method was successful.
 *  PreviousMatrixWasComplex  (int)
 *      This flag in needed to determine how to clear the matrix.  When
 *      dealing with real matrices, it is important that the imaginary terms
 *      in the matrix elements be zero.  Thus, if the previous matrix was
 *      complex, then the current matrix will be cleared as if it were complex
 *      even if it is real.
 *  RelThreshold  (RealNumber)
 *      The magnitude an element must have relative to others in its row
 *      to be considered as a pivot candidate, except as a last resort.
 *  Reordered  (int)
 *      This flag signifies that the matrix has been reordered.  It
 *      is cleared in spCreate(), set in spMNA_Preorder() and
 *      spOrderAndFactor() and is used in spPrint().
 *  RowsLinked  (int)
 *      A flag that indicates whether the row pointers exist.  The AddByIndex
 *      routines do not generate the row pointers, which are needed by some
 *      of the other routines, such as spOrderAndFactor() and spScale().
 *      The row pointers are generated in the function spcLinkRows().
 *  SingularCol  (int)
 *      Normally zero, but if matrix is found to be singular, SingularCol is
 *      assigned the external column number of pivot that was zero.
 *  SingularRow  (int)
 *      Normally zero, but if matrix is found to be singular, SingularRow is
 *      assigned the external row number of pivot that was zero.
 *  Singletons  (int)
 *      The number of singletons available for pivoting.  Note that if row I
 *      and column I both contain singletons, only one of them is counted.
 *  Size  (int)
 *      Number of rows and columns in the matrix.  Does not change as matrix
 *      is factored.
 *  TrashCan  (MatrixElement)
 *      This is a dummy MatrixElement that is used to by the user to stuff
 *      data related to the zero row or column.  In other words, when the user
 *      adds an element in row zero or column zero, then the matrix returns
 *      a pointer to TrashCan.  In this way the user can have a uniform way
 *      data into the matrix independent of whether a component is connected
 *      to ground.
 *
 *  >>> The remaining fields are related to memory allocation.
 *  TopOfAllocationList  (AllocationListPtr)
 *      Pointer which points to the top entry in a list. The list contains
 *      all the pointers to the segments of memory that have been allocated
 *      to this matrix. This is used when the memory is to be freed on
 *      deallocation of the matrix.
 *  RecordsRemaining  (int)
 *      Number of slots left in the list of allocations.
 *  NextAvailElement  (ElementPtr)
 *      Pointer to the next available element which has been allocated but as
 *      yet is unused. Matrix elements are allocated in groups of
 *      ELEMENTS_PER_ALLOCATION in order to speed element allocation and
 *      freeing.
 *  ElementsRemaining  (int)
 *      Number of unused elements left in last block of elements allocated.
 *  NextAvailFillin  (ElementPtr)
 *      Pointer to the next available fill-in which has been allocated but
 *      as yet is unused.  Fill-ins are allocated in a group in order to keep
 *      them physically close in memory to the rest of the matrix.
 *  FillinsRemaining  (int)
 *      Number of unused fill-ins left in the last block of fill-ins
 *      allocated.
 *  FirstFillinListNode  (FillinListNodeStruct *)
 *      A pointer to the head of the linked-list that keeps track of the
 *      lists of fill-ins.
 *  LastFillinListNode  (FillinListNodeStruct *)
 *      A pointer to the tail of the linked-list that keeps track of the
 *      lists of fill-ins.
 */

/* Begin `MatrixFrame'. */
struct  MatrixFrame
{
    RealNumber                   AbsThreshold;
    int                          AllocatedSize;
    int                          AllocatedExtSize;
    int                      Complex;
    int                          CurrentSize;
    ArrayOfElementPtrs           Diag;
    int                     *DoCmplxDirect;
    int                     *DoRealDirect;
    int                          Elements;
    int                          Error;
    int                          ExtSize;
    int                         *ExtToIntColMap;
    int                         *ExtToIntRowMap;
    int                      Factored;
    int                          Fillins;
    ArrayOfElementPtrs           FirstInCol;
    ArrayOfElementPtrs           FirstInRow;
    unsigned long                ID;
    RealVector                   Intermediate;
    int                      InternalVectorsAllocated;
    int                         *IntToExtColMap;
    int                         *IntToExtRowMap;
    int                         *MarkowitzRow;
    int                         *MarkowitzCol;
    long                        *MarkowitzProd;
    int                          MaxRowCountInLowerTri;
    int                      NeedsOrdering;
    int                      NumberOfInterchangesIsOdd;
    int                          Originals;
    int                      Partitioned;
    int                          PivotsOriginalCol;
    int                          PivotsOriginalRow;
    char                         PivotSelectionMethod;
    int                      PreviousMatrixWasComplex;
    RealNumber                   RelThreshold;
    int                      Reordered;
    int                      RowsLinked;
    int                          SingularCol;
    int                          SingularRow;
    int                          Singletons;
    int                          Size;
    struct MatrixElement         TrashCan;

    AllocationListPtr            TopOfAllocationList;
    int                          RecordsRemaining;
    ElementPtr                   NextAvailElement;
    int                          ElementsRemaining;
    struct ElementListNodeStruct *FirstElementListNode;
    struct ElementListNodeStruct *LastElementListNode;
    ElementPtr                   NextAvailFillin;
    int                          FillinsRemaining;
    struct FillinListNodeStruct *FirstFillinListNode;
    struct FillinListNodeStruct *LastFillinListNode;
};


/*
 *  Function declarations
 */

extern ElementPtr spcGetElement( MatrixPtr );
extern ElementPtr spcGetFillin( MatrixPtr );
extern ElementPtr spcFindElementInCol( MatrixPtr, ElementPtr*, int, int, int );
extern ElementPtr spcCreateElement( MatrixPtr, int, int, ElementPtr*, int );
extern void spcCreateInternalVectors( MatrixPtr );
extern void spcLinkRows( MatrixPtr );
extern void spcColExchange( MatrixPtr, int, int );
extern void spcRowExchange( MatrixPtr, int, int );

void spErrorMessage(MatrixPtr, FILE *, char *);

#endif



