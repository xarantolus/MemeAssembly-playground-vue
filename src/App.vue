<script lang="ts">
import { defineComponent } from 'vue';
import Grid from './components/Grid.vue';

export default defineComponent({
  name: 'App',
  components: {
    Grid
  },
});
</script>

<template>
  <Suspense>
    <Grid />
  </Suspense>
</template>
