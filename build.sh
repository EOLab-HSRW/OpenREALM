# spack env activate -d .
#
# VIEW="$PWD/.spack-env/view"

cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    # -G Ninja \
    # -DCMAKE_PREFIX_PATH="$VIEW" \
    # -DCMAKE_FIND_PACKAGE_PREFER_CONFIG=ON

cmake --build build -j
cmake --install build --prefix "$PWD/install"
