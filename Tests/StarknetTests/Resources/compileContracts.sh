#!/bin/bash

cd "$(dirname "$0")" || exit
mkdir -p "Compiled"

while IFS= read -r -d '' file; do
  name="$(basename -- "$file" .cairo)"
  if [[ $name == *"account"* ]]; then
    starknet-compile-deprecated "$file" --account_contract --output "Compiled/$name.json" --abi "Compiled/${name}Abi.json"
  else
    starknet-compile-deprecated "$file" --output "Compiled/$name.json" --abi "Compiled/${name}Abi.json"
  fi
done < <(find Contracts -name "*.cairo" -type f -print0)

