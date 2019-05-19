#!/usr/bin/env python

"""Description goes here"""

import os
import platform
import subprocess
import sys
import uuid
# pylint: disable=E0611
from OpenDirectory import ODSession, ODNode, kODNodeTypeLocalNodes, kODRecordTypeUsers
# pylint: enable=E0611

USER_DATA = {
    "authentication_authority": ";ShadowHash;HASHLIST:<SALTED-SHA512-PBKDF2>",
    "generateduid":             str(uuid.uuid4()).upper(),
    "gid":                      "20",
    "IsHidden":                 "#ISHIDDEN",
    "home":                     "#HOME",
    "name":                     "#NAME",
    "passwd":                   "********",
    "realname":                 "#REALNAME",
    "ShadowHash":               """#SHADOWHASH""",
    "shell":                    "#SHELL",
    "uid":                      "#UID",
    "_writers_hint":            "#NAME",
    "_writers_jpegphoto":       "#NAME",
    "_writers_passwd":          "#NAME",
    "_writers_picture":         "#NAME",
    "_writers_realname":        "#NAME",
    "_writers_UserCertificate": "#NAME"
}

USER_PREFERENCES = {
    "admin":              "#ADMIN",
    "autologin":          "#AUTOLOGIN",
    "kcpassword":         "#KCPASSWORD",
    "skipsetupassistant": "#SKIPSETUPASSISTANT"
}

def is_booted_volume():
    """Description"""

    if len(sys.argv) < 4:
        return True

    target = sys.argv[3]
    local_disk = "/"
    return target is local_disk


def get_od_node():
    """Description"""

    session = ODSession.defaultSession()

    if not session:
        return None

    node, error = ODNode.nodeWithSession_type_error_(
        session, kODNodeTypeLocalNodes, None
    )

    if error:
        print >> sys.stderr, error
        return None

    return node


def od_record_exists(name):
    """Description"""

    node = get_od_node()

    if not node:
        return False

    record, error = node.recordWithRecordType_name_attributes_error_(
        kODRecordTypeUsers,
        name,
        None,
        None
    )

    if error:
        print >> sys.stderr, error
        return False

    return record is not None


def create_od_record(user_data):
    """Description"""

    node = get_od_node()

    if not node:
        return

    record, error = node.createRecordWithRecordType_name_attributes_error_(
        kODRecordTypeUsers,
        user_data["name"],
        None,
        None
    )

    if error:
        print >> sys.stderr, error
        return

    print "User record '" + user_data["name"] + "' created"


def update_od_record(user_data):
    """Description"""

    node = get_od_node()

    if not node:
        return

    record, error = node.recordWithRecordType_name_attributes_error_(
        kODRecordTypeUsers,
        user_data["name"],
        None,
        None
    )

    if error:
        print >> sys.stderr, error
        return

    for attribute, value in user_data.items():

        if attribute == "ShadowHash":
            continue

        success, error = record.setValue_forAttribute_error_(
            value,
            attribute,
            None
        )

        if error:
            print >> sys.stderr, error
            return

        print "User record '" + user_data["name"] + "' updated attribute " + \
            attribute + ": " + str(value)


def plist_record_exists(name):
    """Description"""

    target = sys.argv[3]
    path = target + "/private/var/db/dslocal/nodes/Default/users/" + name + ".plist"
    return os.path.isfile(path)


def create_plist_record(user_data):
    """Description"""
    print "create plist record"
    print user_data


def update_plist_record(user_data):
    """Description"""
    print "update plist record"
    print user_data


def set_shadowhash(name, shadowhash):
    """Description"""

    path = "/private/var/db/dslocal/nodes/Default/users/" + name + ".plist"
    command = "Remove :ShadowHashData:0"
    subprocess.call(["/usr/libexec/plistbuddy", "-c", command, path])
    command = "Add :ShadowHashData:0 string " + "..." + shadowhash + "..."
    subprocess.call(["/usr/libexec/plistbuddy", "-c", command, path])
    filehandler = open(path, 'r')
    plist = filehandler.read()
    filehandler.close()
    plist = plist.replace('<string>...', '<data>')
    plist = plist.replace('...</string>', '</data>')
    filehandler = open(path, 'w')
    filehandler.write(plist)
    filehandler.close()
    print "User record '" + name + "' updated attribute ShadowHash"


def set_admin(state, name, generateduid):
    """Description"""

    if is_booted_volume():
        membertype = "-a" if state == "TRUE" else "-d"
        subprocess.call(["dseditgroup", "-o", "edit", membertype, name, "-t", "user", "admin"])
        print ("Set" if state else "Removed") + " Admin for user record '" + name + "'"
    else:
        print "plist method"


def set_autologin(name, kcpassword):
    """Description"""


def create_home_directory(name):
    """Description"""

    subprocess.call(["createhomedir", "-c", "-u", name])
    print "Created user record '" + name + "' home folder"


def skip_setup_assistant(name, home):
    """Description"""

    path = "/private/var/db/.AppleSetupDone"
    subprocess.call(["touch", path])
    path = home + "/Library/Preferences/com.apple.SetupAssistant.plist"

    command = "Add :DidSeeCloudSetup bool TRUE"
    subprocess.call(["/usr/libexec/plistbuddy", "-c", command, path])
    print "Skipped Setup Assistant: iCloud"

    command = "Add :DidSeeSiriSetup bool TRUE"
    subprocess.call(["/usr/libexec/plistbuddy", "-c", command, path])
    print "Skipped Setup Assistant: Siri"

    command = "Add :DidSeeTouchIDSetup bool TRUE"
    subprocess.call(["/usr/libexec/plistbuddy", "-c", command, path])
    print "Skipped Setup Assistant: Touch ID"

    productversion = platform.mac_ver()[0]
    buildversion = os.popen("sw_vers -buildVersion").read().strip()
    command = "Add :LastSeenCloudProductVersion string " + productversion
    subprocess.call(["/usr/libexec/plistbuddy", "-c", command, path])
    command = "Add :LastSeenBuddyBuildVersion string " + buildversion
    subprocess.call(["/usr/libexec/plistbuddy", "-c", command, path])
    print "Skipped Setup Assistant: Analytics"

    command = "Add :DidSeePrivacy bool TRUE"
    subprocess.call(["/usr/libexec/plistbuddy", "-c", command, path])
    print "Skipped Setup Assistant: Data & Privacy"

    subprocess.call(["chown", name, path])
    subprocess.call(["chmod", "600", path])
    print "Set correct ownership and permissions on " + path

def restart_directory_services():
    """Description"""

    subprocess.call(["killall", "DirectoryService"])
    subprocess.call(["killall", "opendirectoryd"])
    print "Restarted Directory Services"


def main():
    """Description"""

    if is_booted_volume():

        print "Target is booted volume, using OpenDirectory API methods"

        if not od_record_exists(USER_DATA["name"]):
            print "User record '" + USER_DATA["name"] + "' does not exist"
            create_od_record(USER_DATA)

        print "User record '" + USER_DATA["name"] + "' exists"
        update_od_record(USER_DATA)

    else:
        print "Target is not booted volume, use Property List methods"

        if not plist_record_exists(USER_DATA["name"]):
            print "User record '" + USER_DATA["name"] + "' does not exist"
            create_plist_record(USER_DATA)

        print "User record '" + USER_DATA["name"] + "' exists"
        update_plist_record(USER_DATA)

    set_shadowhash(USER_DATA["name"], USER_DATA["ShadowHash"])
    set_admin(USER_PREFERENCES["admin"], USER_DATA["name"], USER_DATA["generateduid"])
    set_autologin(USER_DATA["name"], USER_PREFERENCES["kcpassword"])
    create_home_directory(USER_DATA["name"])

    if USER_PREFERENCES["skipsetupassistant"] == "TRUE":
        skip_setup_assistant(USER_DATA["name"], USER_DATA["home"])

    restart_directory_services()


if __name__ == '__main__':
    main()
