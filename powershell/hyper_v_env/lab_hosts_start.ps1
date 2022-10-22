# Sourcing Var Files
. ".\var_file.ps1"

ForEach ($VMname In $Linux_Machines)
{
	Start-VM $VMname
}