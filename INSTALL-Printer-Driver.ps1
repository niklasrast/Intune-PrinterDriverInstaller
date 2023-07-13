<#
    .SYNOPSIS 
    Windows 10 Software packaging wrapper

    .DESCRIPTION
    Install:   C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -Command .\INSTALL-Printer-Driver.ps1 -install
    Uninstall: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -Command .\INSTALL-Printer-Driver.ps1 -uninstall

    .ENVIRONMENT
    PowerShell 5.0

    .AUTHOR
    Niklas Rast
#>

[CmdletBinding()]
param(
	[Parameter(Mandatory = $true, ParameterSetName = 'install')]
	[switch]$install,
	[Parameter(Mandatory = $true, ParameterSetName = 'uninstall')]
	[switch]$uninstall
)

$ErrorActionPreference = "SilentlyContinue"
#Use "C:\Windows\Logs" for System Installs and "$env:TEMP" for User Installs
$logFile = ('{0}\{1}.log' -f "C:\Windows\Logs", [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name))

if ($install)
{
    Start-Transcript -path $logFile -Append
        try
        {         
            #Install printer
            pnputil.exe /a "$PSSCRIPTROOT\DRIVERFILES\oemsetup.inf"
            Add-PrinterDriver -Name "PRINTERDRIVERNAME" -InfPath "C:\Windows\System32\DriverStore\FileRepository\oemsetup.inf_amd64_PRINTERID\oemsetup.inf"
            Add-PrinterPort -Name "PRINTERNAME" -PrinterHostAddress "PRINTERIP"
            Add-Printer -DriverName "PRINTERDRIVERNAME" -Name "PRINTERNAME" -PortName "PRINTERNAME"

            return $true
        } 
        catch
        {
            $PSCmdlet.WriteError($_)
            return $false
        }
    Stop-Transcript
}

if ($uninstall)
{
    Start-Transcript -path $logFile -Append
        try
        {
            #Uninstall Printer
            Remove-Printer -Name "PRINTERNAME"

            return $true     
        }
        catch
        {
            $PSCmdlet.WriteError($_)
            return $false
        }
    Stop-Transcript
}