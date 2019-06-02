# MacUserGenerator

A Mac utility that assists in automating the creation of macOS User Accounts.

**MacUserGenerator** (MUG) is written from the ground up, with ideas ***heavily*** inspired from [MagerValp's](https://github.com/MagerValp) [CreateUserPkg](https://github.com/MagerValp/CreateUserPkg):

| **Light Appearance**                                         | **Dark Appearance**                                         |
| :----------------------------------------------------------: | :---------------------------------------------------------: |
| ![Sample User](Readme%20Resources/Sample%20User%20Light.png) | ![Sample User](Readme%20Resources/Sample%20User%20Dark.png) |

## Features

*   [x] Export a user account as a **Python script (PY)**.
*   [x] Export a user account as an **Installer Package (PKG)**.
*   [x] Ability to Open / Save the user account document / snapshot (MUGshot? 🙃).

|                                          | **Booted Volumes**                   | **Targeted Volumes** |
| ---------------------------------------: | :----------------------------------: | :------------------: |
| **Create User Accounts**                 | Yes [*](#-macos-mojave-1014-caveats) | Yes                  |
| **Set Administrator**                    | Yes                                  | Yes                  |
| **Hide User Account**                    | Yes                                  | Yes                  |
| **Hide User Account Home Folder**        | Yes                                  | Yes                  |
| **Login Automatically**                  | Yes                                  | Yes                  |
| **Skip Setup Assistant**                 | Yes                                  | Yes                  |
| **Abort if user account already exists** | Yes                                  | Yes                  |

### * macOS Mojave 10.14 Caveats:

*   Supported when [System Integrity Protection (SIP)](https://support.apple.com/en-us/HT204899) is **disabled**
*   When SIP is **enabled**, attempting to update the **User ID** and **Home Directory** attributes will result in the following prompts:

    | **Scripts**                                                | **Packages**                                                 |
    | :--------------------------------------------------------: | :----------------------------------------------------------: |
    | ![Mojave Scripts](Readme%20Resources/Mojave%20Scripts.png) | ![Mojave Packages](Readme%20Resources/Mojave%20Packages.png) |

## Under the hood (the nerdy stuff)
*   Export a user account as a **Python script (PY):**
    *   The user account password is hashed using [PBKDF2](https://en.wikipedia.org/wiki/PBKDF2). Your password does not appear in plain text anywhere!
    *   The user account picture is embedded into the python script (base64). No need for a separate image file!
*   Export a user account as an **Installer Package (PKG):**
    *   Package is payload free - it uses the script export mentioned above as a **postinstall** script within the package.
    *   Package will be signed with a [Developer ID Installer Certificate](https://developer.apple.com/developer-id/) (if selected) during export:

    ![Export](Readme%20Resources/Export.png)

## Things I would love some help with
*   [ ]   Ability for the user account to be allowed to unlock FileVault (FDE).

## Requirements
*   Written in Swift 5.0.1.
*   Built using Xcode 10.2.1.
*   Builds run on OS X El Capitan 10.11 or later.

## Download
Grab the latest version of MacUserGenerator from the [releases page](https://github.com/ninxsoft/MacUserGenerator/releases).

## Credits / Thank You
*   Project created and maintained by Nindi Gill ([ninxsoft](https://github.com/ninxsoft)).
*   Per Olofsson ([MagerValp](https://github.com/MagerValp)) for his blessing and advice on the project.
*   Greg Neagle ([gregneagle](https://github.com/gregneagle)) for his work on [pycreateuserpackage](https://github.com/gregneagle/pycreateuserpkg) - his project has really helped me understand how to communicate with the OS via the OpenDirectory API.
*   Marcus Ransom ([@marcusransom](https://twitter.com/marcusransom)) for his advice and help with testing.

## Version History
*   0.3
    *   Export script rewritten in **Python**
        *   Home directory is now created correctly
        *   Full support for macOS Mojave **10.14**!
        *   User account creation will abort if **username** or **uid** already exists
    *   Dark appearance support
    *   Removed all unnecessary Setup Assistant checkboxes
    *   Full name conversion to account no longer capitalises
    *   A new UUID is generated every time the exported package / script is run
    *   Xcode project updated to support Swift 5.0
*   0.2
    *   Selecting Administrator for **Account Type** should now work correctly
    *   Added option to skip the **Data & Privacy** screen
    *   Photo support
    *   Rewrote the export script:
        *   No longer uses `defaults write`
        *   Uses `PlistBuddy` instead
*   0.1
    *   Initial release

## License
    Copyright © 2019 Nindi Gill

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
