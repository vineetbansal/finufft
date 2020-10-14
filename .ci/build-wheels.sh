#!/bin/bash

# Copyright (c) 2019, Henry Schreiner.
#
# Distributed under the 3-clause BSD license, see accompanying file LICENSE
# or https://github.com/scikit-hep/azure-wheel-helpers for details.

# Based on https://github.com/pypa/python-manylinux-demo/blob/master/travis/build-wheels.sh
# with CC0 license here: https://github.com/pypa/python-manylinux-demo/blob/master/LICENSE

set -e -x

curl http://www.fftw.org/fftw-3.3.8.tar.gz --output fftw-3.3.8.tar.gz
tar -xvzf fftw-3.3.8.tar.gz
cd fftw-3.3.8
CFLAGS=-fPIC ./configure --enable-threads --enable-openmp
make
make install

cd /io/
make lib

pys=(/opt/python/py3*/bin)

# Filter out Python 3.4
pys=(${pys[@]//*34*/})

for PYBIN in "${pys[@]}"; do
    "${PYBIN}/pip" install wheel auditwheel twine pybind11
    "${PYBIN}/pip" wheel /io/ -w wheelhouse    
done

for whl in wheelhouse/$package_name-*.whl; do
    auditwheel repair "$whl" -w /io/wheelhouse/
done
