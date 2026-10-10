#!/bin/bash
# Replays every corpus entry against the FIXED program.
# Success = /tmp/CORPUS_PROOF is never created.
cd "$(dirname "$0")/../Labsetup" || exit 1
P=./catall_fixed
T=/tmp/CORPUS_PROOF
rm -f $T
echo hello > /tmp/t.txt
mkdir -p /tmp/evil
printf '#!/bin/sh\n/usr/bin/touch /tmp/CORPUS_PROOF\n' > /tmp/evil/cat
chmod +x /tmp/evil/cat

echo "C1"; $P "/dev/null; /usr/bin/touch $T"
echo "C2"; $P "/dev/null && /usr/bin/touch $T"
echo "C3"; $P "/dev/null | /usr/bin/touch $T"
echo "C4"; $P "\$(/usr/bin/touch $T)"
echo "C5"; $P "\`/usr/bin/touch $T\`"
echo "C6"; $P $'/dev/null\n/usr/bin/touch '"$T"
echo "C7"; PATH=/tmp/evil:$PATH $P /tmp/t.txt
echo "C8"; IFS=/ $P /tmp/t.txt
echo "C9"; LD_PRELOAD=/tmp/evil.so $P /tmp/t.txt

if [ -e $T ]; then echo "RESULT: FAIL, proof file exists"; else echo "RESULT: PASS, all inputs inert"; fi
