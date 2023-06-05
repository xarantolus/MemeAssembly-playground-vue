#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(pwd)"

curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh

rm -rf dependencies && mkdir -p dependencies/{ax,assembly-script,memeassembly}

TMP_DIR=$(mktemp -d)

# Build AssemblyScript assembler
cd "$TMP_DIR"
git clone "https://github.com/xarantolus/assembly-script.git"
cd assembly-script
make
cp pkg/* "$BASE_DIR/dependencies/assembly-script"


# Build MemeAssembly
cd "$TMP_DIR"
git clone "https://github.com/xarantolus/MemeAssembly.git"

cd MemeAssembly

git checkout wasm

mkdir -p wasm

make wasm

cp "wasm/memeasm.js" "$BASE_DIR/dependencies/memeassembly/memeasm.js"
cp "wasm/memeasm.wasm" "$BASE_DIR/dependencies/memeassembly/memeasm.wasm"

cd "$BASE_DIR"

echo "NPM version:"
npm --version
echo "Node version:"
node --version

if [ -n "${CI:-}" ]; then
	npm ci
else
	npm install
fi
