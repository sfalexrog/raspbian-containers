#!/bin/bash

RPI_IMAGE=https://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2019-07-12/2019-07-10-raspbian-buster-lite.zip

echo "Downloading image from ${RPI_IMAGE}"

curl --location ${RPI_IMAGE} --fail --output image_archive.zip

unzip image_archive.zip

LODEV=$(losetup --find --read-only --partscan --show ./2019-07-10-raspbian-buster-lite.img)

echo "Image mounted to ${LODEV}"

echo "Waiting for the kernel to settle"
sleep 0.5

echo "Available loop devices:"
ls ${LODEV}*

(mkdir -p rpi || true)

mount -o ro ${LODEV}p2 ./rpi

echo "Packing rootfs"

tar -C ./rpi -czpf 2019-07-10-raspbian-buster-lite.tar.gz --numeric-owner .

echo "Unmounting the image"

umount ./rpi

losetup -d ${LODEV}

echo "Generating container"

mv ./2019-07-10-raspbian-buster-lite.tar.gz docker-staging/
cd docker-staging
docker build --rm --tag=sfalexrog/raspbian:buster-lite .

