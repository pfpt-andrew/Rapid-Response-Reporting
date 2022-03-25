Import-Module -Name PSWriteWord

$file = Read-Host -Prompt "Enter FQpath to Attck JSON layer"
$list = gc -path $file
$list2 = (($list | ConvertFrom-json).techniques).techniqueID
$t = foreach($item in $list2){
    Get-AttckTechnique | ?{$_.id -eq $item}
}

$m = $t.Mitigations()

$tectable = $m | ?{$_.Id -like '*T*'} | Select-Object -Property Name,Description -Unique 
$gentable = $m | ?{$_.Id -like '*M*'} | Select-Object -Property Name,Description -Unique
$ref =$m | Select-Object -Property Name,Wiki -Unique 

$filepath = "C:\work\rec.docx"

$wordDocument = New-WordDocument $filepath

Add-WordText -WordDocument $wordDocument -Text "Attack Technique Specific Mitigations" -FontSize 12 -HeadingType Heading3 -FontFamily 'Calibri'
Add-WordTable -WordDocument $wordDocument -DataTable $tectable -Design LightListAccent5 -AutoFit Contents,ColumnWidth -transpose
Add-WordText -WordDocument $WordDocument -Text 'Mitigating Processes and Controls' -FontSize 12 -HeadingType Heading3 -FontFamily 'Calibri'
Add-WordTable -WordDocument $wordDocument -DataTable $gentable -Design LightListAccent5 -autofit Contents,ColumnWidth -transpose
Add-WordText -WordDocument $WordDocument -Text 'Technical References' -FontSize 12 -HeadingType Heading3 -FontFamily 'Calibri'
Add-WordTable -WordDocument $wordDocument -DataTable $ref -Design LightListAccent5 -autofit Contents,ColumnWidth -transpose

Save-WordDocument $WordDocument -Language 'en-US' 

Invoke-Item $FilePath