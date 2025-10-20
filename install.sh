sudo apt-get update -y --quiet

sudo DEBIAN_FRONTEND=noninteractive apt-get -y --quiet --no-install-recommends install \
    build-essential \
    pkg-config \
    wget \
    curl \
    unzip

sudo DEBIAN_FRONTEND=noninteractive apt-get -y --quiet --no-install-recommends install \
    libeigen3-dev \
    gdal-bin \
    libcgal-dev \
    libpcl-dev \
    exiv2 \
    libexiv2-dev \
    libgoogle-glog-dev
    # ? libcgal-qt5-dev
    # ? apt-utils

# cd ~ && git clone https://github.com/RainerKuemmerle/g2o.git g2o && cd g2o
# git checkout 9b41a4ea5ade8e1250b9c1b279f3a9c098811b5a
# mkdir build && cd build
# cmake \
#     -DCMAKE_BUILD_TYPE=Release \
#     -DCMAKE_INSTALL_PREFIX=/usr/local \
#     -DCMAKE_CXX_FLAGS=-std=c++17 \
#     -DBUILD_SHARED_LIBS=ON \
#     -DBUILD_UNITTESTS=OFF \
#     -DG2O_USE_CHOLMOD=OFF \
#     -DG2O_USE_CSPARSE=ON \
#     -DG2O_USE_OPENGL=OFF \
#     -DG2O_USE_OPENMP=ON \
#     ..
# make -j$(nproc)
# sudo make install

cd ~ && git clone https://github.com/laxnpander/openvslam.git openvslam && cd openvslam
git submodule init && git submodule update
sudo ln -sfn /home/harley/g2o/g2o/EXTERNAL/csparse/cs.h /usr/local/include/cs.h # fix problem with "cs.h" header
mkdir build && cd build
cmake \
    -DUSE_SOCKET_PUBLISHER=OFF \
    -DUSE_STACK_TRACE_LOGGER=ON \
    -DBUILD_TESTS=ON \
    -DBUILD_EXAMPLES=ON \
    -DCMAKE_CXX_FLAGS="-I$HOME/g2o/EXTERNAL/csparse" \
    ..
    # ? -DUSE_PANGOLIN_VIEWER=ON \
    # ? -DINSTALL_PANGOLIN_VIEWER=ON \
make -j$(nproc)
sudo make install

# opencl
