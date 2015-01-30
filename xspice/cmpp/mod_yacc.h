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
     TOK_ARGS = 258,
     TOK_INIT = 259,
     TOK_ANALYSIS = 260,
     TOK_NEW_TIMEPOINT = 261,
     TOK_TIME = 262,
     TOK_RAD_FREQ = 263,
     TOK_TEMPERATURE = 264,
     TOK_T = 265,
     TOK_PARAM = 266,
     TOK_PARAM_SIZE = 267,
     TOK_PARAM_NULL = 268,
     TOK_PORT_SIZE = 269,
     TOK_PORT_NULL = 270,
     TOK_PARTIAL = 271,
     TOK_AC_GAIN = 272,
     TOK_CHANGED = 273,
     TOK_OUTPUT_DELAY = 274,
     TOK_STATIC_VAR = 275,
     TOK_STATIC_VAR_SIZE = 276,
     TOK_STATIC_VAR_INST = 277,
     TOK_INPUT = 278,
     TOK_INPUT_STRENGTH = 279,
     TOK_INPUT_STATE = 280,
     TOK_INPUT_TYPE = 281,
     TOK_OUTPUT = 282,
     TOK_OUTPUT_CHANGED = 283,
     TOK_OUTPUT_STRENGTH = 284,
     TOK_OUTPUT_STATE = 285,
     TOK_OUTPUT_TYPE = 286,
     TOK_COMMA = 287,
     TOK_LPAREN = 288,
     TOK_RPAREN = 289,
     TOK_LBRACKET = 290,
     TOK_RBRACKET = 291,
     TOK_MISC_C = 292,
     TOK_IDENTIFIER = 293,
     TOK_LOAD = 294,
     TOK_TOTAL_LOAD = 295,
     TOK_MESSAGE = 296,
     TOK_CALL_TYPE = 297
   };
#endif



#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
{

/* Line 2068 of yacc.c  */
#line 329 "mod_yacc.y"

   char *str;
   Sub_Id_t sub_id;



/* Line 2068 of yacc.c  */
#line 99 "mod_yacc.h"
} YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;




