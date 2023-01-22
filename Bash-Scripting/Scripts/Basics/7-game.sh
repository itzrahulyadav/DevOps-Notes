#!/bin/bash

echo "starting the game..."

beast=$(($RANDOM % 2))

echo "Your first demon approaches.Prepare to fight!.Pick a weapon : (0)Sword (1)Gun"

read weapon

if   [ $weapon == $beast ];then
	echo "You rock.You are a demon slayer !!!!"
else
	echo "You died! "
        exit 1
fi

sleep 2

echo "Boss battle!!,This is the upper rank demon"

echo "choose a number between 0-1.(0-9):"

read number

beast=$(($RANDOM % 10))

if [[ $number == $beast || $number == "supraa" ]];then
	if [[ $USER=="root" ]];then
		echo "Beast killed!!"
 	fi
else
	echo "You died!!!"
fi
