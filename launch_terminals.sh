#!/bin/bash
# Launch both terminals side-by-side for CVE-2026-109618/109619 demonstration

clear
cat << 'EOF'
╔═══════════════════════════════════════════════════════════════════════════╗
║                                                                           ║
║              CVE-2026-109618 / CVE-2026-109619 Launcher                  ║
║                   Opening Two External Terminals                          ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝

This will open two terminal windows:

  🖥️  Terminal 1: Docker Container Logs (LEFT)
      - Real-time log monitoring
      - Shows session activity
      - Displays exploit evidence

  🎯 Terminal 2: Exploit Execution (RIGHT)
      - Runs the PoC attacks
      - Interactive demonstration
      - Step-by-step progression

Press Enter to launch both terminals...
EOF
read

# Detect available terminal emulator
if command -v gnome-terminal &> /dev/null; then
    TERM_CMD="gnome-terminal"
elif command -v xfce4-terminal &> /dev/null; then
    TERM_CMD="xfce4-terminal"
elif command -v konsole &> /dev/null; then
    TERM_CMD="konsole"
elif command -v xterm &> /dev/null; then
    TERM_CMD="xterm"
else
    echo "❌ No terminal emulator found!"
    echo "Please install: gnome-terminal, xfce4-terminal, konsole, or xterm"
    exit 1
fi

echo "✓ Using terminal: $TERM_CMD"
echo ""
echo "Launching terminals..."
sleep 1

WORKDIR="/home/kali/php2shell-testing"

# Launch Terminal 1 (Docker Logs) - Left side
if [ "$TERM_CMD" = "gnome-terminal" ]; then
    gnome-terminal --geometry=80x40+0+0 \
        --title="Terminal 1: Docker Logs Monitor" \
        -- bash -c "cd $WORKDIR && ./run_docker_logs.sh; exec bash" &
    
    sleep 1
    
    # Launch Terminal 2 (Exploit) - Right side
    gnome-terminal --geometry=80x40+700+0 \
        --title="Terminal 2: Exploit Execution" \
        -- bash -c "cd $WORKDIR && ./run_exploit_demo.sh; exec bash" &

elif [ "$TERM_CMD" = "xfce4-terminal" ]; then
    xfce4-terminal --geometry=80x40 \
        --title="Terminal 1: Docker Logs Monitor" \
        --command="bash -c 'cd $WORKDIR && ./run_docker_logs.sh; exec bash'" &
    
    sleep 1
    
    xfce4-terminal --geometry=80x40 \
        --title="Terminal 2: Exploit Execution" \
        --command="bash -c 'cd $WORKDIR && ./run_exploit_demo.sh; exec bash'" &

elif [ "$TERM_CMD" = "konsole" ]; then
    konsole --new-tab \
        --title "Terminal 1: Docker Logs Monitor" \
        -e bash -c "cd $WORKDIR && ./run_docker_logs.sh; exec bash" &
    
    sleep 1
    
    konsole --new-tab \
        --title "Terminal 2: Exploit Execution" \
        -e bash -c "cd $WORKDIR && ./run_exploit_demo.sh; exec bash" &

elif [ "$TERM_CMD" = "xterm" ]; then
    xterm -geometry 80x40+0+0 \
        -title "Terminal 1: Docker Logs Monitor" \
        -e bash -c "cd $WORKDIR && ./run_docker_logs.sh; exec bash" &
    
    sleep 1
    
    xterm -geometry 80x40+700+0 \
        -title "Terminal 2: Exploit Execution" \
        -e bash -c "cd $WORKDIR && ./run_exploit_demo.sh; exec bash" &
fi

echo ""
echo "✅ Both terminals launched!"
echo ""
echo "Terminal 1 (LEFT):  Docker container logs monitor"
echo "Terminal 2 (RIGHT): Exploit execution and testing"
echo ""
echo "Watch Terminal 1 for real-time log activity while Terminal 2 runs exploits."
echo ""
