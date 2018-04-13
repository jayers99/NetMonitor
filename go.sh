#!/bin/bash
#script to generate box plots of the tcpdump files
#cp -n /mnt/OpsCrash/*.pcap /mnt/sniffs/pcapGatewayFull
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
rsync -av --exclude=$(date +"%Y-%m-%d_%a_%H00").pcap //mnt/OpsCrash/*.pcap //mnt/sniffs/pcapGatewayFull/
for f in /mnt/sniffs/pcapGatewayFull/*.pcap
    do 
        if [ ! -f /mnt/sniffs/pcapGatewayEgress/${f##*/}  ]
            then 
            tcpdump -nr $f src net '10.0.0.0/8' and src '!10.12.2.190' -w /mnt/sniffs/pcapGatewayEgress/${f##*/}
            #else 
            #echo "file exists"
        fi
        if [ ! -f /mnt/sniffs/pcapGatewayEgressInternet/${f##*/}  ]
            then 
            tcpdump -nr $f src net '10.0.0.0/8' and src '!10.12.2.190' and dst net '!10.0.0.0/8' -w /mnt/sniffs/pcapGatewayEgressInternet/${f##*/}
            #else 
            #echo "file exists"
        fi
        if [ ! -f /mnt/sniffs/pcapGatewayArp/${f##*/}  ]
            then 
            tcpdump -nr $f arp -w /mnt/sniffs/pcapGatewayArp/${f##*/}
            #else 
            #echo "file exists"
        fi
        if [ ! -f /mnt/sniffs/pcapGatewayBroadcast/${f##*/}  ]
            then 
            tcpdump -nr $f broadcast -w /mnt/sniffs/pcapGatewayBroadcast/${f##*/}
            #else 
            #echo "file exists"
        fi
done
python /mnt/sniffs/NetTrafficBoxPlots.py
echo "rsync -av //mnt/sniffs/www/ jayers@ja-linux-02:/var/www/html/"

