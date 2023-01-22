#!/bin/bash


# a function that displays the sum of two numbers

func_add ()
{
   local x=$1 # 1st argument to the function
   local y=$2 # 2nd argument  to the function

   result=$(( x + y ))
}

# the function can be called like this

func_add 2 5
