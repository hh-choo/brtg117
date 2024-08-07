#!/bin/bash

TCP_LOG_FILE="/nfs/log/tcp.log"
UDP_LOG_FILE="/nfs/log/udp.log"
MAX_SIZE=10  # 10KB in kilobytes
BACKUP_DIR="/nfs/log"

echo "Checking log file: $LOG_FILE"
echo "Max size: $MAX_SIZE KB"

# Check if tcp log file exists
if [ -f "$TCP_LOG_FILE" ]; then
    FILE_SIZE=$(du -sk "$TCP_LOG_FILE" | cut -f1)
    echo "File size: ${FILE_SIZE} KB"

    if [ $FILE_SIZE -ge $MAX_SIZE ]; then
        TIMESTAMP=$(date +"%Y%m%d%H%M%S")
        BACKUP_FILE="${BACKUP_DIR}/${TIMESTAMP}_TCP.tar.gz"
        
        echo "Rotating log file: $TCP_LOG_FILE"
        tar -czf "$BACKUP_FILE" "$TCP_LOG_FILE"
        > "TCP_LOG_FILE"
        
        echo "Log file rotated: $BACKUP_FILE"
    else
        echo "Log file size is under the limit."
    fi
else
    echo "Log file does not exist."
fi

# Check if udp log file exists
if [ -f "$UDP_LOG_FILE" ]; then
    FILE_SIZE=$(du -sk "$UDP_LOG_FILE" | cut -f1)
    echo "File size: ${FILE_SIZE} KB"

    if [ $FILE_SIZE -ge $MAX_SIZE ]; then
        TIMESTAMP=$(date +"%Y%m%d%H%M%S")
        BACKUP_FILE="${BACKUP_DIR}/${TIMESTAMP}_UDP.tar.gz"
        
        echo "Rotating log file: $UDP_LOG_FILE"
        tar -czf "$BACKUP_FILE" "$UDP_LOG_FILE"
        > "TCP_LOG_FILE"
        
        echo "Log file rotated: $BACKUP_FILE"
    else
        echo "Log file size is under the limit."
    fi
else
    echo "Log file does not exist."
fi
