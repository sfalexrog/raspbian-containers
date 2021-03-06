#!/bin/bash

RPI_BASE_URL=https://downloads.raspberrypi.org/raspbian_lite/images
RPI_PREFIX=raspbian_lite

# Raspbian release dates are somewhat inconsistent

case "${RELEASE_DATE}" in
    "2020-08-24")
        RPI_IMAGE_NAME="2020-08-20-raspios-buster-arm64-lite"
        RPI_PREFIX="raspios_lite_arm64"
        RPI_BASE_URL="https://downloads.raspberrypi.org/raspios_lite_arm64/images"
        RELEASE_OS=${RELEASE_OS:-raspios}
        ;;
    "2020-02-14")
        RPI_IMAGE_NAME="2020-02-13-raspbian-buster-lite"
        ;;
    "2019-09-30")
        RPI_IMAGE_NAME="2019-09-26-raspbian-buster-lite"
        ;;
    "2019-07-12")
        RPI_IMAGE_NAME="2019-07-10-raspbian-buster-lite"
        ;;
    "2019-04-09")
        RPI_IMAGE_NAME="2019-04-08-raspbian-stretch-lite"
        ;;
    *)
        echo "Unsupported release date: ${RELEASE_DATE}"
        exit 1
esac

RELEASE_OS=${RELEASE_OS:-raspbian}

RPI_FOLDER="${RPI_PREFIX}-${RELEASE_DATE}"
RPI_IMAGE="${RPI_BASE_URL}/${RPI_FOLDER}/${RPI_IMAGE_NAME}.zip"

echo "Downloading image from ${RPI_IMAGE}"

curl --location ${RPI_IMAGE} --fail --output "${RPI_IMAGE_NAME}.zip"

unzip "${RPI_IMAGE_NAME}.zip"

echo "Mounting ${RPI_IMAGE_NAME}.img"

LODEV=$(losetup --find --read-only --partscan --show "${RPI_IMAGE_NAME}.img")

echo "Image mounted to ${LODEV}"

echo "Waiting for the kernel to settle"
sleep 0.5

echo "Available loop devices:"
ls ${LODEV}*

(mkdir -p rpi || true)

mount -o ro ${LODEV}p2 ./rpi

echo "Packing rootfs"

tar -C ./rpi --exclude='./lib/modules' -czpf "${RPI_IMAGE_NAME}.tar.gz" --numeric-owner .

echo "Unmounting the image"

umount ./rpi

losetup -d ${LODEV}

echo "Generating container"

mv "${RPI_IMAGE_NAME}.tar.gz" docker-staging/rootfs.tar.gz
cd docker-staging
docker build --rm --tag="sfalexrog/${RELEASE_OS}:${RELEASE_DIST}-${RELEASE_DATE}" .
