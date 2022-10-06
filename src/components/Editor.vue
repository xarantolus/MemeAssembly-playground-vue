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

const defaultText = `I like to have fun, fun, fun, fun, fun, fun, fun, fun, fun, fun main

    sneak 100 rbx

    What the hell happened here? rcx counts how many characters have been read
    sneak 100 rcx

    upgrade

        What the hell happened here? Read one character from stdin
        let me in. LET ME IIIIIIIIN bl

        What the hell happened here? Check if it's the end of a line
        corporate needs you to find the difference between bl and \\n

        What the hell happened here? If not, we just push it to the stack (very efficient lol)
        stonks rbx
        upvote rcx

    fuck go back

    they're the same picture


    What the hell happened here? Now write what we've seen
    banana

        What the hell happened here? Check if we have reached the end of the input
        who would win? rcx or 0

        0 wins
            What the hell happened here? rcx is <= 0, jump to end of program
            return to monke uaaaaaua

        rcx wins
            What the hell happened here? rcx > 0, get the character and print it to stdout

            not stonks rbx
            what can I say except bl

            downvote rcx

    where banana

    monke uaaaaaua

    what can I say except \\n

    I see this as an absolute win

`

export default defineComponent({
	name: 'Editor',
	props: {
		text: {
			type: String,
			default: defaultText
		},
		runFunction: {
			type: Function as PropType<(text: string) => Promise<void>>,
			required: true
		}
	},
	setup(props, context) {
		monaco.languages.register({ id: 'memeasm', extensions: ['.memeasm'], aliases: ['memeasm', 'Memeasm', "MemeAssembly"] });
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
				value: props.text,
				language: 'memeasm',
				theme: 'vs-dark',
				automaticLayout: true,
				contextmenu: true,
			});

			// Add bottom navigation bar as widget
			monaco_editor.addOverlayWidget({
				getId() { return "bottom-navigation" },
				getDomNode: () => {
					// Create a run button
					let node = document.createElement("button");
					node.innerText = "Run"
					node.className = "run-button";
					node.onclick = async () => {
						if (!monaco_editor) return;

						node.disabled = true;

						try {
							await props.runFunction(monaco_editor!.getValue({
								lineEnding: "\n",
								preserveBOM: false,
							}));
						} catch (e) {
							console.error("Editor: Running \"Run\" function:", e);
						} finally {
							node.disabled = false;
						}
					};
					return node;
				},
				getPosition() {
					return {
						preference: monaco.editor.OverlayWidgetPositionPreference.TOP_RIGHT_CORNER
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
.run-button:disabled {
	background-color: #999;
	cursor: not-allowed;
}
</style>
