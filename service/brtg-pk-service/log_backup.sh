#!/bin/bash

TCP_LOG_FILE="/nfs/log/tcp.log"
UDP_LOG_FILE="/nfs/log/udp.log"
MAX_SIZE=10  # 10KB in kilobytes
BACKUP_DIR="/nfs/log"

rotate_log_file() {
    local LOG_FILE=$1
    local LOG_TYPE=$2

    echo "Checking log file: $LOG_FILE"
    echo "Max size: $MAX_SIZE KB"

    if [ -f "$LOG_FILE" ]; then
        FILE_SIZE=$(du -sk "$LOG_FILE" | cut -f1)
        echo "File size: ${FILE_SIZE} KB"

        if [ $FILE_SIZE -ge $MAX_SIZE ]; then
            TIMESTAMP=$(date +"%Y%m%d%H%M%S")
            BACKUP_FILE="${BACKUP_DIR}/${TIMESTAMP}_${LOG_TYPE}.tar.gz"
            
            echo "Rotating log file: $LOG_FILE"
            tar -czf "$BACKUP_FILE" "$LOG_FILE"
            : > "$LOG_FILE"  # Correctly truncate the log file
            
            echo "Log file rotated and truncated: $BACKUP_FILE"
        else
            echo "Log file size is under the limit."
        fi
    else
        echo "Log file does not exist."
    fi
}

rotate_log_file "$TCP_LOG_FILE" "TCP"
rotate_log_file "$UDP_LOG_FILE" "UDP"
