import os, shutil

os.makedirs("corpus", exist_ok=True)

entries = []

# 1. Real local Set-UID overflow (E3)
if os.path.exists("setuid/code/badfile"):
    shutil.copy("setuid/code/badfile", "corpus/01_overflow_local_setuid.bin")
    entries.append(("01_overflow_local_setuid.bin",
        "Local Set-UID buffer overflow (E3/T3). Overwrites the saved return "
        "address of bof() in stack.c with a NOP-sled + shellcode address, "
        "granting a root shell. Violates: admissible length domain of the "
        "input (str[] far exceeds buffer[] capacity) and the return-address "
        "integrity invariant."))

# 2. Real remote server overflow (E9)
if os.path.exists("server/attack-code/badfile"):
    shutil.copy("server/attack-code/badfile", "corpus/02_overflow_remote_server.bin")
    entries.append(("02_overflow_remote_server.bin",
        "Remote network buffer overflow against server-1 in Docker (E9/T8), "
        "517 bytes sent over TCP port 9090. Same violated invariant as #1 "
        "but exploited across a process boundary with no local file access, "
        "demonstrating the property violation is independent of delivery "
        "channel."))

with open("corpus/README_INDEX.txt", "w") as f:
    for name, desc in entries:
        f.write(f"{name}: {desc}\n\n")

print("Copied", len(entries), "real exploit entries.")
