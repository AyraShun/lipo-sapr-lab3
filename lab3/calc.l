%{
/*
This file is part of Reverse Notation Calc.

    Reverse Notation Calc is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Foobar is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.

*/

#include "mystack.h"

#define TYPE_NUMBER 90988
#define TYPE_ARRAY 4774.789

typedef enum {
    LexNumber=1001,
    LexPlus,
    LexMinus,
    LexDiv,
    LexMult,
    LexEnd,
    LexUnknown,
    LexArray,
} LexType;

my_stack stack;

double value;
int k;
int end_file;
double array[100];
int j;

%}

%s SKIPERROR

digit     [0-9]
number    (-?{digit}+\.?{digit}*)+
array     \[{number}(\,{number})*\]

%%

{array} {		  
		  fprintf(stderr, "found array\n");}
{array}.{number}.\+ {
		  char *i = yytext;
		  j = 0;
		  while (*i != ']') {
		   if (isdigit(*i)) {
	      if(*(i-1) != '-') {
	        array[j] = strtod(i, &i);}
	      else {
	       array[j] = strtod(i, &i) * -1;}
	    	if(isinteger(array[j])){
	    	  fprintf(stderr, "found \"%d\" from array\n", (int)array[j]);}
	     	else {
	    	  fprintf(stderr, "found \"%.2f\" from array\n", array[j]);}
		  	j++;
			 }
			 else {
			  i++;
			 }
		  }
	    while (*i) {
	     if (isdigit(*i)) {
     	   if(*(i-1) != '-') {
           array[j] = strtod(i, &i);}
         else {
           array[j] = strtod(i, &i) * -1;}
         if(isinteger(array[j])){
     	     fprintf(stderr, "found \"%d\" to add to array from right\n", (int)array[j]);}
     	   else{
     	     fprintf(stderr, "found \"%.2f\" to add to array from right\n", array[j]);}
     	   j++;
	     }
	     else {
	    	i++;
	     }
	   }	  
		  return LexArray;}
{number}.{array}.\+ {
		   char* i = yytext;
		   j = 0;
		   while (*i != '[') {
		    if(isdigit(*i))
		    {
		      if(*(i-1) != '-') {
		        array[j] = strtod(i, &i);}
		      else {
		        array[j] = strtod(i, &i) * -1;}
		      if(isinteger(array[j])){
		        fprintf(stderr, "found \"%d\" to add to array from left\n", (int)array[j]);}
		      else{
		        fprintf(stderr, "found \"%.2f\" to add to array from left\n", array[j]);}
		      j++;			
		    }
		    else {
		      i++;}
		   }
		   while (*i != ']') {
		    if(isdigit(*i))
		    {
			    if(*(i-1) != '-') {
		        array[j] = strtod(i, &i);}
		      else {
		        array[j] = strtod(i, &i) * -1;}
		      if(isinteger(array[j])){
			      fprintf(stderr, "found \"%d\" from array\n", (int)array[j]);}
			    else {
			      fprintf(stderr, "found \"%.2f\" from array\n", array[j]);}
			    j++;			
		    }
		    else {
		      i++;}
		   }
		  return LexArray;}
{array}.{array}.\+ {
		  char* i = yytext;
		  j = 0;
		  while (*i != ']') {
		    if(isdigit(*i))
		    {
		      if(*(i-1) != '-') {
		      array[j] = strtod(i, &i);}
		      else {
		        array[j] = strtod(i, &i) * -1;}
		      if(isinteger(array[j])){
		        fprintf(stderr, "found \"%d\" from 1st array\n", (int)array[j]);}
		      else {
		        fprintf(stderr, "found \"%.2f\" from 1st array\n", array[j]);}
		      j++;			
		    }
		    else {
		      i++;
		    }
		  }
		  i++;
		  while (*i != ']') {
		    if(isdigit(*i))
		    {
		      if(*(i-1) != '-') {
		      array[j] = strtod(i, &i);}
		      else {
		        array[j] = strtod(i, &i) * -1;}
		      if(isinteger(array[j])){
		        fprintf(stderr, "found \"%d\" from 2nd array\n", (int)array[j]);}
		      else {
		        fprintf(stderr, "found \"%.2f\" from 2nd array\n", array[j]);}
		      j++;			
		    }
		    else {
		      i++;
		    }
		  }
		  return LexArray; }
{number}	{
		  value=strtod(yytext, &yytext);
		  if(isinteger(value)){
    	  fprintf(stderr, "found %d\n", (int)value);}
  	  else{
  	    fprintf(stderr, "found %.2f\n", value);}
		  return LexNumber; }
\+		{
		  fprintf(stderr, "plus\n");
		  return LexPlus; }
\-		{
		  fprintf(stderr, "minus\n");
		  return LexMinus; }
\/		{
		  fprintf(stderr, "div\n");
		  return LexDiv; }
\*		{
		  fprintf(stderr, "mult\n");
		  return LexMult; }
^[ \t]*\n	{
		  fprintf(stderr, "empty line\n");
		}
\n		{
		  fprintf(stderr, "CR\n");
		  return LexEnd; }
[ \t]		{ }
.		{ return LexUnknown; }

<SKIPERROR>[^\n]* {}
%%

int isinteger(double n)
{
  return n - (double)(int)n == 0.0;
}

int process_command(int token)
{
    fprintf(stderr, "token: %d\n", token);

    switch (token) {
    case LexArray:
	      while(k != j)
	      {
	        my_stack_push(&stack, array[k]);
	        k++;
	      }
	      my_stack_push(&stack, j);
	      my_stack_push(&stack, TYPE_ARRAY);
        if (my_stack_is_full(&stack)) {
            return -1;
        }
        break;
    case LexNumber:
        my_stack_push(&stack, value);
        if (my_stack_is_full(&stack)) {
            return -1;
        }
        break;
    case LexPlus: {
        if (my_stack_is_empty(&stack)) {
            return -1;
        }
        double a=my_stack_pull(&stack);

        if (my_stack_is_empty(&stack)) {
            return -1;
        }
        double b=my_stack_pull(&stack);

        my_stack_push(&stack, a+b);
        if (my_stack_is_full(&stack)) {
            return -1;
        }
        break;}
    case LexMinus: {
        if (my_stack_is_empty(&stack)) {
            return -1;
        }
        double a=my_stack_pull(&stack);

        if (my_stack_is_empty(&stack)) {
            return -1;
        }
        double b=my_stack_pull(&stack);

        my_stack_push(&stack, b-a);
        if (my_stack_is_full(&stack)) {
            return -1;
        }
        break;}
    case LexDiv: {
        if (my_stack_is_empty(&stack)) {
            return -1;
        }
        double a=my_stack_pull(&stack);

        if (my_stack_is_empty(&stack)) {
            return -1;
        }
        double b=my_stack_pull(&stack);

        my_stack_push(&stack, b/a);
        if (my_stack_is_full(&stack)) {
            return -1;
        }
        break;}
    case LexMult: {
        if (my_stack_is_empty(&stack)) {
            return -1;
        }
        double a=my_stack_pull(&stack);

        if (my_stack_is_empty(&stack)) {
            return -1;
        }
        double b=my_stack_pull(&stack);

        my_stack_push(&stack, b*a);
        if (my_stack_is_full(&stack)) {
            return -1;
        }
        break;}
    case LexEnd:
        if(stack.count == 1){         
          my_stack_push(&stack, TYPE_NUMBER);
        }
    case 0:
        return 0;
    case LexUnknown:
        return -1;

    }
    return 1;
}

int calc_line()
{
    int token = yylex();
    if (token == 0) {
        return 1;
    }

    while (1) {
        int cmd_res = process_command(token);
        if (cmd_res == 0) {
            break;
        }
        else if (cmd_res == -1) {
            fprintf(stderr, "Syntax error\n");
            return 0;
        }
        token = yylex();
    }

    if (my_stack_is_empty(&stack)) {
        fprintf(stderr, "Stack is empty but required value\n");
        return 0;
    }

    if( (stack.count == 2) && (my_stack_pull(&stack) == TYPE_NUMBER) ) {
	      double result = my_stack_pull(&stack);
	      if(isinteger(result)){
      	  fprintf(yyout, "%d ", (int)result);}
    	  else{
    	    fprintf(yyout, "%.2f ", result);}
	  }
    else if( (stack.count > 2) && (my_stack_pull(&stack) == TYPE_ARRAY) ) {
    	k=0;
    	fprintf(yyout, "array(%d, ",(int)my_stack_pull(&stack));
    	while (stack.count) {
    	  array[k] = my_stack_pull(&stack);
    	  k++;
    	}
    	k--;
    	while (k) {
    	  if(isinteger(array[k])){
    	    fprintf(yyout, "%d, ", (int)array[k]);}
    	  else{
    	    fprintf(yyout, "%.2f, ", array[k]);}
    	  k--;
    	}
    	if(isinteger(array[k])){
    	    fprintf(yyout, "%d) ", (int)array[k]);}
  	  else{
  	    fprintf(yyout, "%.2f) ", array[k]);}
    }

    if (!my_stack_is_empty(&stack)) {
        fprintf(stderr, "Stack not empty after calculation\n");
        return 0;
    }

    return 1;
}

void calc()
{
    while (!end_file) {
        fprintf(stderr, "parse line\n");
        if (calc_line() == 0) {
            printf("FAIL\n");
            BEGIN(SKIPERROR);
            yylex();
            BEGIN(INITIAL);
        }
        else {
            printf("OK\n");
        }
        fprintf(stderr, "line parsed\n");
    }
}

int main(void)
{
    my_stack_init(&stack, 100);
    end_file = 0;

    calc();

    my_stack_done(&stack);
    return 0;
}

int yywrap(void)
{
    end_file = 1;
    return 1;
}
