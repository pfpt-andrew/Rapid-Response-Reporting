Import-Module -Name PSWriteWord
$file = Read-Host -Prompt "Enter FQpath to flat file with techniques"
$list = gc -path $file

$t = foreach($item in $list){
    Get-AttckTechnique | ?{$_.id -eq $item}
}

$m = $t.Mitigations()

$m | Select-Object -Property ID,Name,Description,Wiki -Unique | Export-Excel -Now