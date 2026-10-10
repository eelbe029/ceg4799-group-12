#!/bin/bash
set -euo pipefail

# T7: replay both E6 attack classes against the fixed program.
root_dir=$(cd "$(dirname "$0")/.." && pwd)
lab_dir="$root_dir/Labsetup"
work_dir=$(mktemp -d /tmp/lab1-t7.XXXXXX)
trap 'rm -rf "$work_dir"' EXIT
injection_proof="$work_dir/injection-proof"

cat > "$work_dir/id" <<EOF
#!/bin/sh
touch "$work_dir/path-proof"
EOF
chmod 755 "$work_dir/id"

echo "=== Rejeu injection de commande (E6a) ==="
"$lab_dir/catall_fixed" "/dev/null; /usr/bin/id -u; /usr/bin/id -ru; /usr/bin/touch $injection_proof" || true
if [[ -e "$injection_proof" ]]; then
    echo "FAIL: E6a proof file exists" >&2
    exit 1
fi
echo "PASS: E6a payload was treated as one filename"

echo "=== Rejeu détournement PATH (E6b) ==="
PATH="$work_dir:/usr/bin:/bin" "$lab_dir/catall_fixed" /dev/null
if [[ -e "$work_dir/path-proof" ]]; then
    echo "FAIL: PATH substitution occurred" >&2
    exit 1
fi
echo "PASS: PATH substitution had no effect"
