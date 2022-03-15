function git-update {
    param ($branch = "master", $remote = "upstream", $remote_branch = "master", $directory="./")

# Import modules for later use here
Import-Module 'C:\Program Files\REPO_UPDATER\Utility\WriteCommands.psm1'
Import-Module 'C:\Program Files\REPO_UPDATER\Utility\ReadCommands.psm1'
# Alright, time to quit importing modules you nerd

# Let's start off by checking if the directory both exists, and is a git repo
$git_repo_status = $true
$output = $null

if ( !($directory -eq "./") ) {
    # If the directory exists, move on
    if ( !(Test-Path -Path $directory) ) {
        $git_repo_status = $false
        $output = "ERROR: Directory does not exist. Can not continue."
    } elseif ( !(Test-Path -Path ($directory + "/.git")) ) {
        $git_repo_status = $false
        $output = "ERROR: Directory not a git repository. Can not continue."
    }
}

if ($git_repo_status -eq $false) {
    $output | Write-ColorOutput("red")
    exit
}
"Git repo successfully found." | Write-ColorOutput("green")

# By now we know we have a git repo. Let's give the usual spiel.
"Hey friend! Now that we've found your git repo, let's lay down a couple things." | Write-ColorOutput("white")
"This script defaults to updating the master branch from upstream." | Write-ColorOutput("white")
$continue = "Would you like to continue? (Y/n)" | Read-ColorHost("yellow")

# Default is YES
if ( $continue.ToLower() -eq "n" ) {
    "Understood! Thank you for your time." | Write-ColorOutput("green")
    exit
}

"Wonderful! Let's go ahead and check your current branch." | Write-ColorOutput("white")
# Push the current location to directory stack and move to repo location
# This can always be done, we just might have a copy of where we are at worst
Push-Location $directory
$local_branch = (git rev-parse --abbrev-ref HEAD) # Collect current git branch
# Yes the following block is a mess. It's done because I need specific coloring.
"Does " | Write-ColorHostNoNew("yellow")
$local_branch | Write-ColorHostNoNew("red")
$local_branch_confirmation = " look right? (Y/n)" | Read-ColorHost("yellow")

if ( $local_branch_confirmation.ToLower() -eq "n" ) {
    "Uh oh! Go back and check your repo to checkout the correct branch." | Write-ColorOutput("red")
    Pop-Location
    exit
}

"Woo! Let's check that you want to update the correct local branch." | Write-ColorOutput("white")
"Does " | Write-ColorHostNoNew("yellow")
$branch | Write-ColorHostNoNew("red")
$branch_confirmation = " look right? (Y/n)" | Read-ColorHost("yellow")

if ( $branch_confirmation.ToLower() -eq "n" ) {
    "Aw man! Please provide the -branch parameter to the command." | Write-ColorOutput("red")
    Pop-Location
    exit
}

# We're going to perform a check for the branch existing here. It sounds stupid to not say something about it,
# just trust me on this. People are stupid.
if ( $(git rev-parse --verify $branch) -eq "fatal: Needed a single revision" ) {
    "Oof! That branch doesn't exist locally. We won't try to create it from the remote branch, either, that's painful." | Write-ColorOutput("red")
    Pop-Location
    exit
}

# Oh well if it's current. We'll add in a check though just so we don't switch branches later.
$branch_switch = $true
if ( $branch -eq $local_branch) {
    $branch_switch = $false
}

# We must be on the right branch. Let's make sure they're updating from the right remote
"Perfect! Now let's make sure you're using the right remote to update from." | Write-ColorOutput("white")
"Is " | Write-ColorHostNoNew("yellow")
$remote | Write-ColorHostNoNew("red")
$remote_confirmation = " the correct remote? (Y/n)" | Read-ColorHost("yellow")

if ( $remote_confirmation.ToLower() -eq "n" ) {
    "Oh no! Please provide the -remote parameter to the command." | Write-ColorOutput("red")
    Pop-Location
    exit
}

# The remote was correct. Let's make sure the branch to update is correct
"Alright, on to the remote branch!" | Write-ColorOutput("white")
"Does " | Write-ColorHostNoNew("yellow")
$remote_branch | Write-ColorHostNoNew("red")
$remote_branch_confirmation = " look correct? (Y/n)" | Read-ColorHost("yellow")

if ($remote_branch_confirmation.ToLower() -eq "n" ) {
    "Oops! Please provide the -branch parameter to the command." | Write-ColorOutput("red")
    Pop-Location
    exit
}

# Branch is correct, let's GOOOO
# Let's notify the user before doing anything
"Absolutely incredible! Let's begin." | Write-ColorOutput("green")
"First we're going to stash your changes." | Write-ColorOutput("white")
$stashed_changes = (git stash)

# There might be no changes, we'll skip applying later if there aren't.
if ($stashed_changes -eq "No local changes to save") {
    "Hey there! I'd like to notify you that there were no changes to save, good job! You're ahead on commits!" | Write-ColorHostNoNew("green")
    " <3" | Write-ColorOutput("red")
}

if ( $branch_switch -eq $true ) {
    "Now we're switching to " | Write-ColorHostNoNew("white")
    $branch | Write-ColorHostNoNew("yellow")
    " to perform updates." | Write-ColorOutput("white")
    # Switch to the branch to update
    $(git checkout $branch) | Out-Null
}

"Pulling updates from remote now..." | Write-ColorOutput("white")
git pull $remote $remote_branch

"Updating complete!" | Write-ColorHostNoNew("green")
if ( $branch_switch -eq $true ) {
    " Let's switch back to your branch now." | Write-ColorOutput("white")
    $(git checkout $local_branch) | Out-Null
} else {
    "" | Write-ColorOutput("white")
}

if ( !($stashed_changes -eq "No local changes to save") ) {
    "Now to apply your changes. This is the dangerous part, make sure to check your diffs!" | Write-ColorOutput("yellow")
    $(git stash apply) | Out-Null
}

"And now, we're done! Thanks for using this updater, and don't forget to check your diffs if your changes were applied." | Write-ColorOutput("green")
"After you confirm your diffs are fine, you can use " | Write-ColorHostNoNew("green")
"git stash clear" | Write-ColorHostNoNew("yellow")
" to clear your stash of all entries." | Write-ColorOutput("green")

# Return to caller directory
Pop-Location

# Remove the imported modules to cleanup
Remove-Module WriteCommands
Remove-Module ReadCommands
}