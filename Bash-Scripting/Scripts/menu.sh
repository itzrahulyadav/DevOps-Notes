#!/bin/bash

select car in BMW MERCEDES TOYOTA MUSTANG GTR SUPRA
do
	case $car in 
	BMW)
		echo "BMW SELECTED";;
	MERCEDES)
		echo "mercedes selected";;
	TOYOTA)
		echo "toyota never breaks!!";;
	MUSTANG)
		echo "Nice choice mustang";;
	GTR)
	 	echo "you selected gtr.❤";;
	SUPRA)
	 	echo "you selected supra ratataa!!!!";;
	*)
		echo "error!not a valid option";;
	esac
done
