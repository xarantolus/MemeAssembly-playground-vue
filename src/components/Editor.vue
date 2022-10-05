<script lang="ts" setup>
import * as monaco from 'monaco-editor'
import { ref, onMounted } from 'vue'

import { configuration, createSnippets } from '../assets/memeasm';

monaco.languages.register({ id: 'memeasm', extensions: ['.memeasm'], aliases: ['memeasm', 'Memeasm', "MemeAssembly"] });
monaco.languages.setLanguageConfiguration('memeasm', configuration)

// monaco.languages.registerCompletionItemProvider('memeasm', {
// 	provideCompletionItems(model, position, context, token) {
// 		console.log("Providing completion");
// 		let range = new monaco.Range(position.lineNumber, position.column, position.lineNumber, position.column+1)
// 		return {
// 			suggestions: createSnippets(range)
// 		};
// 	},
// })

const editor = ref()

onMounted(() => {
	let monaco_editor = monaco.editor.create(editor.value, {
		value: `I like to have fun, fun, fun, fun, fun, fun, fun, fun, fun, fun main
	rax is brilliant, but I like a

	What the hell happened here? Print each character
	upgrade

		who would win? rax or z

		What the hell happened here? rax is equal to z

		z wins
		What the hell happened here? rax < z

		what can I say except al
		upvote rax

	fuck go back

	rax wins
	What the hell happened here? rax > z

	what can I say except \\n

	I see this as an absolute win
`,
		language: 'memeasm',
		theme: 'vs-dark',
		automaticLayout: true,
		contextmenu: true,
	});

	let runMemeAsmFile = () => {
		alert("Not implemented yet");
	}

	// Add bottom navigation bar as widget
	monaco_editor.addOverlayWidget({
		getId() { return "bottom-navigation" },
		getDomNode() {
			// Create a run button
			let node = document.createElement("button");
			node.innerText = "Run"
			node.className = "run-button";
			node.onclick = runMemeAsmFile;
			return node;
		},
		getPosition() {
			return {
				preference: monaco.editor.OverlayWidgetPositionPreference.TOP_RIGHT_CORNER
			}
		}
	});
})
</script>

<template>
	<div id="editor" ref="editor"></div>
</template>

<style scoped>
.wrap,
#editor {
	text-align: left;
	width: 100%;
	height: 100%;
}
</style>

<style>
.run-button {
	margin: 1em;
	padding: 0.5em 1em;
	border: none;
	border-radius: 0.5em;
	background-color: #007acc;
	color: white;
	font-size: 1em;
	font-weight: bold;
	cursor: pointer;
}
</style>
