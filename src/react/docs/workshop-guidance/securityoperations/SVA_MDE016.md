# Turn on network protection

**Implementation Effort:** High: Enabling network protection requires configuring endpoint security policies and potentially updating the Microsoft Defender anti-malware platform, which involves ongoing management and resource commitment.

**User Impact:** Medium: A subset of non-privileged users may need to be notified or take action, especially if network protection settings affect their ability to access certain domains or applications.

## Overview
Network protection in Microsoft Defender for Endpoint helps prevent access to dangerous domains that might host phishing scams, exploits, and other malicious content. It can be enabled through various methods, including endpoint security policies and PowerShell commands, fitting into the Zero Trust framework by ensuring that only safe and verified network connections are allowed.

## Reference
[Turn on network protection - Microsoft Defender for Endpoint](https://learn.microsoft.com/en-us/defender-endpoint/enable-network-protection)
