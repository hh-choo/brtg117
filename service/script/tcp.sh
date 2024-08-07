#!/bin/bash

INTERFACE="ens7"
LOG_FILE="/nfs/log/data.log"

tshark -i $INTERFACE -l -T fields -e frame.time -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport -e udp.srcport -e udp.dstport -e ip.proto | awk 'BEGIN {OFS="\t"} {
    time = $1 " " $2 " " $3 " " $4 " " $5
    srcIP = $6
    dstIP = $7
    srcPort = ($8 != "" ? $8 : $10)
    dstPort = ($9 != "" ? $9 : $11)
    printf "time: %s srcIP: %s dstIP: %s srcPort: %s dstPort: %s\n", time, srcIP, dstIP, srcPort, dstPort
}' >> $LOG_FILE
