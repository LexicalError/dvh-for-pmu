# DVH for PMU

---

## Environmental Setup

Make sure to `git submodule update --init --recursive`

**Kernel:**
Version: 7.0.10
- **L0:**

    ```bash
    cd linux
    git checkout <branch>
    cp /boot/config-$(uname -r) .config
    yes "" | make oldconfig
    make -j`nproc`
    make modules_install
    make install
    ```

- **L1:**

    ```bash
    cd linux
    git checkout <branch>
    make defconfig
    make -j`nproc`
    ```

    Then copy the kernel image (`arch/x86/boot/bzImage`) to `img/l0_<branch>_Image`

- **L2:**
    Same as L0, except you should copy the kernel image (`arch/x86/boot/bzImage`) to `img/l2_Image`

**Qemu**
**Version:** v11.0.1
```bash
git clone https://gitlab.com/qemu-project/qemu.git
cd qemu
git checkout v11.0.1
./configure --target-list=x86_64-softmmu --disable-werror --enable-slirp
make -j`nproc`
make install
```

**Disk:**
Use `create_disk.sh` to create two disk and copy it to `img/l1.img` & `img/l2.img`
```bash
cd img
wget https://cloud.debian.org/images/cloud/trixie/latest/debian-13-generic-amd64.tar.xz
../scripts/create_disk.sh l1.img debian-13-generic-amd64.tar.xz
cp l1.img l2.img
```

## Running VMs

**Run L1:**
```bash
cd scripts
./run-l1.sh -p ../ -k <kernel>
```
inside there should be a `/host` that shares whatever you passed into the `-p` argument.

**Run L2:**
Note that in L1, you will need to link the compiled qemu:
```bash
ln -s /host/qemu/build/qemu-system-x86_64 /usr/local/bin/qemu-system-x86_64
```
You will also need to install the kvm kernel modules, they can be copied out with the `cp_out.sh` script after compiling the kernel:

```bash
cd /linux
../cp_out.sh ../img
```

Then you can install them inside L1 with the `set_pmu_pv.sh` script

```bash
cd /host/scripts
./set_pmu_pv.sh 1 # Enable DVH PMU Passthrough, 0 for disable
```

Finally:

```bash
cd /host/scripts
./run-l2.sh -p ../ -k <kernel>
```

(You will want to setup ssh for L1 too)

## Experiments

### PMU Microbench

Use `./msr_microbench.sh`, you will need to compile `kvm-unit-tests` first and point the directory to the script, you may need to clone `kvm-unit-tests` twice to build it for L0 and L1.
Running the script on L0 launches a L1 VM and tests MSR microbenches there. Running the script in L1 launches a L2 VM and tests inside.

### Perf

To use perf:
```bash
cd linux/tools/perf
make
```
