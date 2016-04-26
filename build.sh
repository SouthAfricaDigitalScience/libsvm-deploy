#!/bin/bash -e
. /etc/profile.d/modules.sh
# The stuff that has to be built is :
BINARIES='svm-train svm-predict svm-scale'
PYTHONS='python/svmutil.py python/svm.py tools/subset.py tools/grid.py tools/checkdata.py tools/easy.py'

module add ci
SOURCE_FILE=${NAME}-${VERSION}.tar.gz

echo "REPO_DIR is "
echo $REPO_DIR
echo "SRC_DIR is "
echo $SRC_DIR
echo "WORKSPACE is "
echo $WORKSPACE
echo "SOFT_DIR is"
echo $SOFT_DIR

mkdir -p ${WORKSPACE}
mkdir -p ${SRC_DIR}
mkdir -p ${SOFT_DIR}

#  Download the source file

if [ ! -e ${SRC_DIR}/${SOURCE_FILE}.lock ] && [ ! -s ${SRC_DIR}/${SOURCE_FILE} ] ; then
  touch  ${SRC_DIR}/${SOURCE_FILE}.lock
  echo "seems like this is the first build - let's geet the source"
# The usual :   wget http://[url]/${SOURCE_FILE} -O ${SRC_DIR}/${SOURCE_FILE}
# is not going to work, because this guy decided to get smart :-/
  wget https://www.csie.ntu.edu.tw/~cjlin/libsvm/oldfiles/${SOURCE_FILE} -O ${SRC_DIR}/${SOURCE_FILE}
  echo "releasing lock"
  rm -v ${SRC_DIR}/${SOURCE_FILE}.lock
elif [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; then
  # Someone else has the file, wait till it's released
  while [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; do
    echo " There seems to be a download currently under way, will check again in 5 sec"
    sleep 5
  done
else
  echo "continuing from previous builds, using source at " ${SRC_DIR}/${SOURCE_FILE}
fi
tar xzf  ${SRC_DIR}/${SOURCE_FILE} -C ${WORKSPACE} --skip-old-files

cd ${WORKSPACE}/${NAME}-${VERSION}

make -j 2

# Make the python bindings

cd python
make
