#!/bin/bash

if [ -z "$1" ]; then
    echo "Missing File"
    exit 1
fi

echo "Errors found:"
grep -c ERROR "$1"
