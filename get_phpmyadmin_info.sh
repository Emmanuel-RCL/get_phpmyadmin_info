#!/bin/bash
# -----------------------------
# A simple script to find and display Pasarguard phpMyAdmin credentials.
# Author: Ali Habibpour
# Version: 2.2
# -----------------------------

ENV_FILE="/opt/pasarguard/.env"
PHPMYADMIN_PORT="8010"
DB_USER="root"

colorized_echo() {
    local color=$1
    local text=$2
    case $color in
    "red") printf "\e[91m%s\e[0m\n" "$text" ;;
    "green") printf "\e[92m%s\e[0m\n" "$text" ;;
    "yellow") printf "\e[93m%s\e[0m\n" "$text" ;;
    "blue") printf "\e[94m%s\e[0m\n" "$text" ;;
    "cyan") printf "\e[96m%s\e[0m\n" "$text" ;;
    *) echo "$text" ;;
    esac
}

# Clear screen for clean output
clear
colorized_echo blue "🔍 Searching for phpMyAdmin credentials..."

# Check .env exist
if [ ! -f "$ENV_FILE" ]; then
    colorized_echo red "❌ Error: .env file not found at $ENV_FILE"
    colorized_echo yellow "💡 Tip: Make sure Pasarguard is installed with MySQL/MariaDB."
    exit 1
fi

# Find password line
password_line=$(grep -E '^\s*(export\s+)?MYSQL_ROOT_PASSWORD\s*=' "$ENV_FILE" | tail -n1 || true)
if [ -z "$password_line" ]; then
    colorized_echo red "❌ Error: MYSQL_ROOT_PASSWORD not found in .env file."
    colorized_echo yellow "💡 You might be using SQLite or PostgreSQL instead."
    exit 1
fi

# Extract password value (support quotes)
raw_value=$(echo "$password_line" | sed -E 's/^\s*(export\s+)?MYSQL_ROOT_PASSWORD\s*=\s*//I')
DB_PASSWORD=$(printf "%s" "$raw_value" | sed -E "s/^\s*['\"]?(.*)['\"]?\s*$/\1/")

if [ -z "$DB_PASSWORD" ]; then
    colorized_echo yellow "⚠️ Warning: MYSQL_ROOT_PASSWORD appears empty."
fi

# -------------------------
# Robust server IP detection
# -------------------------
colorized_echo blue "🌐 Detecting server IP (robust)..."

candidate=""

# 1) prefer ip route (doesn't require external network service)
if command -v ip >/dev/null 2>&1; then
    candidate=$(ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src") {print $(i+1); exit}}' || true)
fi

# 2) fallback to hostname -I (local interfaces)
if [ -z "$candidate" ]; then
    candidate=$(hostname -I 2>/dev/null | awk '{print $1}' || true)
fi

# 3) last-resort: try common metadata endpoint only if explicitly available (commented out by default)
# NOTE: disabled to avoid external requests / HTML responses. Uncomment if you really want it.
# if [ -z "$candidate" ] && command -v curl >/dev/null 2>&1; then
#     candidate=$(curl -s -4 ifconfig.me 2>/dev/null || true)
# fi

# sanitize candidate: accept only IPv4-like patterns (simple check)
# allow: 0-255.0-255.0-255.0-255 (we use a permissive regex, not full strict validation)
if [ -n "$candidate" ]; then
    # trim whitespace
    candidate=$(printf "%s" "$candidate" | tr -d '[:space:]')
    # reject if contains '<' or HTML-like content or letters
    if printf "%s" "$candidate" | grep -Eq '[A-Za-z<>&]'; then
        candidate=""
    else
        # basic IPv4 pattern match
        if ! printf "%s" "$candidate" | grep -Eq '^([0-9]{1,3}\.){3}[0-9]{1,3}$'; then
            candidate=""
        fi
    fi
fi

if [ -z "$candidate" ]; then
    colorized_echo yellow "⚠️ Could not auto-detect a valid IPv4 address."
    server_ip="YOUR_SERVER_IP"
else
    server_ip="$candidate"
fi

# Final display (clear screen first)
clear
echo
colorized_echo green "=============================="
colorized_echo green "     phpMyAdmin Credentials"
colorized_echo green "=============================="
echo
colorized_echo cyan "Username : $DB_USER"
colorized_echo cyan "Password : $DB_PASSWORD"
echo
colorized_echo yellow "Login URL: http://$server_ip:$PHPMYADMIN_PORT"
echo
colorized_echo green "=============================="
colorized_echo blue "✅ Done! Use the credentials above to log in."
echo
