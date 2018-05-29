#!/usr/bin/env bash

PlistBuddyAddArray() {

  local plistBuddy="/usr/libexec/PlistBuddy"
  local plist_path="$1"
  local array="$2"
  local type="$3"
  local value="$4"

  # add the array value if it does not exist
  if ! "$plistBuddy" -c "Print :$array" "$plist_path" > /dev/null ; then
    "$plistBuddy" -c "Add :$array array" "$plist_path"
  fi

  # add the value if it does not exist
  "$plistBuddy" -c "Add :$array: $type \"$value\"" "$plist_path"
}

PlistBuddyAddKey() {

  local plistBuddy="/usr/libexec/PlistBuddy"
  local plist_path="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  # add the value if it does not exist
  if ! "$plistBuddy" -c "Print :$key" "$plist_path" > /dev/null ; then
    "$plistBuddy" -c "Add :$key $type \"$value\"" "$plist_path"
  else # otherwise just update the value
    "$plistBuddy" -c "Set :$key \"$value\"" "$plist_path"
  fi
}

setUser() {

  local target="$1"
  local generateduid="$2"
  local gid="$3"
  local home="$4"
  local name="$5"
  local realname="$6"
  local shadowHash="$7"
  local shell="$8"
  local uid="$9"
  local userPlist="$target/private/var/db/dslocal/nodes/Default/users/$name.plist"

  PlistBuddyAddArray "$userPlist" "_writers_UserCertificate" "string" "$name"
  PlistBuddyAddArray "$userPlist" "_writers_hint" "string" "$name"
  PlistBuddyAddArray "$userPlist" "_writers_jpegphoto" "string" "$name"
  PlistBuddyAddArray "$userPlist" "_writers_passwd" "string" "$name"
  PlistBuddyAddArray "$userPlist" "_writers_picture" "string" "$name"
  PlistBuddyAddArray "$userPlist" "_writers_realname" "string" "$name"
  PlistBuddyAddArray "$userPlist" "_writers_UserCertificate" "string" "$name"
  PlistBuddyAddArray "$userPlist" "authentication_authority" "string" ";ShadowHash;HASHLIST:<SALTED-SHA512-PBKDF2>"
  PlistBuddyAddArray "$userPlist" "generateduid" "string" "$generateduid"
  PlistBuddyAddArray "$userPlist" "gid" "string" "$gid"
  PlistBuddyAddArray "$userPlist" "home" "string" "$home"
  PlistBuddyAddArray "$userPlist" "name" "string" "$name"
  PlistBuddyAddArray "$userPlist" "passwd" "string" "********"
  PlistBuddyAddArray "$userPlist" "realname" "string" "$realname"
  PlistBuddyAddArray "$userPlist" "shell" "string" "$shell"
  PlistBuddyAddArray "$userPlist" "uid" "string" "$uid"

  # for the shadow hash, we need to convert the string to a data element
  PlistBuddyAddArray "$userPlist" "ShadowHashData" "string" "...$shadowHash..."
  sed -i '' "s/<string>\\.\\.\\./<data>/" "$userPlist"
  sed -i '' "s/\\.\\.\\.<\\/string>/<\\/data>/" "$userPlist"

  # set permissions on the user plist
  chmod 600 "$userPlist"
}

setPhoto() {

  local target="$1"
  local name="$2"
  local userPlist="$target/private/var/db/dslocal/nodes/Default/users/$name.plist"
  local firstChunk="#FIRSTCHUNK#"
  local secondChunk="#SECONDCHUNK#"
  local thirdChunk="#THIRDCHUNK#"

  # for the jpeg photo, we need to convert the string to a data element
  PlistBuddyAddArray "$userPlist" "jpegphoto" "string" "...FIRSTCHUNKSECONDCHUNKTHIRDCHUNK..."
  sed -i '' "s/<string>\\.\\.\\./<data>/" "$userPlist"
  sed -i '' "s/\\.\\.\\.<\\/string>/<\\/data>/" "$userPlist"
  sed -i '' "s#FIRSTCHUNK#$firstChunk#" "$userPlist"
  sed -i '' "s#SECONDCHUNK#$secondChunk#" "$userPlist"
  sed -i '' "s#THIRDCHUNK#$thirdChunk#" "$userPlist"
}

setAdministrator() {

  local target="$1"
  local generateduid="$2"
  local name="$3"
  local adminPlist="$target/private/var/db/dslocal/nodes/Default/groups/admin.plist"

  PlistBuddyAddArray "$adminPlist" "users" "string" "$name"
  PlistBuddyAddArray "$adminPlist" "groupmembers" "string" "$generateduid"
}

hideUserAccount() {

  local target="$1"
  local name="$2"
  local userPlist="$target/private/var/db/dslocal/nodes/Default/users/$name.plist"

  PlistBuddyAddKey "$userPlist" "IsHidden" "string" "YES"
}

setAutoLogin() {

  local target="$1"
  local name="$2"
  local kcpassword="$3"
  local path="$target/etc/kcpassword"

  echo "$kcpassword" | base64 -D -o "$path"
  chmod 600 "$path"

  plist="$target/Library/Preferences/com.apple.loginwindow.plist"
  PlistBuddyAddKey "$plist" "lastUserName" "string" "$name"
  PlistBuddyAddKey "$plist" "autoLoginUser" "string" "$name"
}

skipSetupAssistant() {

  local target="$1"
  local home="$2"
  local homeFolder="$target$home"
  local preferencesFolder="$homeFolder/Library/Preferences"

  mkdir -p "$preferencesFolder"
  touch "$target/var/db/.AppleSetupDone"
}

skipiCloud() {

  local target="$1"
  local home="$2"
  local homeFolder="$target$home"
  local plist="$homeFolder/Library/Preferences/com.apple.SetupAssistant.plist"

  PlistBuddyAddKey "$plist" "DidSeeCloudSetup" "bool" "TRUE"
}

skipSiri() {

  local target="$1"
  local home="$2"
  local homeFolder="$target$home"
  local plist="$homeFolder/Library/Preferences/com.apple.SetupAssistant.plist"

  PlistBuddyAddKey "$plist" "DidSeeSiriSetup" "bool" "TRUE"
}

skipTouchID() {

  local target="$1"
  local home="$2"
  local homeFolder="$target$home"
  local plist="$homeFolder/Library/Preferences/com.apple.SetupAssistant.plist"

  PlistBuddyAddKey "$plist" "DidSeeTouchIDSetup" "bool" "TRUE"
}

skipAnalytics() {

  local target="$1"
  local home="$2"
  local homeFolder="$target$home"
  local plist="$homeFolder/Library/Preferences/com.apple.SetupAssistant.plist"

  productVersion=$(sw_vers -productVersion)
  buildVersion=$(sw_vers -buildVersion)
  PlistBuddyAddKey "$plist" "LastSeenCloudProductVersion" "string" "$productVersion"
  PlistBuddyAddKey "$plist" "LastSeenBuddyBuildVersion" "string" "$buildVersion"
}

skipDataPrivacy() {

  local target="$1"
  local home="$2"
  local homeFolder="$target$home"
  local plist="$homeFolder/Library/Preferences/com.apple.SetupAssistant.plist"

  PlistBuddyAddKey "$plist" "DidSeePrivacy" "bool" "TRUE"
}

setPermissions() {

  local target="$1"
  local home="$2"
  local name="$3"
  local homeFolder="$target$home"
  local libraryFolder="$homeFolder/Library"
  local preferencesFolder="$libraryFolder/Preferences"
  local plist="$preferencesFolder/com.apple.SetupAssistant.plist"

  chmod 755 "$homeFolder"
  chown "$name" "$homeFolder"
  chmod 700 "$libraryFolder"
  chown "$name" "$libraryFolder"
  chmod 700 "$preferencesFolder"
  chown "$name" "$preferencesFolder"

  if [[ -f "$plist" ]] ; then
    chmod 600 "$plist"
    chown "$name" "$plist"
  fi
}

restartDirectoryServices() {

  local target="$1"

  # reboot the directory service if targeting local volume
  if [[ -z "$target" ]] ; then
    killall DirectoryService &> /dev/null || killall opendirectoryd &> /dev/null
  fi
}

generateduid="#GENERATEDUID#"
gid="#GID#"
home="#HOME#"
name="#NAME#"
realname="#REALNAME#"
shadowHash="#SHADOWHASH#"
shell="#SHELL#"
uid="#UID#"
hint="#HINT#"

target="$3"

if [[ "$target" == "/" ]] ; then
  target=""
fi

setUser "$target" "$generateduid" "$gid" "$home" "$name" "$realname" "$shadowHash" "$shell" "$uid"
setPhoto "$target" "$name"
###SETADMINISTRATOR###setAdministrator "$target" "$generateduid" "$name"###SETADMINISTRATOR###
###HIDEUSERACCOUNT###hideUserAccount "$target" "$name"###HIDEUSERACCOUNT###
###SETAUTOLOGIN###setAutoLogin "$target" "$name" "#KCPASSWORDSTRING#"###SETAUTOLOGIN###
###SKIPSETUPASSISTANT###skipSetupAssistant "$target" "$home"###SKIPSETUPASSISTANT###
###SKIPICLOUD###skipiCloud "$target" "$home"###SKIPICLOUD###
###SKIPSIRI###skipSiri "$target" "$home"###SKIPSIRI###
###SKIPTOUCHID###skipTouchID "$target" "$home"###SKIPTOUCHID###
###SKIPANALYTICS###skipAnalytics "$target" "$home"###SKIPANALYTICS###
###SKIPDATAPRIVACY###skipDataPrivacy "$target" "$home"###SKIPDATAPRIVACY###
setPermissions "$target" "$home" "$name"
restartDirectoryServices "$target"
