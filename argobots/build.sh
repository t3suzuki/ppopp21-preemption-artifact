./autogen.sh
#./configure --prefix=$PWD/install --enable-affinity --enable-fast=O3 --enable-debug
./configure --prefix=$PWD/install --enable-affinity --enable-fast=O3
make && make install
