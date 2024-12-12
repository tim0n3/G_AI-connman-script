# G_AI-connman-script
# Enhanced TCP Connection Testing Script

## Overview

This script is a comprehensive tool for diagnosing network issues by evaluating connectivity across all layers of the OSI model. It checks everything from basic physical connectivity (Layer 1) to application-level interactions (Layer 7), providing detailed feedback and logs for troubleshooting.

## Features

- **Layer 1**: Tests physical connectivity using `ping`.
- **Layer 2**: Resolves MAC address using `ip neigh`.
- **Layer 3**: Validates IP reachability with `nmap`.
- **Layer 4**: Tests TCP connection with `netcat`.
- **Layer 5**: Establishes session via `telnet`.
- **Layer 6**: Evaluates SSL/TLS configuration with `openssl`.
- **Layer 7**: Performs application-level checks using `nmap` scripts.
- **Logging**: Generates detailed logs and error reports.

## Requirements

- Supported operating systems: Linux-based systems
- Dependencies:
  - `ping`
  - `ip`
  - `nmap`
  - `nc` (netcat)
  - `telnet`
  - `openssl`

Ensure these dependencies are installed before running the script.

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/tim0n3/G_AI-connman-script.git
   cd G_AI-connman-script
   ```
2. Make the script executable:
   ```bash
   chmod +x osi_connection_test.sh
   ```

## Usage

1. Edit the `TARGET_IP` and `TARGET_PORT` variables in the script to match the target host and port.
2. Run the script:
   ```bash
   ./osi_connection_test.sh
   ```
3. View the generated log files for detailed analysis:
   - Connection status: `*-tcp_connection_test.log`
   - Errors: `*-tcp_connection_test_error.log`
   - OSI layer report: `*-OSI_Report.txt`

## Disclaimer

This script is provided "AS IS" without any warranty of any kind. By using this script, you agree to the following:

- The author is not responsible for any damage, breakage, or disruptions caused by running this script.
- Use this script at your own risk.

## License

This project is licensed under the GNU General Public License v3.0. See the [LICENSE](LICENSE) file for details.

## Contributions

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/tim0n3/G_AI-connman-script/issues) to report a bug or request a feature.

---

Thank you for using this script! If you find it helpful, consider giving the repository a ⭐.
