#!/bin/bash

set -exuo pipefail

autoreconf -i

if [[ "${target_platform}" == "osx-arm64" ]]; then
  export ac_cv_search_SQLGetPrivateProfileString="-lodbcinst"
fi

./configure --prefix=$PREFIX --with-libpq=$PREFIX/lib --enable-pthreads || (cat config.log; exit 1)

make -j${CPU_COUNT}
make install
# generate the driver inst files
python $RECIPE_DIR/generate_odbc_inst_template.py
