#################################################################################
#
# VMware PowerCLI script to start / stop servers in a specific order
#
#################################################################################

# Custom variables - should be modified to suit your environment
$shutdownDelay = 20				# seconds between each shutdown
$startupDelay = 30				# seconds between each startup
$clusterName = "Cluster1"


$ScriptName = $MyInvocation.MyCommand.Name

# logging setup
$logDate = (Get-Date).tostring("yyyyMMdd-HHmm")
$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"


If ( $args.Count -ne 1 ) {
		Write-Host ""
        Write-Host "Usage: $ScriptName [start|stop]"
		Write-Host ""
		}
    ElseIf ( $args -eq "stop" ) {
		# check if shutdownOrder.txt exists
		$FileName=".\shutdownOrder.txt"
		If (Test-Path $FileName){
			# start logging
			$logFile = 'shutdown.'+$logDate+'.log'
			Start-Transcript -path $logFile
			
			$GuestVM = Get-Content .\shutdownOrder.txt
			Write-Host ""
			Write-Host "Number of servers to shutdown: " $GuestVM.count
			$maintenanceTime = $GuestVM.count * $shutdownDelay / 60
			Write-Host "Estimated time required for shutdown: " $maintenanceTime minutes
			Write-Host
			foreach ($vm in $GuestVM) {
				Write-Host "Shutting down $vm..."
				Get-Cluster $clusterName | Get-VM $vm | Shutdown-VMGuest -Confirm:$false
				Write-Host ""
				sleep $shutdownDelay
				}
			Stop-Transcript
		}
		Else{
				Write-Host ""
				Write-Host "No shutdownOrder.txt file found"
				Write-Host "Please create this file with the list of servers to be shutdown"
				Write-Host "One server per line, in the order that you want the servers to be shutdown"
				Write-Host ""
		}
	}
    ElseIf ($args -eq "start" ) {
	
		# check if startupOrder.txt exists
		$FileName=".\startupOrder.txt"
		If (Test-Path $FileName){
			# start logging
			$logFile = 'startup.'+$logDate+'.log'
			Start-Transcript -path $logFile
			
			$GuestVM = Get-Content .\startupOrder.txt
			Write-Host ""
			Write-Host "Number of servers to start: " $GuestVM.count
			$maintenanceTime = $GuestVM.count * $startupDelay / 60
			Write-Host "Estimated time required for startup: " $maintenanceTime minutes
			Write-Host
				foreach ($vm in $GuestVM) {
				Write-Host "Starting up $vm..."
				Get-Cluster $clusterName | Get-VM $vm | Start-VM -Confirm:$false
				Write-Host ""
				sleep $startupDelay
				}
			Stop-Transcript
		}
		Else{
			Write-Host ""
			Write-Host "No startupOrder.txt file found"
			Write-Host "Please create this file with the list of servers to be started"
			Write-Host "One server per line, in the order that you want the servers to be started"
			Write-Host ""
		}
	

	}
    Else {
		Write-Host ""
		Write-Host "Options are either start or stop"
		Write-Host ""
		Write-Host "Example: $ScriptName start"
		Write-Host ""
    }

