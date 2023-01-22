#!/bin/bash

echo "Hello $USER"

for city in Jabalpur Belpahar Mumbai
do
      weather=$(curl wttr.in/$city)
      echo "$weather"
done
