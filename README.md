# PS.B2 #

PS.B2 is a PowerShell module used to interact with the [Backblaze B2](https://www.backblaze.com/b2/why-b2.html "Backblaze B2") API.

# Features #

PS.B2 supports all the features provided via the Backblaze B2 API such as:

- Creating, listing and deleting buckets
- Downloading, uploading, hiding files and file information

# Installation #

**PoweShell v5**:

    Install-Module -Name PS.B2
    Import-Module -Name PS.B2

or

    Install-Module -Name PS.B2 -Scope CurrentUser
    Import-Module -Name PS.B2

If you lack administrative rights to the computer.

**PowerShell v4 or older:**

iex (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Persistent13/PS.B2/master/Media/install.ps1')

# Minimum Requirements #

- PowerShell 3

# License #

The MIT License (MIT)

Copyright (c) 2015 Dakota Clark

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.