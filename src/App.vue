<script setup>
import {ref, onMounted, onUnmounted,} from "vue";
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
  RotateCcw,
  SkipForward,
  Edit3,
  Trash2
} from "lucide-vue-next";

const isDark = ref(false);
const startMinutes = 0.10;
const timeLeft = ref(startMinutes * 60);
const isRunning = ref(false);
let interval = null;
const TOTAL_MARKERS = 13;
const completed = ref(7);
const editingIndex = ref(null);
const editingText = ref("");

const savedCompleted = Number(localStorage.getItem("completed") || 0);
completed.value = Math.min(isNaN(savedCompleted) ? 0 : savedCompleted, TOTAL_MARKERS);
const taskInput = ref("");
const tasks = ref(JSON.parse(localStorage.getItem("tasks") || "[]"));

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
    if (timeLeft.value > 0) {
      timeLeft.value--;
    } else {
      completed.value = Math.min(completed.value + 1, TOTAL_MARKERS);
      localStorage.setItem("completed", String(completed.value));
      addCurrentInputToList();
      pause();
      timeLeft.value = startMinutes * 60;
    }
  }, 1000);
}

function pause() {
  isRunning.value = false;
  clearInterval(interval);
}

function reset() {
  pause();
  timeLeft.value = startMinutes * 60;

  if (completed.value >= TOTAL_MARKERS) {
    completed.value = 0;
    localStorage.setItem("completed", "0");
  }
  tasks.value = [];
  localStorage.setItem("tasks", "[]");
  if (typeof editingIndex !== "undefined") {
    editingIndex.value = null;
    editingText.value = "";
  }
}

function skipForward() {
  // Imitate a finished Pomodoro session
  completed.value = Math.min(completed.value + 1, TOTAL_MARKERS);
  localStorage.setItem("completed", String(completed.value));
  addCurrentInputToList();

  pause();
  timeLeft.value = startMinutes * 60;
}

function addCurrentInputToList() {
  const v = taskInput.value.trim();
  if (!v) return;
  tasks.value.unshift(v);
  taskInput.value = "";
  localStorage.setItem("tasks", JSON.stringify(tasks.value));
}

function removeTask(index) {
  tasks.value.splice(index, 1);
  localStorage.setItem("tasks", JSON.stringify(tasks.value));

  if (completed.value > 0) {
    completed.value--;
    localStorage.setItem("completed", String(completed.value));
  }
}

function startEditing(index) {
  editingIndex.value = index;
  editingText.value = tasks.value[index];
}

function saveEditing(index) {
  const text = editingText.value.trim();
  if (!text) return;
  tasks.value[index] = text;
  localStorage.setItem("tasks", JSON.stringify(tasks.value));
  editingIndex.value = null;
  editingText.value = "";
}

onUnmounted(() => clearInterval(interval));

onMounted(() => applyTheme());
</script>

<template>
  <div class="flex items-center justify-center min-h-screen bg-black">
    <div
        class="relative w-[440px] h-[780px] bg-white dark:bg-gray-900 text-black dark:text-white  shadow-2xl  overflow-hidden transition-colors"
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
      <span class="font-thin-italic text-8xl text-gray-700 dark:text-gray-100">
        {{ formatTime() }}
      </span>
          </div>

          <div class="flex items-center justify-center gap-0.5">
            <template v-for="i in TOTAL_MARKERS" :key="i">
              <CircleStar
                  v-if="i <= completed"
                  class="w-6 h-6 text-gray-700 dark:text-gray-200"
              />
              <Circle
                  v-else
                  class="w-4 h-4 text-gray-700 dark:text-gray-200"
              />
            </template>
          </div>


          <div class="flex items-center justify-center gap-8">
            <Play
                v-if="!isRunning"
                class="w-12 h-12 text-gray-700 dark:text-gray-200 cursor-pointer"
                @click="start"
            />
            <Pause
                v-else
                class="w-12 h-12 text-gray-700 dark:text-gray-200 cursor-pointer"
                @click="pause"
            />
            <SkipForward
                class="w-10 h-10 text-gray-700 dark:text-gray-200 cursor-pointer"
                @click="skipForward"
            />
            <RotateCcw
                class="w-10 h-10 text-gray-700 dark:text-gray-200 cursor-pointer"
                @click="reset"
            />
          </div>


          <div class="flex justify-between items-center mt-10 gap-4">
            <Cat class="w-6 h-6 text-gray-700 dark:text-gray-100"/>
            <input
                type="text"
                placeholder="So what are we going to do now?"
                class="border-0 border-b font-serif  text-gray-700 dark:text-gray-100 focus:outline-none w-64 pb-1"
                v-model="taskInput"
            />
          </div>

          <div class="flex justify-center mt-2">
            <div class="w-80 h-55 overflow-y-auto">
              <ul class="space-y-4 font-serif text-gray-800 dark:text-gray-100">
                <li
                    v-for="(item, idx) in tasks"
                    :key="idx"
                    class="flex items-center justify-between gap-2"
                >
                  <div class="flex items-center gap-2 w-full min-w-0">
                    <CircleStar class="w-5 h-5 text-gray-700 dark:text-gray-100"/>

                    <template v-if="editingIndex === idx">
                      <input
                          v-model="editingText"
                          @keyup.enter="saveEditing(idx)"
                          @blur="saveEditing(idx)"
                          class="bg-transparent border-b border-gray-400 dark:border-gray-600 focus:outline-none flex-1 min-w-0"
                          autofocus
                      />
                    </template>

                    <template v-else>

                      <span class="flex-1 min-w-0 break-all whitespace-pre-wrap">
          {{ item }}
        </span>
                    </template>
                  </div>

                  <div class="flex items-center gap-2">
                    <button
                        v-if="editingIndex !== idx"
                        @click="startEditing(idx)"
                        class="p-1 rounded-lg hover:scale-110 active:scale-95 transition"
                        title="Edit task"
                    >
                      <Edit3 class="w-5 h-5 text-blue-500 dark:text-blue-600"/>
                    </button>
                    <button
                        @click="removeTask(idx)"
                        class="p-1 rounded-lg hover:scale-110 active:scale-95 transition"
                        title="Delete task"
                    >
                      <Trash2 class="w-5 h-5 text-red-500 dark:text-red-800"/>
                    </button>
                  </div>
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