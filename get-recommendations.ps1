Function Flatten-Object {										# https://powersnippets.com/flatten-object/
	[CmdletBinding()]Param (									# Version 02.00.16, by iRon
		[Parameter(ValueFromPipeLine = $True)][Object[]]$Objects,
		[String]$Separator = ".", [ValidateSet("", 0, 1)]$Base = 1, [Int]$Depth = 5, [Int]$Uncut = 1,
		[String[]]$ToString = ([String], [DateTime], [TimeSpan], [Version], [Enum]), [String[]]$Path = @()
	)
	$PipeLine = $Input | ForEach {$_}; If ($PipeLine) {$Objects = $PipeLine}
	If (@(Get-PSCallStack)[1].Command -eq $MyInvocation.MyCommand.Name -or @(Get-PSCallStack)[1].Command -eq "<position>") {
		$Object = @($Objects)[0]; $Iterate = New-Object System.Collections.Specialized.OrderedDictionary
		If ($ToString | Where {$Object -is $_}) {$Object = $Object.ToString()}
		ElseIf ($Depth) {$Depth--
			If ($Object.GetEnumerator.OverloadDefinitions -match "[\W]IDictionaryEnumerator[\W]") {
				$Iterate = $Object
			} ElseIf ($Object.GetEnumerator.OverloadDefinitions -match "[\W]IEnumerator[\W]") {
				$Object.GetEnumerator() | ForEach -Begin {$i = $Base} {$Iterate.($i) = $_; $i += 1}
			} Else {
				$Names = If ($Uncut) {$Uncut--} Else {$Object.PSStandardMembers.DefaultDisplayPropertySet.ReferencedPropertyNames}
				If (!$Names) {$Names = $Object.PSObject.Properties | Where {$_.IsGettable} | Select -Expand Name}
				If ($Names) {$Names | ForEach {$Iterate.$_ = $Object.$_}}
			}
		}
		If (@($Iterate.Keys).Count) {
			$Iterate.Keys | ForEach {
				Flatten-Object @(,$Iterate.$_) $Separator $Base $Depth $Uncut $ToString ($Path + $_)
			}
		}  Else {$Property.(($Path | Where {$_}) -Join $Separator) = $Object}
	} ElseIf ($Objects -ne $Null) {
		@($Objects) | ForEach -Begin {$Output = @(); $Names = @()} {
			New-Variable -Force -Option AllScope -Name Property -Value (New-Object System.Collections.Specialized.OrderedDictionary)
			Flatten-Object @(,$_) $Separator $Base $Depth $Uncut $ToString $Path
			$Output += New-Object PSObject -Property $Property
			$Names += $Output[-1].PSObject.Properties | Select -Expand Name
		}
		$Output | Select ([String[]]($Names | Select -Unique))
	}
}; Set-Alias Flatten Flatten-Object


Import-Module -Name PSWriteWord
#Install-Module -Name PSAttck
$name = Read-Host -Prompt 'Enter Malware Name'

$malware = Get-AttckMalware -Name $name

$tec = $malware.Techniques()
$m = $null
$m = $tec | %{Get-AttckTechnique -name $_.name}

$all= $m | select-object -property ID,Name,DataSource | flatten-object  | ForEach-Object {
    $NonEmptyProperties = $_.psobject.Properties | Where-Object {$_.Value} | Select-Object -ExpandProperty Name;    $_ | Select-Object -Property $NonEmptyProperties
 }


<#

#$mit | add-member -membertype NoteProperty "Malware" -Value "$name"

#$mit | Select-Object -Property Malware,ID,Name,Description,Wiki -Unique | Export-Excel -Now

$tectable = $m | ?{$_.Id -like '*T*'} | Select-Object -Property Name,Description -Unique 
$gentable = $m | ?{$_.Id -like '*M*'} | Select-Object -Property Name,Description -Unique
$ref =$m | Select-Object -Property Name,Wiki -Unique 

Remove-Item "C:\work\rec.docx"
$filepath = "C:\work\rec.docx"

$wordDocument = New-WordDocument $filepath


Add-WordText -WordDocument $wordDocument -Text "Attack Technique Specific Mitigations" -FontSize 12 -HeadingType Heading3 -FontFamily 'Calibri'
Add-WordTable -WordDocument $wordDocument -DataTable $tectable -Design LightListAccent5 -ColumnWidth 100
Add-WordText -WordDocument $WordDocument -Text 'Strategic Posture, Processes, and Controls' -FontSize 12 -HeadingType Heading3 -FontFamily 'Calibri'
#Add-WordText -WordDocument $wordDocument -Text "This table of mitigations represents "
Add-WordTable -WordDocument $wordDocument -DataTable $gentable -Design LightListAccent5 -ColumnWidth 100
Add-WordText -WordDocument $WordDocument -Text 'Technical References' -FontSize 12 -HeadingType Heading3 -FontFamily 'Calibri'
Add-WordTable -WordDocument $wordDocument -DataTable $ref -Design LightListAccent5 -ColumnWidth 100
#Set-WordTableAutoFit -Table $techtable
#Set-WordTableAutoFit -table $gentable
#Set-WordTableAutoFit -table $ref

Save-WordDocument $WordDocument -Language 'en-US' 

Invoke-Item $FilePath #>