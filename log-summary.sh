#!/bin/bash

if [ -z "$1" ]; then echo "Usage: ./log-summary.sh"; exit 1; fi

for f in "$1"/*.log; do echo "$f: $(grep -c ERROR "$f")"; done
