<script lang="ts">
import Terminal from './components/Terminal.vue';
import Editor from './components/Editor.vue';
import { defineComponent, ref } from 'vue'

export default defineComponent({
  name: 'App',
  components: {
    Terminal,
    Editor
  },
  setup() {
    const terminal = ref<InstanceType<typeof Terminal> | null>(null);
    return {
      terminal
    }
  },
  methods: {
  }
})
</script>

<template>
  <div class="fullwindow grid-layout">
    <Editor class="grid-editor" />
    <Terminal ref="terminal" class="grid-terminal" />
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

