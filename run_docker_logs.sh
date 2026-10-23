#!/bin/bash
# Terminal 1: Docker logs monitoring with visual enhancements

clear

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

cat << 'EOF'
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║         TERMINAL 1: Docker Container Logs Monitor            ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF

echo ""
echo -e "${CYAN}Container:${NC} php2shell-test"
echo -e "${CYAN}Image:${NC}     php:8.3.12-apache (VULNERABLE)"
echo -e "${CYAN}Port:${NC}      8888"
echo -e "${CYAN}Flag:${NC}      /flag.txt"
echo ""

# Check container status
echo -e "${YELLOW}[*] Checking container status...${NC}"
if sudo docker ps | grep -q php2shell-test; then
    echo -e "${GREEN}[✓] Container is RUNNING${NC}"
else
    echo -e "${RED}[✗] Container is NOT running${NC}"
    echo -e "${YELLOW}[*] Starting container...${NC}"
    sudo docker start php2shell-test 2>/dev/null || \
        sudo docker run -d --name php2shell-test -p 8888:80 php2shell-vuln:latest
    sleep 2
fi
echo ""

echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${WHITE}Monitoring logs for exploit activity...${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "Watch for:"
echo -e "  ${GREEN}✓${NC} Session write operations"
echo -e "  ${GREEN}✓${NC} Upload progress handler triggers"
echo -e "  ${GREEN}✓${NC} Gadget class loading"
echo -e "  ${GREEN}✓${NC} Pwn::__wakeup() execution"
echo -e "  ${GREEN}✓${NC} FLAG{...} output"
echo ""
echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Show last 5 lines first
echo -e "${BLUE}[Recent logs before monitoring:]${NC}"
sudo docker logs php2shell-test 2>&1 | tail -5 | sed 's/^/  /'
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}[LIVE LOGS - Starting now...]${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Follow logs with highlighting
sudo docker logs -f --tail 0 php2shell-test 2>&1 | while IFS= read -r line; do
    # Highlight important patterns
    if echo "$line" | grep -qi "pwn"; then
        echo -e "${MAGENTA}🎯 $line${NC}"
    elif echo "$line" | grep -qi "flag"; then
        echo -e "${GREEN}🏁 $line${NC}"
    elif echo "$line" | grep -qi "gadget"; then
        echo -e "${CYAN}⚙️  $line${NC}"
    elif echo "$line" | grep -qi "session"; then
        echo -e "${YELLOW}📝 $line${NC}"
    elif echo "$line" | grep -qi "error\|warning"; then
        echo -e "${RED}⚠️  $line${NC}"
    elif echo "$line" | grep -qi "upload"; then
        echo -e "${BLUE}📤 $line${NC}"
    else
        echo "   $line"
    fi
done
