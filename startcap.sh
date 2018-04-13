#!/bin/bash

#cap all non arp traffic
tcpdump -nnvvXSs 1514 '(src !10.101.0.133 and dst !10.101.0.133) and (dst 10.101.0.99 or src 10.101.0.99) and !arp'

#awk top talkers by packet count
tcpdump -tnr ./pcapGatewayEgressInternet/2016-05-05_Thu_1400.pcap | awk -F ' ' '{print $2 " " $3 " " $4}' | sort | uniq -c | sort -rn | head -n 10

#final hourly full cap
tcpdump -ni eth1 -G 3600 -w '/mnt/hgfs/E/Sniffs/%Y-%m-%d_%a_%H%M.pcap'

#start cap on the hour
sudo at $(date -d 'next hour' '+%H:00')
tcpdump -ni eth0 -G 3600 -w '/mnt/hgfs/E/Sniffs/%Y-%m-%d_%a_%H%M.pcap'

#on ops crash box RUN THIS TO RESTART CAP
echo "tcpdump -ni eth1 -G 3600 -w '/mnt/hgfs/E/Sniffs/%Y-%m-%d_%a_%H%M.pcap'&" | at $(date -d 'next hour' '+%H:00')
#test my box
echo "tcpdump -ni eth0 -G 3600 -w '/home/jayers/sniffs/%Y-%m-%d_%a_%H%M.pcap'&" | sudo at $(date -d 'next hour' '+%H:00')

#at job managment
ps -e | grep tcpdump
atq
atrm

#to filter a full cap file
tcpdump -nr ./$f src net '10.0.0.0/8' and src '!10.12.2.190' -w ./EgressTraffic/$f

cp -n /mnt/OpsCrash/*.pcap /mnt/sniffs/pcapGatewayFull
rsync -avn --exclude=$(date +"%Y-%m-%d_%a_%H00").pcap //mnt/OpsCrash/*.pcap //mnt/sniffs/pcapGatewayFull/
rsync -av //mnt/sniffs/*.svg jayers@ja-linux-02:var/www/html/network

#to loop through all the files
for f in /mnt/sniffs/pcapGatewayFull/*.pcap; do if [ ! -f /mnt/sniffs/pcapGatewayEgress/${f##*/}  ]; then tcpdump -nr $f src net '10.0.0.0/8' and src '!10.12.2.190' -w /mnt/sniffs/pcapGatewayEgress/${f##*/} ; else echo "file exists"; fi; done

tshark
tcpick

#to list file name and size
del d:\Sniffs\NetTraffic.csv
for %F in (d:\Sniffs\*.pcap) do @echo %~tF,%~zF >> d:\Sniffs\NetTraffic.csv

#to merg pcap files
"c:\Program Files\Wireshark\mergecap" -s 128 -w 2016-03-03all.pcap 2016-03-03_*.pcap

#rename all the files with the day of the week
for f in *.pcap; do echo $f to ${f:0:10}_$(date --date=${f:0:10} '+%a')_${f:11:4}.pcap;done
for f in *.pcap; do mv $f ${f:0:10}_$(date --date=${f:0:10} '+%a')_${f:11:4}.pcap;done

#sync remote mon folders
rsync -av --ignore-existing <src> <dst>
rsync -av --ignore-existing /mnt/OpsCrash /mnt/sniffs/pcapGatewayFull
cp -n /mnt/OpsCrash/*.pcap /mnt/sniffs/pcapGatewayFull

#windows searching for files greater than some size
System.Size:>500mb
Sun OR Sat AND Size: > 0.025gb
NOT Sun OR NOT Sat AND Size: > 0.25gb


python NetTraffic.py | grep 'Sat\|Sun' > pcapGatewayFullWeekend.csv
python NetTraffic.py | grep 'Mon\|Tue\|Wed\|Thu\|Fri' > pcapGatewayFullWeekday.csv

for f in ./pcapGatewayFull/*.pcap; do if [ ! -f ./pcapGatewayEgress/${f##*/}  ]; then tcpdump -nr $f src net '10.0.0.0/8' and src '!10.12.2.190' -w ./pcapGatewayEgress/${f##*/}; fi; done
