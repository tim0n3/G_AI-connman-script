#!/bin/bash

TARGET_IP="192.168.88.250"
TARGET_PORT=443
LOG_FILE="$(date +"%Y-%m-%d_%T")-tcp_connection_test.log"
ERROR_LOG_FILE="$(date +"%Y-%m-%d_%T")-tcp_connection_test_error.log"
DEPENDENCIES=("nc" "telnet" "nmap" "ping" "openssl")

log_message() {
    echo "$1"
    echo "$1" >> "$LOG_FILE"
}

log_error() {
    echo "$1" >&2
    echo "$1" >> "$ERROR_LOG_FILE"
}

check_and_install_dependency() {
    local DEP="$1"
    local DEP_RETRIES=3

    declare -A PKG_MANAGERS=(
        [apt-get]="sudo apt-get install -y"
        [yum]="sudo yum install -y"
        [dnf]="sudo dnf install -y"
    )

    for PM in "${!PKG_MANAGERS[@]}"; do
        if command -v "$PM" &>/dev/null; then
            INSTALL_CMD="${PKG_MANAGERS[$PM]}"
            break
        fi
    done

    if [ -z "$INSTALL_CMD" ]; then
        log_error "No supported package manager found for $DEP. Please install it manually."
        exit 1
    fi

    while (( DEP_RETRIES > 0 )); do
        if command -v "$DEP" &>/dev/null; then
            log_message "Dependency $DEP is already installed."
            return 0
        fi

        log_error "Dependency $DEP is not installed. Attempting to install..."

        if $INSTALL_CMD "$DEP" >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"; then
            log_message "$DEP installed successfully."
            return 0
        else
            log_error "Failed to install $DEP using $INSTALL_CMD. Retrying... ($DEP_RETRIES attempts left)"
            (( DEP_RETRIES-- ))
        fi
    done

    log_error "Failed to install $DEP after multiple attempts. Please install it manually and rerun the script."
    exit 1
}

retry_command() {
    local CMD="$1"
    local RETRIES="$2"
    local DELAY="$3"

    for (( i=1; i<=RETRIES; i++ )); do
        if eval "$CMD"; then
            return 0
        else
            log_error "Attempt $i failed. Retrying in $DELAY seconds..."
            sleep "$DELAY"
        fi
    done
    return 1
}

> "$LOG_FILE"
> "$ERROR_LOG_FILE"

log_message "Checking dependencies..."
for DEP in "${DEPENDENCIES[@]}"; do
    check_and_install_dependency "$DEP"
done

log_message "Starting enhanced OSI troubleshooting to $TARGET_IP on port $TARGET_PORT"
log_message "Timestamp: $(date)"
log_message "------------------------------------------"

# Layer 1: Physical Connectivity
log_message "Testing network connectivity with ping..."
PING_CMD="ping -c 4 -W 2 $TARGET_IP >> $LOG_FILE 2>> $ERROR_LOG_FILE"
if retry_command "$PING_CMD" 3 1; then
    PING_SUCCESS=true
    log_message "Ping to $TARGET_IP successful. Network connectivity confirmed."
else
    PING_SUCCESS=false
    log_error "Ping to $TARGET_IP failed after multiple attempts. Please check physical connections or routing."
    exit 1
fi

# Layer 2: Data Link Layer
log_message "Checking MAC address resolution using ip neigh..."
ARP_ENTRY=$(ip neigh show | grep -w "$TARGET_IP")
if [ -n "$ARP_ENTRY" ]; then
    MAC_SUCCESS=true
    log_message "MAC address for $TARGET_IP resolved: $ARP_ENTRY"
else
    MAC_SUCCESS=false
    log_error "No entry found for $TARGET_IP in ip neighbor table. There may be a Layer 2 issue."
    exit 1
fi

# Layer 3: Network Layer
log_message "Validating IP reachability with nmap ping scan..."
nmap -sn "$TARGET_IP" >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"
NMAP_SN_STATUS=$?
if [ $NMAP_SN_STATUS -eq 0 ]; then
    NMAP_SUCCESS=true
    log_message "nmap ping scan to $TARGET_IP successful."
else
    NMAP_SUCCESS=false
    log_error "nmap ping scan to $TARGET_IP failed. Check Layer 3 configuration."
    exit 1
fi

# Layer 4: Transport Layer
log_message "Testing TCP connection using netcat..."
nc -vz "$TARGET_IP" "$TARGET_PORT" >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"
NC_STATUS=$?
if [ $NC_STATUS -eq 0 ]; then
    TCP_SUCCESS=true
    log_message "TCP connection to $TARGET_IP on port $TARGET_PORT was successful."
else
    TCP_SUCCESS=false
    log_error "TCP connection to $TARGET_IP on port $TARGET_PORT failed."
fi

# Layer 5: Session Layer
log_message "Testing session establishment using telnet..."
{
    echo "open $TARGET_IP $TARGET_PORT"
    sleep 2
    echo "quit"
} | telnet >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"
TELNET_STATUS=$?
if [ $TELNET_STATUS -eq 0 ]; then
    TELNET_SUCCESS=true
    log_message "Telnet connection to $TARGET_IP on port $TARGET_PORT was successful."
else
    TELNET_SUCCESS=false
    log_error "Telnet connection to $TARGET_IP on port $TARGET_PORT failed."
fi

# Layer 6: Presentation Layer
log_message "Checking SSL/TLS configuration using OpenSSL..."
if command -v openssl &>/dev/null; then
    echo | timeout 10 openssl s_client -connect "$TARGET_IP:$TARGET_PORT" -servername "$TARGET_IP" >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"
    OPENSSL_STATUS=$?
    if [ $OPENSSL_STATUS -eq 0 ]; then
        SSL_SUCCESS=true
        log_message "SSL/TLS handshake with $TARGET_IP on port $TARGET_PORT was successful."
    elif [ $OPENSSL_STATUS -eq 124 ]; then
        SSL_SUCCESS=false
        log_error "SSL/TLS handshake timed out after 10 seconds. Please investigate connectivity or server responsiveness."
    else
        SSL_SUCCESS=false
        log_error "SSL/TLS handshake with $TARGET_IP on port $TARGET_PORT failed with error code $OPENSSL_STATUS."
    fi
else
    SSL_SUCCESS=false
    log_error "OpenSSL is not installed or not available. Skipping SSL/TLS check."
fi

# Layer 7: Application Layer
log_message "Gathering service information using nmap with detailed port scanning and script checks..."
nmap -vv -Pn --reason --script=banner,http-title -p "$TARGET_PORT" "$TARGET_IP" >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"
NMAP_STATUS=$?
if [ $NMAP_STATUS -eq 0 ]; then
    APP_SUCCESS=true
    PORT_STATUS=$(grep "$TARGET_PORT/tcp" "$LOG_FILE" | awk '{print $2}')
    case "$PORT_STATUS" in
        "")
            log_error "No port status found in nmap output. Output format may have changed or the port is not present. Logging raw nmap output."
            grep -A 10 "$TARGET_PORT/tcp" "$LOG_FILE" >> "$ERROR_LOG_FILE"
            ;;
        "open")
            log_message "Port $TARGET_PORT is open."
            ;;
        *)
            log_error "Port $TARGET_PORT appears to be $PORT_STATUS."
            ;;
    esac
else
    APP_SUCCESS=false
    log_error "nmap scan failed."
fi

log_message "------------------------------------------"
log_message "Enhanced OSI troubleshooting completed."
log_message "Timestamp: $(date)"
log_message "Log file saved as $LOG_FILE"
log_message "Error log file saved as $ERROR_LOG_FILE"

# Generate Report
REPORT_FILE="$(date +"%Y-%m-%d_%T")-OSI_Report.txt"
{
    echo "========================================"
    echo "      OSI Layer Connection Report       "
    echo "========================================"
    declare -A LAYER_RESULTS=(
        ["Layer 1 (Physical)"]=$PING_SUCCESS
        ["Layer 2 (Data Link)"]=$MAC_SUCCESS
        ["Layer 3 (Network)"]=$NMAP_SUCCESS
        ["Layer 4 (Transport)"]=$TCP_SUCCESS
        ["Layer 5 (Session)"]=$TELNET_SUCCESS
        ["Layer 6 (Presentation)"]=$SSL_SUCCESS
        ["Layer 7 (Application)"]=$APP_SUCCESS
    )

    for LAYER in "Layer 1 (Physical)" "Layer 2 (Data Link)" "Layer 3 (Network)" "Layer 4 (Transport)" "Layer 5 (Session)" "Layer 6 (Presentation)" "Layer 7 (Application)"; do
        RESULT="Failure"
        if [ "${LAYER_RESULTS[$LAYER]}" = true ]; then
            RESULT="Success"
        fi
        echo "$LAYER: $RESULT"
    done

    echo "========================================"
    echo "Detailed logs available in: $LOG_FILE"
    echo "Error logs available in: $ERROR_LOG_FILE"
} > "$REPORT_FILE"

log_message "Report generated: $REPORT_FILE"

# Display Report Content
echo "\n=============================="
echo " OSI Layer Connection Report "
echo "=============================="
cat "$REPORT_FILE"
echo "=============================="
