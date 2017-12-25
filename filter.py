import os, sys, datetime

srcPath='/mnt/sniffs/pcapGatewayEgressInternet/'
dirs = os.listdir( srcPath )

filterPath=srcPath + 'filter.txt'
filterList = open(filterPath,'r').read().split('\n')

#for file in filterList:
#		print file #.strip()

startDate=datetime.datetime.now().date() - datetime.timedelta(days=45)
print startDate

for file in dirs:
	if datetime.datetime.strptime(file[0:10], '%Y-%m-%d').date() >= startDate: print file
	#if file in filterList: print file + ' in list'
	#if file not in filterList: print file + ' not in list'