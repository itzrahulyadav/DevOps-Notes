#!/bin/bash



for i in {1..20}

do
   echo "The number is $i"
   if [[ $i == 5 ]]; then
	break
   fi

done
