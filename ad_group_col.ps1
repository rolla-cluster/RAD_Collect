##Powershell script to aggegrate nested groups into a new flat group within Azure AD; This script IS NOT compatible with on-prem Active Directory
##
##--SourceGroup:
##--------User A
##--------User B
##--------Group 1
##-------------User C
##-------------User D
##-------------Group 2
##-----------------User E
##-----------------User F
##      | |
##      | |
##      | |
##      \ /
##       v
##
##--AggregateGroup:
##--------User A
##--------User B
##--------User C
##--------User D
##--------User E
##--------User F
##-----------------------------------------------------------------------
Set-StrictMode -Version 2
## Input Collection: this section gathers the source group and desired name for the Aggregate Group
#
## user inputs the group they want to Aggregate
$SourceGroup = $(Write-Host "Input name of Source Group: " -ForegroundColor yellow -NoNewLine; Read-Host)
## this variable will be called during group creation and adding members
$AggregateGroup = $(Write-Host "Input name of new aggregated group: " -ForegroundColor yellow -NoNewLine; Read-Host)
##create the aggregate group
New-AzureADGroup -DisplayName "$AggregateGroup" -MailEnabled $False -MailNickName "NotSet" -SecurityEnabled $True
#
##Enumerate Source Group Member and Type: This section will take the group name defined in "$SourceGroup" variable and enumate and Capture all members
##of the source group by display name, object type and object ID in a variable
#
##Pulls "ObjectId" attribute of -AzureADGroup -source group and aggregate group & converts it into a variable string
$SGObjectId = Get-AzureADGroup -SearchString $SourceGroup | select-object -ExpandProperty ObjectID -First 1
$AGObjectId = Get-AzureADGroup -SearchString $AggregateGroup | select-object -ExpandProperty ObjectID -First 1
if ($SGObjectId -eq $null) {
    "--- Error ---"
    "No Object ID found for provided Source Group:"
    Write-Output $SourceGroup
    "Available groups:"
    Get-AzureADGroup
    exit
}
##Pulls all group members of the source group and captures it in a variable
$SGMembers = Get-AzureADGroupMember -ObjectId $SGObjectId | Select-object -ExpandProperty ObjectID -First 1
#
##Sort members by type: This will loop through each member in $SGMembers and sort them by type into seperate variables
#
##empty array to append user's ObjectID to list for membership to Aggregate Group
$AGUsers = @()

##
### Recursive function definition to parse members and their sub groups for userIDs
##
function Get-Members {
    param ($GroupID)
    $_AGUsers = @()
    $_IterateUsers = @()
    $_IterateUsers += Get-AzureADGroupMember -ObjectId $GroupID | Select-object ObjectType,ObjectId,DisplayName

    foreach ($_member in $_IterateUsers) {
        if ($_member.ObjectType -eq 'User') {
            $_AGUsers += $_member.ObjectID
        }
        if ($_member.ObjectType -eq 'Group') {
            $_AGUsers += Get-Members -GroupID $_member.ObjectID   
        }     
    }
    return $_AGUsers
}

$AGUsers += Get-Members $SGObjectId

##Add all users to the aggregeated group: This section will take the $AGusers array which contains all Object ID's of users within nested groups and loop through each one adding as
## a group member
if ($AGUsers -eq $null) {
    Write-Output "Array is empty"
}

foreach ($AGUser in $AGUsers) {
    if ($AGUser -eq $null) {
        Write-Output "Error: User is empty"
    }
    Add-AzureADGroupMember -ObjectId $AGObjectId -RefObjectId $AGUser
}
#
##Print Member list: once the all members are added to the list, script will print list of all members in aggregate group
#
Get-AzureADGroupMember -ObjectID $AGObjectId | Select-Object DisplayName,ObjectType
