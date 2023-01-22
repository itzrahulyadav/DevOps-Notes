#!/bin/bash

echo "Hey do you watch anime ?(y/n)"

read answer

if [ $answer == "y"];then
	echo "Great,you are awesome"
else
	echo "Okay,try it sometimes"
fi
