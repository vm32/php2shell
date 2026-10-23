#!/bin/bash
# Terminal 1: Interactive Docker Shell with Real-time Monitoring

clear

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

cat << 'EOF'
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║      TERMINAL 1: Docker Container Interactive Shell          ║
║              (Real Docker Environment)                        ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF

echo ""
echo -e "${CYAN}Container:${NC} php2shell-test"
echo -e "${CYAN}Image:${NC}     php:8.3.12-apache (VULNERABLE)"
echo -e "${CYAN}Port:${NC}      8888 → 80"
echo ""

# Check container
if ! sudo docker ps | grep -q php2shell-test; then
    echo -e "${YELLOW}[*] Starting container...${NC}"
    sudo docker start php2shell-test 2>/dev/null || \
        sudo docker run -d --name php2shell-test -p 8888:80 php2shell-vuln:latest
    sleep 2
fi

echo -e "${GREEN}[✓] Container is running${NC}"
echo ""

# Create monitoring script inside container
echo -e "${YELLOW}[*] Setting up internal monitoring...${NC}"

sudo docker exec php2shell-test bash -c 'cat > /monitor.sh << "SCRIPT"
#!/bin/bash

# Colors for inside container
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
WHITE="\033[1;37m"
NC="\033[0m"

clear
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║           Inside Container: php2shell-test                    ║"
echo "║              Real-time System Monitor                         ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# System info
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${WHITE}Container System Information${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Hostname:${NC} $(hostname)"
echo -e "${YELLOW}User:${NC}     $(whoami)"
echo -e "${YELLOW}PHP:${NC}      $(php -v | head -1)"
echo -e "${YELLOW}Webserver:${NC} Apache $(apache2 -v | head -1 | cut -d/ -f2 | cut -d" " -f1)"
echo ""

# Flag
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${WHITE}Target Flag${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}Flag Location:${NC} /flag.txt"
echo -e "${GREEN}Flag Content:${NC} $(cat /flag.txt)"
echo ""

# PHP Configuration
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${WHITE}Vulnerable PHP Configuration${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
php -i | grep -E "session.upload_progress.enabled|session.upload_progress.cleanup|session.save_path|memory_limit|post_max_size" | sed "s/^/${YELLOW}/"
echo -e "${NC}"

# Session directory
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${WHITE}Session Storage${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Session Directory:${NC} /tmp/sessions"
echo -e "${YELLOW}Permissions:${NC}       $(ls -ld /tmp/sessions | awk "{print \$1, \$3, \$4}")"
echo -e "${YELLOW}Current Sessions:${NC}  $(ls /tmp/sessions 2>/dev/null | wc -l) files"
echo ""

# Apache processes
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${WHITE}Apache Worker Processes${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
ps aux | grep apache2 | grep -v grep | head -5 | awk "{print \"${YELLOW}PID \" \$2 \"${NC} - User: \" \$1 \" - \" \$11}"
echo ""

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}Starting Real-time Monitoring${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Monitoring:"
echo -e "  ${GREEN}✓${NC} Apache access/error logs"
echo -e "  ${GREEN}✓${NC} Session file creation"
echo -e "  ${GREEN}✓${NC} PHP errors and notices"
echo ""
echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
echo ""

# Monitor logs and session files
tail -f /var/log/apache2/access.log /var/log/apache2/error.log 2>/dev/null &
TAIL_PID=$!

# Watch session directory
while true; do
    # Check for new session files
    SESSIONS=$(ls -t /tmp/sessions/sess_* 2>/dev/null | head -1)
    if [ -n "$SESSIONS" ]; then
        LAST_SESSION=$(stat -c %Y "$SESSIONS" 2>/dev/null || stat -f %m "$SESSIONS" 2>/dev/null)
        CURRENT_TIME=$(date +%s)
        AGE=$((CURRENT_TIME - LAST_SESSION))
        
        if [ $AGE -lt 5 ]; then
            echo ""
            echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${MAGENTA}🔔 NEW SESSION FILE DETECTED${NC}"
            echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${YELLOW}File:${NC} $SESSIONS"
            echo -e "${YELLOW}Size:${NC} $(stat -c %s "$SESSIONS" 2>/dev/null || stat -f %z "$SESSIONS" 2>/dev/null) bytes"
            echo ""
            echo -e "${CYAN}Content (first 200 chars):${NC}"
            head -c 200 "$SESSIONS" 2>/dev/null | sed "s/^/  ${WHITE}/" | sed "s/$/${NC}/"
            echo ""
            echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo ""
        fi
    fi
    sleep 2
done

kill $TAIL_PID 2>/dev/null
SCRIPT
chmod +x /monitor.sh
'

echo -e "${GREEN}[✓] Monitor ready${NC}"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}Entering Docker Container Shell...${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
sleep 1

# Enter container with monitoring
sudo docker exec -it php2shell-test /monitor.sh
