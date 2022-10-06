<template>
	<div class="terminal" ref="terminalHTMLElement"></div>
</template>

<script lang="ts">
import { defineComponent, onMounted, onUnmounted, ref, Ref, VNodeRef } from 'vue';
import { Terminal } from 'xterm';
import { FitAddon } from 'xterm-addon-fit';
import 'xterm/css/xterm.css';

export default defineComponent({
	name: 'Terminal',
	setup(props, context) {
		// Setup xterm with automatic resize
		const terminalHTMLElement: Ref<HTMLElement | null> = ref(null);
		const term: Terminal = new Terminal();
		const fitAddon: FitAddon = new FitAddon();
		term.loadAddon(fitAddon);

		let resizeHandler = () => {
			fitAddon.fit();
		};

		let termBuffer = new Uint8Array();

		let prompt = '$ ';

		onMounted(() => {
			if (!terminalHTMLElement.value) throw new Error("Terminal HTML element not found");

			term.open(terminalHTMLElement.value);
			window.addEventListener('resize', resizeHandler);
			resizeHandler();

			// Terminal is now usable
			term.write('Hello from \x1B[1;3;31mxterm.js\x1B[0m $ ');

			term.onKey((ev) => {
				const printable = !ev.domEvent.altKey && !ev.domEvent.ctrlKey && !ev.domEvent.metaKey;

				if (ev.domEvent.keyCode === 13) {
					// Enter key
					term.write('\r\n');
					term.write('You entered: ' + termBuffer);
					termBuffer = new Uint8Array();
					term.write('\r\n' + prompt);
				} else if (ev.domEvent.keyCode === 8) {
					// Backspace key
					if (termBuffer.length > 0) {
						termBuffer = termBuffer.slice(0, termBuffer.length - 1);
						term.write('\b \b');
					}
				} else if (printable) {
					termBuffer = new Uint8Array([...termBuffer, ev.key.charCodeAt(0)]);
					term.write(ev.key);
				}
			});
		});

		context.expose({
			term,
		});

		onUnmounted(() => {
			window.removeEventListener('resize', resizeHandler);
			term.dispose();
		});

		return {
			terminalHTMLElement,
			term,
		};
	},
})

</script>

<style scoped>
.terminal {
	text-align: left;
	width: 100%;
	height: 100%;
}
</style>

<style>
.terminal-container {
	/* this is important */
	overflow: hidden;
}

.xterm .xterm-viewport {
	/* see : https://github.com/xtermjs/xterm.js/issues/3564#issuecomment-1004417440 */
	width: initial !important;
}
</style>
