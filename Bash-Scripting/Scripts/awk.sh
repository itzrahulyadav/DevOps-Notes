#!/bin/bash

echo "enter file name to search from"
read filename 

aws '{print}' $filename
