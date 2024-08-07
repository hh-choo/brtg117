#!/bin/bash
#LP is logpath
LP="/nfs/log/udp.log"
tcpdump -i eno2 udp -nnNS -tttt | awk '{
  if ($3 ~ />/) {
    src = $3
    dst = $5
  } else {
    src = $4
    dst = $6
  }
  gsub(":", "", src)
  gsub(":", "", dst)
  split(src, srcParts, ".")
  split(dst, dstParts, ".")
  srcIP = srcParts[1]"."srcParts[2]"."srcParts[3]"."srcParts[4]
  srcPort = srcParts[5]
  dstIP = dstParts[1]"."dstParts[2]"."dstParts[3]"."dstParts[4]
  dstPort = dstParts[5]
  print "<DATE> "$1, $2, "<SI> " srcIP, "<SP> " srcPort, "<DI> " dstIP, "<DP> " dstPort
}' >> $LP
