if(VCPKG_TARGET_IS_WINDOWS)
    set(PATCHES
    )
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO guyshe-jfrog/file
    REF 19dfa44f1743120259a2043f6f159a65ea6db833
    SHA512 b587b0233528e08bc04610901a6b2aa486cf35769dfdadd0c5f99a5b3c0da128f748cd7a7ad02a9382e246116371485708f33f228b104b9e8a5fd75af77dc5dc
    HEAD_REF jfrog5
    PATCHES ${PATCHES}
)

if(VCPKG_TARGET_IS_WINDOWS)
    set(VCPKG_C_FLAGS "${VCPKG_C_FLAGS} -D_CRT_SECURE_NO_WARNINGS -D_CRT_NONSTDC_NO_WARNINGS")
    set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS} -D_CRT_SECURE_NO_WARNINGS -D_CRT_NONSTDC_NO_WARNINGS")
endif()

vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH "${SOURCE_PATH}"
)

if(VCPKG_CROSSCOMPILING)
    vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/libmagic/bin")
elseif(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(EXTRA_ARGS "ADD_BIN_TO_PATH")
endif()

vcpkg_install_make(${EXTRA_ARGS})
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/bin")
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}/share/misc")
        file(COPY "${CURRENT_PACKAGES_DIR}/share/${PORT}/misc/magic.mgc" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/share/misc")
    endif()
    if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/share/misc")
        file(COPY "${CURRENT_PACKAGES_DIR}/share/${PORT}/misc/magic.mgc" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/share/misc")
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/${PORT}/man5")

include(CMakePackageConfigHelpers)
configure_package_config_file(
    "${CMAKE_CURRENT_LIST_DIR}/unofficial-${PORT}-config.cmake.in"
    "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}/unofficial-${PORT}-config.cmake"
    INSTALL_DESTINATION "share/unofficial-${PORT}"
)

# Handle copyright and usage
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
