if [[ "$target_platform" == osx-* ]]; then
    ARCH_ARGS=""

    # c-f-provided CMAKE_ARGS handles CMAKE_OSX_DEPLOYMENT_TARGET, CMAKE_OSX_SYSROOT
fi
if [[ "$target_platform" == linux-* ]]; then
    ARCH_ARGS=""

fi
if [[ "$target_platform" == "linux-ppc64le" ]]; then
    CFLAGS="$(echo $CFLAGS | sed 's/-fno-plt //g')"
    CXXFLAGS="$(echo $CXXFLAGS | sed 's/-fno-plt //g')"
fi

${BUILD_PREFIX}/bin/cmake ${CMAKE_ARGS} ${ARCH_ARGS} \
  -S ${SRC_DIR} \
  -B build \
  -G Ninja \
  -D CMAKE_INSTALL_PREFIX=${PREFIX} \
  -D CMAKE_BUILD_TYPE=Debug \
  -D CMAKE_CXX_COMPILER=${CXX} \
  -D CMAKE_CXX_FLAGS="${CXXFLAGS} -O0" \
  -D CMAKE_INSTALL_LIBDIR=lib \
  -D OpenOrbitalOptimizer_INSTALL_CMAKEDIR="share/cmake/OpenOrbitalOptimizer" \
  -D OpenOrbitalOptimizer_BUILD_TESTING=ON \
  -D CMAKE_PREFIX_PATH="${PREFIX}"

cmake --build build --target install -j${CPU_COUNT}

cd build
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
    ctest --rerun-failed --output-on-failure -j${CPU_COUNT}
fi

