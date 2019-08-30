# Raspbian docker images [![Build Status](https://travis-ci.com/sfalexrog/raspbian-containers.svg?branch=master)](https://travis-ci.com/sfalexrog/raspbian-containers)

Automated builds for Raspbian Stretch and Buster from their "lite" images (from [the official repository](https://downloads.raspberrypi.org/raspbian_lite/images/))

Heavily based on [this tutorial](http://www.guoyiang.com/2016/11/04/Build-My-Own-Raspbian-Docker-Image/). As mentioned, this may result in less-than-optimal Docker images, although they represent the Raspbian environment about as accurately as possible.

These images are built with qemu emulation in mind. Check out the [qemu-register](https://github.com/sfalexrog/qemu-register) repository for simple and easy QEMU interpreter installation!
