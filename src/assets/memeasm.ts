import * as monaco from 'monaco-editor/esm/vs/editor/editor.api'

let configuration: monaco.languages.LanguageConfiguration = {
	"comments": {
		lineComment: "What the hell happened here?",
	},
	// symbols used as brackets
	"brackets": [],
	// symbols that are auto closed when typing
	"autoClosingPairs": [],
	// symbols that can be used to surround a selection
	"surroundingPairs": [],
	// If we don't add a pattern that includes "//", the comment suggestion snippet won't work
	"wordPattern": new RegExp("(\\b(\\S|\\s){2,}\\b|\\S)")
}

import snippets_raw from './snippets.json';

function createSnippets(range: monaco.IRange) {
	let snippets: monaco.languages.CompletionItem[] = [];
	for (let key of Object.keys(snippets_raw)) {
		let snippet = (snippets_raw as any)[key];
		snippets.push({
			label: key,
			kind: monaco.languages.CompletionItemKind.Snippet,
			insertText: snippet.body.join('\n'),
			documentation: snippet.description,
			range: range
		});
	}
	console.log(snippets);

	return snippets;
}


export {
	configuration,
	createSnippets
}
