function Read-ColorHost($ForegroundColor) {
    # Save the current color
    $fc = $host.UI.RawUI.ForegroundColor

    # Set the new color
    $host.UI.RawUI.ForegroundColor = $ForegroundColor

    # Read host
    $to_return = $nulll
    if ($args) {
        Write-Host ($args + ": ") -NoNewLine
    }
    else {
        ($input + ": ") | Write-Host -NoNewLine
    }
    $to_return = Read-Host

    # Restore the original color
    $host.UI.RawUI.ForegroundColor = $fc

    # Return the read value
    return $to_return
}