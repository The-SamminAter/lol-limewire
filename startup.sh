#!/bin/bash
#This script generates/creates plists that go in /Library/LaunchAgents/
#After doing that, it runs "sudo launchctl load /Library/LaunchAgents/$1.$2.$3.plist"
#
#Variables 1, 2, and 3 will be randomly generated, probably by using RANDOM

echo "<?xml version="1.0" encoding="UTF-8"?>" >> /Library/LaunchAgents/$1.$2.$3.plist
echo "<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">" >> /Library/LaunchAgents/$1.$2.$3.plist
echo "<plist version="1.0">" >> /Library/LaunchAgents/$1.$2.$3.plist
echo "<dict>" >> /Library/LaunchAgents/$1.$2.$3.plist
echo "    <key>Label</key>" >> /Library/LaunchAgents/$1.$2.$3.plist
echo "    <string>$1.$2.$3</string>" >> /Library/LaunchAgents/$1.$2.$3.plist
echo "    <key>ProgramArguments</key>" >> /Library/LaunchAgents/$1.$2.$3.plist
echo "    <array>" >> /Library/LaunchAgents/$1.$2.$3.plist
echo "        <string>hello</string>" >> /Library/LaunchAgents/$1.$2.$3.plist
echo "        <string>world</string>" >> /Library/LaunchAgents/$1.$2.$3.plist
echo "    </array>" >> /Library/LaunchAgents/$1.$2.$3.plist
echo "    <key>KeepAlive</key>" >> /Library/LaunchAgents/$1.$2.$3.plist
echo "    <true/>" >> /Library/LaunchAgents/$1.$2.$3.plist
echo "</dict>" >> /Library/LaunchAgents/$1.$2.$3.plist
echo "</plist>" >> /Library/LaunchAgents/$1.$2.$3.plist
