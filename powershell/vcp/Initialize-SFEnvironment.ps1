# Launch text
write-host "       Welcome to SolidFire Tools for PowerShell!"
write-host ""
write-host "                ______________            ___" -foregroundcolor red
write-host "               /__/__\__\__\__\       ___/__/" -foregroundcolor red
write-host "              /_ /__/_\__\__\__\  ___/__/__/ " -foregroundcolor red
write-host "             /__/__/__/\__\__\__\/__/__/__/  " -foregroundcolor red
write-host "            /__/__/__/  \__\__\__\_/__/__/   " -foregroundcolor red
write-host "           /__/__/       \__\__\__\__/__/    " -foregroundcolor red
write-host "          /__/            \__\__\__\/__/     " -foregroundcolor red
write-host ""
write-host "                  Fueled By SolidFire        "

write-host ""
write-host "    Log into a SolidFire Cluster or Node:                " -NoNewLine
write-host "Connect-SFCluster" -foregroundcolor red
write-host "    To find out what commands are available, type:       " -NoNewLine
write-host "Get-SFCommand" -foregroundcolor red
write-host "    To get help for SolidFire commands use:              " -NoNewline
write-host "Get-Help <SolidFire CmdLet>" -foregroundcolor red
write-host ""
write-host "   Copyright (C) 2015 SolidFire, Inc. All rights reserved."
write-host ""
write-host ""

#import-module .\SolidFire.psd1

function global:Get-SFCommand([string] $Name = "*") {
  get-command -Module SolidFire -Name $Name
}
