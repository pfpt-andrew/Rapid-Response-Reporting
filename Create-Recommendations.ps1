#Install Requirements
Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy RemoteSigned -Force
    #PSSQLITE
    If (!(Get-module "PSSQLITE")) {
        Install-Module -name PSSQLITE;Import-module -name PSSQLITE}else{Import-module -name PSSQLITE}

    #PSWriteWord
    If (!(Get-module "PSWriteWord")) {
        Install-Module -name PSWriteWord;Import-module -name PSWriteWord}else{Import-module -name PSWriteWord}

    #GIT
    If (!(Get-module "Posh-Git")) {
        Install-Module -name Posh-Git;Import-module -name Posh-Git}else{Import-module -name Posh-Git}
    #Makingsure Git is in our '$Profile'
    'Import-Module Posh-Git' | Out-File -Append -Encoding default -FilePath $profile

#Checking For a working directory, if not making
$Work = "C:\work\attck"

If (!(test-path $Work))
{
    md C:\work\attck
}

cd $work
#Check to see if DB is present, if not, downloading
$DB = "C:\work\attck\ATTACK-Tools\attack_view_db.sqlite"

If (!(test-path $DB))
{
    git clone https://github.com/nshalabi/ATTACK-Tools.git
}

#Has the database changed?
cd C:\work\attck\ATTACK-Tools\
$pullstatus = git pull


if($pullstatus -eq 'Already up to date'){#Does the View exist?
$v_check = "Select * from V_Flat Limit 1;" 
try{
Invoke-SqliteQuery -Query $v_check -DataSource $DB -ErrorAction Stop}catch{#it doesn't exist so we will create the view!
$create_view = @"
Create View V_Flat
as
SELECT 
       [main].[sdos_object].[name] AS [Malware], 
       [main].[sdos_object].[description] AS [Malware_Description], 
       [main].[kill_chain_phases].[phase_name] AS [Tactic], 
       [main].[external_references].[external_id] AS [Technique_ID], 
       [sdos_object1].[name] AS [Technique], 
       [sdos_object1].[description] AS [Technique_Description], 
       [main].[external_references].[url] AS [URL], 
       [sdos_object2].[name] AS [Mitigation], 
       [sdos_object2].[description] AS [Mitigation_Description], 
       [sdos_object1].[x_mitre_detection] AS [Data_Source_Description], 
       [main].[x_mitre_defenses_bypassed].[x_mitre_defense_bypassed] AS [Defenses_Bypassed], 
       [main].[x_mitre_data_sources].[x_mitre_data_source] AS [Data_Source]
FROM   [main].[sdos_object]
       INNER JOIN [main].[relationship] ON [main].[sdos_object].[id] = [main].[relationship].[source_ref]
       INNER JOIN [main].[sdos_object] [sdos_object1] ON [main].[relationship].[target_ref] = [sdos_object1].[id]
       INNER JOIN [main].[external_references] ON [sdos_object1].[id] = [main].[external_references].[fk_object_id]
       INNER JOIN [main].[relationship] [relationship1] ON [sdos_object1].[id] = [relationship1].[target_ref]
       INNER JOIN [main].[sdos_object] [sdos_object2] ON [sdos_object2].[id] = [relationship1].[source_ref]
       INNER JOIN [main].[x_mitre_defenses_bypassed] ON [sdos_object1].[id] = [main].[x_mitre_defenses_bypassed].[fk_object_id]
       INNER JOIN [main].[x_mitre_data_sources] ON [sdos_object1].[id] = [main].[x_mitre_data_sources].[fk_object_id]
       INNER JOIN [main].[kill_chain_phases] ON [sdos_object1].[id] = [main].[kill_chain_phases].[fk_object_id]
WHERE  [main].[external_references].[url] LIKE '%attack.mitre.org%'
         AND [main].[sdos_object].[type] = 'malware'
         AND [relationship1].[relationship_type] = 'mitigates';
"@
Invoke-SqliteQuery -Query $create_view -DataSource $db
}
#Get all the data from the view
$v_query = "Select * from V_Flat"
$v_data = Invoke-SqliteQuery -Query $v_query -DataSource $db

#index malware family names
$Malware_names = $v_data|Select-Object -Property malware -Unique
$malware_names = $Malware_names.Malware

#check for document dir, if not create it
$docs = "C:\work\attck\docs"

If (!(test-path $docs))
{
    md C:\work\attck\docs
}

cd $docs


#Check if individual csvs for each malware name exist, if not make them
foreach($name in $Malware_names){
$dir = $docs+"\"+$name.Replace("/","") +".csv" 
If (!(test-path $dir)){$V_data | Where-Object -Property "name" -EQ "$name"  | Export-Csv -nti -Path $dir ; Write-Host "Writing $dir" -ForegroundColor Magenta}}

#Create word Doc Logic
$maldata = $null
foreach($name in $Malware_names){
$Worddoc = $docs+"\"+$name.Replace("/","") +".docx" 
If (!(test-path $Worddoc))
{
    #Get all data for the specific for each malware family
    $maldata = $V_data | Where-Object -Property "malware" -EQ "$name"
    #Create Tables for Word Doc
        #Tactics with Techniques
        $TT = $maldata | Select-Object -Property Tactic,Technique_ID,Technique,Technique_Description -Unique
        #Mitigating Controls Not Present or Bypassed
        $MC = $maldata | Select-Object -Property Technique,Defenses_Bypassed -Unique
        #Tactical Mitigation
        $TM = $maldata | Select-Object -Property Technique_ID,Mitigation,Mitigation_Description -unique
        #Monitoring and Detection Requirements
        $MR = $maldata | Select-Object -Property Technique_ID,Technique,Data_Source -Unique
        $MS = $maldata | Select-Object -Property Data_Source,Data_Source_Description -Unique
        #References
        $R = $maldata | Select-Object -Property Technique,URL -Unique
    
    Write-Host "Writing $Worddoc" -ForegroundColor Magenta
   

$wordDocument = New-WordDocument $Worddoc


Add-WordText -WordDocument $wordDocument -Text "Tactics Techniques" -FontSize 12 -HeadingType Heading3 -FontFamily 'Calibri' -Supress $true
Add-WordText -WordDocument $wordDocument -Text "This table represents the tradecraft utilized by this specific malware and which phase of the killchain each technique was utilized in." -Supress $true
Add-WordTable -WordDocument $wordDocument -DataTable $TT -Design LightListAccent5 -ColumnWidth 100 -Supress $true
Add-WordText -WordDocument $WordDocument -Text 'Defensive Controls Not Present or Bypassed' -FontSize 12 -HeadingType Heading3 -FontFamily 'Calibri' -Supress $true
Add-WordText -WordDocument $wordDocument -Text "This table represents Defensive Controls that were either not present or bypassed by the specific techniques employed by this malware.  For example, though anti-virus may be present at the time of incident the capabilities of the control were not sufficient to mitigate the evasion of said malware." -Supress $true
Add-WordTable -WordDocument $wordDocument -DataTable $MC -Design LightListAccent5 -ColumnWidth 100 -Supress $true
Add-WordText -WordDocument $WordDocument -Text 'Tactical Mitigation' -FontSize 12 -HeadingType Heading3 -FontFamily 'Calibri' -Supress $true
Add-WordText -WordDocument $wordDocument -Text "This table represents specific steps that can be taken to mitigate the techniques used in this incident" -Supress $true
Add-WordTable -WordDocument $wordDocument -DataTable $TM -Design LightListAccent5 -ColumnWidth 100 -Supress $true
Add-WordText -WordDocument $WordDocument -Text 'Monitoring and Detection Requirements' -FontSize 12 -HeadingType Heading3 -FontFamily 'Calibri' -Supress $true
Add-WordText -WordDocument $wordDocument -Text "In order to adequately monitor for and respond to these attacks the following data sources must be monitored" -Supress $true
Add-WordTable -WordDocument $wordDocument -DataTable $MR -Design LightListAccent5 -ColumnWidth 100 -Supress $true
Add-WordText -WordDocument $WordDocument -Text 'Monitoring and Detection Strategy' -FontSize 12 -HeadingType Heading3 -FontFamily 'Calibri' -Supress $true
Add-WordText -WordDocument $wordDocument -Text "The application of monitoring strategy for each applicable data source" -Supress $true
Add-WordTable -WordDocument $wordDocument -DataTable $MS -Design LightListAccent5 -ColumnWidth 100 -Supress $true
Add-WordText -WordDocument $WordDocument -Text 'References' -FontSize 12 -HeadingType Heading3 -FontFamily 'Calibri' -Supress $true
Add-WordText -WordDocument $wordDocument -Text "Additional Reading and Technical References" -Supress $true
Add-WordTable -WordDocument $wordDocument -DataTable $R -Design LightListAccent5 -ColumnWidth 100 -Supress $true

Save-WordDocument $WordDocument -Language 'en-US' -Supress $true

}}



}else{##########The Database was updated so all the files need to be created again even if they already exist!##########################

#Does the View exist?
$v_check = "Select * from V_Flat Limit 1;"
try{
Invoke-SqliteQuery -Query $v_check -DataSource $DB -ErrorAction Stop
}catch{
#it doesn't exist so we will create the view!
$create_view = @"
Create View V_Flat
as
SELECT 
       [main].[sdos_object].[name] AS [Malware], 
       [main].[sdos_object].[description] AS [Malware_Description], 
       [main].[kill_chain_phases].[phase_name] AS [Tactic], 
       [main].[external_references].[external_id] AS [Technique_ID], 
       [sdos_object1].[name] AS [Technique], 
       [sdos_object1].[description] AS [Technique_Description], 
       [main].[external_references].[url] AS [URL], 
       [sdos_object2].[name] AS [Mitigation], 
       [sdos_object2].[description] AS [Mitigation_Description], 
       [sdos_object1].[x_mitre_detection] AS [Data_Source_Description], 
       [main].[x_mitre_defenses_bypassed].[x_mitre_defense_bypassed] AS [Defenses_Bypassed], 
       [main].[x_mitre_data_sources].[x_mitre_data_source] AS [Data_Source]
FROM   [main].[sdos_object]
       INNER JOIN [main].[relationship] ON [main].[sdos_object].[id] = [main].[relationship].[source_ref]
       INNER JOIN [main].[sdos_object] [sdos_object1] ON [main].[relationship].[target_ref] = [sdos_object1].[id]
       INNER JOIN [main].[external_references] ON [sdos_object1].[id] = [main].[external_references].[fk_object_id]
       INNER JOIN [main].[relationship] [relationship1] ON [sdos_object1].[id] = [relationship1].[target_ref]
       INNER JOIN [main].[sdos_object] [sdos_object2] ON [sdos_object2].[id] = [relationship1].[source_ref]
       INNER JOIN [main].[x_mitre_defenses_bypassed] ON [sdos_object1].[id] = [main].[x_mitre_defenses_bypassed].[fk_object_id]
       INNER JOIN [main].[x_mitre_data_sources] ON [sdos_object1].[id] = [main].[x_mitre_data_sources].[fk_object_id]
       INNER JOIN [main].[kill_chain_phases] ON [sdos_object1].[id] = [main].[kill_chain_phases].[fk_object_id]
WHERE  [main].[external_references].[url] LIKE '%attack.mitre.org%'
         AND [main].[sdos_object].[type] = 'malware'
         AND [relationship1].[relationship_type] = 'mitigates';
"@
Invoke-SqliteQuery -Query $create_view -DataSource $db
}
#Get all the data from the view
$v_query = "Select * from V_Flat"
$v_data = Invoke-SqliteQuery -Query $v_query -DataSource $db

#index malware family names
$Malware_names = $v_data|?{$_.type -eq 'malware'} | Select-Object -Property name -Unique

#check for document dir, if not create it
$docs = "C:\work\attck\docs"

If (!(test-path $docs))
{
    md C:\work\attck\docs
}

cd $docs


#Overwrite CSV Files
foreach($name in $Malware_names){
$dir = $docs+"\"+$name.Replace("/","") +".csv" 

$V_data | Where-Object -Property "name" -EQ "$name" |Select-Object -Unique | Export-Csv -nti -Path $dir -Force; Write-Host "Writing $dir" -ForegroundColor Magenta
}

#Create word Doc Logic

$maldata = $null
foreach($name in $Malware_names){
$Worddoc = $docs+"\"+$name.Replace("/","") +".docx" 


    #Get all data for the specific for each malware family
    $maldata = $V_data | Where-Object -Property "malware" -EQ "$name" | Select-Object -Unique
    #Create Tables for Word Doc
        #Tactics with Techniques
        $TT = $maldata | Select-Object -Property Tactic,Technique_ID,Technique,Technique_Description -Unique
        #Mitigating Controls Not Present or Bypassed
        $MC = $maldata | Select-Object -Property Technique,Defenses_Bypassed -Unique
        #Tactical Mitigation
        $TM = $maldata | Select-Object -Property Technique_ID,Mitigation,Mitigation_Description -Unique
        #Monitoring and Detection Requirements
        $MR = $maldata | Select-Object -Property Technique_ID,Technique,Detection_DataSource -Unique
        #Monitoring Strategy
        $MS = $maldata | Select-Object -Property Detection_DataSource,Detection_Description -Unique
        #References
        $R = $maldata | Select-Object -Property Technique,URL -Unique
    
    Write-Host "Writing $dir" -ForegroundColor Magenta
   

$wordDocument = New-WordDocument $Worddoc


Add-WordText -WordDocument $wordDocument -Text "Tactics Techniques" -FontSize 12 -HeadingType Heading3 -FontFamily 'Calibri'
Add-WordText -WordDocument $wordDocument -Text "This table represents the tradecraft utilized by this specific malware and which phase of the killchain each technique was utilized in."
Add-WordTable -WordDocument $wordDocument -DataTable $TT -Design LightListAccent5 -ColumnWidth 100
Add-WordText -WordDocument $WordDocument -Text 'Defensive Controls Not Present or Bypassed' -FontSize 12 -HeadingType Heading3 -FontFamily 'Calibri'
Add-WordText -WordDocument $wordDocument -Text "This table represents Defensive Controls that were either not present or bypassed by the specific techniques employed by this malware.  For example, though anti-virus may be present at the time of incident the capabilities of the control were not sufficient to mitigate the evasion of said malware."
Add-WordTable -WordDocument $wordDocument -DataTable $MC -Design LightListAccent5 -ColumnWidth 100
Add-WordText -WordDocument $WordDocument -Text 'Tactical Mitigation' -FontSize 12 -HeadingType Heading3 -FontFamily 'Calibri'
Add-WordText -WordDocument $wordDocument -Text "This table represents specific steps that can be taken to mitigate the specifc tecniques used in this incident"
Add-WordTable -WordDocument $wordDocument -DataTable $TM -Design LightListAccent5 -ColumnWidth 100
Add-WordText -WordDocument $WordDocument -Text 'Monitoring and Detection Requirements' -FontSize 12 -HeadingType Heading3 -FontFamily 'Calibri'
Add-WordText -WordDocument $wordDocument -Text "In order to adequately monitor for and respond to these attacks the following data sources must be monitored"
Add-WordTable -WordDocument $wordDocument -DataTable $MR -Design LightListAccent5 -ColumnWidth 100
Add-WordText -WordDocument $WordDocument -Text 'Monitoring and Detection Strategy' -FontSize 12 -HeadingType Heading3 -FontFamily 'Calibri'
Add-WordText -WordDocument $wordDocument -Text "The application of monitoring strategy for each applicable data source"
Add-WordTable -WordDocument $wordDocument -DataTable $MS -Design LightListAccent5 -ColumnWidth 100
Add-WordText -WordDocument $WordDocument -Text 'References' -FontSize 12 -HeadingType Heading3 -FontFamily 'Calibri'
Add-WordText -WordDocument $wordDocument -Text "Additional Reading and Technical References"
Add-WordTable -WordDocument $wordDocument -DataTable $R -Design LightListAccent5 -ColumnWidth 100

Save-WordDocument $WordDocument -Language 'en-US' 









}

}
