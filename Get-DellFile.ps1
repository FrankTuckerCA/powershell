Function Get-DellFile{
# FrankTuckerCA

<# 
    .SYNOPSIS
    Function downloads files from the Dell download site by model-number and download type (alldrivers, video, audio, network, bios, guide). Function only downloads .exe and .pdf files. 

    .PARAMETER Model
    Specfiy the dell model-number. The dell site uses hypen (-) instead of blanks. Some dell models may inculde "desktop or laptop", such as optiplex-7040-desktop.
    A full list can be found https://downloads.dell.com/published/Pages/index.html

    .PARAMTER Type 
    Alldrivers = all files ending with (.exe). video = all files located in video directories ending with (.exe). Audio = all files located in audio directories ending with (.exe).
    Network = all files located in network directories ending with (.exe). Bios = all files located in bios directories ending with (.exe). Guide will download all files = (*guide*.pdf)

    .PARAMTER Path
    Enter the local path that will be created to store downloads. 

    .EXAMPLE
    PS> get-dellfile -model precision-t5400 -type network -path c:\users\localadmin\tmp -verbose
    Will download all network drivers.

    .EXAMPLE
    PS. get-dellfile -model poweredge-r430 -type guide -path c:\tmp
    Will download all .pdf guide files. 

#>

    [CmdletBinding()]
    param(
    [Parameter(Mandatory=$True,
               ValueFromPipeline=$True,
               ValueFromPipelineByPropertyName=$True,
               HelpMessage="The. Model. Name.")]
    [Alias('system model')]
    [object[]]$model,

    [Parameter(Mandatory=$False,
                ValueFromPipeline=$True,
                ValueFromPipelineByPropertyName=$True,
                HelpMessage="AllDrivers. Video. Network. Audio. Bios. Guide.")]
    [String]$type,
     
    [Parameter(Mandatory=$True,
                ValueFromPipeline=$True,
                ValueFromPipelineByPropertyName=$True,
                HelpMessage="The. Path. For. Saving. Downloads")]
    [Alias('literalpath')]
    [String]$path
    )

# dell site uses hypen in model name, example model 747 is model-747"
Write-Verbose "model name, replacing blank with hypen"
$model = ($model -replace " ", "-")

Write-Verbose "checking if type alldrivers"
If ($type -like "alldrivers"){
  
    Write-Verbose "connecting to downloads.dell.com"
    $dell = ( (Invoke-WebRequest -Uri https://downloads.dell.com/published/pages/$model.html#drivers).links | where-Object {$_.href -like "*.exe"})

    Foreach ($href in $dell.href){
        write-verbose "Creating directory $path\$href"
        $md = (Split-Path -Path $href)
        New-Item -ItemType Directory -path "$path\$md" -Force
        Write-verbose "downloading $href"
        Invoke-WebRequest ("https://downloads.dell.com$href") -outfile "$path\$href" 
    } #end of foreach 

} #end if type alldrivers

write-verbose "checking type if video, network, audio, bios" 
If ($type -notlike "guide" -and $type -notlike "alldrivers") {
    Write-Verbose "Connecting to downloads.dell.com"
    $dell = ( (Invoke-WebRequest -Uri https://downloads.dell.com/published/pages/$model.html#drivers).links | where-Object {$_.href -like "*$type*.exe"})

    Foreach ($href in $dell.href){
        write-verbose "Creating directory $path\$href"
        $md = (Split-Path -Path $href)
        New-Item -ItemType Directory -path "$path\$md" -Force

        Write-verbose "downloading $href"
        Invoke-WebRequest ("https://downloads.dell.com$href") -outfile "$path\$href" 
    } #end of foreach 

} #end if type video, network, audio, bios

If ($type -like "guide"){
    Write-verbose "connecting to downloads.dell.com"
    $dell = ( (Invoke-WebRequest -Uri https://downloads.dell.com/published/pages/$model.html#drivers).links | where-Object {$_.href -like "*$type*en*.pdf"})
    
    Foreach ($group in $dell){
        $file = $group.outertext + ".pdf"
        write-verbose "downloading $file"
        Invoke-WebRequest ($group.href) -outfile "$path\$file"
    } # end foreach

} #end if type guide

} #end function get-dellfile


Function Get-DellModelIndex{
#FrankTuckerCA

<#
    .SYNOPSIS 
    Provides the index/list of Dell Model Names. 

#>
$modelindex = ( (Invoke-WebRequest -Uri https://downloads.dell.com/published/Pages/index.html).links.outertext )
Write-Output $modelindex

} #end get-dellmodelindex

