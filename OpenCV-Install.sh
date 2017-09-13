#!/bin/bash
#
# Builds OpenCV
# Based on: http://www.pyimagesearch.com/2016/10/24/ubuntu-16-04-how-to-install-opencv/

source /usr/local/bin/virtualenvwrapper.sh


function usage {
    echo "Usage: $(basename $0) [VIRTUAL_ENV [VERSION [INSTALL_DIR]]]

    Install OpenCV in the given install director

    VIRTUAL_ENV     the name of an existing, or to be created, virtual environment;
                    (default: cv3)

    VERSION         the version of OpenCV to install (default: 3.3.0)

    INSTALL_DIR     where to install the source code and libraries (default: /usr/local)

Before running this script, you will need to create and activate a suitable
virtualenv; alas, it does not seem possible to do so from within this script.

These are the steps:

    mkvirtualenv -p `which python3` \${VIRTUAL_ENV}
    workon \${VIRTUAL_ENV}
    pip install -U numpy
"
}

declare -r VIRTUAL_ENV=${1:-cv3}
declare -r VERSION=${2:-3.3.0}
declare -r INSTALL_DIR=${3:-/usr/local}

declare -r OPENCV_DIR="${INSTALL_DIR}/src/opencv-${VERSION}"
declare -r OPENCV_DIR_CONTRIB="${INSTALL_DIR}/src/opencv_contrib-${VERSION}"

HELP=${1:-}
if [[ ${HELP} == "-h" ]]; then
    usage
    exit
fi

set -eu

sudo apt-get install build-essential cmake pkg-config \
    libjpeg8-dev libtiff5-dev libjasper-dev libpng12-dev \
    libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
    libxvidcore-dev libx264-dev \
    libgtk-3-dev \
    libatlas-base-dev gfortran \
    python3.5-dev

if [[ ! -d ${OPENCV_DIR} ]]; then
    cd /tmp
    wget -O opencv.zip https://github.com/Itseez/opencv/archive/${VERSION}.zip
    unzip opencv.zip
    mkdir -p ${INSTALL_DIR}/src
    sudo mv ./opencv-${VERSION} ${OPENCV_DIR}
    sudo chown -R ${USER} ${OPENCV_DIR}
fi

if [[ ! -d ${OPENCV_DIR_CONTRIB} ]]; then
    cd /tmp
    wget -O opencv_contrib.zip https://github.com/Itseez/opencv_contrib/archive/${VERSION}.zip
    unzip opencv_contrib.zip
    sudo mv ./opencv_contrib-${VERSION} ${OPENCV_DIR_CONTRIB}
    sudo chown -R ${USER} ${OPENCV_DIR_CONTRIB}
fi

cd ${OPENCV_DIR}

# Let's do a bit of cleanup.
if [[ -d build ]]; then
    rm -rf build
fi
mkdir build && cd build

cmake -D CMAKE_BUILD_TYPE=RELEASE \
 -D CMAKE_INSTALL_PREFIX=${INSTALL_DIR}/opencv-${VERSION} \
 -D INSTALL_PYTHON_EXAMPLES=OFF \
 -D INSTALL_C_EXAMPLES=OFF \
 -D PYTHON_EXECUTABLE=$(which python3) \
 -D OPENCV_EXTRA_MODULES_PATH=${OPENCV_DIR_CONTRIB}/modules \
 -D BUILD_EXAMPLES=OFF \
 -D BUILD_TESTS=OFF ..

make -j 8
echo "[SUCCESS] OpenCV ${VERSION} built successfully"

make install
sudo ldconfig

echo "[SUCCESS] OpenCV ${VERSION} installed successfully to ${INSTALL_DIR}/opencv-${VERSION}"

# Fix for missing link:
CV2_DYLIB="${HOME}/.virtualenv/${VIRTUAL_ENV}/lib/python3.5/site-packages/cv2.so"
if [[ ! -e ${CV2_DYLIB} ]]; then
    ln -snf ${INSTALL_DIR}/opencv-${VERSION}/lib/python3.5/site-packages/cv2.*.so \
        ${CV2_DYLIB}
fi

set +e
ERROR=$(python3 -c "import cv2" 2>&1 | grep ImportError)
if [[ -z ${ERROR} ]]; then
    echo "[SUCCESS] Python virtualenv ${VIRTUAL_ENV} can now use OpenCV"
else
    echo "[FAILURE] OpenCV built successfully, but Python virtualenv cannot import it"
fi
