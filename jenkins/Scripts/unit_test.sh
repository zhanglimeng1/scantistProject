#!/bin/sh

set -e 

run() {
    ./gradlew jacocoAggregatedReport
}

run || exit 1
