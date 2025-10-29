<script setup>
import { onMounted } from "vue";

function applyTheme() {
  if (
      localStorage.theme === "dark" ||
      (!("theme" in localStorage) && window.matchMedia("(prefers-color-scheme: dark)").matches)
  ) {
    document.documentElement.classList.add("dark");
  } else {
    document.documentElement.classList.remove("dark");
  }
}

function toggleTheme() {
  const isDark = document.documentElement.classList.toggle("dark");
  localStorage.theme = isDark ? "dark" : "light";
}

onMounted(() => applyTheme());
</script>

<template>
  <div class="bg-white dark:bg-gray-900 text-black dark:text-white min-h-screen p-8">
    <button
        @click="toggleTheme"
        class="fixed top-4 right-4 bg-gray-200 dark:bg-gray-700 text-sm px-3 py-2 rounded"
    >
      Toggle theme
    </button>

    <h1 class="text-2xl font-bold">Hello world</h1>
    <p class="text-emerald-900 dark:text-emerald-300 mt-4">Dark mode toggle works!</p>
  </div>
</template>

<style scoped>
</style>

