# Copyright (C) 2010 Cristian Greco <cristian@regolo.cc>
# Distributed under the same license terms of the program itself (see COPYING).

cmake_minimum_required(VERSION 2.6)

project("twident" C)

set(VERSION "0.1")

set(APPNAME "twident")
set(PACKAGE "${APPNAME}")
set(PACKAGE_NAME "${APPNAME}")
set(PACKAGE_STRING "${APPNAME}-${VERSION}")
set(PACKAGE_VERSION "${APPNAME}-${VERSION}")
set(APP_VERSION "${VERSION}")
set(GETTEXT_PACKAGE "${APPNAME}")
string(REGEX REPLACE "([0-9])\\.([0-9]).*" "\\1.\\2" VERSION_MAJOR_MINOR ${VERSION})

configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/config.h.in"
  "${CMAKE_CURRENT_BINARY_DIR}/config.h"
)
add_definitions(-include config.h)


configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake_uninstall.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
  IMMEDIATE @ONLY
)
add_custom_target(uninstall "${CMAKE_COMMAND}" -P
  "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake")


list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
include(ValaVersion)
include(ValaPrecompile)
find_package(Vala REQUIRED)
ensure_vala_version("0.7.9" MINIMUM)


option(ENABLE_DEBUG "Enable debug messages" OFF)
option(UBUNTU_ICONS "Install icons for Ubuntu mono themes" OFF)
set(twident_VALA_OPTIONS)

#execute_process(COMMAND ${VALA_EXECUTABLE} "--version")

find_package(PkgConfig)
pkg_check_modules(GLIB REQUIRED "glib-2.0 >= 2.14.0")
pkg_check_modules(GOBJECT REQUIRED "gobject-2.0 >= 2.14.0")
pkg_check_modules(GTK+ REQUIRED "gtk+-2.0 >= 2.10.0")
pkg_check_modules(GEE REQUIRED "gee-1.0 >= 0.5.0")
pkg_check_modules(GIO REQUIRED "gio-2.0 >= 2.0")
pkg_check_modules(LIBNOTIFY REQUIRED "libnotify")
pkg_check_modules(LIBSOUP REQUIRED "libsoup-2.4 >= 2.4")
pkg_check_modules(LIBXML REQUIRED "libxml-2.0 >= 2.0")
pkg_check_modules(GTKSPELL REQUIRED "gtkspell-2.0 >= 2.0")
pkg_check_modules(REST REQUIRED "rest-0.7 >= 0.7")
pkg_check_modules(RESTEXTRAS REQUIRED "rest-extras-0.7 >= 0.7")
pkg_check_modules(LIBINDICATE "indicate >= 0.3")

if(${LIBINDICATE_FOUND})
  message(STATUS "libindicate found, support enabled...")
  set(twident_VALA_OPTIONS ${twident_VALA_OPTIONS} -D LIBINDICATE)
else()
  message(STATUS "libindicate not found, support disabled...")
endif()


if(ENABLE_DEBUG)
  set(twident_VALA_OPTIONS ${twident_VALA_OPTIONS} -D HAS_DEBUG)
endif()
if(UBUNTU_ICONS)
  set(twident_VALA_OPTIONS ${twident_VALA_OPTIONS} -D HAS_UBUNTUICONS)
endif()

file(GLOB twident_VALA_SOURCES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "src/*.vala")
#list(REMOVE_ITEM twident_VALA_SOURCES "src/oauth-client.vala")


vala_precompile(
twident_C_SOURCES
  ${twident_VALA_SOURCES}
PACKAGES
  glib-2.0
  gobject-2.0
  gtk+-2.0
  gee-1.0
  gio-2.0
  libnotify
  libsoup-2.4
  libxml-2.0
  rest-0.6
  rest-extras-0.6
OPTIONS
  --thread
  -g
  --save-temps
  ${twident_VALA_OPTIONS}
CUSTOM_VAPIS
  ${CMAKE_CURRENT_SOURCE_DIR}/src/vapi/config.vapi
)


add_definitions(
  ${GLIB_CFLAGS}
  ${GOBJECT_CFLAGS}
  ${GTK+_CFLAGS}
  ${GEE_CFLAGS}
  ${GIO_CFLAGS}
  ${LIBNOTIFY_CFLAGS}
  ${LIBSOUP_CFLAGS}
  ${LIBXML_CFLAGS}
  ${GTKSPELL_CFLAGS}
  ${LIBINDICATE_CFLAGS}
  ${REST_CFLAGS}
  ${RESTEXTRAS_CFLAGS}
)

link_libraries(
  ${GLIB_LIBRARIES}
  ${GOBJECT_LIBRARIES}
  ${GTK+_LIBRARIES}
  ${GEE_LIBRARIES}
  ${GIO_LIBRARIES}
  ${LIBNOTIFY_LIBRARIES}
  ${LIBSOUP_LIBRARIES}
  ${LIBXML_LIBRARIES}
  ${GTKSPELL_LIBRARIES}
  ${LIBINDICATE_LIBRARIES}
  ${REST_LIBRARIES}
  ${RESTEXTRAS_LIBRARIES}
)

include_directories(src/vapi/)
add_definitions(-std=c99)

add_executable(twident
  ${twident_C_SOURCES}
  #src/vapi/sha1.c
  src/vapi/time_parser.c
  src/vapi/img_cache_saver.c
)

install(TARGETS twident DESTINATION bin)


find_program(MSGFMT_EXECUTABLE msgfmt)
file(GLOB PO_FILES "po/*.po")
set(MO_FILES)
foreach(PO_FILE ${PO_FILES})
  get_filename_component(PO_FILE_BASE ${PO_FILE} NAME_WE)
  set(MO_FILE_PATH ${CMAKE_CURRENT_BINARY_DIR}/po)
  set(MO_FILE ${MO_FILE_PATH}/${PO_FILE_BASE}.mo)

  file(MAKE_DIRECTORY "${MO_FILE_PATH}")
  add_custom_command(
    OUTPUT ${MO_FILE}
    COMMAND ${MSGFMT_EXECUTABLE} -o ${MO_FILE} ${PO_FILE})

  install(FILES ${MO_FILE}
    DESTINATION share/locale/${PO_FILE_BASE}/LC_MESSAGES
    RENAME ${GETTEXT_PACKAGE}.mo)
  set(MO_FILES ${MO_FILES} ${MO_FILE})
endforeach()
add_custom_target(locales ALL DEPENDS ${MO_FILES})


set(twident_IMAGES
  img/delete_status.png
  img/direct_fresh.svg
  img/direct_reply.png
  img/direct.svg
  #img/favorite_no.png
  #img/favorite.png
  img/service-twitter.png
  img/service-identica.png
  img/mentions_fresh.svg
  img/mentions.svg
  img/group.svg
  img/reply.png
  img/timeline_fresh.svg
  img/timeline.svg
  img/public.svg
  img/userpic.svg
  img/updating.png
  img/retweet.svg
  img/rt.png
  img/conversation.png
)
install(FILES ${twident_IMAGES} DESTINATION share/twident/icons)


set(twident_ICONS
  img/twident_fresh.svg
  img/twident.svg
)
install(FILES ${twident_ICONS} DESTINATION share/icons/hicolor/scalable/apps)


set(twident_UBUNTU_ICONS_DARK
 img/ubuntu-mono-dark/twident-tray-icon.svg
 img/ubuntu-mono-dark/twident-tray-icon-fresh.svg
)
set(twident_UBUNTU_ICONS_LIGHT
  img/ubuntu-mono-light/twident-tray-icon.svg
  img/ubuntu-mono-light/twident-tray-icon-fresh.svg
)
if(UBUNTU_ICONS)
  install(FILES ${twident_UBUNTU_ICONS_DARK} DESTINATION share/icons/ubuntu-mono-dark/apps/22)
  install(FILES ${twident_UBUNTU_ICONS_LIGHT} DESTINATION share/icons/ubuntu-mono-light/apps/22)
endif()


set(twident_DOCS
  COPYING
  README
  INSTALL
)
install(FILES ${twident_DOCS} DESTINATION share/doc/twident)

install(FILES twident.desktop DESTINATION share/applications)
install(FILES indicator/twident DESTINATION share/indicators/messages/applications)
