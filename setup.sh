#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(pwd)"

rm -rf dependencies && mkdir -p dependencies/{ax,assembly-script,memeassembly}

TMP_DIR=$(mktemp -d)

# Build AX
cd "$TMP_DIR"
git clone "https://github.com/xarantolus/ax.git" -b develop
cd "ax"
make debug
cp pkg/* "$BASE_DIR/dependencies/ax"

# Build AssemblyScript assembler
cd "$TMP_DIR"
git clone "https://github.com/xarantolus/assembly-script.git" -b develop
cd assembly-script
make
cp pkg/* "$BASE_DIR/dependencies/assembly-script"


# Build MemeAssembly with some patches to make it work with emscripten

# -- First install emscripten
cd "$BASE_DIR"
if [ -d "build/emsdk" ]; then
    echo "emsdk already downloaded"
	cd build/emsdk
else
    mkdir -p build
	cd build

	echo "Installing emsdk for Wasm"
    git clone https://github.com/emscripten-core/emsdk
	cd emsdk

	chmod +x ./emsdk

	./emsdk install latest
	./emsdk activate latest
fi
source ./emsdk_env.sh


cd "$TMP_DIR"
git clone "https://github.com/xarantolus/MemeAssembly.git"

cd MemeAssembly

git checkout wasm

mkdir -p wasm

make wasm

cp "wasm/memeasm.js" "$BASE_DIR/dependencies/memeassembly/memeasm.js"
cp "wasm/memeasm.wasm" "$BASE_DIR/dependencies/memeassembly/memeasm.wasm"

cd "$BASE_DIR"
npm install
