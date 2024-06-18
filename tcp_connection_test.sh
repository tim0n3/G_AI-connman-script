#!/bin/bash

TARGET_IP="192.168.1.10"  
TARGET_PORT=44818
LOG_FILE="$(date +"%Y-%m-%d_%T")-tcp_connection_test.log"
ERROR_LOG_FILE="$(date +"%Y-%m-%d_%T")-tcp_connection_test_error.log"
DEPENDENCIES=("nc" "telnet" "nmap")

log_message() {
    echo "$1"
    echo "$1" >> "$LOG_FILE"
}

log_error() {
    echo "$1" >&2
    echo "$1" >> "$ERROR_LOG_FILE"
}

> "$LOG_FILE"
> "$ERROR_LOG_FILE"

log_message "Checking dependencies..."

for DEP in "${DEPENDENCIES[@]}"; do
    case $(command -v "$DEP" &> /dev/null; echo $?) in
        0)
            log_message "Dependency $DEP is already installed."
            ;;
        1)
            log_error "Dependency $DEP is not installed. Attempting to install..."
            if sudo apt-get install -y "$DEP" >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"; then
                log_message "$DEP installed successfully."
            else
                log_error "Failed to install $DEP. Please install it manually and rerun the script."
                exit 1
            fi
            ;;
    esac
done

log_message "Starting TCP connection test to $TARGET_IP on port $TARGET_PORT"
log_message "Timestamp: $(date)"
log_message "------------------------------------------"

log_message "Testing TCP connection using netcat..."

nc -vz "$TARGET_IP" "$TARGET_PORT" >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"
NC_STATUS=$?

case $NC_STATUS in
    0)
        log_message "TCP connection to $TARGET_IP on port $TARGET_PORT was successful."
        ;;
    *)
        log_message "TCP connection to $TARGET_IP on port $TARGET_PORT failed. Please check the network connection or the target device."
        ;;
esac

log_message "Collecting connection details using telnet..."
{
    echo "open $TARGET_IP $TARGET_PORT"
    sleep 2
    echo "quit"
} | telnet >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"

TELNET_STATUS=$?

case $TELNET_STATUS in
    0)
        log_message "Telnet connection to $TARGET_IP on port $TARGET_PORT was successful."
        ;;
    *)
        log_message "Telnet connection to $TARGET_IP on port $TARGET_PORT failed. Please check the network connection or the target device."
        ;;
esac

log_message "Gathering additional information using nmap..."
nmap -vv -p "$TARGET_PORT" "$TARGET_IP" >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"
NMAP_STATUS=$?

case $NMAP_STATUS in
    0)
        log_message "nmap scan completed successfully."
        ;;
    *)
        log_message "nmap scan failed. Please ensure nmap is installed correctly and the network connection is stable."
        ;;
esac

log_message "------------------------------------------"
log_message "TCP connection test completed."
log_message "Timestamp: $(date)"

log_message "The log file is saved as $LOG_FILE"
log_message "Any errors encountered are logged in $ERROR_LOG_FILE"

