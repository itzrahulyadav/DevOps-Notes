#!/bin/bash

echo "What is your name?"

read name

echo "What is your age?"

read age

echo "hold on for a moment,calculating..."

sleep 3

echo "Hey,$name you will become a millionaire in $(((RANDOM % 10)+ $age)) years"


