###########################################################
#    GET VCENTER SNAPSHOT REPORT  
#    This script generates a report for active Snapshot  
#    Tested: VMWare vCenter Ver 6.x.x
#    
#   Haim Cohen 
#   July 04, 2019
#   https://github.com/sk3pp3r/vmware-snapshot-report
#   https://www.linkedin.com/in/haimc/
#   Version 1.0
###########################################################

add-pssnapin VMware.VimAutomation.Core
$vc = "< VCENTER-SERVER >" # vCenter server or IP
$vc_admin = "< administrator@vsphere.local >" # vCenter Admin Username
$vc_password = "< Admin-Password-here >" # vCenter Admin Password

Connect-VIServer -Server $vc -User $vc_admin -Password $vc_password -WarningAction SilentlyContinue 

# HTML header style
$Header = @"
<style>
TABLE {border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}
TH {border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color: #6495ED;}
TD {border-width: 1px;padding: 3px;border-style: solid;border-color: black;}
</style>
"@

$sn1 = get-vm|Get-Snapshot
$sn2 = $sn1.count
$sn3 = $sn2
$From = "Snapshot.Report@mydomain.com"
$Subject = "Snapshot Report - $((Get-Date).ToShortDateString()) ($sn3 snapshots)"
$SMTPserver = "< SMTP SERVER >"
$To = "< rcpt @ domain.name >"



 
$Report = Get-VM | 
    Get-Snapshot | 
    Select-Object VM,
    Name,
    Description,
    @{Name="SizeGB";Expression={ [math]::Round($_.SizeGB,2) }},
    Created,
    @{Name="Days Old";Expression={ (New-TimeSpan -End (Get-Date) -Start $_.Created).Days }}

If (-not $Report)
{   $Report = [PSCustomObject]@{
        VM = "No snapshots found on any VM's"
        Name = "NA"
        Description = "NA"
        Size = "NA"
        Creator = "NA"
        Created = "NA"
        'Days Old' = "NA"
    }
}

$Report = $Report | 
    ConvertTo-Html -Head $Header -title "Snapshot Report" -body "<H1>Active Snapshot Report</H1>"  -pre (get-date)  -post "<h4>Haim Cohen 2019 &copy</h4>"  

$MailSplat = @{
    To         = $To
    From       = $From
    Subject    = $Subject
    Body       = ($Report | Out-String)
    BodyAsHTML = $true
    SMTPServer = $SMTPServer
}

Send-MailMessage @MailSplat

exit