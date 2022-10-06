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

		let translationFunction = await MemeAsmWrapper();

		const runFunction = async (text: string) => {
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

		}

		return {
			terminalRef,
			editorRef,
			runFunction
		}
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

