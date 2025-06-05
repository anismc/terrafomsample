# terrafomsample

while ($true) {
    # Kill Notepad if running
    Get-Process notepad -ErrorAction SilentlyContinue | ForEach-Object {
        $_.CloseMainWindow() | Out-Null
        Start-Sleep -Milliseconds 500
        if (!$_.HasExited) {
            $_.Kill()
        }
    }

    # Start Notepad
    Start-Process notepad

    # Wait 2 minutes
    Start-Sleep -Seconds 120
}
