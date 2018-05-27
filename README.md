# MacUserGenerator
A utility that assists in automating the creation of macOS User Accounts.

MacUserGenerator (MUG) is written from the ground up, with ideas ***heavily*** inspired from [MagerValp's](https://github.com/MagerValp) [CreateUserPkg](https://github.com/MagerValp/CreateUserPkg).
![Sample User](Readme%20Resources/Sample%20User.png)

## Features
*   [x] Export a user account as a **Shell script (sh)**.
*   [x] Export a user account as an **Installer Package (pkg)**.
*   [x] Ability to Open / Save the user account document / snapshot (MUGshot? 🙃).
*   [x] Nice to haves:
    *   User account can be hidden from the login window and the **Users and Groups** preference pane in **System Preferences.app**.
        *   User home folder can also be hidden.
    *   User can be set to login automatically.
    *   User can skip the Setup Assistant on first login.
        *   User can also skip the iCloud setup screen.
        *   User can also skip the Siri setup screen.
        *   User can also skip the Touch ID setup screen.
        *   User can also skip the Analytics screen.
        *   User can also skip the Data & Privacy screen.

## Under the hood (the nerdy stuff)
*   Export a user account as a **Shell script (sh):**
    *   Shell environment is bash: `#!/usr/bin/env bash`
    *   The user account picture is embedded into the shell script (base64). No need for a separate image file!
    *   The user account password is hashed using [PBKDF2](https://en.wikipedia.org/wiki/PBKDF2) (your password does not appear in plain text anywhere).
*   Export a user account as an **Installer Package (pkg):**
    *   Package is payload free, it uses the script export mentioned above as a postinstall script within the package.
    *   Package will be signed with a [Developer ID Installer Certificate](https://developer.apple.com/developer-id/) (if selected) during export.
    *   Exports should work with targeted volumes (used in imaging workflows ie. [AutoDMG](https://github.com/MagerValp/AutoDMG)).

![Export](Readme%20Resources/Export.png)

## Things I would love some help with
*   [ ]   A proper app icon. It's horrible.
*   [ ]   Maybe a better app name? **MacUserGenerator (MUG)** is a play on words on **CreateUserPkg (CUP)**. Open to alternatives 😀.
*   [ ]   Ability for the user account to be allowed to unlock FileVault (FDE).

## Requirements
*   Written in Swift 4.3.
*   Built using Xcode 9.3.
*   Builds run on OS X El Capitan 10.11 or later.
*   Exports tested on macOS Sierra 10.12 and later.

## Download
Grab the latest version of MacUserGenerator from the [releases page](https://github.com/ninxsoft/MacUserGenerator/releases).

## Credits / Thank You
*   Project created and maintained by Nindi Gill ([ninxsoft](https://github.com/ninxsoft)).
*   Per Olofsson ([MagerValp](https://github.com/MagerValp)) for his blessing and advice on the project.
*   Marcus Ransom ([@marcusransom](https://twitter.com/marcusransom)) for his advice and help with testing.

## Version History
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
    Copyright © 2017 Nindi Gill

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
