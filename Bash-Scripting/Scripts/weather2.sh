#!/bin/bash

read -p "enter the name of the city:  " city

weather=$(curl wttr.in/$city)

echo "$weather"
