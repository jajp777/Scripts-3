## SharePoint Server: PowerShell Script That Uses The Object Model To Query Information On List Library Items ##
## Usage: Edit the following variables to suit your environment '$stream'; '$site'; '$list' and run your script
## Environments: MOSS 2007 and SharePoint Server 2010 Farms
## Resource: http://gallery.technet.microsoft.com/scriptcenter/SPListEnumerator-PowerShell-b0ce0b9f#content

[void][System.reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")
[void][System.reflection.Assembly]::LoadWithPartialName("System")
[System.Collections.ArrayList] $AL = new-object System.Collections.ArrayList
$AL.Add("Parent,Name,Content Type,No. of Versions (Minor and Major),Document Size in Bytes (Current Version Only),Breaks Permission Inheritance,Item Count (For Folders Only)") | Out-Null
$stream = [System.IO.StreamWriter] "C:\BoxBuild\Scripts\Enum_List_Log.csv" #Change this path to suit your environment

function TraverseListFolder([Microsoft.SharePoint.SPFolder] $folder)
{
  $qry = new-object Microsoft.SharePoint.SPQuery
  $qry.Folder = $folder
  $web = $null

  $delimiter = ","
  #[System.Collections.Array] $AR

  try
  {
    $web = $folder.ParentWeb
    [Microsoft.SharePoint.SPListItemCollection] $ic = $web.Lists[$folder.ParentListId].GetItems($qry)    

    
    if($subitem -eq $null)
    {
    [Microsoft.SharePoint.SPListItem] $subitem 
    }

   foreach($subitem in $ic)
   {
     $tempAL = ""
     $Name = $subitem.Name
     if($subitem.File.Length -eq $null)     
     {
        $tempFL = $subitem.File.Length
        $vCount = $subitem.Versions.Count
        $tempAL = [string]$folder + $delimiter + $Name + $delimiter + $subitem.ContentType.Name + $delimiter + $vCount + $delimiter + $delimiter + [string]$subitem.HasUniqueRoleAssignments + $delimiter
     }
     else
     {
        $tempFL = $subitem.File.Length
        $vCount = $subitem.Versions.Count
        $tempAL = [string]$folder + $delimiter + $Name + $delimiter + $subitem.ContentType.Name + $delimiter + $vCount + $delimiter + [string]$tempFL + $delimiter + [string]$subitem.HasUniqueRoleAssignments + $delimiter
     }
           if ($subitem.Folder -ne $null)
           {
               if($subitem.Folder.ItemCount -ne $null)
               {
                $tempAL = $tempAL + $subitem.Folder.ItemCount
                }
           TraverseListFolder($subitem.Folder)
           }           
           $AL.Add($tempAL) | Out-Null
   }
}
Catch 
{
 "Caught in a catch"
 $err=$Error[0]
 $err
 $err |Format-List *
 }
}
 
function TraverseList([Microsoft.SharePoint.SPList] $list)
{
Write-Host Traversing list: $list.Title
Write-Host Base Type: $list.BaseType.ToString()
TraverseListFolder($list.RootFolder)
}
  

$site = new-object Microsoft.SharePoint.SPSite("http://YourWebApp.com") #Change this URL to match your environment
$web = $site.rootweb
$list = $web.Lists["Shared Documents"] #Change this List Library name
TraverseList($list)
foreach($AR in $AL)
{
   $stream.WriteLine($AR)
}
$stream.Close()
$Site.Dispose();
$Web.Dispose();