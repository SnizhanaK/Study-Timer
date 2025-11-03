<script setup>
import {ref, onMounted, onUnmounted} from "vue";
import {
  Cat,
  Flower,
  Sun,
  Moon,
  ChevronLeft,
  ChevronRight,
  Circle,
  CircleStar,
  Pause,
  Play,
  RotateCcw
} from "lucide-vue-next";

const isDark = ref(false);
const startMinutes = 25;
const timeLeft = ref(startMinutes * 60);
const isRunning = ref(false);
let interval = null;


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

function pastDay() {
  console.log("⬅️ previous day");
}

function nextDay() {
  console.log("➡️ next day");
}

function formatTime() {
  const m = String(Math.floor(timeLeft.value / 60)).padStart(2, "0");
  const s = String(timeLeft.value % 60).padStart(2, "0");
  return `${m}:${s}`;
}

function start() {
  if (isRunning.value) return;
  isRunning.value = true;
  interval = setInterval(() => {
    if (timeLeft.value > 0) timeLeft.value--;
    else pause();
  }, 1000);
}

function pause() {
  isRunning.value = false;
  clearInterval(interval);
}

function reset() {
  pause();
  timeLeft.value = startMinutes * 60;
}

onUnmounted(() => clearInterval(interval));

onMounted(() => applyTheme());
</script>

<template>
  <div class="flex items-center justify-center min-h-screen bg-gray-100">
    <div
        class="relative w-[390px] h-[780px] bg-white dark:bg-gray-900 text-black dark:text-white rounded-[2rem] shadow-2xl border border-gray-300 overflow-hidden transition-colors"
    >
      <div class="h-full p-6 flex flex-col justify-start gap-6">

        <div class="flex justify-between items-center">
          <div class="flex items-center gap-2">
            <button
                @click="cat"
                class="p-2 rounded-xl hover:scale-110 active:scale-95 transition cursor-pointer"
                aria-label="cat time"
            >
              <Cat class="w-6 h-6 text-gray-700 dark:text-gray-100"/>
            </button>

            <button
                @click="caramel"
                class="p-2 rounded-xl hover:scale-110 active:scale-95 transition cursor-pointer"
                aria-label="caramel time"
            >
              <Flower class="w-6 h-6 text-pink-500 dark:text-pink-300"/>
            </button>
          </div>

          <button
              @click="toggleTheme"
              class="p-2 rounded-xl hover:scale-110 active:scale-95 transition cursor-pointer"
              aria-label="Toggle theme"
          >
            <Sun v-if="!isDark" class="w-7 h-7 text-yellow-500"/>
            <Moon v-else class="w-7 h-7 text-gray-100"/>
          </button>
        </div>


        <div class="flex justify-between items-center mt-6">
          <button
              @click="pastDay"
              class="p-2 rounded-xl hover:scale-110 active:scale-95 transition cursor-pointer"
              aria-label="previous day"
          >
            <ChevronLeft class="w-6 h-6 text-gray-700 dark:text-gray-200"/>
          </button>

          <span class="font-serif text-lg font-bold">Wed 29 Oct</span>

          <button
              @click="nextDay"
              class="p-2 rounded-xl hover:scale-110 active:scale-95 transition cursor-pointer"
              aria-label="next day"
          >
            <ChevronRight class="w-6 h-6 text-gray-700 dark:text-gray-200"/>
          </button>
        </div>


        <div class="flex flex-col items-center justify-center gap-6">
          <div class="flex items-center justify-center">
      <span class="font-thin-italic text-7xl text-gray-700 dark:text-gray-100">
        {{ formatTime() }}
      </span>
          </div>


          <div class="flex items-center justify-center gap-0.5">
            <CircleStar class="w-4 h-4 text-gray-700 dark:text-gray-200"/>
            <CircleStar class="w-4 h-4 text-gray-700 dark:text-gray-200"/>
            <CircleStar class="w-4 h-4 text-gray-700 dark:text-gray-200"/>
            <CircleStar class="w-4 h-4 text-gray-700 dark:text-gray-200"/>
            <CircleStar class="w-4 h-4 text-gray-700 dark:text-gray-200"/>
            <CircleStar class="w-4 h-4 text-gray-700 dark:text-gray-200"/>
            <CircleStar class="w-4 h-4 text-gray-700 dark:text-gray-200"/>
            <Circle class="w-4 h-4 text-gray-700 dark:text-gray-200"/>
            <Circle class="w-4 h-4 text-gray-700 dark:text-gray-200"/>
            <Circle class="w-4 h-4 text-gray-700 dark:text-gray-200"/>
            <Circle class="w-4 h-4 text-gray-700 dark:text-gray-200"/>
            <Circle class="w-4 h-4 text-gray-700 dark:text-gray-200"/>
            <Circle class="w-4 h-4 text-gray-700 dark:text-gray-200"/>
          </div>

          <div class="flex items-center justify-center gap-4">
            <div class="flex items-center justify-center gap-4">
              <Play
                  v-if="!isRunning"
                  class="w-8 h-8 text-gray-700 dark:text-gray-200 cursor-pointer"
                  @click="start"
              />
              <Pause
                  v-else
                  class="w-7 h-7 text-gray-700 dark:text-gray-200 cursor-pointer"
                  @click="pause"
              />
              <RotateCcw
                  class="w-7 h-7 text-gray-700 dark:text-gray-200 cursor-pointer"
                  @click="reset"
              />
            </div>
          </div>

          <div class="flex justify-between items-center mt-5">
            <Cat class="w-6 h-6 text-gray-700 dark:text-gray-100"/>
            <input
                type="text"
                placeholder="So what are we going to do now?"
                class="border-0 border-b font-serif  text-gray-700 dark:text-gray-100 focus:outline-none w-72 pb-1"
            />
          </div>

          <div class="flex justify-center mt-10">
            <div class="w-72 h-50 overflow-y-auto border border-gray-300/70 rounded-md p-3">
              <ul class="space-y-4 font-serif text-gray-800 dark:text-gray-100">
                <li class="flex items-center gap-2">
                  <CircleStar class="w-5 h-5 text-gray-700 dark:text-gray-100"/>
                  <span>First item with an icon</span>
                </li>
                <li class="flex items-center gap-2">
                  <CircleStar class="w-5 h-5 text-gray-700 dark:text-gray-100"/>
                  <span>Second item with an icon</span>
                </li>
                <li class="flex items-center gap-2">
                  <CircleStar class="w-5 h-5 text-gray-700 dark:text-gray-100"/>
                  <span>Third item with an icon</span>
                </li>
                <li class="flex items-center gap-2">
                  <CircleStar class="w-5 h-5 text-gray-700 dark:text-gray-100"/>
                  <span>First item with an icon</span>
                </li>
                <li class="flex items-center gap-2">
                  <CircleStar class="w-5 h-5 text-gray-700 dark:text-gray-100"/>
                  <span>Second item with an icon</span>
                </li>
                <li class="flex items-center gap-2">
                  <CircleStar class="w-5 h-5 text-gray-700 dark:text-gray-100"/>
                  <span>Third item with an icon</span>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>

</style>