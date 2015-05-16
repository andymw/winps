<#
.SYNOPSIS
Parses the netsh command to collect Wi-Fi SSID, BSSID, signal strength
.LINK
http://lac.fi/words/powershell-wifi-signal-strength.html
#>
[CmdletBinding()]
param ()

begin {
    $strDump = netsh wlan show interfaces
    $tbl = "" ` | Select-Object -Property SSID,Signal,BSSID,Physical_Address,`
        State,RadioType,ReceiveRate_Mbps,TransmitRate_Mbps
}
process {
    foreach ($line in $strDump) {
        if ($line -match "^\s+Physical address") {
            $tbl.Physical_Address = `
                $line -Replace "^\s+Physical address\s+:\s+",""
        } elseif ($line -match "^\s+State") {
            $tbl.State = $line -Replace "^\s+State\s+:\s+",""
        } elseif ($line -match "^\s+SSID") {
            $tbl.SSID = $line -Replace "^\s+SSID\s+:\s+",""
        } elseif ($line -match "^\s+BSSID") {
            $tbl.BSSID = $line -Replace "^\s+BSSID\s+:\s+",""
        } elseif ($line -match "^\s+Radio type") {
            $tbl.RadioType = $line -Replace "^\s+Radio type\s+:\s+",""
        } elseif ($line -match "^\s+Receive rate \(Mbps\)") {
            $tbl.ReceiveRate_Mbps = `
                $line -Replace "^\s+Receive rate \(Mbps\)\s+:\s+",""
        } elseif ($line -match "^\s+Transmit rate \(Mbps\)") {
            $tbl.TransmitRate_Mbps =
                $line -Replace "^\s+Transmit rate \(Mbps\)\s+:\s+",""
        } elseif ($line -match "^\s+Signal") {
            $tbl.Signal = $line -Replace "^\s+Signal\s+:\s+",""
        }
    }
}
end {
    return $tbl
}
