#!/bin/bash
#
# Builds OpenCV
# Based on: http://www.pyimagesearch.com/2016/10/24/ubuntu-16-04-how-to-install-opencv/

set -ex

declare -r VERSION=${OPEN_CV_VERSION:-3.3.0}

install build-essential cmake pkg-config \
    libjpeg8-dev libtiff5-dev libjasper-dev libpng12-dev \
    libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
    libxvidcore-dev libx264-dev \
    libgtk-3-dev \
    libatlas-base-dev gfortran \
    python3.5-dev

mkvirtualenv -p `which python3` cv3 --system-site-packages
pip install numpy

wget -O opencv.zip https://github.com/Itseez/opencv/archive/${VERSION}.zip
unzip opencv.zip
sudo mv Downloads/opencv-${VERSION} /usr/local
sudo chown -R marco:marco /usr/local/opencv-${VERSION}

wget -O opencv_contrib.zip https://github.com/Itseez/opencv_contrib/archive/${VERSION}.zip
unzip opencv_contrib.zip
sudo mv opencv_contrib-${VERSION} /usr/local/
sudo chown -R marco:marco /usr/local/opencv_contrib-${VERSION}/

cd /usr/local/opencv-${VERSION}/
mkdir build && cd build

cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/data/store/usr/local/opencv3.3 \
    -D INSTALL_PYTHON_EXAMPLES=ON \
    -D INSTALL_C_EXAMPLES=OFF \
    -D PYTHON_EXECUTABLE=~/.virtualenv/cv/bin/python \
    -D OPENCV_EXTRA_MODULES_PATH=../opencv_contrib-${VERSION}/modules \
    -D BUILD_EXAMPLES=ON  ..

make -j 8
make install
sudo ldconfig
ln -s /usr/local/opencv-${VERSION}/build/lib/python3/cv2.cpython-35m-x86_64-linux-gnu.so \
    ~/.virtualenv/cv/lib/python3.5/site-packages/cv2.so
