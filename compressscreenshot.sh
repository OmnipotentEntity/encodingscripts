#!/bin/bash

name=${1%.*}
cp $name.png $name-best.png
for ((i=1; i<$2; i++)) 
do
  ~/coding/pngout/pngout-linux-athlon-static -r -y $name.png $name-trial.png
  wine ~/coding/pngout/DeflOpt.exe $name-trial.png
  du --bytes $name-best.png $name-trial.png | sort -n | awk 'BEGIN {ORS=" "} {print $2}' | xargs cp
done 

