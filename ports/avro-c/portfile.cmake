vcpkg_buildpath_length_warning(37)
if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()


set(OPTIONAL_DUCKDB_PATCHES "")
if (VCPKG_TARGET_IS_EMSCRIPTEN)
  set(CMAKE_POSITION_INDEPENDENT_CODE ON)
  set(CMAKE_CXX_FLAGS " -fPIC ${VCPKG_CXX_FLAGS}" CACHE STRING "")
  set(CMAKE_C_FLAGS " -fPIC ${VCPKG_C_FLAGS}" CACHE STRING "")

  set(IS_CROSS_COMPILE 1)
  set(cross_compiling 1)
  set(VCPKG_CROSSCOMPILING 1)

  set(OPTIONAL_DUCKDB_PATCHES "${ADDITIONAL_PATCHES} static_link_only.patch")
endif()
separate_arguments(OPTIONAL_DUCKDB_PATCHES)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tishj/duckdb-avro-c
    REF a480d2ee208c37b55dbdd2d2b8ec1c38a57c181a
    SHA512 935b3d516e996f6d25948ba8a54c1b7f70f7f0e3f517e36481fdf0196c2c5cfc2841f86e891f3df9517746b7fb605db47cdded1b8ff78d9482ddaa621db43a34
    PATCHES
        ${OPTIONAL_DUCKDB_PATCHES}
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/lang/c"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_DOCS=OFF
        -DTHREADSAFE=true
        -DCMAKE_C_FLAGS=-DTHREADSAFE
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
# the files are broken and there is no way to fix it because the snappy dependency has no pkgconfig file
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")



if(NOT VCPKG_TARGET_IS_EMSCRIPTEN)
  vcpkg_copy_tools(TOOL_NAMES avroappend avrocat AUTO_CLEAN)

  if(NOT VCPKG_TARGET_IS_WINDOWS)
    vcpkg_copy_tools(TOOL_NAMES avropipe avromod AUTO_CLEAN)
  endif()

  if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" AND NOT VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
  endif()
endif()

file(INSTALL "${SOURCE_PATH}/lang/c/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
