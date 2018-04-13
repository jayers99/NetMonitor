import os, sys, datetime, pygal
from pygal.style import Style
from pygal import Config

#define the chart settings
custom_style = Style(
    guide_stroke_dasharray = '1,4',
    major_guide_stroke_dasharray = '2,4',
    colors=('#5B9BD5','#5B9BD5', '#5B9BD5', '#5B9BD5', '#5B9BD5', '#5B9BD5', '#5B9BD5', '#5B9BD5', '#5B9BD5', '#5B9BD5', '#5B9BD5', '#5B9BD5', '#5B9BD5', '#5B9BD5', '#5B9BD5', '#5B9BD5', '#5B9BD5', '#5B9BD5', '#5B9BD5', '#5B9BD5', '#5B9BD5', '#5B9BD5', '#5B9BD5', '#5B9BD5', '#5B9BD5' )
)

config = Config()
config.show_legend = False
config.show_x_lables = True
config.box_mode = 'tukey'
config.x_title = 'Hour'
config.y_title = 'GB'
config.x_labels = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]

def genBoxPlot(plotTitle, srcPath, svgName, plotStartDate):
    dirs = os.listdir( srcPath )

    dictHoursWeekday = {0:[],1:[],2:[],3:[],4:[],5:[],6:[],7:[],8:[],9:[],\
                   10:[],11:[],12:[],13:[],14:[],15:[],16:[],17:[],18:[],19:[],\
                   20:[],21:[],22:[],23:[]}

    dictHoursWeekend = {0:[],1:[],2:[],3:[],4:[],5:[],6:[],7:[],8:[],9:[],\
                   10:[],11:[],12:[],13:[],14:[],15:[],16:[],17:[],18:[],19:[],\
                   20:[],21:[],22:[],23:[]}

    filterPath=srcPath + 'filter.txt'
    filterList = open(filterPath,'r').read().split('\n')

    for file in dirs:
        if file.endswith('.pcap'):
            if (file not in filterList) and (datetime.datetime.strptime(file[0:10], '%Y-%m-%d').date() >= plotStartDate):
                #print file + ',',
                #print file[0:10] + ',',
                #print datetime.datetime.strptime(file[0:10], '%Y-%m-%d').strftime('%a') + ',',
                #print file[15:17] + ',',
                statinfo = os.stat(srcPath + file)
                #print '{}{}'.format(statinfo.st_size, ','),
                #print float(statinfo.st_size)/1073741824
                if datetime.datetime.strptime(file[0:10], '%Y-%m-%d').strftime('%a') != 'Sat'\
                    and datetime.datetime.strptime(file[0:10], '%Y-%m-%d').strftime('%a') != 'Sun':
                    dictHoursWeekday[int(file[15:17])].append(float(statinfo.st_size)/1073741824)
                else:
                    dictHoursWeekend[int(file[15:17])].append(float(statinfo.st_size)/1073741824)
            #else:
                #print 'file in list'

    print plotTitle

    box_plot = pygal.Box(config, style=custom_style, title='Weekday ' + plotTitle)
    for hr in sorted(dictHoursWeekday):
        print hr,
        box_plot.add(hr,dictHoursWeekday[hr])
    box_plot.render_to_file('/mnt/sniffs/www/Network/' + svgName + 'Weekday.svg')
    print
    
    box_plot = pygal.Box(config, style=custom_style, title='Weekend ' + plotTitle)
    for hr in sorted(dictHoursWeekend):
        print hr,
        box_plot.add(hr,dictHoursWeekend[hr])
    box_plot.render_to_file('/mnt/sniffs/www/Network/' + svgName + 'Weekend.svg')
    print
    
    return;

#main build box plots
startDate=datetime.datetime.now().date() - datetime.timedelta(days=14)

genBoxPlot ( 'Gateway Hourly Traffic Profile', '/mnt/sniffs/pcapGatewayFull/', 'GatewayFullBoxPlot', startDate)
genBoxPlot ( 'Gateway Hourly Egress Traffic Profile', '/mnt/sniffs/pcapGatewayEgress/', 'GatewayEgressBoxPlot', startDate)
genBoxPlot ( 'Gateway Hourly Egress Internet Traffic Profile', '/mnt/sniffs/pcapGatewayEgressInternet/', 'GatewayEgressInternetBoxPlot', startDate)
genBoxPlot ( 'Gateway Hourly ARP Traffic Profile', '/mnt/sniffs/pcapGatewayArp/', 'GatewayArpBoxPlot', startDate)
genBoxPlot ( 'Gateway Hourly Broadcast Traffic Profile', '/mnt/sniffs/pcapGatewayBroadcast/', 'GatewayBroadcastBoxPlot', startDate)
