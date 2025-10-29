<script setup>
import { ref, onMounted } from "vue";
import { Cat, Flower, Sun, Moon } from "lucide-vue-next";

const isDark = ref(false);


function applyTheme() {
  isDark.value =
      localStorage.theme === "dark" ||
      (!("theme" in localStorage) && window.matchMedia("(prefers-color-scheme: dark)").matches);
  document.documentElement.classList.toggle("dark", isDark.value);
}

function toggleTheme() {
  isDark.value = !isDark.value;
  document.documentElement.classList.toggle("dark", isDark.value);
  localStorage.theme = isDark.value ? "dark" : "light";
}

function cat() {
  console.log("Cat time 🐱");
}

function caramel() {
  console.log("Flower time 🌸");
}

onMounted(() => applyTheme());
</script>

<template>
  <div class="flex items-center justify-center min-h-screen bg-gray-100">
    <div
        class="relative w-[390px] h-[780px] bg-white dark:bg-gray-900 text-black dark:text-white rounded-[2rem] shadow-2xl border border-gray-300 overflow-hidden transition-colors"
    >
      <div class="h-full p-8 relative">

        <button
            @click="toggleTheme"
            class="absolute top-3 right-3 p-3 rounded-xl  hover:scale-110 active:scale-95 transition cursor-pointer"
            aria-label="Toggle theme"
        >
          <Sun v-if="!isDark" class="w-7 h-7 text-yellow-500" />
          <Moon v-else class="w-7 h-7 text-gray-100" />
        </button>

        <button
            @click="cat"
            class="absolute top-4 left-4 p-2 rounded-xl  hover:scale-110 active:scale-95 transition cursor-pointer"
            aria-label="cat time"
        >
          <Cat class="w-6 h-6 text-gray-700 dark:text-gray-100" />
        </button>

        <button
            @click="caramel"
            class="absolute top-4 left-15 p-2 rounded-xl  hover:scale-110 active:scale-95 transition cursor-pointer"
            aria-label="caramel time"
        >
          <Flower class="w-6 h-6 text-pink-500 dark:text-pink-300" />
        </button>

        <div>
          <div>
            <button
                @click="pastDay"
                class="absolute top-4 left-15 p-2 rounded-xl  hover:scale-110 active:scale-95 transition cursor-pointer"
                aria-label="caramel time"
            >
              <Flower class="w-6 h-6 text-pink-500 dark:text-pink-300" />
            </button>
          </div>
          <h1 class="mt-12 text-1xl font-bold">Hello world</h1>
          <div>
            <button
                @click="pastDay"
                class="absolute top-4 left-15 p-2 rounded-xl  hover:scale-110 active:scale-95 transition cursor-pointer"
                aria-label="caramel time"
            >
              <Flower class="w-6 h-6 text-pink-500 dark:text-pink-300" />
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>

</style>