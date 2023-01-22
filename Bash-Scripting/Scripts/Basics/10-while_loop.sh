#!/bin/bash

#The while loop

x=1

while [[ $x -le 100 ]]
do
	echo "Number=$x"
	(( x++ ))
done



#Note : The variable x can also be increased by x=$(( $x+1 ))
