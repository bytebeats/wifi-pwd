function Extract-Value([string[]]$Lines, [string]$Name) {
    $Lines | Select-String " $Name\s+: (.*)" |% { $_.Matches.Groups[1].Value }
}

<#
.Synopsis
    Get list of wifi networks
.Description
    Returns SSIDs of all stored wifi networks
.Example
    List-wifi
#>
function Select-Wifi {
    netsh wlan show profiles | Select-String ": (.*)" |% { $_.Matches.Groups[1].Value }
}

<#
.Synopsis
    print password of current wifi network or the given one
.Description
    Allows to check stored password of current wifi network or the earlier connected one
.Parameter SSID
    Names of stored wifi networks
.Example
    Check stored password of current wifi network
.Example
    Check stored password of the earlier connected one
#>
function Show-WifiPwd([string]$SSID = (Extract-Value (netsh wlan show interface) "SSID") {
    $Network = netsh wlan show profiles name=$SSID key=clear
    If(!$?) {
        Write-Host $Network
        Return
    }
    $AuthType = Extract-Value $Network "Authentication"
    $Password = Extract-Value $Network "Key Content"
    Write-Host "
    SSID        : $SSID
    Password    : $Password
    Auth Type   : $AuthType
    "
}

Set-Alias Wifi-pwd Show-WifiPwd

Export-ModuleMember -Function *WiFi* -Alias *WiFi*