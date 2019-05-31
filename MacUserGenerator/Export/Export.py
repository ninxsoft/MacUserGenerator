#!/usr/bin/env python

"""Description goes here"""

import os
import platform
import plistlib
import stat
import subprocess
import sys
import uuid
from Foundation import NSArray, NSData
from OpenDirectory import ODSession, ODNode
from OpenDirectory import kODNodeTypeLocalNodes, kODRecordTypeUsers

USER_DATA = {
    "authentication_authority": ";ShadowHash;HASHLIST:<SALTED-SHA512-PBKDF2>",
    "generateduid":             str(uuid.uuid4()).upper(),
    "gid":                      "20",
    "IsHidden":                 "#ISHIDDEN",
    "home":                     "#HOME",
    "jpegphoto":                "#JPEGPHOTO".decode('base64'),
    "name":                     "#NAME",
    "passwd":                   "********",
    "realname":                 "#REALNAME",
    "ShadowHashData":           """#SHADOWHASHDATA""".decode('base64'),
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
    "kcpassword":         "#KCPASSWORD".decode('base64'),
    "skipsetupassistant": "#SKIPSETUPASSISTANT"
}


def is_booted_volume():
    """Description"""

    if len(sys.argv) < 4:
        return True

    target = sys.argv[3]
    local_disk = "/"
    return target is local_disk


def get_target():
    """Description"""

    if len(sys.argv) < 4:
        return ""

    target = sys.argv[3]
    local_disk = "/"
    return "" if target == local_disk else target


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


def get_user_plist_path():
    """Description"""

    user_plist_path = "/private/var/db/dslocal/nodes/Default/users/"
    return user_plist_path


def check_if_user_name_exists(name):
    """Description"""

    if not is_booted_volume():
        node = get_od_node()

        if not node:
            print "Unable to look up OpenDirectory node, aborting..."
            exit(1)

        record, error = node.recordWithRecordType_name_attributes_error_(
            kODRecordTypeUsers,
            name,
            None,
            None
        )

        if error:
            print >> sys.stderr, error
            exit(1)

        if record is not None:
            print "User account '" + name + "' already exists, aborting..."
            exit(1)

    else:
        path = get_target() + get_user_plist_path() + name + ".plist"

        if os.path.isfile(path):
            print "User account '" + name + "' already exists, aborting..."
            exit(1)

    print "User account '" + name + "' does not exist, continuing..."


def check_if_user_id_exists(uid):
    """Description"""

    if is_booted_volume():
        dscl_arguments = ["dscl", ".", "list", "/Users", "UniqueID"]
        dscl_process = subprocess.Popen(dscl_arguments,
                                        stdout=subprocess.PIPE)
        awk_arguments = ["awk", "{ print $2 }"]
        awk_process = subprocess.Popen(awk_arguments,
                                       stdin=dscl_process.stdout,
                                       stdout=subprocess.PIPE)
        dscl_process.stdout.close()
        output, error = awk_process.communicate()
        uids = output.split()

        if uid in uids:
            print "User ID '" + uid + "' already exists, aborting..."
            exit(1)

    else:
        path = get_target() + get_user_plist_path()

        for filename in os.listdir(path):

            plist = path + filename
            dictionary = plistlib.readPlist(plist)

            if uid == dictionary["uid"]:
                print "User ID '" + uid + "' already exists, aborting..."
                exit(1)

    print "User ID '" + uid + "' does not exist, continuing..."


def create_user_account(name):
    """Description"""

    if is_booted_volume():
        node = get_od_node()

        if not node:
            print "Unable to look up OpenDirectory node, aborting..."
            exit(1)

        record, error = node.createRecordWithRecordType_name_attributes_error_(
            kODRecordTypeUsers,
            name,
            None,
            None
        )

        if error:
            print >> sys.stderr, error
            exit(1)

        print "User account '" + name + "' created via Open Directory"
    else:
        dictionary = {
            "name": name
        }
        path = get_target() + get_user_plist_path() + name + ".plist"
        plistlib.writePlist(dictionary, path)
        os.chmod(path, stat.S_IRUSR | stat.S_IWUSR)
        print "User account '" + name + "' created via Property List"


def update_user_account(user_data):
    """Description"""

    name = user_data["name"]

    if is_booted_volume():
        node = get_od_node()

        if not node:
            print "Unable to look up OpenDirectory node, aborting..."
            exit(1)

        record, error = node.recordWithRecordType_name_attributes_error_(
            kODRecordTypeUsers,
            name,
            None,
            None
        )

        if error:
            print >> sys.stderr, error
            exit(1)

        for attribute, value in user_data.items():

            if attribute == "jpegphoto" or attribute == "ShadowHashData":
                data = NSData.dataWithBytes_length_(value, len(value))
                value = NSArray.alloc().initWithObjects_(data)

            success, error = record.setValue_forAttribute_error_(
                value,
                attribute,
                None
            )

            if error:
                print >> sys.stderr, error
                exit(1)

            if attribute == "jpegphoto" or attribute == "ShadowHashData":
                value = "DATA"

            print "User account '" + name + "' updated attribute " + \
                attribute + ": " + str(value)
    else:
        path = get_target() + get_user_plist_path() + name + ".plist"
        dictionary = plistlib.readPlist(path)

        for attribute, value in user_data.items():

            if attribute == "jpegphoto":
                value = plistlib.Data(value.decode('base64'))

            if attribute == "ShadowHashData":
                value = plistlib.Data(value)

            dictionary[attribute] = value

            if attribute == "jpegphoto" or attribute == "ShadowHashData":
                value = "DATA"

            print "User account '" + name + "' updated attribute " + \
                attribute + ": " + str(value)

        plistlib.writePlist(dictionary, path)


def set_admin(state, name, generateduid):
    """Description"""

    if is_booted_volume():
        membertype = "-a" if state == "TRUE" else "-d"
        subprocess.call(["dseditgroup", "-o", "edit", membertype,
                         name, "-t", "user", "admin"])
        granted = ("Granted" if state else "Removed")
        print "User account '" + name + "' admin privileges " + granted
    else:
        plist = "/private/var/db/dslocal/nodes/Default/groups/admin.plist"
        path = get_target() + plist
        dictionary = plistlib.readPlist(path)

        if state:
            if name not in dictionary["users"]:
                dictionary["users"].append(name)

            if generateduid not in dictionary["groupmembers"]:
                dictionary["groupmembers"].append(generateduid)
        else:
            if name in dictionary["users"]:
                dictionary["users"].remove(name)

            if generateduid in dictionary["groupmembers"]:
                dictionary["groupmembers"].remove(generateduid)

        plistlib.writePlist(dictionary, path)
        granted = ("granted" if state else "removed")
        print "User account '" + name + "' administrator privileges " + granted


def set_autologin(state, kcpassword, name):
    """Description"""

    if not state:
        return

    path = get_target() + "/private/etc/kcpassword"

    with open(path, "w") as file:
        file.write(kcpassword)

    os.chmod(path, stat.S_IRUSR | stat.S_IWUSR)

    plist = "/Library/Preferences/com.apple.loginwindow.plist"
    path = get_target() + plist

    with open(path, "rb") as file:
        filecontents = file.read()
    arguments = ["plutil", "-convert", "xml1", "-o", "-", "--", "-"]
    process = subprocess.Popen(arguments,
                               stdin=subprocess.PIPE,
                               stdout=subprocess.PIPE)
    string, error = process.communicate(filecontents)
    dictionary = plistlib.readPlistFromString(string)
    dictionary["autoLoginUser"] = name
    dictionary["lastUserName"] = name
    plistlib.writePlist(dictionary, path)

    if is_booted_volume():
        subprocess.call(["killall", "cfprefsd"])

    print "User account '" + name + "' set autologin"


def create_home_directory(name, home):
    """Description"""

    if is_booted_volume():
        os.system("createhomedir -c -u " + name)

        if not os.path.isfolder(home):
            print "User account '" + name + \
                "' home folder was not created, aborting..."
            exit(1)
    else:
        print "CREATE HOME DIRECTORY PLIST METHOD"

    print "User account '" + name + "' home folder created"


def skip_setup_assistant(state, name, uid, home):
    """Description"""

    if not state:
        return

    path = get_target() + "/private/var/db/.AppleSetupDone"

    with open(path, 'a'):
        os.utime(path, None)

    productversion = platform.mac_ver()[0]
    buildversion = os.popen("sw_vers -buildVersion").read().strip()

    dictionary = {
        "DidSeeCloudSetup": True,
        "DidSeeSiriSetup": True,
        "LastSeenCloudProductVersion": productversion,
        "LastSeenBuddyBuildVersion": buildversion,
        "DidSeePrivacy": True
    }

    plist = "/Library/Preferences/com.apple.SetupAssistant.plist"
    path = get_target() + home + plist
    plistlib.writePlist(dictionary, path)
    os.chown(path, int(uid), -1)
    os.chmod(path, stat.S_IRUSR | stat.S_IWUSR)
    print "User account '" + name + "' skipped Setup Assistant"


def restart_directory_services():
    """Description"""

    if is_booted_volume():
        subprocess.call(["killall", "opendirectoryd"])
        print "Restarted Directory Services"


def main():
    """Description"""

    check_if_user_name_exists(USER_DATA["name"])
    check_if_user_id_exists(USER_DATA["uid"])

    create_user_account(USER_DATA["name"])
    update_user_account(USER_DATA)

    set_admin(USER_PREFERENCES["admin"],
              USER_DATA["name"],
              USER_DATA["generateduid"])

    set_autologin(USER_PREFERENCES["autologin"],
                  USER_PREFERENCES["kcpassword"],
                  USER_DATA["name"])

    create_home_directory(USER_DATA["name"], USER_DATA["home"])

    skip_setup_assistant(USER_PREFERENCES["skipsetupassistant"],
                         USER_DATA["name"],
                         USER_DATA["uid"],
                         USER_DATA["home"])

    restart_directory_services()


if __name__ == '__main__':
    main()
