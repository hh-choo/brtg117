#!/bin/bash

LOG_FILE="/nfs/log/data.log"
MAX_SIZE=10  # 10KB in kilobytes
BACKUP_DIR="/nfs/log"

echo "Checking log file: $LOG_FILE"
echo "Max size: $MAX_SIZE KB"

# Check if log file exists
if [ -f "$LOG_FILE" ]; then
    FILE_SIZE=$(du -sk "$LOG_FILE" | cut -f1)
    echo "File size: ${FILE_SIZE} KB"

    if [ $FILE_SIZE -ge $MAX_SIZE ]; then
        TIMESTAMP=$(date +"%Y%m%d%H%M%S")
        BACKUP_FILE="${BACKUP_DIR}/data_${TIMESTAMP}.tar.gz"
        
        echo "Rotating log file: $LOG_FILE"
        tar -czf "$BACKUP_FILE" "$LOG_FILE"
        > "$LOG_FILE"
        
        echo "Log file rotated: $BACKUP_FILE"
    else
        echo "Log file size is under the limit."
    fi
else
    echo "Log file does not exist."
fi
