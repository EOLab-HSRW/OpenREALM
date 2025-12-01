# libgdal-dev getting 3.4       but 3.11 is available from source
# libpcl-dev getting 1.12       but 1.14 is available from source
# libeigen3 getting 3.4          but 3.5 and 5.0 available from source
# libexiv2-dev getting 0.27     but 0.28 is available from source


# git clone https://github.com/Exiv2/exiv2.git ~/exiv2
# cd ~/exiv2                          # Location of the project code
# cmake -S . -B build -DCMAKE_BUILD_TYPE=Release # Configure the project with CMake
# cmake --build build                            # Compile the project
# ctest --test-dir build --verbose               # Run tests
# sudo cmake --install build                     # Run the install target (install library, public headers, application and CMake files)

apt install -y \
    libgdal-dev \
    libpcl-dev \
    libeigen3-dev \
    libexiv2-dev \
  # - vtk@9.4                     # (Ubuntu 22.04) apt 7.1.1: see https://packages.ubuntu.com/jammy/libvtk7-dev
