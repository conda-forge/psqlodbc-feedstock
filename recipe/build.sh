#!/bin/bash

set -exuo pipefail

autoreconf -i

if [[ "${target_platform}" == "osx-arm64" ]]; then
  export ac_cv_search_SQLGetPrivateProfileString="-lodbcinst"
  export ac_cv_path_ODBC_CONFIG=__without_odbc_config
  export CPPFLAGS="${CPPFLAGS} -I$PREFIX/include/internal"
  mv $PREFIX/bin/pg_config $PREFIX/bin/pg_config.invalid
fi

./configure --prefix=$PREFIX --with-libpq=$PREFIX/lib --enable-pthreads || (cat config.log; exit 1)

make -j${CPU_COUNT}
make install
# generate the driver inst files
python $RECIPE_DIR/generate_odbc_inst_template.py

if [[ "${target_platform}" == "osx-arm64" ]]; then
  mv $PREFIX/bin/pg_config.invalid $PREFIX/bin/pg_config
fi
