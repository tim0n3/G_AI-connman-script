# G_AI-connman-script

## Purpose of this script

This Bash script performs a TCP connection test to a specified IP address and port using various utilities such as `netcat`, `telnet`, and `nmap`. It also checks for required dependencies and logs the results to files for later analysis.

## Script Overview

- **Target IP**: `192.168.1.10`
- **Target Port**: `44818`
- **Log Files**: 
  - `YYYY-MM-DD_HH:MM:SS-tcp_connection_test.log` (General log)
  - `YYYY-MM-DD_HH:MM:SS-tcp_connection_test_error.log` (Error log)

## Dependencies

The script checks for the following dependencies:
- `nc` (netcat)
- `telnet`
- `nmap`

If any of these dependencies are missing, the script attempts to install them using `apt`.

## Usage

1. Make sure you have `bash` installed.
2. Ensure you have `sudo` privileges if dependencies need to be installed.
3. Execute the script using `./tcp_connection_test.sh`.

## Logging

- **General Log**: Contains all script execution details, including successful connections and any errors encountered.
- **Error Log**: Captures errors encountered during dependency checks, installation attempts, and connection tests.

## Output

After execution, the script provides:
- Connection status (success or failure) for `netcat`, `telnet`, and `nmap` tests.
- Detailed logs for each test and overall script execution.
- Timestamped log files for easy tracking and debugging.

## Troubleshooting

If the script fails:
- Check the error logs (`YYYY-MM-DD_HH:MM:SS-tcp_connection_test_error.log`) for specific error messages.
- Verify network connectivity and target device availability.
- Ensure dependencies are installed correctly and accessible.

