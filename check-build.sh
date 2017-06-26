#!/bin/bash -e
. /etc/profile.d/modules.sh
module load ci
module  add gcc/${GCC_VERSION}
module add python/2.7.13-gcc-${GCC_VERSION}
# The stuff that has to be built is :
BINARIES='svm-train svm-predict svm-scale'
PYTHONS='python/svmutil.py python/svm.py tools/subset.py tools/grid.py tools/checkdata.py tools/easy.py'

cd ${WORKSPACE}/${NAME}-${VERSION}/
# there is no make check.

echo $?
mkdir -vp ${SOFT_DIR}-gcc-${GCC_VERSION}/bin \
          ${SOFT_DIR}-gcc-${GCC_VERSION}/include  \
          ${SOFT_DIR}-gcc-${GCC_VERSION}/lib \
          ${SOFT_DIR}-gcc-${GCC_VERSION}/tools \
          ${SOFT_DIR}-gcc-${GCC_VERSION}/python
# there is no make install - we need to push stuff there by hand
echo "putting binaries $BINARIES in ${SOFT_DIR}/bin "
for bin in $BINARIES ; do
  cp -v ${bin} ${SOFT_DIR}-gcc-${GCC_VERSION}/bin
done
echo "putting libraries in ${SOFT_DIR}/lib"
cp -v libsvm.so.2 ${SOFT_DIR}-gcc-${GCC_VERSION}/lib

echo "putting in the pythons"
for py in $PYTHONS ; do
  cp -rv $py ${SOFT_DIR}-gcc-${GCC_VERSION}
done

echo "They python stuff still needs to be added to $PYTHONHOME or $PYTHONPATH - that will come later."
echo "It's also not clear whether we need the svm header if folks want to compile against that."

mkdir -vp ${REPO_DIR}
mkdir -vp modules
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION."
setenv       LIBSVM_VERSION       $VERSION
setenv       LIBSVM_DIR           /data/ci-build/$::env(SITE)/$::env(OS)/$::env(ARCH)/$::env(NAME)/$::env(VERSION)-gcc-$::env(GCC_VERSION)
prepend-path LD_LIBRARY_PATH   $::env(LIBSVM_DIR)/lib
prepend-path PATH              $::env(LIBSVM_DIR)/bin
prepend-path CFLAGS            "-I$::env(LIBSVM_DIR)/include"
prepend-path LDFLAGS           "-L$::env(LIBSVM_DIR)/lib"
MODULE_FILE
) > modules/${VERSION}-gcc-${GCC_VERSION}

echo "making ${LIBRARIES}/${NAME}"
mkdir -vp ${LIBRARIES}/${NAME}
echo "copying into ${LIBRARIES}/${NAME}"
cp -v modules/${VERSION}-gcc-${GCC_VERSION} ${LIBRARIES}/${NAME}
module avail ${NAME}
module add ${NAME}/${VERSION}-gcc-${VERSION}
echo "binaries are ${BINARIES}"
for binary in ${BINARIES} ; do
  echo "checking $binary"
  which ${binary}
done
