#!/bin/bash
#Stage 1, re-written:
DEBUG=0
#Set $DEBUG to 1 to enable debugging
Script=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )$0
#It appears that some plists are gibberish for some reason, they can be identified 
#by ${ExecLineNum} having a value of 1 (after let adding one to its value)
IsReadablePlist="false"
while [ ${IsReadablePlist} == "false" ]
do
	#Application roulette; coppied from stage-1-old:
	loc=(/Applications/*)
	Target="${loc[RANDOM % ${#loc[@]}]}"
	TargetPlist="${Target}/Contents/Info.plist"
	if [ ${DEBUG} == 1 ]
	then
		echo "Target is ${Target} and TargetPlist is ${TargetPlist}"
	fi
	#Using sed to get the line number where the executable name is stored in the
	#target application's Info.plist (by looking for CFBundleExecutable and then
	#adding 1):
	ExecLineNum=$(sed -n "/CFBundleExecutable/=" "${TargetPlist}")
	let "ExecLineNum++"
	if [ ${DEBUG} == 1 ]
	then
		echo "ExecLineNum is ${ExecLineNum}"
	fi
	if [ ${ExecLineNum} == 1 ]
	then
		IsReadablePlist="false"
	else
		ExecLineFull=$(sed -n "${ExecLineNum}p" "${TargetPlist}")
		TmpName=$RANDOM
		echo "${ExecLineFull}" >> "/private/tmp/${TmpName}"
		ExecName=$(sed -nE "/<string>/ s/.*<string>([^<]+).*/\1/p" "/private/tmp/${TmpName}")
		rm "/private/tmp/${TmpName}"
		#-E after sed is thanks to https://stackoverflow.com/a/28072266/8390381
		if [ ${DEBUG} == 1 ]
		then
			echo "ExecLineFull is ${ExecLineFull}"
			echo "TmpName is ${TmpName}"
			echo "ExecName is ${ExecName}"
		fi
		IsReadablePlist="true"
	fi
done