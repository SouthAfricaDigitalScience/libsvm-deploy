#!/bin/bash -e
# this should be run after check-build finishes.
. /etc/profile.d/modules.sh
# The stuff that has to be built is :
BINARIES='svm-train svm-predict svm-scale'
PYTHONS='python/svmutil.py python/svm.py tools/subset.py tools/grid.py tools/checkdata.py tools/easy.py'

echo ${SOFT_DIR}
module add deploy
module  add gcc/${GCC_VERSION}
module add python/2.7.13-gcc-${GCC_VERSION}
echo ${SOFT_DIR}
cd ${WORKSPACE}/${NAME}-${VERSION}

echo "All tests have passed, will now clean and build into ${SOFT_DIR}"
make clean
make
echo "Making the python bindings"

cd python
make

cd ${WORKSPACE}/${NAME}-${VERSION}

mkdir -vp ${SOFT_DIR}/bin \
          ${SOFT_DIR}/include  \
          ${SOFT_DIR}/lib \
          ${SOFT_DIR}/tools \
          ${SOFT_DIR}/python

echo "putting binaries $BINARIES in ${SOFT_DIR}/bin "
for bin in $BINARIES ; do
  cp -v ${bin} ${SOFT_DIR}/bin
done

echo "putting binaries in ${SOFT_DIR}/bin"
cp -v svm-predict svm-scale svm-train ${SOFT_DIR}/bin
echo "putting libraries in ${SOFT_DIR}/lib"
cp -v libsvm.so.2 ${SOFT_DIR}/lib

echo "putting in the pythons"
for py in $PYTHONS ; do
  cp -rv $py ${SOFT_DIR}
done

echo "Creating the modules file directory ${LIBRARIES}"
mkdir -p ${LIBRARIES}/${NAME}
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION : See https://github.com/SouthAfricaDigitalScience/LIBSVM-deploy"
setenv LIBSVM_VERSION       $VERSION
setenv LIBSVM_DIR           $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$::env(NAME)/$::env(VERSION)-gcc-$::env(GCC_VERSION)
prepend-path LD_LIBRARY_PATH   $::env(LIBSVM_DIR)/lib
prepend-path PATH              $::env(LIBSVM_DIR)/bin
prepend-path GCC_INCLUDE_DIR   $::env(LIBSVM_DIR)/include
prepend-path CFLAGS            "-I$::env(LIBSVM_DIR)/include"
prepend-path LDFLAGS           "-L$::env(LIBSVM_DIR)/lib"
MODULE_FILE
) > ${LIBRARIES}/${NAME}/${VERSION}-gcc-${GCC_VERSION}

module avail ${NAME}
module add ${NAME}/${VERSION}-gcc-${VERSION}
for binary in ${BINARIES} ; do
  which $binary
done
