# This function takes in a foreground color as the first argument, and outputs 
# either piped input or the remaining arguments with that foreground color
function Write-ColorOutput($ForegroundColor) {
<#
.Description
Write-ColorOutput provides output with a specific foreground color
#>
    # Save the current color
    $fc = $host.UI.RawUI.ForegroundColor

    # Set the new color
    $host.UI.RawUI.ForegroundColor = $ForegroundColor

    # Output
    if ($args) {
        Write-Output $args
    }
    else {
        $input | Write-Output
    }

    # Restore the original color
    $host.UI.RawUI.ForegroundColor = $fc
}

function Write-ColorHostNoNew($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor

    if ($args) {
        Write-Host $args -NoNewline
    }
    else {
        $input | Write-Host -NoNewline
    }

    $host.UI.RawUI.ForegroundColor = $fc
}