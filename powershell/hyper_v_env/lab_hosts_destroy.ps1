# Sourcing Var Files
. ".\var_file.ps1"

ForEach ($VMname In $Linux_Machines)
{
	Stop-VM $VMname -TurnOff
}

ForEach ($VMname In $Linux_Machines)
{
	Remove-VM -Name $VMname -Force
	
	Remove-Item -Path "C:\Users\$env:UserName\Hyper-V\$VMname" -Recurse
}