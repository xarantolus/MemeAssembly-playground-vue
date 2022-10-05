<template>
	<div id="terminal" ref="el"></div>
</template>

<script setup lang="ts">
import { onMounted, onUnmounted, ref, Ref, VNodeRef } from 'vue';
import { Terminal } from 'xterm';
import { FitAddon } from 'xterm-addon-fit';
import 'xterm/css/xterm.css';

let el = ref<HTMLElement>();

let term = new Terminal();
let fitAddon = new FitAddon();
term.loadAddon(fitAddon);

let resizeHandler = () => {
	fitAddon.fit();
};

let termBuffer = new Uint8Array();

onMounted(() => {
	if (!el.value) return;

	term.open(el.value);
	window.addEventListener('resize', resizeHandler);
	resizeHandler();

	// Terminal is now usable
	term.write('Hello from \x1B[1;3;31mxterm.js\x1B[0m $ ');
	term.onKey((ev) => {
		const printable = !ev.domEvent.altKey && !ev.domEvent.ctrlKey && !ev.domEvent.metaKey;
		if (ev.domEvent.keyCode === 13) {
			term.write('\r\n');
			term.write('You entered: ' + termBuffer);
			termBuffer = new Uint8Array();
			term.write('\r\n$ ');
		} else if (ev.domEvent.keyCode === 8) {
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

onUnmounted(() => {
	window.removeEventListener('resize', resizeHandler);
});
</script>

<style scoped>
#terminal {
	text-align: left;
	width: 100%;
	height: 100%;
}
</style>
