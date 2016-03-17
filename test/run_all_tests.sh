#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

TEST_BASE_PATH=test/project

function run_test_project() {
    local TEST_NAME=${1}
    local TEST_PATH=${2}

    TEST_PATH=${1}
}

function run_all_test_projects() {
    local TEST_NAME
    local TEST_PATH

    for TEST_NAME in $(ls test/project); do
        TEST_PATH=${TEST_BASE_PATH}/${TEST_NAME}
        echo ${TEST_NAME}
        echo ${TEST_PATH}
    done
}

function main() {
    run_all_test_projects
}

main
