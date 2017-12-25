#!/bin/bash

unset filter
IFS=$'\r\n' GLOBIGNORE='*' command eval  'filter=($(cat ./ExceptionFilter.txt))'

for f in /mnt/sniffs/pcapGatewayFull/*.pcap 
	do
		
		for i in "${filter[@]}"
		do
			
			if [[ $i == $(basename $f) ]]; then
	    	echo $(basename $f) $i filtered
			else
	    	echo $(basename $f) $i unfiltered
			fi

		done
done
