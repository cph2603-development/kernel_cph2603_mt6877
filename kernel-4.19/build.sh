#!/bin/bash

# some paths
KERNELDIR=$(pwd)
CLANG_DIR=$HOME/toolchains/clang-r383902
DEFCONFIG=k6877v1_64_k419_defconfig
IM=Image.gz

# clang install
if [ ! -d "$CLANG_DIR" ]; then
    echo "Clang not found! Downloading..."
    git clone --depth=1 https://github.com/crdroidandroid/android_prebuilts_clang_host_linux-x86_clang-6443078 $CLANG_DIR
    cd $KERNELDIR
fi

# some exports
export PATH=$CLANG_DIR/bin:$PATH
export ARCH=arm64
export CLANG_TRIPLE=aarch64-linux-gnu-
export CROSS_COMPILE=aarch64-linux-gnu-
export KBUILD_BUILD_USER=root
export KBUILD_BUILD_HOST=dg02-pool06-kvm32
export KBUILD_BUILD_VERSION=1

# make .config
make O=out \
  CC=clang \
  LD=ld.lld \
  AR=llvm-ar \
  NM=llvm-nm \
  OBJCOPY=llvm-objcopy \
  OBJDUMP=llvm-objdump \
  STRIP=llvm-strip \
  $DEFCONFIG

# kernel build
make -j$(nproc) O=out \
  CC=clang \
  LD=ld.lld \
  AR=llvm-ar \
  NM=llvm-nm \
  OBJCOPY=llvm-objcopy \
  OBJDUMP=llvm-objdump \
  STRIP=llvm-strip \
  $IM

if [ -f "out/arch/arm64/boot/$IM" ]; then
    echo "Done! Image in out/arch/arm64/boot/"
else
    echo "Build error! Check the compilation logs."
fi