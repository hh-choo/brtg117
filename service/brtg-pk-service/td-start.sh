#!/bin/bash
/usr/local/bin/td-udp.sh &
/usr/local/bin/td-tcp.sh &
wait
