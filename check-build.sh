#!/bin/bash -e
. /etc/profile.d/modules.sh
module load ci
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
# there is no make check.

echo $?
mkdir -vp ${SOFT_DIR}/lib ${SOFT_DIR}/bin ${SOFT_DIR}/include
# there is no make install - we need to push stuff there by hand
echo "putting binaries in ${SOFT_DIR}/bin"
cp -v svm-predict svm-scale svm-train ${SOFT_DIR}/bin
echo "putting libraries in ${SOFT_DIR}/lib"
cp -v libsvm.so.2 ${SOFT_DIR}/lib

echo "They python stuff still needs to be added to $PYTHONHOME or $PYTHONPATH - that will come later."

mkdir -p ${REPO_DIR}
mkdir -p modules
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
setenv       LIBSVM_DIR           /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH   $::env(LIBSVM_DIR)/lib
prepend-path PATH              $::env(LIBSVM_DIR)/bin
prepend-path CFLAGS            "-I${LIBSVM_DIR}/include"
prepend-path LDFLAGS           "-L${LIBSVM_DIR}/lib"
MODULE_FILE
) > modules/$VERSION

mkdir -p ${LIBRARIES_MODULES}/${NAME}
cp modules/$VERSION ${LIBRARIES_MODULES}/${NAME}
