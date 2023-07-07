#!/bin/bash
# Script outline to install and build kernel.
# Original Author: Siddhant Jajoo.
# Modified by Amith Rao - University of Colorado - Boulder

set -e
set -u

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.1.10
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-

if [ $# -lt 1 ]
then
        echo "Using default directory ${OUTDIR} for output"
else
        OUTDIR=$1
        echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
        echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
        git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}

    #export PATH=~/aarc64_cross_compiler/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/bin:$PATH
    
    # TODO: Add your kernel build steps here
    
    echo "Checking before 1"
    echo "${PATH}"
    # deep Clean, to remove .config and other configurations
    make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- mrproper
    #ARCH=${ARCH} CC=${CROSS_COMPILE} make mrproper
	

	
	echo "Checking before 2"
    echo "${PATH}"
	# defconfig for virt arm dev board simulated on QEMU
    make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- defconfig
    #ARCH=${ARCH} CC=${CROSS_COMPILE} make defconfig
    
  
    
    echo "Checking before 3"
    echo "${PATH}"
    # Build the kernel image for booting on QEMU , This takes longer
    make -j4 ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- all
    #ARCH=${ARCH} CC=${CROSS_COMPILE} make -j4 all
    
    
     #exit 0
    
    echo "Checking before 4"
    echo "${PATH}"
    # Build kernel modules
    make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- modules
    
    echo "Checking before 5"
    echo "${PATH}"
    
    # Build device tree
    make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- dtbs
    #ARCH=${ARCH} CC=${CROSS_COMPILE} make dtbs
  
  
    
fi

echo "Adding the Image in outdir"

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
        echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories
# Create the rootfs directory
sudo mkdir "${OUTDIR}/rootfs"

#Create base directories
cd "${OUTDIR}/rootfs"
sudo mkdir -p bin dev etc home lib lib64 proc sbin sys tmp usr var
sudo mkdir -p usr/bin usr/lib usr/sbin
sudo mkdir -p var/log


cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
git clone git://busybox.net/busybox.git
    cd busybox
fi

# TODO: Make and install busybox
cd "$OUTDIR/busybox"
sudo make distclean
sudo make defconfig   # Optional: Use default configuration
#make menuconfig  # Optional: Customize BusyBox configuration
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}
make CONFIG_PREFIX=${OUTDIR}/rootfs ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install
#sudo make install

echo "build complete"

pwd

########### To be debugged from here #################
#bin/busybox missing
echo "Library dependencies"
${CROSS_COMPILE}readelf -a bin/busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a bin/busybox | grep "Shared library"

# TODO: Add library dependencies to rootfs
# Copy library dependencies to the rootfs
${CROSS_COMPILE}readelf -a bin/busybox | grep "program interpreter" | awk '{print $4}' | xargs -I '{}' sudo cp -L '{}' "${OUTDIR}/rootfs/lib"
${CROSS_COMPILE}readelf -a bin/busybox | grep "Shared library" | awk '{print $1}' | xargs -I '{}' sudo cp -L '{}' "${OUTDIR}/rootfs/lib64"



# TODO: Make device nodes
sudo mknod -m 666 dev/null c 1 3
sudo mknod -m 666 dev/console c 5 1

# TODO: Clean and build the writer utility
cd /home/amith_srao/Assignments/finder-app
make clean
make
cp writer "$OUTDIR/rootfs/home"


# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs
cp finder.sh conf/username.txt finder-test.sh "$OUTDIR/rootfs/home"
cp autorun-qemu.sh "$OUTDIR/rootfs/home"

# TODO: Chown the root directory
cd "${OUTDIR}/rootfs"
find . | cpio -H newc -ov --owner root:root > ${OUTDIR}/initramfs.cpio


# TODO: Create initramfs.cpio.gz
gzip -f initramfs.cpio                                                                                                                                                                                                 76,1          Bot                                                                                                                                                                                                 1,1           Top
