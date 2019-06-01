#!/usr/bin/env python

"""
MacUserGenerator - Export.py
Copyright 2019 Nindi Gill. All rights reserved.

A template python script used to create macOS user accounts.
"""

import os
import plistlib
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
    """
    Returns True if the script / package (pkg) is being executed on
    the booted volume, or False if being executed on a targeted volume.
    """

    # sys.argv will only have more than 3 arguments when running within a pkg
    # (which means scripts are always targeting the booted bolume)
    if len(sys.argv) < 4:
        return True

    # grab the target destination
    target = sys.argv[3]
    local_disk = "/"
    # true if installing pkg to booted volume, otherwise false
    return target is local_disk


def get_target():
    """
    Returns the target volume path:
      eg. Booted volume: /
      eg. Targeted volume: /Volumes/Mac HD
    """

    # sys.argv will only have more than 3 arguments when running within a pkg
    # (which means scripts are always targeting the booted bolume)
    if len(sys.argv) < 4:
        return ""

    # grab the target destination
    target = sys.argv[3]
    local_disk = "/"
    # blank if installing pkg to booted volume, otherwise target volume path
    return "" if target == local_disk else target


def get_od_node():
    """
    Returns an ODNode object, used to communicate with the Open Directory API.
    """

    session = ODSession.defaultSession()

    if not session:
        return None

    node, error = ODNode.nodeWithSession_type_error_(
        session, kODNodeTypeLocalNodes, None
    )

    if error:
        print error
        return None

    return node


def get_user_plist_path():
    """
    Helper function returning the path to the user account property list.
    """

    user_plist_path = "/private/var/db/dslocal/nodes/Default/users/"
    return user_plist_path


def get_dictionary_from_plist(path):
    """
    Loads a Property List located at the provided path, converts from binary to
    xml, and returns the converted contents as a dictionary.
    """

    with open(path, "rb") as file:
        filecontents = file.read()
    arguments = ["plutil", "-convert", "xml1", "-o", "-", "--", "-"]
    process = subprocess.Popen(arguments,
                               stdin=subprocess.PIPE,
                               stdout=subprocess.PIPE)
    string, error = process.communicate(filecontents)
    dictionary = plistlib.readPlistFromString(string)
    return dictionary


def create_directory(path, mode, uid, gid):
    """
    Creates a directory located at the provided path, setting the mode and
    ownership with the provided mode, uid and gid.
    Returns True if successful, otherwise returns False.
    """

    if not os.path.isdir(path):
        try:
            os.mkdir(path, mode)
        except OSError:
            return False

    os.chown(path, int(uid), int(gid))
    return True


def check_if_user_is_root():
    """
    Determines, if the script is being executed as root. When installing a
    package (pkg), the script within the package is being executed as root.
    The script will exit early if it is not being executed as root.
    """

    # root has a uid of 0
    if os.geteuid() != 0:
        file = os.path.basename(__file__)
        print "Please execute '" + file + "' as a user with sudo priviliges!"
        exit(1)


def check_if_user_name_exists(name):
    """
    Determines if the provided user name exists. When being executed on a
    booted volume, performs lookup via the Open Directory API. When being
    executed on a targeted volume, performs lookup via reading Property Lists.
    """

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
            print error
            exit(1)

        if record is not None:
            print "User account '" + name + "' already exists, aborting..."
            exit(1)

    else:  # Property List logic
        path = get_target() + get_user_plist_path() + name + ".plist"

        if os.path.isfile(path):
            print "User account '" + name + "' already exists, aborting..."
            exit(1)

    print "User account '" + name + "' does not exist, continuing..."


def check_if_user_id_exists(uid):
    """
    Determines if the provided user id exists. When being executed on a booted
    volume, performs lookup via dscl. When being executed on a targeted volume,
    performs lookup via reading Property Lists.
    """

    if is_booted_volume():
        # grab all booted volume user ids
        # dscl . list /Users UniqueID
        dscl_arguments = ["dscl", ".", "list", "/Users", "UniqueID"]
        dscl_process = subprocess.Popen(dscl_arguments,
                                        stdout=subprocess.PIPE)
        # pipe them into awk, grab the last column
        # dscl . list /Users UniqueID | awk '{ print $NF }'
        awk_arguments = ["awk", "{ print $NF }"]
        awk_process = subprocess.Popen(awk_arguments,
                                       stdin=dscl_process.stdout,
                                       stdout=subprocess.PIPE)
        dscl_process.stdout.close()
        output, error = awk_process.communicate()
        # separate the user ids into an array
        uids = output.split()

        if uid in uids:
            print "User ID '" + uid + "' already exists, aborting..."
            exit(1)
    else:  # Property List logic
        path = get_target() + get_user_plist_path()

        for filename in os.listdir(path):
            plist = path + filename
            dictionary = get_dictionary_from_plist(plist)

            if uid == dictionary["uid"][0]:
                print "User ID '" + uid + "' already exists, aborting..."
                exit(1)

    print "User ID '" + uid + "' does not exist, continuing..."


def create_user_account(name):
    """
    Creates the user account 'stub'. When being executed on a booted volume,
    creates a user account stub via the Open Directory API. When being executed
    on a targeted volume, creates a user account stub Property List.
    """

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
            print error
            exit(1)

        print "User account '" + name + "' created via Open Directory"
    else:  # Property List logic
        dictionary = {
            "name": name
        }
        path = get_target() + get_user_plist_path() + name + ".plist"
        plistlib.writePlist(dictionary, path)
        os.chmod(path, 0600)
        print "User account '" + name + "' created via Property List"


def update_user_account(user_data):
    """
    Updates the user account. When being executed on a booted volume, updates
    via the Open Directory API. When being executed on a targeted volume,
    updates via the user account Property List.
    """

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
            print error
            exit(1)

        for attribute, value in user_data.items():

            # jpegphoto and ShadowHashData are data blobs, not strings, so a
            # little conversion is required
            if attribute == "jpegphoto" or attribute == "ShadowHashData":
                data = NSData.dataWithBytes_length_(value, len(value))
                value = NSArray.alloc().initWithObjects_(data)

            success, error = record.setValue_forAttribute_error_(
                value,
                attribute,
                None
            )

            if error:
                print error
                exit(1)

            # we don't want to spew out the data blobs to stdout, so we just
            # replace it with something simple. this is purely for formatting
            # reasons
            if attribute == "jpegphoto" or attribute == "ShadowHashData":
                value = "DATA"

            print "User account '" + name + "' updated attribute " + \
                attribute + ": " + str(value)
    else:  # Property List logic
        path = get_target() + get_user_plist_path() + name + ".plist"
        dictionary = plistlib.readPlist(path)

        for attribute, value in user_data.items():

            # jpegphoto and ShadowHashData are data blobs, not strings, so a
            # little conversion is required
            if attribute == "jpegphoto" or attribute == "ShadowHashData":
                value = plistlib.Data(value)

            dictionary[attribute] = [value]

            # we don't want to spew out the data blobs to stdout, so we just
            # replace it with something simple. this is purely for formatting
            # reasons
            if attribute == "jpegphoto" or attribute == "ShadowHashData":
                value = "DATA"

            print "User account '" + name + "' updated attribute " + \
                attribute + ": " + str(value)

        plistlib.writePlist(dictionary, path)


def set_admin(state, name, generateduid):
    """
    Grants or removes administrator privileges for the user account. When being
    executed on a booted volume, uses the 'dseditgroup' command. When being
    executed on a targeted volume, updates via the user account Property List.
    """

    if is_booted_volume():
        member_type = "-a" if state == "TRUE" else "-d"
        subprocess.call(["dseditgroup", "-o", "edit", member_type,
                         name, "-t", "user", "admin"])
        granted = ("Granted" if state == "TRUE" else "Removed")
        print "User account '" + name + "' admin privileges " + granted
    else:  # Property List logic
        plist = "/private/var/db/dslocal/nodes/Default/groups/admin.plist"
        path = get_target() + plist
        dictionary = get_dictionary_from_plist(path)

        if state == "TRUE":  # add administrator privileges
            if name not in dictionary["users"]:
                dictionary["users"].append(name)

            if generateduid not in dictionary["groupmembers"]:
                dictionary["groupmembers"].append(generateduid)
        else:  # remove administrator privileges
            if name in dictionary["users"]:
                dictionary["users"].remove(name)

            if generateduid in dictionary["groupmembers"]:
                dictionary["groupmembers"].remove(generateduid)

        plistlib.writePlist(dictionary, path)
        granted = ("granted" if state == "TRUE" else "removed")
        print "User account '" + name + "' administrator privileges " + granted


def set_autologin(state, kcpassword, name):
    """
    Sets Auto Login for the user account. This involves writing the
    obfuscated password to '/private/etc/kcpassword', and also updating the
    Property List '/Library/Preferences/com.apple.loginwindow.plist'.
    """

    if state != "TRUE":
        return

    path = get_target() + "/private/etc/kcpassword"

    with open(path, "w") as file:
        file.write(kcpassword)

    os.chmod(path, 0600)

    plist = "/Library/Preferences/com.apple.loginwindow.plist"
    path = get_target() + plist
    dictionary = get_dictionary_from_plist(path)
    dictionary["autoLoginUser"] = name
    dictionary["lastUserName"] = name
    plistlib.writePlist(dictionary, path)

    if is_booted_volume():  # not required on targeted volumes
        subprocess.call(["killall", "cfprefsd"])

    print "User account '" + name + "' set autologin"


def skip_setup_assistant(state, name, uid, gid, home):
    """
    Skips Setup Assistant for the user account. This involves creating
    '/private/var/db/.AppleSetupDone', as well as
    '~/Library/Preferences/com.apple.SetupAssistant.plist'. When being executed
    on a booted volume, the user account is also populated via the
    'createhomedir' command. When being executed on a targeted volume, the
    '~/Library/Preferences' directory structure is created.
    """

    if state != "TRUE":
        return

    # creating .AppleSetupDone
    path = get_target() + "/private/var/db/.AppleSetupDone"
    if not os.path.isfile(path):
        os.mknod(path, 0644)

    # creating the home directory strucure
    if is_booted_volume():
        os.system("createhomedir -c -u " + name)

        if not os.path.isdir(home):
            print "User account '" + name + \
                "' home directory was not created, aborting..."
            exit(1)
    else:  # targeted volume logic
        path = get_target() + home
        if not create_directory(path, 0755, uid, gid):
            print "User account '" + name + \
                "' home directory was not created, aborting..."
            exit(1)

        path = get_target() + home + "/Library"
        if not create_directory(path, 0700, uid, gid):
            print "User account '" + name + \
                "' home directory was not created, aborting..."
            exit(1)

        path = get_target() + home + "/Library/Preferences"
        if not create_directory(path, 0700, uid, gid):
            print "User account '" + name + \
                "' home directory was not created, aborting..."
            exit(1)

    print "User account '" + name + "' home directory created"

    # determine productversion and buildversion
    plist = "/System/Library/CoreServices/SystemVersion.plist"
    path = get_target() + plist
    dictionary = get_dictionary_from_plist(path)
    product_version = dictionary["ProductVersion"]
    build_version = dictionary["ProductBuildVersion"]

    dictionary = {
        "DidSeeCloudSetup": True,
        "DidSeeSiriSetup": True,
        "LastSeenCloudProductVersion": product_version,
        "LastSeenBuddyBuildVersion": build_version,
        "DidSeePrivacy": True
    }

    # creating com.apple.SetupAssistant.plist
    plist = "/Library/Preferences/com.apple.SetupAssistant.plist"
    path = get_target() + home + plist
    plistlib.writePlist(dictionary, path)
    os.chown(path, int(uid), -1)
    os.chmod(path, 0600)
    print "User account '" + name + "' skipped Setup Assistant"


def restart_directory_services():
    """
    Restarts directory services (opendirectoryd). Only required when executing
    script on booted volume.
    """

    if is_booted_volume():
        subprocess.call(["killall", "opendirectoryd"])
        print "Restarted Directory Services"


def main():
    """
    Here is where the fun begins... each of the following functions will exit
    the script if conditions are not met or an error occurs.
    """

    check_if_user_is_root()

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

    skip_setup_assistant(USER_PREFERENCES["skipsetupassistant"],
                         USER_DATA["name"],
                         USER_DATA["uid"],
                         USER_DATA["gid"],
                         USER_DATA["home"])

    restart_directory_services()


if __name__ == '__main__':
    main()
