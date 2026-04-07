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
    REPO duckdb/duckdb-avro-c
    REF a480d2ee208c37b55dbdd2d2b8ec1c38a57c181a
    SHA512 265e9fbe5f87a7f2939b30e62dd64c4469a9f6d974022312b35933a7c7d713a18099c10b97d4af49216335368dc6d118b2516ca5bf75b95f07a3b5ab11406cf9
    PATCHES
        ${OPTIONAL_DUCKDB_PATCHES}
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/lang/c"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_DOCS=OFF
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
