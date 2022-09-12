setup() {
  set -eu -o pipefail
  export DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )/.."
  export TESTDIR=~/tmp/test-addon-template
  mkdir -p $TESTDIR
  export PROJNAME=test-ports-alt
  export DDEV_NON_INTERACTIVE=true
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  cp -R ${DIR}/tests/testdata/* .
  ddev config --project-name=${PROJNAME} --project-type=php
  # We will test different ports, so don't start it now
  #ddev start -y >/dev/null
}

teardown() {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  ddev delete -Oy ${PROJNAME} >/dev/null
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

@test "install from directory" {
  set -eu -o pipefail
  cd ${TESTDIR}
  echo "# ddev get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get ${DIR}
  ddev restart
  # Do something here to verify functioning extra service
  wget -O - http://test-ports-alt.ddev.site:8888 | grep "ddev-ports-alt succeeded"
  wget -O - https://test-ports-alt.ddev.site:4444 | grep "ddev-ports-alt succeeded"
  wget -O - http://test-ports-alt.ddev.site:8300 | grep -i mailhog
  wget -O - https://test-ports-alt.ddev.site:8301 | grep -i mailhog
}

@test "install from release" {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  echo "# ddev get hanoii/ddev-ports-alt with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get hanoii/ddev-ports-alt
  ddev restart >/dev/null
  # Do something useful here that verifies the add-on
  wget -O - http://test-ports-alt.ddev.site:8888 | grep "ddev-ports-alt succeeded"
  wget -O - https://test-ports-alt.ddev.site:4444 | grep "ddev-ports-alt succeeded"
  wget -O - http://test-ports-alt.ddev.site:8300 | grep -i mailhog
  wget -O - https://test-ports-alt.ddev.site:8301 | grep -i mailhog
}
