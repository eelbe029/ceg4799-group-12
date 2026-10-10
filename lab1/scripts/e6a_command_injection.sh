#!/bin/bash
rm -f /tmp/E6A_PROOF
cd "$(dirname "$0")/../Labsetup" || exit 1
./catall_e6a '/dev/null; /usr/bin/id -u; /usr/bin/id -ru; /usr/bin/touch /tmp/E6A_PROOF'
ls -l /tmp/E6A_PROOF
