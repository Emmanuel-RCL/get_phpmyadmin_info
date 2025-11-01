# 🧩 Retrieve phpMyAdmin Credentials Script

A lightweight Bash utility to **extract phpMyAdmin credentials** from a `.env` file and print a ready-to-use login URL.  
Designed for quick administrative use on Linux servers.

---

## 🚀 Features

- Reads `MYSQL_ROOT_PASSWORD` (supports `export`, single/double quotes)  
- Detects a server IPv4 address automatically (no external web services by default)  
- Prints phpMyAdmin **username**, **password**, and **login URL**  
- Colorful terminal output for readability  
- Basic checks for missing files/variables and file permission warnings

---

## 📦 Installation

Clone the repository and make the script executable:

```bash
wget https://raw.githubusercontent.com/Emmanuel-RCL/get_phpmyadmin_info/main/get_phpmyadmin_info.sh
```
```bash
chmod +x get_phpmyadmin_info.sh
```
```bash
./get_phpmyadmin_info.sh
```
