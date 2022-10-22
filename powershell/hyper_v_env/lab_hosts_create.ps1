# Sourcing Var Files
. ".\var_file.ps1"

ForEach ($VMname In $Linux_Server_Names_Array)
{
	New-VM -name $VMname -Generation 1 -NewVHDPath "C:\Users\$env:UserName\Hyper-V\$VMname\Disks\$VMname.vhdx"`
	-NewVHDSizeBytes 15GB -path "C:\Users\$env:UserName\Hyper-V\$VMname\Files" -SwitchName "NginX-Internal";
	
	Add-VMDvdDrive -VMName $VMname -Path $Linux_Server_ISO_Path;
	
	Set-VMMemory $VMname -MinimumBytes 512MB -StartupBytes 2GB -MaximumBytes 4GB;
	
	Set-VM -Name $VMname -AutomaticStartAction Nothing -AutomaticStopAction ShutDown;
	
	Enable-VMIntegrationService -VMName $VMname -Name "guest service interface";
	
	Set-VMFirmware $VMname -FirstBootDevice (Get-VMDvdDrive $VMname);
	
	Add-VMNetworkAdapter -VMName $VMname -SwitchName External;
}

#Linux_Client

New-VM -name $Linux_Client -Generation 1 -NewVHDPath "C:\Users\$env:UserName\Hyper-V\$Linux_Client\Disks\$Linux_Client.vhdx"`
-NewVHDSizeBytes 15GB -path "C:\Users\$env:UserName\Hyper-V\$Linux_Client\Files" -SwitchName "NginX-Internal";

Add-VMDvdDrive -VMName $Linux_Client -Path $Linux_Client_ISO_Path;

Set-VMMemory $Linux_Client -MinimumBytes 512MB -StartupBytes 2GB -MaximumBytes 4GB;

Set-VM -Name $Linux_Client -AutomaticStartAction Nothing -AutomaticStopAction ShutDown;

Enable-VMIntegrationService -VMName $Linux_Client -Name "guest service interface";

Set-VMFirmware $Linux_Client -FirstBootDevice (Get-VMDvdDrive $Linux_Client);

Add-VMNetworkAdapter -VMName $Linux_Client -SwitchName External;