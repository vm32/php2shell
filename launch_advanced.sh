#!/bin/bash
# Launch advanced terminals with Docker internals and technical details

clear
cat << 'EOF'
╔═══════════════════════════════════════════════════════════════════════════╗
║                                                                           ║
║         CVE-2026-109618 / CVE-2026-109619 Advanced Launcher              ║
║              Real Docker Shell + Technical Exploit Details               ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝

This will open two ADVANCED terminal windows:

  🐳 Terminal 1 (LEFT):  Real Docker Container Shell
      • Inside container environment
      • Real-time file system monitoring
      • Session directory watcher
      • Apache logs streaming
      • System information display

  🔬 Terminal 2 (RIGHT): Technical Step-by-Step Exploit
      • Detailed technical breakdown
      • Slower execution with explanations
      • Serialization analysis
      • HTTP protocol details
      • Attack chain visualization
      • Complete CVE analysis

Press Enter to launch advanced terminals...
EOF
read

# Detect terminal
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
    exit 1
fi

echo "✓ Using terminal: $TERM_CMD"
echo ""
echo "Launching advanced terminals..."
sleep 1

WORKDIR="/home/kali/php2shell-testing"

# Launch Terminal 1 (Docker Interactive) - Left
if [ "$TERM_CMD" = "gnome-terminal" ]; then
    gnome-terminal --geometry=90x50+0+0 \
        --title="🐳 Docker Container Shell (Inside)" \
        -- bash -c "cd $WORKDIR && ./run_docker_interactive.sh; exec bash" &
    
    sleep 2
    
    # Launch Terminal 2 (Technical Exploit) - Right
    gnome-terminal --geometry=90x50+750+0 \
        --title="🔬 Technical Exploit (Detailed)" \
        -- bash -c "cd $WORKDIR && ./run_exploit_technical.sh; exec bash" &

elif [ "$TERM_CMD" = "xfce4-terminal" ]; then
    xfce4-terminal --geometry=90x50 \
        --title="🐳 Docker Container Shell (Inside)" \
        --command="bash -c 'cd $WORKDIR && ./run_docker_interactive.sh; exec bash'" &
    
    sleep 2
    
    xfce4-terminal --geometry=90x50 \
        --title="🔬 Technical Exploit (Detailed)" \
        --command="bash -c 'cd $WORKDIR && ./run_exploit_technical.sh; exec bash'" &

elif [ "$TERM_CMD" = "konsole" ]; then
    konsole --new-tab \
        --title "🐳 Docker Container Shell" \
        -e bash -c "cd $WORKDIR && ./run_docker_interactive.sh; exec bash" &
    
    sleep 2
    
    konsole --new-tab \
        --title "🔬 Technical Exploit" \
        -e bash -c "cd $WORKDIR && ./run_exploit_technical.sh; exec bash" &

elif [ "$TERM_CMD" = "xterm" ]; then
    xterm -geometry 90x50+0+0 -fa 'Monospace' -fs 10 \
        -title "🐳 Docker Container Shell (Inside)" \
        -e bash -c "cd $WORKDIR && ./run_docker_interactive.sh; exec bash" &
    
    sleep 2
    
    xterm -geometry 90x50+750+0 -fa 'Monospace' -fs 10 \
        -title "🔬 Technical Exploit (Detailed)" \
        -e bash -c "cd $WORKDIR && ./run_exploit_technical.sh; exec bash" &
fi

echo ""
echo "✅ Both advanced terminals launched!"
echo ""
echo "Terminal 1 (LEFT):  Real Docker container shell with monitoring"
echo "Terminal 2 (RIGHT): Technical step-by-step exploit (slower, detailed)"
echo ""
echo "💡 Terminal 2 advances step-by-step - press Enter to see each phase"
echo "💡 Terminal 1 shows real-time activity inside the container"
echo ""
echo "Watch both terminals together for complete technical understanding!"
echo ""
