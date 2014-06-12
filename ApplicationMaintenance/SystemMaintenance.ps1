#################################################################################
#
# VMware PowerCLI script to start / stop servers in a specific order
#
#################################################################################

# Custom variables - can be modified to suit your specific needs
$shutdownDelay = 20				# seconds between each shutdown
$startupDelay = 30				# seconds between each startup
$clusterName = "Cluster1"


$ScriptName = $MyInvocation.MyCommand.Name

# Logging setup - creates logfile in same folder with current date in the filename
$logDate = (Get-Date).tostring("yyyyMMdd-HHmm")
$logFile = '.\report.'+$logDate+'.log'
$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
Start-Transcript -path $logFile


if ( $args.Count -ne 1 ) {
		Write-Host ""
        Write-Host "Usage: $ScriptName [start|stop]"
		Write-Host ""
		}
    elseif ( $args -eq "stop" ) {
	    $GuestVM = Get-Content .\shutdownOrder.txt
		Write-Host ""
		Write-Host "Number of servers to shutdown: " $GuestVM.count
		$maintenanceTime = $GuestVM.count * $shutdownDelay / 60
		Write-Host "Estimated time required for shutdown: " $maintenanceTime minutes
		foreach ($vm in $GuestVM) {
			Write-Host "Shutting down $vm..."
			Get-Cluster $clusterName | Get-VM $vm | Shutdown-VMGuest -Confirm:$false
			Write-Host ""
			sleep $shutdownDelay
			}
	}
    elseif ($args -eq "start" ) {
	    $GuestVM = Get-Content .\startupOrder.txt
		Write-Host ""
		Write-Host "Number of servers to start: " $GuestVM.count
		$maintenanceTime = $GuestVM.count * $startupDelay / 60
		Write-Host "Estimated time required for startup: " $maintenanceTime minutes
			foreach ($vm in $GuestVM) {
			Write-Host "Starting up $vm..."
			Get-Cluster $clusterName | Get-VM $vm | Start-VM -Confirm:$false
			Write-Host ""
			sleep $startupDelay
			}
	}
    else {
		Write-Host ""
		Write-Host "Options are either start or stop"
		Write-Host ""
		Write-Host "Example: $ScriptName start"
		Write-Host ""
    }

Stop-Transcript