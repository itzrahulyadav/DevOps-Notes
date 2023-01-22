#!/bin/bash


until [[ $choice == "blue" ]]
do
	echo "Pick red or blue"
	read choice
done

echo "you chose blue"
