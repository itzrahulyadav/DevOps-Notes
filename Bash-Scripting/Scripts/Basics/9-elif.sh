#!/bin/bash

echo "enter a number"

read num

if [[ $num -gt 10 ]];then
    echo "The number is greater than 10"
elif [[ $num -lt 10 ]];then
    echo "The number is less than 10"
else
    echo "The number is negative"
fi
