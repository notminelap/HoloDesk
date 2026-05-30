# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 2.1.x   | ✅ Current |
| < 2.0   | ❌ Not supported |

## Reporting a Vulnerability

HoloDesk is a visionOS spatial computing application that runs entirely offline with zero network connectivity. The attack surface is minimal by design.

If you discover a security concern (e.g., unsafe data handling, privacy leak in spatial tracking, or unsafe memory access), please report it responsibly:

1. **Do NOT** open a public issue
2. Email: **radhesh.ranvijay@notminelap.com**
3. Include a detailed description and reproduction steps
4. Allow up to 72 hours for an initial response

## Security Design Principles

- **Zero Network Access** — No HTTP requests, no API calls, no telemetry
- **No Data Collection** — No analytics, no tracking, no user data leaves the device
- **On-Device AI** — All NLP processing runs locally via native frameworks
- **Minimal Permissions** — Only Camera (spatial scanning) and Microphone (voice commands) with explicit purpose strings
- **No Persistent Storage** — Workspace state is session-only, no sensitive data written to disk
