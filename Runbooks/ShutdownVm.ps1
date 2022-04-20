Param(
    [Parameter (Mandatory = $true)]
    [String] $VMName,

    [Parameter (Mandatory = $true)]
    [String] $ResourceGroup
)

try {
    "Logging in to Azure..."
    Connect-AzAccount -Identity

    "Shutting down $VMName"
    Stop-AzVM -ResourceGroupName $ResourceGroup -Name $VMName

    "Shutdown command sent"

}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}