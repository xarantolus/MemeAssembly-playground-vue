<script lang="ts" setup>
import * as monaco from 'monaco-editor/esm/vs/editor/editor.api'
import { ref, onMounted } from 'vue'

import customLangMonarch from '../assets/custom-lang';

monaco.languages.register({ id: 'custom' })
monaco.languages.setMonarchTokensProvider('custom', customLangMonarch as monaco.languages.IMonarchLanguage)

const editor = ref()

onMounted(() => {
	let monaco_editor = monaco.editor.create(editor.value, {
		value: `// Type source code in your language here...
class MyClass {
  @attribute
  void main() {
    Console.writeln("Hello Monarch World!\\n");
  }
}`,
		language: 'custom',
		theme: 'vs-dark',
		automaticLayout: true,
	});

	// monaco_editor.addOverlayWidget({
	// 	getId: () => 'my-widget',
	// 	getDomNode: () => {
	// 		const div = document.createElement('div')
	// 		div.innerHTML = 'Hello world'
	// 		return div
	// 	},
	// 	getPosition: () => null,
	// });

	monaco_editor.addAction({
		id: 'run-file',
		label: 'Run MemeAssembly file',
		keybindings: [
			monaco.KeyMod.CtrlCmd | monaco.KeyCode.KeyM,
			monaco.KeyMod.CtrlCmd | monaco.KeyCode.Enter,
		],
		contextMenuGroupId: 'navigation',
		contextMenuOrder: 1.5,
		run: () => alert('My action was triggered!')
	});
})
</script>

<template>
	<div id="editor" ref="editor"></div>
</template>

<style scoped>
#editor {
	text-align: left;
	width: 100%;
	height: 100%;
}
</style>
