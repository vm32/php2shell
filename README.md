# php2shell - CVE-2026-109618 & CVE-2026-109619 Testing Environment

Vulnerable PHP 8.3.12 Docker environment for testing php2shell session poisoning RCE vulnerabilities.

## Quick Start

```bash
# Build vulnerable container
docker build -t php2shell-vuln .
docker run -d -p 8888:80 --name php2shell-test php2shell-vuln

# Add flag
docker exec php2shell-test bash -c 'echo "FLAG{php2shell_CVE_2026_109618_109619_pwned_successfully}" > /flag.txt'

# Launch dual-terminal demonstration
./launch_advanced.sh
```

## What's Inside

- **Dockerfile**: PHP 8.3.12-apache with vulnerable session upload progress handler
- **Exploit Scripts**: Multiple PoC variants (exploit.py, final_exploit.py)
- **Live Demos**: Interactive terminal demonstrations with real-time Docker monitoring
- **Documentation**: Step-by-step guides for exploitation techniques

## Vulnerabilities

- **CVE-2026-109618**: RCE via OOM bailout state corruption
- **CVE-2026-109619**: RCE via stale global state in session upload progress handler

## Attack Vector

1. Poison session data with serialized PHP object
2. Trigger memory exhaustion via upload progress
3. Exploit OOM bailout + stale session state
4. Execute arbitrary PHP code

## Documentation

- `QUICKSTART.md` - Fast setup guide
- `ADVANCED_GUIDE.md` - Detailed technical walkthrough
- `STEP_BY_STEP_GUIDE.md` - Complete exploitation guide

## Requirements

- Docker
- Python 3.x with requests module
- xfce4-terminal (for live demos)

## Disclaimer

**For authorized security testing only.** These vulnerabilities affect PHP < 8.3.36.