import os

entries = []

# 4. Exact-boundary input (buffer_length = 12, SAFE, should NOT raise)
with open("corpus/04_boundary_exact_safe.bin", "wb") as f:
    f.write(b"A" * 12)
entries.append(("04_boundary_exact_safe.bin",
    "Exactly 12 bytes (Buffer_Type'Length in safe_bof.adb). This is the "
    "upper edge of the admissible length domain: Input'Length = "
    "Buffer'Length. Property: Buffer(1..12) := Input must succeed without "
    "raising Constraint_Error. Tests the non-strict boundary of the length "
    "precondition."))

# 5. One byte over the boundary (minimal overflow, should raise)
with open("corpus/05_boundary_plus1_overflow.bin", "wb") as f:
    f.write(b"A" * 13)
entries.append(("05_boundary_plus1_overflow.bin",
    "13 bytes -- exactly one byte past Buffer_Type'Length (12). The "
    "smallest possible violation of the length-domain property. In C this "
    "silently corrupts 1 byte of adjacent stack memory; in the Ada "
    "rewrite (E7) it deterministically raises Constraint_Error. Proves "
    "the property is checked at the boundary, not just for large inputs."))

# 6. Zero-length input (index-bound edge case)
with open("corpus/06_empty_input.bin", "wb") as f:
    f.write(b"")
entries.append(("06_empty_input.bin",
    "Zero-length input. Exercises the lower bound of the index/length "
    "domain (Input'Length = 0). In the original C bof(), strcpy of an "
    "empty string is technically safe, but any routine indexing "
    "Buffer(1..Input'Length) must handle the degenerate empty range "
    "correctly without an off-by-one index error."))

# 7. Maximum-size malicious input (full 517-byte E3 payload pattern)
with open("corpus/07_overflow_max_e3_pattern.bin", "wb") as f:
    f.write(b"\x90" * 300 + b"A" * 217)
entries.append(("07_overflow_max_e3_pattern.bin",
    "517-byte maximum-size input matching the fread() bound in stack.c's "
    "main() (char str[517]). NOP-sled pattern (300 bytes) plus filler "
    "representing the worst-case admissible C buffer read, before it is "
    "copied via strcpy() into the 12-byte local buffer. Demonstrates the "
    "largest-magnitude violation of the length-domain property."))

# 8. Partial/corrupted return-address overwrite (structural dangerous input)
with open("corpus/08_partial_retaddr_corruption.bin", "wb") as f:
    content = bytearray(b"A" * 12 + b"BBBB" + b"\xd8\xd1")  # only 2 of 4 ret bytes
    f.write(content)
entries.append(("08_partial_retaddr_corruption.bin",
    "18 bytes: fills buffer(12) + saved EBP(4) + only 2 of the 4 "
    "return-address bytes. Models a truncated/malformed overflow (e.g. a "
    "network read cut short, as could happen against the E9 server). "
    "Violates the buffer invariant at an intermediate point rather than "
    "fully; in Ada, Constraint_Error still fires at Input'Length > 12 "
    "before any partial corruption can occur, regardless of what later "
    "bytes contain."))

with open("corpus/README_INDEX.txt", "a") as f:
    for name, desc in entries:
        f.write(f"{name}: {desc}\n\n")

print("Added", len(entries), "documented boundary entries.")
