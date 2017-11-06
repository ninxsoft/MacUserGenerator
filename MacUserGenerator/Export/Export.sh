#!/usr/bin/env bash

userName="#USERNAME#"
fullName="#FULLNAME#"
uid="#UID#"
shell="#SHELL#"
hint="#HINT#"
home="#HOME#"
picture="#PICTURE#"
hash="#HASH#"

if [[ "$3" == "/" ]] ; then
  target=""
else
  target="$3"
fi
 
# create new account
plist="$target"/var/db/dslocal/nodes/Default/users/"$userName".plist
defaults write "$plist" _writers_UserCertificate '<array><string>'"$userName"'</string></array>'
defaults write "$plist" _writers_hint '<array><string>'"$userName"'</string></array>'
defaults write "$plist" _writers_jpegphoto '<array><string>'"$userName"'</string></array>'
defaults write "$plist" _writers_passwd '<array><string>'"$userName"'</string></array>'
defaults write "$plist" _writers_picture '<array><string>'"$userName"'</string></array>'
defaults write "$plist" _writers_realname '<array><string>'"$userName"'</string></array>'
defaults write "$plist" authentication_authority '<array><string>'"$userName"'</string></array>'
defaults write "$plist" generateduid '<array><string>'"$(uuidgen)"'</string></array>'
defaults write "$plist" gid '<array><string>20</string></array>'
defaults write "$plist" hint '<array><string>'"$hint"'</string></array>'
defaults write "$plist" home '<array><string>'"$home"'</string></array>'
# defaults write "$plist" jpegphoto '<array><data>'"$picture"'</data></array>'
defaults write "$plist" name '<array><string>'"$userName"'</string></array>'
defaults write "$plist" realname '<array><string>'"$fullName"'</string></array>'
defaults write "$plist" shell '<array><string>'"$shell"'</string></array>'
defaults write "$plist" uid '<array><string>'"$uid"'</string></array>'
defaults write "$plist" ShadowHashData '<array><data>'"$hash"'</data></array>'
mkdir -p "$target$home"/Library/Preferences

###HIDEUSERACCOUNT###
# hide user account
defaults write "$plist" IsHidden '<array><string>YES</string></array>'
###HIDEUSERACCOUNT###

###LOGINAUTOMATICALLY###
# login automatically
kcpassword="#KCPASSWORDSTRING#"
echo "$kcpassword" | base64 -D -o "$target"/etc/kcpassword
chmod 600 "$target"/etc/kcpassword
defaults write "$target"/Library/Preferences/com.apple.loginwindow lastUserName "$userName"
defaults write "$target"/Library/Preferences/com.apple.loginwindow autoLoginUser "$userName"
defaults write "$target"/Library/Preferences/com.apple.loginwindow autoLoginUserUID "$uid"
###LOGINAUTOMATICALLY###

###SKIPSETUPASSISTANT###
# skip setup assistant
touch "$target"/var/db/.AppleSetupDone
###SKIPSETUPASSISTANT###

###SKIPICLOUD###
# skip iCloud
defaults write "$target$home"/Library/Preferences/com.apple.SetupAssistant DidSeeCloudSetup -bool TRUE
###SKIPICLOUD###

###SKIPSIRI###
# skip siri
defaults write "$target$home"/Library/Preferences/com.apple.SetupAssistant DidSeeSiriSetup -bool TRUE
###SKIPSIRI###

###SKIPTOUCHID###
# skip touch id
defaults write "$target$home"/Library/Preferences/com.apple.SetupAssistant DidSeeTouchIDSetup -bool TRUE
###SKIPTOUCHID###

###SKIPANALYTICS###
# skip analytics
productVersion=$(sw_vers -productVersion)
buildVersion=$(sw_vers -buildVersion)
defaults write "$target$home"/Library/Preferences/com.apple.SetupAssistant LastSeenCloudProductVersion "$productVersion"
defaults write "$target$home"/Library/Preferences/com.apple.SetupAssistant LastSeenBuddyBuildVersion "$buildVersion"
###SKIPANALYTICS###

# permissions
chmod 755 "$target$home"
chown "$userName" "$target$home"
chmod 700 "$target$home"/Library
chown "$userName" "$target$home"/Library
chmod 700 "$target$home"/Library/Preferences
chown "$userName" "$target$home"/Library/Preferences
chmod 600 "$target$home"/Library/Preferences/com.apple.SetupAssistant.plist
chown "$userName" "$target$home"/Library/Preferences/com.apple.SetupAssistant.plist

exit 0
