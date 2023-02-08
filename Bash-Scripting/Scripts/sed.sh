#!/bin/bash

echo "enter filename to substitute using sed"
read filename

if [[ -f $filename ]]
then
	cat menu.sh | sed 's/i/I/'
else
	echo "$filename does not exist"
fi

