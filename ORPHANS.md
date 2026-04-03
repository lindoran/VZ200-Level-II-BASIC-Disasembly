# Orphaned Byte Ranges

| Address Range | Nature of Issue | Status |
|---------------|-----------------|--------|
| 010A - 010E   | Unused bytes before banner | open |
| 0191 - 019C   | Junk/Padding bytes | needs-user |
| 021A - 021C   | Table end padding | open |

## Decision Log

| Date | Address/Range | Decision | Approved By |
|------|---------------|----------|-------------|
| 2026-04-02 | 0191-019C | Flagged as DIRECT_BYTE/Junk as per user hint. | User |
| 2026-04-02 | 01D9-0219 | Keyboard Matrix identified. Added ASCII char comments. | AI (inferred) |
