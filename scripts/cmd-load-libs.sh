#!/bin/bash

set -e

input="./libs.txt"

lib_load() {
    echo "Loading libraries..."
    while IFS= read -r lib
    do
      echo "$lib"
      if [[ "$lib" != "---START---" && "$lib" != "---END---" ]]; then
        R --no-echo --no-restore --no-save -e "library($lib)"
      fi

    done < "$input"
}

lib_load