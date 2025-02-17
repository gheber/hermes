#!/bin/bash

set -x
set -e
set -o pipefail

INSTALL_DIR="${HOME}/${LOCAL}"
SPACK_DIR=${INSTALL_DIR}/spack
MOCHI_REPO_DIR=${INSTALL_DIR}/mochi-spack-packages
THALLIUM_VERSION=0.8.3
GOTCHA_VERSION=develop
CATCH2_VERSION=2.13.3
ORTOOLS_VERSION=7.7
SPACK_VERSION=0.16.3

echo "Installing dependencies at ${INSTALL_DIR}"
mkdir -p ${INSTALL_DIR}
git clone https://github.com/spack/spack ${SPACK_DIR}
pushd ${SPACK_DIR}
git checkout v${SPACK_VERSION}
popd

set +x
. ${SPACK_DIR}/share/spack/setup-env.sh
set -x

cp ci/packages.yaml ${SPACK_DIR}/etc/spack/packages.yaml
MOCHI_REPO=https://github.com/mochi-hpc/mochi-spack-packages.git
git clone ${MOCHI_REPO} ${MOCHI_REPO_DIR}

spack repo add ${MOCHI_REPO_DIR}
spack repo add ./ci/hermes

THALLIUM_SPEC="mochi-thallium~cereal@${THALLIUM_VERSION} ^mercury~boostsys"
CATCH2_SPEC="catch2@${CATCH2_VERSION}"
ORTOOLS_SPEC="gortools@${ORTOOLS_VERSION}"

spack install ${THALLIUM_SPEC} ${CATCH2_SPEC} ${ORTOOLS_SPEC}
SPACK_STAGING_DIR=~/spack_staging
mkdir -p ${SPACK_STAGING_DIR}
spack view --verbose symlink ${SPACK_STAGING_DIR} ${THALLIUM_SPEC} ${CATCH2_SPEC} ${ORTOOLS_SPEC}

cp -LRnv ${SPACK_STAGING_DIR}/* ${INSTALL_DIR}
