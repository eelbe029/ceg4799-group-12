01_overflow_local_setuid.bin: Local Set-UID buffer overflow (E3/T3). Overwrites the saved return address of bof() in stack.c with a NOP-sled + shellcode address, granting a root shell. Violates: admissible length domain of the input (str[] far exceeds buffer[] capacity) and the return-address integrity invariant.

02_overflow_remote_server.bin: Remote network buffer overflow against server-1 in Docker (E9/T8), 517 bytes sent over TCP port 9090. Same violated invariant as #1 but exploited across a process boundary with no local file access, demonstrating the property violation is independent of delivery channel.

04_boundary_exact_safe.bin: Exactly 12 bytes (Buffer_Type'Length in safe_bof.adb). This is the upper edge of the admissible length domain: Input'Length = Buffer'Length. Property: Buffer(1..12) := Input must succeed without raising Constraint_Error. Tests the non-strict boundary of the length precondition.

05_boundary_plus1_overflow.bin: 13 bytes -- exactly one byte past Buffer_Type'Length (12). The smallest possible violation of the length-domain property. In C this silently corrupts 1 byte of adjacent stack memory; in the Ada rewrite (E7) it deterministically raises Constraint_Error. Proves the property is checked at the boundary, not just for large inputs.

06_empty_input.bin: Zero-length input. Exercises the lower bound of the index/length domain (Input'Length = 0). In the original C bof(), strcpy of an empty string is technically safe, but any routine indexing Buffer(1..Input'Length) must handle the degenerate empty range correctly without an off-by-one index error.

07_overflow_max_e3_pattern.bin: 517-byte maximum-size input matching the fread() bound in stack.c's main() (char str[517]). NOP-sled pattern (300 bytes) plus filler representing the worst-case admissible C buffer read, before it is copied via strcpy() into the 12-byte local buffer. Demonstrates the largest-magnitude violation of the length-domain property.

08_partial_retaddr_corruption.bin: 18 bytes: fills buffer(12) + saved EBP(4) + only 2 of the 4 return-address bytes. Models a truncated/malformed overflow (e.g. a network read cut short, as could happen against the E9 server). Violates the buffer invariant at an intermediate point rather than fully; in Ada, Constraint_Error still fires at Input'Length > 12 before any partial corruption can occur, regardless of what later bytes contain.

