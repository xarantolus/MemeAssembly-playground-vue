# MemeAssembly Playground
The [MemeAssembly Playground](https://memeasm.010.one) is a website for writing, compiling and running [MemeAssembly](https://github.com/kammt/MemeAssembly) code in the browser.

MemeAssembly is a custom assembly-like language that is transpiled to x86-64 assembly, which is then turned into x86-64 machine code.

### How it works
1. The user writes MemeAssembly code in the editor
2. This code is transpiled to the x86-64 assembly text format by [my fork of the MemeAssembly compiler that can run in WASM](https://github.com/xarantolus/MemeAssembly/tree/wasm)
3. This text is then compiled/assembled to real x86-64 machine code by [my x86-64 assembler](https://github.com/xarantolus/assembly-script)
4. This machine code is then executed by [my x86-64 emulator for WASM](https://github.com/xarantolus/ax)

The website emulates some syscalls by registering hooks for relevant instructions. This allows usage of syscalls like `read`, `write` and `exit`. The console on the page is used for the `read` and `write` syscalls.


### Development setup
1. Make sure Node, NPM, Rust and `wasm-pack` are installed
1. Clone repository
2. Run `setup.sh`
3. Run `npm install`
4. Run `npm run dev` to serve site locally
