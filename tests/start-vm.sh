#!/bin/bash
# Boots a fresh cloud image as a virtual machine and waits until root can log
# in over SSH on 127.0.0.1:2222 with the key tests/vm/key.
#
#   tests/start-vm.sh <debian-12|debian-13|ubuntu-22.04|ubuntu-24.04|ubuntu-26.04>
set -euo pipefail

os="$1"
dir="$(cd "$(dirname "$0")" && pwd)/vm"
mkdir -p "${dir}"

case "${os}" in
    debian-12)  url="https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2" ;;
    debian-13)  url="https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2" ;;
    ubuntu-*)   url="https://cloud-images.ubuntu.com/releases/${os#ubuntu-}/release/ubuntu-${os#ubuntu-}-server-cloudimg-amd64.img" ;;
    *)          echo "Unknown system: ${os}" >&2; exit 2 ;;
esac

echo "== Download ${url}"
curl -fsSL --retry 3 -o "${dir}/base.img" "${url}"
qemu-img create -q -f qcow2 -b "${dir}/base.img" -F qcow2 "${dir}/disk.qcow2" 12G

ssh-keygen -q -t ed25519 -N '' -f "${dir}/key"
cat > "${dir}/user-data" <<CONFIG
#cloud-config
disable_root: false
ssh_pwauth: false
users:
  - name: root
    ssh_authorized_keys:
      - $(cat "${dir}/key.pub")
CONFIG
printf 'instance-id: test-%s\nlocal-hostname: target\n' "${os}" > "${dir}/meta-data"
cloud-localds "${dir}/seed.img" "${dir}/user-data" "${dir}/meta-data"

echo "== Boot"
sudo qemu-system-x86_64 -enable-kvm -cpu host -m 2048 -smp 2 \
    -drive "file=${dir}/disk.qcow2,if=virtio" \
    -drive "file=${dir}/seed.img,if=virtio,format=raw" \
    -netdev user,id=net0,ipv6=off,hostfwd=tcp:127.0.0.1:2222-:22 -device virtio-net-pci,netdev=net0 \
    -display none -serial "file:${dir}/serial.log" -daemonize

ssh_vm() {
    ssh -i "${dir}/key" -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
        -o LogLevel=ERROR -o ConnectTimeout=5 root@127.0.0.1 "$@"
}

echo "== Wait for SSH"
for _ in $(seq 1 60); do
    if ssh_vm true 2>/dev/null; then break; fi
    sleep 5
done
ssh_vm true || { echo "The machine did not come up:" >&2; sudo tail -n 40 "${dir}/serial.log" >&2; exit 1; }

# first boot: let cloud-init and the boot-time package jobs finish
ssh_vm 'cloud-init status --wait > /dev/null 2>&1 || true; systemctl is-system-running --wait > /dev/null 2>&1 || true'
# the test network has no IPv6: without this apt can wait minutes for an address it cannot reach
ssh_vm 'echo "Acquire::ForceIPv4 \"true\";" > /etc/apt/apt.conf.d/99-test-ipv4'
# stands in for a mail program: keeps the last mail in /tmp/mail.out
ssh_vm 'printf "%s\n" "#!/bin/sh" "{ echo \"ARGS: \$*\"; cat; } > /tmp/mail.out" > /usr/bin/mail && chmod 755 /usr/bin/mail'
ssh_vm '. /etc/os-release; echo "== Up: ${PRETTY_NAME} (${VERSION_CODENAME}), kernel $(uname -r)"'
