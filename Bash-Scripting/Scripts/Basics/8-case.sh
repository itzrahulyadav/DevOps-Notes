#!/bin/bash

echo "Pick a language to start:
1 - Go
2 - Python
3 - JavaScript
"

read number

case $number in
	1)
	   echo "You chose 1"

           lan="Go"
           ;;

	2)
          echo "You chose 2"

          lan="Python"
          ;;

	3)
          echo "You chose 3"
          lan="Javascript"
          ;;
        *)
	  echo "You did not pick a correct number"
          ;;
esac

echo "$lan"

