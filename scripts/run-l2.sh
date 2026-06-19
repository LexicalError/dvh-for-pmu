#!/bin/bash

CONSOLE=mon:stdio
SMP=2
MEMSIZE="2G"
KERNEL="../img/l2_Image"
FS=../img/l2.img
CMDLINE="earlyprintk=serial,ttyS0,115200"
SHARE_DIR="$PWD"

usage() {
        U=""
        if [[ -n "$1" ]]; then
                U="${U}$1\n\n"
        fi
        U="${U}Usage: $0 [options]\n\n"
        U="${U}Options:\n"
        U="$U    -c | --CPU <nr>:       Number of cores (default ${SMP})\n"
        U="$U    -m | --mem <MB>:       Memory size (default ${MEMSIZE})\n"
        U="$U    -k | --kernel <Image>: Use kernel image (default ${KERNEL})\n"
        U="$U    -s | --serial <file>:  Output console to <file>\n"
        U="$U    -i | --image <image>:  Use <image> as block device (default $FS)\n"
        U="$U    -a | --append <snip>:  Add <snip> to the kernel cmdline\n"
        U="$U    --dumpdtb <file>       Dump the generated DTB to <file>\n"
        U="$U    --dtb <file>           Use the supplied DTB instead of the auto-generated one\n"
        U="$U    -h | --help:           Show this output\n"
        U="${U}\n"
        echo -e "$U" >&2
}

while :
do
        case "$1" in
          -c | --cpu)
                SMP="$2"
                shift 2
                ;;
          -m | --mem)
                MEMSIZE="$2"
                shift 2
                ;;
          -k | --kernel)
                KERNEL="$2"
                shift 2
                ;;
          -s | --serial)
                CONSOLE="file:$2"
                shift 2
                ;;
          -i | --image)
                FS="$2"
                shift 2
                ;;
          -a | --append)
                CMDLINE="$2"
                shift 2
                ;;
          -p | --path)
                SHARE_DIR="$2"
                shift 2
                ;;
          -h | --help)
                usage ""
                exit 1
                ;;
          --) # End of all options
                shift
                break
                ;;
          -*) # Unknown option
                echo "Error: Unknown option: $1" >&2
                exit 1
                ;;
          *)
                break
                ;;
        esac
done

if [[ -z "$KERNEL" ]]; then
        echo "You must supply a guest kernel" >&2
        exit 1
fi

# Configure 9pfs arguments if a share directory was provided
SHARE_ARGS=""
if [[ -n "$SHARE_DIR" ]]; then
        if [[ ! -d "$SHARE_DIR" ]]; then
                echo "Error: Shared path '$SHARE_DIR' does not exist or is not a directory." >&2
                exit 1
        fi
        # Using mapped-xattr for security_model is generally best for non-root users
        SHARE_ARGS="-fsdev local,path=${SHARE_DIR},security_model=mapped-xattr,id=fsdev0 -device virtio-9p-pci,fsdev=fsdev0,mount_tag=hostshare"
fi

qemu-system-x86_64 -nographic \
        -machine q35 -m ${MEMSIZE} -cpu host,pmu=on -smp ${SMP} -enable-kvm \
        -kernel ${KERNEL} \
        -drive if=none,file=$FS,id=vda,cache=none,format=raw \
        -device virtio-blk-pci,drive=vda \
        -display none \
        -serial $CONSOLE \
        -append "console=ttyS0 root=/dev/vda1 rw $CMDLINE" \
        -netdev user,id=net0,hostfwd=tcp::2222-:22 \
        -device virtio-net-pci,netdev=net0,mac=de:ad:be:ef:41:49 \
        ${SHARE_ARGS}


sleep 1

# Pin each vCPU thread to its own physical core
# CORE_PIN is your starting core (e.g. 2, to leave 0-1 for the host)
CORE_PIN=0
CORE=$CORE_PIN

VCPU_TIDS=$(ps -T -p $QEMU_PID | awk '/CPU [0-9]\/KVM/{print $2}')

if [[ -z "$VCPU_TIDS" ]]; then
    echo "[!] Warning: Could not find vCPU threads. Falling back to taskset on whole process."
    taskset -cp ${CORE_PIN}-$((CORE_PIN + SMP - 1)) $QEMU_PID
else
    echo "[*] Pinning vCPU threads to physical cores:"
    for tid in $VCPU_TIDS; do
        taskset -cp $CORE $tid
        echo "    Thread $tid -> Core $CORE"
        CORE=$((CORE + 1))
    done
fi

wait $QEMU_PID