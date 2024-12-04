#!/bin/bash
#
# CONDA build script variables 
# 
# $PREFIX The install prefix
# $PKG_NAME The name of the package
# $PKG_VERSION The version of the package
# $PKG_BUILDNUM The build number of the package
#
set -eux -o pipefail

SHARE_DIR="${PREFIX}/libexec/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
OS=$(./install get_os)

mkdir -p "${PREFIX}/bin"

cd t_coffee/src
make t_coffee CC="$CXX" CFLAGS="$CFLAGS -O3 -Wno-register" -j$"${CPU_COUNT}"
install -v -m 0755 t_coffee ${PREFIX}/bin

# llvm-otool -l fails for these plugins on macosx
if [[ "$OS" = macosx ]]; then
    for bad_plug in probconsRNA prank
    do
	rm -f "${SHARE_DIR}/plugins/macosx/${bad_plug}"
    done
fi

# The installer may try to update dependencies and install them to bin/,
# which will cause conflicts with the dependencies as separately packaged.
# t_coffee itself is not installed here
rm -f ${PREFIX}/bin/*

sed -e "s|CHANGEME|${SHARE_DIR}|" -e "s|__OS__|${OS}|" "$RECIPE_DIR/t_coffee.sh" > "${PREFIX}/bin/t_coffee"
