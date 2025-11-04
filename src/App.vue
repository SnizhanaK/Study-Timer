<script setup>
import { ref, computed, onMounted, onUnmounted } from "vue";
import {
  Cat,
  Flower,
  Heart,
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
const editingIndex = ref(null);
const editingText = ref("");


const accountId = ref(localStorage.getItem("accountId") || "cat");
const accountIconMap = { cat: Cat, caramel: Flower, both: Heart };
const currentAccountIcon = computed(() => accountIconMap[accountId.value] || Cat);

function switchAccount(id) {
  accountId.value = id;
  localStorage.setItem("accountId", id);
}

function cat() {
  switchAccount("cat");
}

function caramel() {
  switchAccount("caramel");
}

function both() {
  switchAccount("both");
}


const completedByAccount = ref(
    JSON.parse(localStorage.getItem("completedByAccount") || '{"cat":0,"caramel":0,"both":0}')
);
const completed = computed({
  get: () => Math.min(completedByAccount.value[accountId.value] ?? 0, TOTAL_MARKERS),
  set: (v) => {
    completedByAccount.value[accountId.value] = Math.max(0, Math.min(v, TOTAL_MARKERS));
    localStorage.setItem("completedByAccount", JSON.stringify(completedByAccount.value));
  },
});

const tasksByAccount = ref(
    JSON.parse(localStorage.getItem("tasksByAccount") || '{"cat":[],"caramel":[],"both":[]}')
);
const saveTasksAll = () => localStorage.setItem("tasksByAccount", JSON.stringify(tasksByAccount.value));
const taskInput = ref("");
const tasks = computed(() => tasksByAccount.value[accountId.value]);

// === THEME ===
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
      const id = accountId.value;
      const inc = (key) => {
        completedByAccount.value[key] = Math.min(
            (completedByAccount.value[key] ?? 0) + 1,
            TOTAL_MARKERS
        );
      };
      if (id === "both") {
        inc("both");
        inc("cat");
        inc("caramel");
      } else {
        inc(id);
      }
      localStorage.setItem("completedByAccount", JSON.stringify(completedByAccount.value));
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
  completed.value = 0;
  const id = accountId.value;
  tasksByAccount.value[id] = [];
  saveTasksAll();
  if (typeof editingIndex !== "undefined") {
    editingIndex.value = null;
    editingText.value = "";
  }
}

function skipForward() {
  const id = accountId.value;
  const inc = (key) => {
    completedByAccount.value[key] = Math.min(
        (completedByAccount.value[key] ?? 0) + 1,
        TOTAL_MARKERS
    );
  };
  if (id === "both") {
    inc("both");
    inc("cat");
    inc("caramel");
  } else {
    inc(id);
  }
  localStorage.setItem("completedByAccount", JSON.stringify(completedByAccount.value));
  addCurrentInputToList();
  pause();
  timeLeft.value = startMinutes * 60;
}


function addCurrentInputToList() {
  const v = taskInput.value.trim();
  if (!v) return;
  const id = accountId.value;
  if (id === "both") {
    tasksByAccount.value.both.unshift(v);
    tasksByAccount.value.cat.unshift(v);
    tasksByAccount.value.caramel.unshift(v);
  } else {
    tasksByAccount.value[id].unshift(v);
  }
  taskInput.value = "";
  saveTasksAll();
}

function removeTask(index) {
  const id = accountId.value;
  tasksByAccount.value[id].splice(index, 1);
  saveTasksAll();
  if (completed.value > 0) completed.value = completed.value - 1;
}

function startEditing(index) {
  editingIndex.value = index;
  editingText.value = tasks.value[index];
}

function saveEditing(index) {
  const text = editingText.value.trim();
  if (!text) return;
  tasks.value[index] = text;
  saveTasksAll();
  editingIndex.value = null;
  editingText.value = "";
}

onUnmounted(() => clearInterval(interval));
onMounted(() => applyTheme());
</script>

<template>
  <div class="flex items-center justify-center min-h-screen bg-black">
    <div class="relative w-[440px] h-[780px] bg-white dark:bg-gray-900 text-black dark:text-white shadow-2xl overflow-hidden transition-colors rounded-3xl">
     <div class="h-full p-6 flex flex-col justify-start gap-6">


        <div class="flex justify-between items-center">
          <div class="flex items-center gap-2">
            <button
                @click="cat"
                class="p-2 rounded-xl hover:scale-110 active:scale-95 transition cursor-pointer"
                :class="accountId==='cat' ? 'ring-2 ring-orange-500/60' : ''"
            >
              <Cat class="w-6 h-6 text-gray-700 dark:text-gray-200 cursor-pointer"/>
            </button>

            <button
                @click="caramel"
                class="p-2 rounded-xl hover:scale-110 active:scale-95 transition cursor-pointer"
                :class="accountId==='caramel' ? 'ring-2 ring-pink-500/60' : ''"
            >
              <Flower class="w-6 h-6  text-gray-700 dark:text-gray-200 cursor-pointer"/>
            </button>

            <button
                @click="both"
                class="p-2 rounded-xl hover:scale-110 active:scale-95 transition cursor-pointer"
                :class="accountId==='both' ? 'ring-2 ring-red-500/60' : ''"
            >
              <Heart class="w-6 h-6 text-gray-700 dark:text-red-600"/>
            </button>
          </div>

          <button
              @click="toggleTheme"
              class="p-2 rounded-xl hover:scale-110 active:scale-95 transition cursor-pointer"
          >
            <Sun v-if="!isDark" class="w-7 h-7 text-yellow-500"/>
            <Moon v-else class="w-7 h-7 text-gray-100"/>
          </button>
        </div>

        <!-- Timer -->
        <div class="flex justify-between items-center mt-6">
          <button class="p-2 rounded-xl hover:scale-110 active:scale-95 transition cursor-pointer">
            <ChevronLeft class="w-6 h-6 text-gray-700 dark:text-gray-200"/>
          </button>
          <span class="font-serif text-lg font-bold">Wed 29 Oct</span>
          <button class="p-2 rounded-xl hover:scale-110 active:scale-95 transition cursor-pointer">
            <ChevronRight class="w-6 h-6 text-gray-700 dark:text-gray-200"/>
          </button>
        </div>

        <div class="flex flex-col items-center justify-center gap-6">
          <div class="flex items-center justify-center">
            <span class="font-thin-italic text-8xl text-gray-700 dark:text-gray-100">{{ formatTime() }}</span>
          </div>

          <div class="flex items-center justify-center gap-0.5">
            <template v-for="i in TOTAL_MARKERS" :key="i">
              <CircleStar v-if="i <= completed" class="w-6 h-6 text-gray-700 dark:text-gray-200"/>
              <Circle v-else class="w-6 h-6 text-gray-700 dark:text-gray-200"/>
            </template>
          </div>

          <div class="flex items-center justify-center gap-8">
            <Play v-if="!isRunning" class="w-12 h-12 text-gray-700 dark:text-gray-200 cursor-pointer" @click="start" />
            <Pause v-else class="w-12 h-12 text-gray-700 dark:text-gray-200 cursor-pointer" @click="pause" />
            <SkipForward class="w-10 h-10 text-gray-700 dark:text-gray-200 cursor-pointer" @click="skipForward" />
            <RotateCcw class="w-10 h-10 text-gray-700 dark:text-gray-200 cursor-pointer" @click="reset" />
          </div>

          <!-- Input -->
          <div class="flex justify-between items-center mt-10 gap-4">
            <component :is="currentAccountIcon" class="w-8 h-8 text-gray-700 dark:text-gray-100"/>
            <input
                type="text"
                placeholder="So what are we going to do now?"
                class="border-0 border-b font-serif text-gray-700 dark:text-gray-100 focus:outline-none w-72 pb-1"
                v-model="taskInput"
            />
          </div>

          <!-- Tasks list -->
          <div class="flex justify-center mt-2">
            <div class="w-80 max-h-55 overflow-y-auto">
              <ul class="space-y-4 font-serif text-gray-800 dark:text-gray-100">
                <li
                    v-for="(item, idx) in tasks"
                    :key="idx"
                    class="flex items-center justify-between gap-2"
                >
                  <div class="flex items-center gap-2 w-full min-w-0">
                    <CircleStar class="w-5 h-5 text-gray-700 dark:text-gray-100" />

                    <template v-if="editingIndex === idx">
                      <input
                          v-model="editingText"
                          @keyup.enter="saveEditing(idx)"
                          @blur="saveEditing(idx)"
                          class="flex-1 min-w-0 bg-transparent border-b border-gray-400 dark:border-gray-600 focus:outline-none"
                          autofocus
                      />
                    </template>

                    <template v-else>
                      <span class="flex-1 min-w-0 break-all whitespace-pre-wrap">{{ item }}</span>
                    </template>
                  </div>

                  <div class="flex items-center gap-2 shrink-0">
                    <button
                        v-if="editingIndex !== idx"
                        @click="startEditing(idx)"
                        class="p-1 rounded-lg hover:scale-110 active:scale-95 transition-transform"
                    >
                      <Edit3 class="w-5 h-5 text-blue-500 dark:text-blue-600" />
                    </button>

                    <button
                        @click="removeTask(idx)"
                        class="p-1 rounded-lg hover:scale-110 active:scale-95 transition-transform"
                    >
                      <Trash2 class="w-5 h-5 text-red-500 dark:text-red-800" />
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