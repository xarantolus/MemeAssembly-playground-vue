<script lang="ts">
import Terminal from '../components/Terminal.vue';
import Editor from '../components/Editor.vue';
import { defineComponent, Ref, ref } from 'vue';
import { default as initAssembler, assemble } from "assembly-script";
import { default as initEmulator, Axecutor, Mnemonic, Register } from 'ax';
import { MemeAsmWrapper } from '../memeasm';
import { Terminal as XTerm } from 'xterm';
import Grid from '../components/Grid.vue';

export default defineComponent({
	name: 'Grid',
	components: {
		Terminal,
		Editor
	},
	async setup() {
		const terminalRef = ref<InstanceType<typeof Terminal>>();
		const editorRef = ref<InstanceType<typeof Editor>>();

		await initAssembler();
		await initEmulator();

		let createSyscallHandler = (term: XTerm) => {
			let dedup = true;
			return async function (ax: Axecutor) {
				if (dedup) {
					console.log("deduplicating")
					dedup = false;
					return null;
				}
				dedup = true;

				console.log(`Syscall ${ax.reg_read_64(Register.RIP)}`);
				let syscall_num = ax.reg_read_64(Register.RAX);

				let rdi = ax.reg_read_64(Register.RDI);
				let rsi = ax.reg_read_64(Register.RSI);
				let rdx = ax.reg_read_64(Register.RDX);

				switch (syscall_num) {
					case 0n: {
						// READ syscall MUST read from stdin
						if (rdi != 0n) {
							throw new Error('READ syscall: cannot read from non-stdin (!= 0) fd, but tried ' + rdi);
						}

						if (rdx != 1n) {
							throw new Error('READ syscall: cannot read more than 1 byte, but tried ' + rdx);
						}

						let byte = await terminalRef.value?.readByte();
						if (byte === undefined) {
							throw new Error('READ syscall: no byte available (invalid input?)');
						}

						console.log(`READ syscall: read byte ${byte} ${String.fromCharCode(byte)}`);

						ax.mem_write_8(rsi, byte);

						return ax.commit();
					}
					case 1n: {
						// WRITE syscall MUST write to stdout or stderr
						// Actually this also supports also "writing" to stdin, as this also works in certain circumstances: https://stackoverflow.com/a/7680234
						if (rdi != BigInt(0) && rdi != BigInt(1) && rdi != BigInt(2)) {
							throw new Error(`WRITE syscall: cannot write non-std{out,err} (!= 1,2) fds, but tried ${rdi}`);
						}

						let result_buf = ax.mem_read_bytes(rsi, rdx);

						term.write(result_buf);

						return ax.unchanged();
					}
					case 60n: {
						// EXIT syscall
						ax.stop();
						return ax.unchanged();
					}
					default: {
						throw new Error('Syscall: unsupported RAX value ' + syscall_num);
					}
				}
			}
		};

		let translationFunction = await MemeAsmWrapper();

		const runFunction = async (text: string) => {
			// Reset colors & clear terminal
			terminalRef.value?.term.reset();
			terminalRef.value?.term.clear();
			terminalRef.value?.term.focus();


			let writeln = (line: string) => {
				terminalRef.value?.term.writeln(line);
			};

			const x86Assembly = await translationFunction(text, writeln);

			let code_start_addr = 0x1000n;
			let data_start_addr = 0x2000n;

			let assembled: {
				code: Array<number>,
				code_start_address: number,
				data_section: Array<{
					label: string,
					offset: number,
					size: number,
				}>,
				data_section_size: number,
				data_start_address: number,
				entrypoint_address: number,
			} = await assemble(x86Assembly, code_start_addr, data_start_addr, "main");
			writeln("Successfully assembled to machine code.");

			let ax = new Axecutor(
				new Uint8Array(assembled.code),
				BigInt(assembled.code_start_address),
				BigInt(assembled.entrypoint_address),
			);
			ax.init_stack(8n * 1024n);

			let initial_rsp = ax.reg_read_64(Register.RSP);
			ax.hook_after_mnemonic(Mnemonic.Ret, (ax: Axecutor) => {
				let rsp = ax.reg_read_64(Register.RSP);
				if (rsp > initial_rsp) {
					console.log("Reached end of stack")
					return ax.stop();
				}

				return null;
			});

			ax.hook_before_mnemonic(Mnemonic.Syscall, createSyscallHandler(terminalRef.value?.term!));

			await ax.execute();

			writeln(`Program exited with exit code ${ax.reg_read_64(Register.RAX)}.`);
		};

		return {
			terminalRef,
			editorRef,
			runFunction
		}
	},
	mounted() {
		this.terminalRef?.term.writeln("Welcome to the MemeAssembly Playground 👋");
	}
})
</script>

<template>
	<div class="fullwindow grid-layout">
		<Editor ref="editorRef" class="grid-editor" :run-function="runFunction" :terminal="(terminalRef as any)" />
		<Terminal ref="terminalRef" class="grid-terminal" />
	</div>
</template>

<style scoped>
.fullwindow {
	width: 100vw;
	height: 100vh;
	margin: 0;
	padding: 0;
}

.grid-layout {
	display: grid;

	grid-template-rows: 1fr;
	grid-template-columns: 1fr 1fr 1fr;

	gap: 0px;
}

.grid-editor {
	grid-row-start: 1;
	grid-column-start: 1;

	grid-row-end: 2;
	grid-column-end: 3;
}

.grid-terminal {
	grid-row-start: 1;
	grid-column-start: 3;

	grid-row-end: 2;
	grid-column-end: 4;
}

/* Mobile screens */
@media only screen and (max-width: 1024px) {
	.grid-layout {
		display: grid;

		grid-template-rows: 1fr 1fr 1fr;
		grid-template-columns: 1fr;

		gap: 0px;
	}

	.grid-editor {
		grid-row-start: 1;
		grid-column-start: 1;

		grid-row-end: 3;
		grid-column-end: 2;

	}

	.grid-terminal {
		grid-row-start: 3;
		grid-column-start: 1;

		grid-row-end: 4;
		grid-column-end: 2;

	}
}
</style>

