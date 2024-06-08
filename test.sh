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
        echo "Expected: $expected_version"
        echo "Actual: $actual_version"
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

echo "All tests passed"
