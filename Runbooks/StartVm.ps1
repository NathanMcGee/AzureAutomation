Param(
    [Parameter (Mandatory = $true)]
    [String] $VMName,

    [Parameter (Mandatory = $true)]
    [String] $ResourceGroup
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

}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}