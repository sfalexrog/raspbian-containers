#!/bin/bash

RPI_BASE_URL=https://downloads.raspberrypi.org/raspbian_lite/images
RPI_PREFIX=raspbian_lite

# Raspbian release dates are somewhat inconsistent

case "${RELEASE_DATE}" in
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

RPI_FOLDER="${RPI_PREFIX}-${RELEASE_DATE}"
RPI_IMAGE="${RPI_BASE_URL}/${RPI_FOLDER}/${RPI_IMAGE_NAME}.zip"

echo "Downloading image from ${RPI_IMAGE}"

curl --location ${RPI_IMAGE} --fail --output "${RPI_IMAGE_NAME}.zip"

unzip ${RPI_IMAGE_NAME}

echo "Mounting ${RPI_IMG_FILE}"

LODEV=$(losetup --find --read-only --partscan --show "${RPI_IMAGE_NAME}.img")

echo "Image mounted to ${LODEV}"

echo "Waiting for the kernel to settle"
sleep 0.5

echo "Available loop devices:"
ls ${LODEV}*

(mkdir -p rpi || true)

mount -o ro ${LODEV}p2 ./rpi

echo "Packing rootfs"

tar -C ./rpi -czpf "${RPI_IMAGE_NAME}.tar.gz" --numeric-owner .

echo "Unmounting the image"

umount ./rpi

losetup -d ${LODEV}

echo "Generating container"

mv "${RPI_IMAGE_NAME}.tar.gz" docker-staging/rootfs.tar.gz
cd docker-staging
docker build --rm --tag="sfalexrog/raspbian:${RELEASE_DIST}" .
