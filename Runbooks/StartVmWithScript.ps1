Param(
    [Parameter (Mandatory = $true)]
    [String] $VMName,

    [Parameter (Mandatory = $true)]
    [String] $ResourceGroup,

    [Parameter (Mandatory = $true)]
    [String] $StorageAccount,

    [Parameter (Mandatory = $true)]
    [String] $StorageContainer,

    [Parameter (Mandatory = $true)]
    [String] $Script
)

try {
    “Logging in to Azure...”
    Connect-AzAccount -Identity

    “Starting $VMName”
    Start-AzVM -ResourceGroupName $ResourceGroup -Name $VMName

    "Checking VM Agent"
    $VMNameStatus = Get-AzVM -ResourceGroupName $ResourceGroup -Name $VMName

    if ($VMNameStatus.OSProfile.WindowsConfiguration.ProvisionVMAgent -ne $true) {

        "Waiting until VM Agent is Ready"
        while ($VMNameStatus.OSProfile.WindowsConfiguration.ProvisionVMAgent -ne $true) {
            Start-Sleep -Seconds 5
            $VMNameStatus = Get-AzVM -ResourceGroupName $ResourceGroup -Name $VMName
        }
    }
    “VM Agent is Ready”

    "Getting maintenance script from $StorageAccount"
    $StorageContext = New-AzStorageContext -StorageAccountName $StorageAccount
    Get-AzStorageBlobContent -Blob $Script -Container $StorageContainer -Destination ($Env:temp+"/ExMaintenance.ps1") -Context $StorageContext

    "Running maintenance script"
    $MaintenanceScriptOutput = Invoke-AzVMRunCommand -ResourceGroupName $ResourceGroup -VMName $VMName -CommandId 'RunPowerShellScript' -ScriptPath ($Env:temp+"/ExMaintenance.ps1")
    
    “Maintenance script output:”
    Write-Output $MaintenanceScriptOutput.Value[0].Message

}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}