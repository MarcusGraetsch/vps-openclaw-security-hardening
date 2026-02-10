#!/bin/bash
# Critical Security Alerting for OpenClaw
# Usage: ./critical-alert.sh <severity> <event> <details>
# Or pipe from ausearch: ausearch -ts today -k agent_credentials | ./critical-alert.sh

set -euo pipefail

# Configuration
CONFIG_FILE="$(dirname "$0")/../config/alerting.env"

# Load config if exists
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
fi

# Default values (fallback)
TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-}"
TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID:-}"
ALERT_LEVEL="${ALERT_LEVEL:-critical}"

# Icons
ICON_CRITICAL="🚨"
ICON_WARNING="⚠️"
ICON_INFO="ℹ️"

log_local() {
    local msg="$1"
    local logfile="/var/log/agent-security-alerts.log"
    echo "[$(date -Iseconds)] $msg" >> "$logfile"
}

send_telegram() {
    local message="$1"
    
    if [[ -z "$TELEGRAM_BOT_TOKEN" || -z "$TELEGRAM_CHAT_ID" ]]; then
        log_local "Telegram not configured, logging locally only"
        echo "$message" >> /var/log/agent-security-alerts.log
        return 1
    fi
    
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        -d "chat_id=${TELEGRAM_CHAT_ID}" \
        -d "parse_mode=Markdown" \
        -d "text=${message}" \
        --max-time 10 \
        > /dev/null 2>&1 || {
        log_local "Failed to send Telegram alert"
        return 1
    }
}

format_alert() {
    local severity="$1"
    local event="$2"
    local details="${3:-}"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S CET')
    
    local icon="$ICON_INFO"
    [[ "$severity" == "WARNING" ]] && icon="$ICON_WARNING"
    [[ "$severity" == "CRITICAL" ]] && icon="$ICON_CRITICAL"
    
    cat <> EOF
${icon} *SECURITY ALERT: ${severity}*

*Event:* ${event}
*Time:* ${timestamp}
*Host:* $(hostname)

${details}

*Action Required:*
Check logs: \`ausearch -ts today -k agent_${event// /_} | tail -20\`

_Agent Security Monitor_
EOF
}

# Main alerting logic
main() {
    # Check if piped input
    if [[ ! -t 0 ]]; then
        # Process piped audit events
        local event_data
        event_data=$(cat)
        
        # Parse audit event (simplified)
        if echo "$event_data" | grep -q "type=PATH.*name=.*\.env"; then
            send_telegram "$(format_alert "CRITICAL" "Credential Access" "\`\`\`$(echo "$event_data" | head -5)\`\`\`")"
        elif echo "$event_data" | grep -q "type=PATH.*sshd_config"; then
            send_telegram "$(format_alert "CRITICAL" "SSH Config Modified" "\`\`\`$(echo "$event_data" | head -5)\`\`\`")"
        elif echo "$event_data" | grep -q "type=SYSCALL.*setuid"; then
            send_telegram "$(format_alert "WARNING" "Privilege Escalation" "\`\`\`$(echo "$event_data" | head -5)\`\`\`")"
        fi
        
        exit 0
    fi
    
    # CLI usage
    if [[ $# -lt 2 ]]; then
        echo "Usage: $0 <severity> <event> [details]"
        echo "   or: ausearch -ts today -k agent_credentials | $0"
        exit 1
    fi
    
    local severity="$1"
    local event="$2"
    local details="${3:-No additional details}"
    
    # Filter by configured level
    if [[ "$ALERT_LEVEL" == "critical" && "$severity" != "CRITICAL" ]]; then
        log_local "Filtered: $severity $event (level=$ALERT_LEVEL)"
        exit 0
    fi
    
    local message
    message=$(format_alert "$severity" "$event" "$details")
    
    send_telegram "$message"
    log_local "Alert sent: $severity $event"
}

# Example usage
if [[ "${1:-}" == "--test" ]]; then
    echo "Testing alert system..."
    TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-test}"
    TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID:-test}"
    format_alert "CRITICAL" "Test Alert" "This is a test of the agent security alerting system."
    exit 0
fi

main "$@"
