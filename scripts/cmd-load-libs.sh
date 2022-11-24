#!/bin/bash

set -e

lib_load() {
    echo "Loading libraries..."
    while IFS= read -r lib
    do
      if [[ "$lib" != "---START---" && "$lib" != "---END---" ]]; then
        echo "Loading $lib"
        R --no-echo --no-restore --no-save -e "library($lib)"
      fi

    done < "$1"
}

lib_load "$1"