# NAble-Remove-Users-From-Admin
This script will remove all users from the specified group.

This was written initially to ensure that users do not have local administrator access on their machine, but can 
also be used for removing users from other groups.

In RMM, you can run this as a daily task to ensure users have not unintentionally received admin.

Also, when enrolling devices in AzureAD, the first user that signs in will receive Administrator rights. Making this script run immediately after deployment
will remove that Azure user from the Adminsitrators group.
