## PS.B2 ##

PS.B2 is a PowerShell module used to interact with the [Backblaze B2](https://www.backblaze.com/b2/why-b2.html "Backblaze B2") API.

### Features ###

PS.B2 supports all the features provided via the Backblaze B2 API such as:

- Create, list and delete buckets
- Download and upload files
- Hide and delete files and file information

## Getting Started ##

### Prerequisites ###

- PowerShell v3
- B2 Account ID
- B2 Application Key

### Basic Installation ###

PS.B2 is installed by running one of the following commands in your PowerShell terminal.

#### PoweShell v5+ ####

```powershell
Install-Module -Name PS.B2
Import-Module -Name PS.B2
```

If you lack administrative rights to the computer.

```powershell
Install-Module -Name PS.B2 -Scope CurrentUser
Import-Module -Name PS.B2
```
#### PowerShell v4 or older ####

```powershell
iex (New-Object System.Net.WebClient).DownloadString('https://git.io/v2aGs')
Import-Module -Name PS.B2
```

## Using PS.B2 ##

### Connect to B2 ###

PS.B2 will require an account ID and application key set to use.

Once created you can connect to B2 like so...

```powershell
Connect-B2Cloud -AccountID "ACCOUNT_ID" -ApplicationKey "APPLICATION_KEY"
```

You can find all exported PS.B2 cmdlets like so...

```powershell
Get-Command -Module PS.B2
```

## License ##

The MIT License (MIT)

Copyright (c) 2016 Dakota Clark

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