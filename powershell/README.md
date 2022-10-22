# Powershell

### Table of Content
* [Untitled](#untitled)
* [Links](#links)

## Untitled
```
#Evaluation Image Shuts Down 
slmgr.vbs -rearm 
slmgr.vbs -ato (requires internet connection) 
```

```
New-NetIpAddress -InterfaceAlias 'Ethernet' -IpAddress 172.16.0.3 -PrefixLength 24 
Set-DnsClientServerAddress -InterfaceIndex 12 -ServerAddresses ("172.16.0.2") 
```

```
# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/rename-computer?view=powershell-7.2&viewFallbackFrom=powershell-6
Rename-Computer DC 
```

```
# install the service only without password and dns 
Install-windowsfeature -name AD-Domain-Services -IncludeManagementTools 

# Promote to DC 
Install-ADDSForest -CreateDnsDelegation:$false -DatabasePath "C:\Windows\NTDS" -SafeModeAdministratorPassword (ConvertTo-SecureString "AdminPass" -AsPlainText -Force) -DomainMode "Win2012R2" -DomainName "contoso.com" -DomainNetbiosName "CONTOSO" -ForestMode "Win2012R2" -InstallDns:$true -LogPath "C:\Windows\NTDS" -NoRebootOnCompletion:$false -SysvolPath "C:\Windows\SYSVOL" -whatif

# Join computer to DC
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist "Contoso.com\Administrator", $(ConvertTo-SecureString -string "AdminPass" -AsPlainText -Force)

Add-Computer "contoso.com" -Credential $cred 
```

```
New-ADGroup -Name "Finance" -SamAccountName "SAM Finance" -GroupCategory Security -GroupScope Global -DisplayName "Display Name Finance" -Path "CN=Users,DC=Contoso,DC=Com" -Description "Finance Group"

New-ADUser -Name "Robert Hatley" -GivenName "Robert" -Surname "Hatley" -SamAccountName "RobertH" -UserPrincipalName "RobertH@Contoso.com" -AccountPassword (ConvertTo-SecureString -string "Mypassword" -AsPlainText -Force) -Enabled $True

Add-ADGroupMember -Identity "SAM Finance" -Members RobertH 
```

## Links

* [AWS SDK Go V2](https://aws.github.io/aws-sdk-go-v2/docs/configuring-sdk/).
