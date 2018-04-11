#!/bin/bash
set -euo pipefail
sha1sum source/*.tgz | awk '{ print $1 }' | tee digests/digest.txt
