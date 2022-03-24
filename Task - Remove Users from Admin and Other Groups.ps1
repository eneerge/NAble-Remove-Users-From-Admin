$global:returns = 0;

# Removes all users from the specified local group that do not match the specified user(s)
function RemoveUsersFromGroup($groupName,$usersToIgnore = @()) {
    
    Write-Host "Processing" $groupName"..."
    # used for getting the list of users later.
    $userListing = $false;
    
    # Get group members as a string and then loop through the string
    # NOTE: Get-LocalGroupMember is broken as 3/23/2022, so we need to use the net command. See https://github.com/PowerShell/PowerShell/issues/2996

    $users = net localgroup $groupName
    foreach ($line in $users) {

      # User Listing Completed
      if ($line -like "The command completed successfully.*") {
        return
      }



      # User Found
      if ($userListing -eq $true) {
        $user = $line.ToLower()

        $removeUser = $true

        # check to see if this user should be ignored
        if ($usersToIgnore.Count -gt 0) {
            foreach ($s in $usersToIgnore) {
                if ($user -like $s) {
                  $removeUser = $false
                  Write-Host "- Ignored user:" $user
                  break
                }
            }
        }

        if ($removeUser) {
          Write-Host "- Removing user:" $user
          Remove-LocalGroupMember -Group $groupName -Member $user

          if ($Error[0].CategoryInfo.Activity -eq "Remove-LocalGroupMember") {
            Write-Host "There was an error removing user" $user "from" $groupName
            $global:returns += 1
          }

        }
      }

      ### User Listing Started
      elseif ($line -like "----*") {
        $userListing = $true;
      }
    }

    Write-Host ""
}

RemoveUsersFromGroup -groupName "Access Control Assistance Operators"

# Exclude the built in administrator account (error is thrown if you attempt to remove it)
# Also excludes any accounts starting with "tadmin" so it will work with the LAPS script I wrote here https://github.com/eneerge/NAble-LAPS-LocalAdmin-Password-Rotation
RemoveUsersFromGroup -groupName "Administrators" -usersToIgnore @("Administrator","tadmin*")

RemoveUsersFromGroup -groupName "Backup Operators"
RemoveUsersFromGroup -groupName "Cryptographic Operators"
RemoveUsersFromGroup -groupName "Device Owners"
RemoveUsersFromGroup -groupName "Distributed COM Users"
RemoveUsersFromGroup -groupName "Event Log Readers"
RemoveUsersFromGroup -groupName "Guests" -usersToIgnore @("noguest")
RemoveUsersFromGroup -groupName "Hyper-V Administrators"

RemoveUsersFromGroup -groupName "Network Configuration Operators"

# Exclude the default user that is added
RemoveUsersFromGroup -groupName "Performance Log Users" -usersToIgnore @("nt authority\interactive")
RemoveUsersFromGroup -groupName "Performance Monitor Users"
RemoveUsersFromGroup -groupName "Power Users"
RemoveUsersFromGroup -groupName "Remote Desktop Users"
RemoveUsersFromGroup -groupName "Remote Management Users"
RemoveUsersFromGroup -groupName "Replicator"

# Exclude the default user that is added
RemoveUsersFromGroup -groupName "System Managed Accounts Group" -usersToIgnore @("DefaultAccount")


if ($env:USERNAME -eq "System") {
    if ($global:returns -gt 0) {
        Write-Host "An error occurred while running the script. " + Environment.NewLine $Error
        exit 1001
    }
    else {
        Write-Host "Script completed successfully."
        exit 0
    }
}
