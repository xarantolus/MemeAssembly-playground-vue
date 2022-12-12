<template>
	<div id="editor" ref="editorHTMLElement"></div>
</template>

<script lang="ts">
import * as monaco from 'monaco-editor'
import editorWorker from 'monaco-editor/esm/vs/editor/editor.worker?worker'
import { ref, onMounted, defineComponent, PropType, Ref } from 'vue'
import { Terminal as XTerm } from 'xterm';
import Terminal from '../components/Terminal.vue';
import { configuration, createSnippets } from '../assets/memeasm';

import * as example from '../example-programs';

export default defineComponent({
	name: 'Editor',
	props: {
		text: {
			type: String,
		},
		runFunction: {
			type: Function as PropType<(text: string) => Promise<void>>,
			required: true
		},
		consoleTextFunction: {
			type: Function as PropType<(text: string) => void>,
			required: true
		},
		consoleResetFunction: {
			type: Function as PropType<() => void>,
			required: true
		},
		translationFunction: {
			type: Function as PropType<(code: string, consoleOutput: (s: string) => void) => Promise<string>>,
			required: true
		},
	},
	setup(props, context) {
		monaco.languages.register({
			id: 'memeasm',
			extensions: ['.memeasm'],
			aliases: ['memeasm', 'Memeasm', "MemeAssembly"],
		});
		monaco.languages.setLanguageConfiguration('memeasm', configuration)


		const editorHTMLElement = ref<HTMLElement | null>()
		self.MonacoEnvironment = {
			getWorker(_: string, label: string) {
				return new editorWorker()
			},
		}

		let monaco_editor: monaco.editor.IStandaloneCodeEditor | null = null;

		onMounted(() => {
			if (!editorHTMLElement.value) throw new Error("Editor HTML element not found")

			monaco_editor = monaco.editor.create(editorHTMLElement.value, {
				value: props.text ?? localStorage.getItem("editor_text_content") ?? example.reverseStringProgram,
				language: 'memeasm',
				theme: 'vs-dark',
				automaticLayout: true,
				contextmenu: true,
			});

			monaco_editor.onDidChangeModelContent((e) => {
				localStorage.setItem("editor_text_content", monaco_editor!.getValue())
			})

			monaco_editor.addOverlayWidget({
				getId() { return "bottom-navigation" },
				getDomNode: () => {
					// Create a run button
					let runButton = document.createElement("button");
					runButton.innerText = "Run"
					runButton.className = "button run-button";

					runButton.onclick = async () => {
						if (!monaco_editor) return;

						runButton.disabled = true;

						try {
							await props.runFunction(monaco_editor!.getValue({
								lineEnding: "\n",
								preserveBOM: false,
							}));
						} catch (e) {
							props.consoleTextFunction("Error: " + e);
							console.error("Editor: Running \"Run\" function:", e);
						} finally {
							runButton.disabled = false;
						}
					};


					let translationButton = document.createElement("button");
					translationButton.innerText = "Translate"
					translationButton.className = "button translate-button";

					translationButton.onclick = async () => {
						if (!monaco_editor) return;

						translationButton.disabled = true;

						try {
							props.consoleResetFunction();

							let translation = await props.translationFunction(monaco_editor!.getValue({
								lineEnding: "\n",
								preserveBOM: false,
							}), (s) => {
								console.log(s);
							});

							props.consoleTextFunction(translation);
						} catch (e) {
							console.error("Editor: Running \"Translate\" function:", e);
							props.consoleTextFunction("Error: " + e);
						} finally {
							translationButton.disabled = false;
						}
					};

					let div = document.createElement("div");
					div.appendChild(translationButton);
					div.appendChild(runButton);

					return div;
				},
				getPosition() {
					return {
						preference: monaco.editor.OverlayWidgetPositionPreference.TOP_RIGHT_CORNER
					}
				}
			});

			// Add a dropdown to select an example program
			monaco_editor.addOverlayWidget({
				getId() { return "select-example" },
				getDomNode: () => {
					let node = document.createElement("select");
					node.className = "select-example";

					let none = document.createElement("option");
					none.innerText = "Select an example program";
					none.value = "";
					node.appendChild(none);


					let alphabetProgramOption = document.createElement("option");
					alphabetProgramOption.value = example.alphabetProgram;
					alphabetProgramOption.innerText = "Alphabet Program";
					node.appendChild(alphabetProgramOption);

					let reverseStringProgramOption = document.createElement("option");
					reverseStringProgramOption.value = example.reverseStringProgram;
					reverseStringProgramOption.innerText = "Reverse String Program";
					node.appendChild(reverseStringProgramOption);

					let toBinaryProgramOption = document.createElement("option");
					toBinaryProgramOption.value = example.toBinaryProgram;
					toBinaryProgramOption.innerText = "To Binary Program";
					node.appendChild(toBinaryProgramOption);

					let toHexProgramOption = document.createElement("option");
					toHexProgramOption.value = example.toHexProgram;
					toHexProgramOption.innerText = "To Hex Program";
					node.appendChild(toHexProgramOption);

					node.onchange = () => {
						if (!monaco_editor || !node.value) return;
						monaco_editor.setValue(node.value);
					}

					return node;
				},
				getPosition() {
					return {
						preference: monaco.editor.OverlayWidgetPositionPreference.BOTTOM_RIGHT_CORNER
					}
				}
			});
		})

		return {
			editorHTMLElement,
			monaco_editor
		}
	},
});
</script>

<style scoped>
.wrap,
#editor {
	text-align: left;
	width: 100%;
	height: 100%;
}
</style>

<style>
.button {
	margin: 1em;
	padding: 0.5em 1em;
	border: none;
	border-radius: 0.5em;
	color: white;
	font-size: 1em;
	font-weight: bold;
	cursor: pointer;
	min-width: 10%;
}

.run-button {
	background-color: #007acc;
}

.reset-text-button {
	background-color: #944242;
}

.button:disabled {
	background-color: #999;
	cursor: not-allowed;
}
</style>
