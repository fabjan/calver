#! /bin/sh

#shellcheck disable=SC2002

set -e
set -u

assert_version()
{
    expected_version=$1
    shift

    actual_version=$(cat | ./calver --stdin "$@")

    if [ ! "$expected_version" = "$actual_version" ]
    then
        echo
        echo "Expected: $expected_version"
        echo "Actual:   $actual_version"
        exit 1
    fi
    printf .
}

assert_bail()
{
    expected_msg=$1
    shift

    set +e
    msg=$(cat | ./calver --stdin "$@" 2>&1)
    exit_code=$?
    set -e

    if [ ! $exit_code -eq 1 ]
    then
        echo
        echo "Expected to bail out"
        exit 1
    fi

    if ! echo "$msg" | grep -q "$expected_msg"
    then
        echo
        echo "Expected: .*$expected_msg.*"
        echo "Actual:   $msg"
        exit 1
    fi

    printf .
}

printf "Testing minor version calculation "
cat <<EOF | assert_version "1970.101.1"
1970-01-01
EOF
cat <<EOF | assert_version "1970.111.1"
1970-01-11
EOF
cat <<EOF | assert_version "1970.1001.1"
1970-10-01
EOF
cat <<EOF | assert_version "1970.1101.1"
1970-11-01
EOF
cat <<EOF | assert_version "1970.1111.1"
1970-11-11
EOF
cat <<EOF | assert_version "2031.1231.1"
2031-12-31
EOF
echo "OK"

printf "Testing patch version calculation "
cat <<EOF | assert_version "1970.102.5"
1970-01-02
1970-01-02
1970-01-02
1970-01-02
1970-01-02
1970-01-01
1970-01-01
1970-01-01
1970-01-01
1970-01-01
EOF
echo "OK"

printf "Testing --prerelease flag "
cat <<EOF | assert_version "1970.101.0-alpha.1" --prerelease alpha
1970-01-01
EOF
cat <<EOF | assert_version "1970.101.0-omega.3" --prerelease omega
1970-01-01
1970-01-01
1970-01-01
EOF
cat <<EOF | assert_version "3000.1231.0-gamma-delta-epsilon.1" --prerelease gamma-delta-epsilon
3000-12-31
EOF

cat <<EOF | assert_bail "lowercase letters only" --prerelease BETA
3000-12-31
EOF
cat <<EOF | assert_bail "lowercase letters only" --prerelease 4711
3000-12-31
EOF
cat <<EOF | assert_bail "lowercase letters only" --prerelease åäö
1970-01-01
EOF
echo "OK"

echo "Testing --timestamp flag "
# compare for both before and after the call to calver in case the test runs over a minute boundary
ts_minute_before=$(date '+%Y.%-m%d.%-H%M')
ts_version=$(./calver --timestamp)
ts_minute_after=$(date '+%Y.%-m%d.%-H%M')

if [ ! "$ts_version" = "$ts_minute_before" ] && [ ! "$ts" = "$ts_minute_after" ]
then
    echo
    echo "Expected: $at_minute_before or $at_minute_after"
    echo "Actual:   $ts_version"
    exit 1
fi

echo "All tests passed"
