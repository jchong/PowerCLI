#################################################################################
#
# VMware PowerCLI script to start / stop servers in a specific order
#
#################################################################################

$ScriptName = $MyInvocation.MyCommand.Name
$shutdownDelay = 20								# seconds between each shutdown
$startupDelay = 30								# seconds between each startup
$clusterName = Cluster1


if ( $args.Count -ne 1 ) {
		write-host ""
        write-host "Usage: $ScriptName [start|stop]"
		write-host ""
		}
    elseif ( $args -eq "stop" ) {
	    $GuestVM = Get-Content .\shutdownOrder.txt
		write-host ""
		write-host "Number of servers to shutdown: " $GuestVM.count
		$maintenanceTime = $GuestVM.count * $shutdownDelay / 60
		write-host "Estimated time required for shutdown: " $maintenanceTime minutes
		foreach ($vm in $GuestVM) {
			write-host ""
			write-host "Shutting down $vm..."
			Get-Cluster $clusterName | Get-VM $vm | Shutdown-VMGuest -Confirm:$false
			write-host ""
			sleep $shutdownDelay
			}
	}
    elseif ($args -eq "start" ) {
	    $GuestVM = Get-Content .\startupOrder.txt
		write-host ""
		write-host "Number of servers to start: " $GuestVM.count
		$maintenanceTime = $GuestVM.count * $startupDelay / 60
		write-host "Estimated time required for startup: " $maintenanceTime minutes
			foreach ($vm in $GuestVM) {
			write-host ""
			write-host "Starting up $vm..."
			Get-Cluster $clusterName | Get-VM $vm | Start-VM -Confirm:$false
			write-host ""
			sleep $startupDelay
			}
	}
    else {
		write-host ""
		write-host "Options are either start or stop"
		write-host ""
		write-host "Example: $ScriptName start"
		write-host ""
    }