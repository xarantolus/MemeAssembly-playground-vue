<script setup lang="ts">
// This starter template is using Vue 3 <script setup> SFCs
// Check out https://vuejs.org/api/sfc-script-setup.html#script-setup
import HelloWorld from './components/HelloWorld.vue'
import Terminal from './components/Terminal.vue';
import Editor from './components/Editor.vue';
</script>

<template>
  <div class="fullwindow grid-layout">
    <Editor class="grid-editor" />
    <Terminal class="grid-terminal" />
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

