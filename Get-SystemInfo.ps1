<#
.SYNOPSIS
Gets detailed information about the computer
.DESCRIPTION
Gets detailed information about the operating system, processor,
    memory, disk, BIOS, and display
.NOTES
Written by Jakob Bindslet (jakob@bindslet.dk)
Modified by Drew Weymouth and Andy Wang
.LINK
http://superuser.com/questions/91305/your-favorite-usefull-powershell-scripts
#>
[CmdletBinding()]

$win32os = Get-WmiObject Win32_OperatingSystem
$battery = Get-WmiObject Win32_Battery
$processor = Get-WmiObject Win32_Processor
$computersys = Get-WmiObject Win32_ComputerSystem
$bios = Get-WmiObject Win32_Bios
$driveletter = $win32os.SystemDrive.ToString()[0]
$disk = Get-WmiObject win32_LogicalDisk `
    | Where-Object { $_.DeviceID -Match $driveletter }

$display = Get-WmiObject Win32_VideoController | Where-Object { `
    $_.CurrentHorizontalResolution -and $_.CurrentVerticalResolution -and `
    $_.CurrentNumberOfColors }
$graphics = Get-WmiObject Win32_VideoController | Where-Object { `
    $_.AdapterDACType -match 'Integrated RAMDAC' }
$chr = $display.CurrentHorizontalResolution
$cvr = $display.CurrentVerticalResolution
$cnc = [int]([Math]::Log($display.CurrentNumberOfColors) / [Math]::Log(2))

$memspeed = (Get-WmiObject Win32_PhysicalMemory).Speed
if ($memspeed -is [System.Object[]]) {
    $memspeed = $memspeed[0]
}

$lbut = $win32os.LastBootUpTime
$lbut = $lbut.Substring(0,4) + '-' + $lbut.Substring(4,2) + '-' `
    + $lbut.Substring(6,2) + ' ' + $lbut.Substring(8,2) + ':' `
    + $lbut.Substring(10,2) + ':' + $lbut.Substring(12,2)

$obj = New-Object PSObject
$obj | Add-Member NoteProperty ComputerName $win32os.PSComputerName
$obj | Add-Member NoteProperty Description $win32os.Description
$obj | Add-Member NoteProperty Domain $computersys.Domain
$obj | Add-Member NoteProperty OSName `
    ($win32os.Caption.TrimEnd(' ') + ' ' + $win32os.OSArchitecture)
$obj | Add-Member NoteProperty ServicePack $win32os.CSDVersion
$obj | Add-Member NoteProperty OSVersion `
    ($win32os.Version + " (build " + $win32os.BuildNumber + ")")
$obj | Add-Member NoteProperty TimeZone (Get-WmiObject Win32_TimeZone).Caption
$obj | Add-Member NoteProperty LastBootTime $lbut
$obj | Add-Member NoteProperty Manufacturer $computersys.Manufacturer
$obj | Add-Member NoteProperty Model $computersys.Model
$obj | Add-Member NoteProperty Battery $battery.Name
$obj | Add-Member NoteProperty Processor $processor.Name
$obj | Add-Member NoteProperty NumberOfCores ('' + $processor.NumberOfCores + `
    ' (' + $processor.NumberOfLogicalProcessors + ' logical)')
$obj | Add-Member NoteProperty Memory `
    ("{0:N2}" -f ($computersys.TotalPhysicalMemory / 1GB) `
    + " GB (usable) @ " + ($memspeed).ToString() + " MHz")
$obj | Add-Member NoteProperty PrimaryDisk `
    ("{0:N2}" -f ($disk.Size / 1GB) + ' GB (' + $disk.FileSystem + ")")
$obj | Add-Member NoteProperty Display "$chr x $cvr ($cnc-bit color)"
$obj | Add-Member NoteProperty GraphicsCard ($graphics.Caption + ' (' + `
    ("{0:N2}" -f ($graphics.AdapterRAM / 1GB)) + ' GB RAM)')
$obj | Add-Member NoteProperty DriverVersion $graphics.DriverVersion
$obj | Add-Member NoteProperty BiosSerialNum $bios.SerialNumber
$obj | Add-Member NoteProperty BiosVersion $bios.SMBIOSBIOSVersion
$obj | Add-Member NoteProperty RegisteredTo $win32os.RegisteredUser
$obj | Add-Member NoteProperty ProductID $win32os.SerialNumber

return $obj
