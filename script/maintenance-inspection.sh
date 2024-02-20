#!/bin/bash
######
export LANG=en_US.UTF-8
###### GET INFO
HN=`hostname`
TODAY=`date '+%Y%m%d'`

###### DIR Create
directory="/opt/onit-inspection"

if [ ! -d "$directory" ]; then
    mkdir -p "$directory"
    if [ $? -eq 0 ]; then
        echo "$directory Create Success."
    else
        clear
        exit 1
    fi
else
        clear
fi

##### OS VERSION CHECK
grep -Fq " 9." /etc/redhat-release
	if [ $? -eq 0 ]; then
    		OV=9
		elif [[ $(grep -F " 8." /etc/redhat-release) ]]; then
    			OV=8
		elif [[ $(grep -F " 7." /etc/redhat-release) ]]; then
    			OV=7
	else
    		OV=6
	fi
##### LOG DIR
LOGDIR="$directory/$TODAY"


show_manual() {
		echo "Options:"
		echo "  -s    ONIT Inscpection Script Start(RHEL6,7,8,9)"
		echo "  -c    Compress logs"
		echo "  -v    Version"
}

show_version() {
		echo "Version : 1.0"
}

start_script() {
		mkdir "$LOGDIR"
		##### OS VERSION CHECK
		grep -Fq " 9." /etc/redhat-release
		        if [ $? -eq 0 ]; then
		                OV=9
		                elif [[ $(grep -F " 8." /etc/redhat-release) ]]; then
		                        OV=8
		                elif [[ $(grep -F " 7." /etc/redhat-release) ]]; then
		                        OV=7
		        else
		                OV=6
		        fi

		# Kernel version
		KV=`uname -r`

		# SERVER MODEL
		SM=$(dmidecode -t system | grep "Product Name" | awk -F: '{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//')

		# OS INFO
		OVER=$(cat /etc/redhat-release)

		# CPU MODEL
		CPU=$(lscpu | grep  "^Model name:" | awk -F ":" '{sub(/^ * /, "", $2); print $2}' | tail -n1)

		# CPU SOCKET
		SCPU=$(lscpu | grep "^Socket" | awk -F ":" '{sub(/^ * /, "", $2); print $2}')

		# MEM ALL SIZE
		PMEM=$(dmidecode -t memory | egrep -i '(gb|mb)' | grep -i size | grep -iv Volatile | awk -F ":" '{sub(/^ * /, "", $2); print $2}')

		# MEM PER SIZE
		SMEM=$(dmidecode -t memory | egrep -i '(gb|mb)' | grep -i size | grep -iv Volatile | awk -F ":" '{sub(/^ * /, "", $2); print $2}' | tail -n1)

		# MEM COUNT
		CMEM=$(dmidecode -t memory | egrep -i '(gb|mb)' | grep -i size | grep -iv Volatile | awk -F ":" '{print $2}' |  column -t | wc -l)

		# SERIAL NUMBER
		SN=$(dmidecode -t system | grep -i "Serial Number" | awk -F: '{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//')

		# RX TX ERR
		NERR7=$(netstat -i | egrep -vi '(lo|kernel)' | awk 'BEGIN {print "INTERFACE\tRX-ERR\tTX-ERR"} NR>2 {print $1 "\t" $4 "\t" $8}' | column -t)
		NERR6=$(netstat -i | egrep -vi '(lo|kernel)' | awk 'BEGIN {print "INTERFACE\tRX-ERR\tTX-ERR"} NR>2 {print $1 "\t" $5 "\t" $9}' | column -t)
		# UPTIME
		uptime_seconds=$(awk '{print $1}' /proc/uptime)
	        uptime_days=$(echo "scale=0; $uptime_seconds / (24 * 3600)" | bc)
       	 	uptime_hours=$(echo "scale=0; ($uptime_seconds % (24 * 3600)) / 3600" | bc)

###### TOP-INFO
{
	for i in {1..5}
	do
    		top -n 1 -b | head -n50
    		sleep 1
	done
} > "$LOGDIR/TOP-INFO.txt" 

###### HW-INFO
{
	echo -e "\n---------- SYSTEM ----------\n"
	dmidecode -t system
	echo -e "\n---------- BIOS ----------\n"
	dmidecode -t BIOS
	echo -e "\n---------- CHASSIS ----------\n"
	dmidecode -t chassis
	echo -e "\n---------- PROCESSOR ----------\n"
	dmidecode -t processor
	echo -e "\n---------- MEMORY ----------\n"
	dmidecode -t memory
	echo -e "\n---------- IPMI SDR ----------\n"
	ipmitool sdr
	echo -e "\n---------- IPMI FRU----------\n"
	ipmitool fru
	echo -e "\n---------- IPMI LAN PRINT ----------\n"
	ipmitool lan print
} > "$LOGDIR/HW-INFO.txt"



###### DISK-INFO
{
which hpacucli &> /dev/null
HPACU=$?
if [ $HPACU = 0 ]
	then
echo "
_____________________________________________________________________
HPACUCLI CMD
_____________________________________________________________________"
hpacucli ctrl all show config
hpacucli ctrl all show config detail
echo "_____________________________________________________________________"
	else
echo "
_____________________________________________________________________
HPACUCLI CMD NOT FOUND
_____________________________________________________________________"
fi

which ssacli &> /dev/null
SSACLI=$?
if [ $SSACLI = 0 ]
	then
echo "
_____________________________________________________________________
SSACLI CMD
_____________________________________________________________________"
ssacli ctrl all show config
ssacli ctrl all show config detail
echo "_____________________________________________________________________"
	else
echo "
_____________________________________________________________________
SSACLI CMD NOT FOUND
_____________________________________________________________________"
fi

which hpssacli &> /dev/null
HPSSACLI=$?
if [ $HPSSACLI = 0 ]
	then
echo "
_____________________________________________________________________
HPACUCLI CMD
_____________________________________________________________________"
hpssacli ctrl all show config
hpssacli ctrl all show config detail
echo "_____________________________________________________________________"
	else
echo "
_____________________________________________________________________
HPSSACLI CMD NOT FOUND
_____________________________________________________________________"
fi


ls /opt/MegaRAID/storcli/storcli64 &> /dev/null
STORCLI=$?
if [ $STORCLI = 0 ]
	then
echo "
_____________________________________________________________________
STORCLI CMD
_____________________________________________________________________"
/opt/MegaRAID/storcli/storcli64 /c0 show all
echo "_____________________________________________________________________"
	else
echo "
_____________________________________________________________________
STORCLI CMD NOT FOUND
_____________________________________________________________________"
fi


ls /opt/MegaRAID/MegaCli/MegaCli64 &> /dev/null
MEGACLI=$?

if [ $MEGACLI = 0 ]
	then
echo "
_____________________________________________________________________
MEGACLI CMD
_____________________________________________________________________"
/opt/MegaRAID/MegaCli/MegaCli64 -ShowSummary -aALL
/opt/MegaRAID/MegaCli/MegaCli64 -PDList -aALL
echo "_____________________________________________________________________"
	else
echo "
_____________________________________________________________________
MEGACLI CMD NOT FOUND
_____________________________________________________________________"
fi


ls /opt/MegaRAID/perccli/perccli64 &> /dev/null
PERCCLI=$?

if [ $PERCCLI = 0 ]
	then 
echo "
_____________________________________________________________________
PERCCLI CMD
_____________________________________________________________________"
/opt/MegaRAID/perccli/perccli64  /c0 show
echo "_____________________________________________________________________"
	else
echo "
_____________________________________________________________________
PERCCLI CMD NOT FOUND
_____________________________________________________________________"
fi

ls /opt/dell/srvadmin/bin/omreport &> /dev/null
OMREPORT=$?
if [ $OMREPORT = 0 ]
        then
echo "
_____________________________________________________________________
OMREPORT CMD
_____________________________________________________________________"
/opt/dell/srvadmin/bin/omreport storage vdisk
/opt/dell/srvadmin/bin/omreport storage controller
/opt/dell/srvadmin/bin/omreport storage controller | grep -i ^ID | awk -F: '{print "/opt/dell/srvadmin/bin/omreport storage adisk controller=" $2+0}' | sh
/opt/dell/srvadmin/bin/omreport storage battery
echo "_____________________________________________________________________"
        else
echo "
_____________________________________________________________________
OMREPORT CMD NOT FOUND
_____________________________________________________________________"
fi

} > "$LOGDIR/DISK-INFO.txt"


{
###### SIMPLE-INFO
echo -e "\t\t\t SERVER INFO"
echo -e "_____________________________________________________________________"
echo -e "\nSERVER MODEL	:	$SM\n"
echo -e "\nOS INFO		:	$OVER\n"
echo -e "\nHOSTNAME 	:	$HN\n"
echo -e "\nUPTIME		:	${uptime_days} Day ${uptime_hours} Hour"
echo -e "_____________________________________________________________________"


		if [ $OV -eq 6 ]; then
			echo -e "\n\n\t\t\tNTP STATUS"
			echo -e "_____________________________________________________________________\n"
			ntpq -p | grep -i "*" | awk -F" " '{print "connect ntpserver \t: \t" $1 "\nconnect reach \t\t:\t "$7 "\noffset \t\t\t:\t " $9}'
			echo -e "_____________________________________________________________________"
		elif [ $OV -le 7 ]; then
			echo -e "\n\n\t\t\tNTP STATUS"
			echo -e "_____________________________________________________________________\n"
			ntpq -p | grep -i "*" | awk -F" " '{print "connect ntpserver \t: \t" $1 "\nconnect reach \t\t:\t "$7 "\noffset \t\t\t:\t " $9}'
			echo -e "_____________________________________________________________________"
			echo -e "\n\n\t\t\tChrony STATUS"
			echo -e "_____________________________________________________________________\n"
			chronyc tracking | egrep -i "Reference ID|Last offset|Leap status"
			echo -e "_____________________________________________________________________"
		fi

echo -e "\n\n\t\t\tFILE SYSTEM"
echo -e "_____________________________________________________________________\n"
df -h
echo -e "_____________________________________________________________________"
echo -e "\n\n\t\t\tFILE SYSTEM I-NODE"
echo -e "_____________________________________________________________________\n"
df -i
echo -e "_____________________________________________________________________"
echo -e "\n\n\t\t\tFile system USE 70% UP"
echo -e "_____________________________________________________________________\n"
	df -h | egrep -v "^Filesystem|tmpfs" | while read -r dfu_out ; do
	echo $dfu_out | awk '$5>70{print}' | awk '{print "DEVICE : " $1 " USE : "$5 " MOUNTPOINT : " $6}'
	done
echo -e "_____________________________________________________________________"

echo -e "\n\n\t\t\tIP INFO"
echo -e "_____________________________________________________________________\n"

        for NDEV in $(ip a s  | grep -vF lo | grep state | awk -F: '{print $2}' | column -t  | awk '{print $1}'); do
	NIP=$(ip a s $NDEV | grep -wF inet | awk '{print$2}') 
	NIP6=$(ip a s $NDEV | grep -wF inet6 | awk '{print$2}') 
	ip a s $NDEV | grep -w "state" | grep -q "state UP" && NLINK=UP || NLINK=DOWN
	echo -e "$NDEV		$NLINK		$NIP		$NIP6"
	done
echo -e "_____________________________________________________________________"
echo -e "\n\n\t\tNIC INFO"
echo -e "_____________________________________________________________________\n"
if [ $OV -ge 7 ] 
	then
	        for NDEV in $(ip a s | grep -F state | awk -F ":" '{print $2}' | column -t | grep -vE "^lo$|^virbr0$|^virbr0-nic$"); do
		LINK=$(cat /sys/class/net/$NDEV/operstate)
		DUP=$(cat /sys/class/net/$NDEV/duplex)
		SPD=$(cat /sys/class/net/$NDEV/speed)
		MTU=$(cat /sys/class/net/$NDEV/mtu)
		echo -e "DEVICE : $NDEV\t\t LINK : $LINK \t DUP : $DUP \t SPEED : $SPD \t MTU : $MTU"
		done
	else
		for NDEV in $(ip a s  | grep -vF lo | grep state | awk -F: '{print $2}' | column -t  | awk '{print $1}'); do
		LINK=$(ethtool $NDEV | grep -iF "Link detected" | awk -F: '{print $2}' |  column -t)
		DUP=$(ethtool $NDEV | grep -iF "Duplex" | awk -F: '{print $2}' |  column -t)
		SPD=$(ethtool $NDEV | grep -iF "speed" | awk -F: '{print $2}' |  column -t)
        	echo -e "DEVICE : $NDEV \t\t LINK : $LINK \t DUP : $DUP \t SPEED : $SPD" 
		done

fi
echo -e "_____________________________________________________________________"
        
echo -e "\n\n\t\tRX/TX ERR"
echo -e "_____________________________________________________________________\n"
if [ $OV -ge  7 ]
	then
		echo "$NERR7"
			{
				echo "$NERR7"
			} > "$LOGDIR/RXTX-INFO.txt"
	else
		echo "$NERR6"
			{
				echo "$NERR6"
			} > "$LOGDIR/RXTX-INFO.txt"
fi
echo -e "_____________________________________________________________________"

##### CPU IDEL

if [ $OV -ge  7 ]
        then
		echo -e "\n\n\t\tCPU IDLE"
		echo -e "_____________________________________________________________________\n"
		cat $LOGDIR/TOP-INFO.txt | grep -F %Cpu"("s")" | awk '{print $8}'
		echo -e "_____________________________________________________________________"
		echo -e "\n\n\t\tCPU Average" 
		echo -e "_____________________________________________________________________\n"
		cat $LOGDIR/TOP-INFO.txt | grep -F %Cpu"("s")" | awk '{print $8}' |  awk '{sum += $1} END {printf "%.2f\n", sum/NR}'
		echo -e "_____________________________________________________________________"
        else
		echo -e "_____________________________________________________________________"
		echo -e "\n\n\t\tCPU IDLE"
		echo -e "_____________________________________________________________________\n"
		cat $LOGDIR/TOP-INFO.txt | grep -F 'Cpu(s)' | awk '{print $5}' | awk -F '%' '{print $1}'
		echo -e "_____________________________________________________________________\n"
		echo -e "\n\n\t\tCPU Average" 
		echo -e "_____________________________________________________________________"
		cat $LOGDIR/TOP-INFO.txt | grep -F 'Cpu(s)' | awk '{print $5}' | awk -F '%' '{print $1}' |  awk '{sum += $1} END {printf "%.2f\n", sum/NR}'

fi




##### MEM FREE
echo -e "\n\n\t\tMEM FREE"
echo -e "_____________________________________________________________________\n"
if [ $OV -ge 7 ]
	then
		cat /proc/meminfo | grep -F "MemAvailable" | awk '{print $2}' | tr -d 'kB' | awk '{ avg = $1/1024 } END{print int(avg)"MB"}'
	else
		cat /proc/meminfo | egrep  "^MemFree|^Buffers|^Cached" | awk -F ":" '{print $2}' | tr -d kB | column -t | awk '{ sum = sum + $1 }END{ free = sum/1024 ; print int(free)"MB"}'
fi
echo -e "_____________________________________________________________________"

##### TOP PROCESS
	echo -e "\n\n\t\tTOP PROCESS"
	echo -e "_____________________________________________________________________\n"
	cat $LOGDIR/TOP-INFO.txt | grep "PID USER" -A 1 | tail -n1 | awk '{print $9 "% " $12}'
	echo -e "_____________________________________________________________________"

##### MESSAGES

	echo -e "\n\n\t\tMESSAGE"
	echo -e "_____________________________________________________________________\n"
	ls  /var/log/messages* | grep -v gz | awk '{print "cat "$1}' | sh -x | egrep -i '(panic|emerg|warn|fault|fail|down|crit|alert|err)' 
	echo -e "_____________________________________________________________________"

} > "$LOGDIR/SIMPLE-INFO.txt"


###### DETAIL-INFO
{
	iscsiadm -m session -P 3
	multipath -ll
	blkid
	lsblk
	pvs
	vgs
	lvs
	
	
} > "$LOGDIR/DETAIL-INFO.txt"

###### EXCEL-INFO
{
	OFS=$(cat $LOGDIR/SIMPLE-INFO.txt | grep -F "offset" | awk -F ":" '{sub(/^ * /, "", $2); print $2}')

	echo "$SM"
	echo "OS Version : $OVER "
	echo "Serial Number : $SN "
	echo "Host Name : $HN"
	echo "Interface IP : "

	echo -e "\n$KV"
	echo "${uptime_days} Day ${uptime_hours} Hour"
	echo "CPU : $CPU "*" $SCPU / MEM : $SMEM "*" $CMEM "
	echo "$OFS"
	echo "NORMAL"
	df -h / | grep -v "^Filesystem" | awk '{print $6 "   " $5}'
	df -i / | grep -v "^Filesystem" | awk '{print $6 "   " $5}'
	echo "NORMAL"
	echo "NORMAL"
	awk 'NR>1 && ($2 > 0 || $3 > 0) { abnormal=1 } END { if(abnormal) print "ABNORMAL"; else print "NORMAL" }'  $LOGDIR/RXTX-INFO.txt
	if [ $OV -ge  7 ]
        	then
                	cat $LOGDIR/TOP-INFO.txt | grep -F %Cpu"("s")" | awk '{print $8}' |  awk '{sum += $1} END {printf "%.2f\n", sum/NR}'
 	       else
			cat $LOGDIR/TOP-INFO.txt | grep -F 'Cpu(s)' | awk '{print $5}' | awk -F '%' '{print $1}' |  awk '{sum += $1} END {printf "%.2f\n", sum/NR}'

fi

	if [ $OV -ge 7 ]
        	then
                	cat /proc/meminfo | grep -F "MemAvailable" | awk '{print $2}' | tr -d 'kB' | awk '{ avg = $1/1024 } END{print int(avg)"MB"}'
        else
                	cat /proc/meminfo | egrep  "^MemFree|^Buffers|^Cached" | awk -F ":" '{print $2}' | tr -d kB | column -t | awk '{ sum = sum + $1 }END{ free = sum/1024 ; print int(free)"MB"}'
fi
	cat $LOGDIR/TOP-INFO.txt | grep "PID USER" -A 1 | tail -n1 | awk '{print $9 "% " $12}'
	echo "NORMAL"
	echo "NORMAL"

} > "$LOGDIR/EXCEL-INFO.txt"



}


while getopts "schv" opt; do
    case $opt in
        s)
                start_script 
                ;;
        c)
                echo " no"
                ;;
        h)
                show_manual
                ;;
        v)
                show_version
                ;;
        ?)
                show_manual
                exit 1
                ;;
    esac
done

#        nmcli con show $(nmcli con show | grep -Fv "NAME" | egrep -v "^lo" | awk '{print $1}')
#        for connection in $(nmcli con show | grep -Fv "NAME" | egrep -v "^lo" | awk '{print $1}'); do
#        echo "_____________________________________________________________________"
#        nmcli con show "$connection" | egrep "^connection.id|^connection.interface-name|^connection.autoconnect|^ipv4.method|^ipv4.addresses|^ipv4.gateway|^GENERAL|^IP4.|^bond.options|^connection.master|^connection.slave-type"
