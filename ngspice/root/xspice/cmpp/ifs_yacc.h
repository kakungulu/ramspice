/* A Bison parser, made by GNU Bison 2.5.  */

/* Bison interface for Yacc-like parsers in C
   
      Copyright (C) 1984, 1989-1990, 2000-2011 Free Software Foundation, Inc.
   
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.
   
   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */


/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     TOK_ALLOWED_TYPES = 258,
     TOK_ARRAY = 259,
     TOK_ARRAY_BOUNDS = 260,
     TOK_BOOL_NO = 261,
     TOK_BOOL_YES = 262,
     TOK_COMMA = 263,
     TOK_PORT_NAME = 264,
     TOK_PORT_TABLE = 265,
     TOK_CTYPE_D = 266,
     TOK_CTYPE_G = 267,
     TOK_CTYPE_GD = 268,
     TOK_CTYPE_H = 269,
     TOK_CTYPE_HD = 270,
     TOK_CTYPE_I = 271,
     TOK_CTYPE_ID = 272,
     TOK_CTYPE_V = 273,
     TOK_CTYPE_VD = 274,
     TOK_CTYPE_VNAM = 275,
     TOK_C_FUNCTION_NAME = 276,
     TOK_DASH = 277,
     TOK_DATA_TYPE = 278,
     TOK_DEFAULT_TYPE = 279,
     TOK_DEFAULT_VALUE = 280,
     TOK_DESCRIPTION = 281,
     TOK_DIRECTION = 282,
     TOK_DIR_IN = 283,
     TOK_DIR_INOUT = 284,
     TOK_DIR_OUT = 285,
     TOK_DTYPE_BOOLEAN = 286,
     TOK_DTYPE_COMPLEX = 287,
     TOK_DTYPE_INT = 288,
     TOK_DTYPE_POINTER = 289,
     TOK_DTYPE_REAL = 290,
     TOK_DTYPE_STRING = 291,
     TOK_IDENTIFIER = 292,
     TOK_STATIC_VAR_NAME = 293,
     TOK_STATIC_VAR_TABLE = 294,
     TOK_INT_LITERAL = 295,
     TOK_LANGLE = 296,
     TOK_LBRACKET = 297,
     TOK_LIMITS = 298,
     TOK_NAME_TABLE = 299,
     TOK_NULL_ALLOWED = 300,
     TOK_PARAMETER_NAME = 301,
     TOK_PARAMETER_TABLE = 302,
     TOK_RANGLE = 303,
     TOK_RBRACKET = 304,
     TOK_REAL_LITERAL = 305,
     TOK_SPICE_MODEL_NAME = 306,
     TOK_STRING_LITERAL = 307
   };
#endif



#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
{

/* Line 2068 of yacc.c  */
#line 488 "ifs_yacc.y"

   Ctype_List_t 	*ctype_list;
   Dir_t		dir;
   Boolean_t		bool;
   Range_t		range;
   Data_Type_t		dtype;
   My_Port_Type_t	ctype;
   My_Value_t		value;
   char			*str;
   Bound_t		bound;
   int			ival;
   double		rval;
   Complex_t		cval;



/* Line 2068 of yacc.c  */
#line 119 "ifs_yacc.h"
} YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;




