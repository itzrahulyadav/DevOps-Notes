#!/bin/bash

echo "enter file name to search from"
read filename

if [[ -f $filename ]]
then
	echo "enter the text to search"
	read grepvar 
	grep $grepvar $filename	
else
	echo "$filename does not exist"
fi

# use -i to remove case sensitivity
# use -n to show line numbers
# use -c to show number of times a word occurs
# use -v to see lines which occur without the word we searched for

