<script setup>
import { ref, computed, onMounted, onUnmounted, watch } from "vue";
import {
  Cat, Flower, Heart, Sun, Moon, ChevronLeft, ChevronRight, Circle, CircleStar,
  Pause, Play, RotateCcw, SkipForward, Edit3, Trash2
} from "lucide-vue-next";

/* ---------- theme ---------- */
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

/* ---------- timer ---------- */
const startMinutes = 25;
const timeLeft = ref(startMinutes * 60);
const isRunning = ref(false);
let interval = null;
const TOTAL_MARKERS = 13;

const manualTime = ref("");
const isEditingTime = ref(false);

const accountId = ref(localStorage.getItem("accountId") || "cat");
const accountIconMap = { cat: Cat, caramel: Flower, both: Heart };
const currentAccountIcon = computed(() => accountIconMap[accountId.value] || Cat);
function switchAccount(id) { accountId.value = id; localStorage.setItem("accountId", id); }
const cat = () => switchAccount("cat");
const caramel = () => switchAccount("caramel");
const both = () => switchAccount("both");

function stripTime(d) { return new Date(d.getFullYear(), d.getMonth(), d.getDate()); }
function dateKey(d) { return `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,"0")}-${String(d.getDate()).padStart(2,"0")}`; }
function addDaysJs(d,n){const nd=new Date(d);nd.setDate(nd.getDate()+n);return stripTime(nd);}
const today=new Date();
const currentDate=ref(stripTime(new Date()));
const headerLabel=computed(()=>new Intl.DateTimeFormat("en-US",{weekday:"short",day:"2-digit",month:"short"}).format(currentDate.value));
const isTodayActive=computed(()=>dateKey(currentDate.value)===dateKey(new Date()));

const stateByAccountDate=ref(JSON.parse(localStorage.getItem("stateByAccountDate")||'{"cat":{},"caramel":{},"both":{}}'));
function persistState(){localStorage.setItem("stateByAccountDate",JSON.stringify(stateByAccountDate.value));}
function ensureDayState(id,d){const k=dateKey(d);stateByAccountDate.value[id]||={};stateByAccountDate.value[id][k]||={completed:0,tasks:[],timeLeft:startMinutes*60};return stateByAccountDate.value[id][k];}
function getDayState(id=accountId.value,d=currentDate.value){return ensureDayState(id,d);}

const completed=computed({
  get:()=>Math.min(getDayState().completed,TOTAL_MARKERS),
  set:v=>{getDayState().completed=Math.max(0,Math.min(v,TOTAL_MARKERS));persistState();}
});

const taskInput=ref("");
const tasks=computed(()=>getDayState().tasks);
const editingIndex=ref(null);
const editingText=ref("");
function saveTasksAll(){persistState();}
function addCurrentInputToList(){
  const v=taskInput.value.trim(); if(!v)return;
  const id=accountId.value; const push=k=>getDayState(k).tasks.unshift(v);
  if(id==="both"){push("both");push("cat");push("caramel");} else push(id);
  taskInput.value=""; persistState();
}
function removeTask(i){const st=getDayState();st.tasks.splice(i,1);persistState();if(completed.value>0)completed.value--;}
function startEditing(i){editingIndex.value=i;editingText.value=tasks.value[i];}
function saveEditing(i){const t=editingText.value.trim();if(!t)return;tasks.value[i]=t;saveTasksAll();editingIndex.value=null;editingText.value="";}

function formatTime(){
  const m=String(Math.floor(timeLeft.value/60)).padStart(2,"0");
  const s=String(timeLeft.value%60).padStart(2,"0");
  return `${m}:${s}`;
}

/* --- inline edit time --- */
function startInlineEditTime(){
  manualTime.value=formatTime();
  isEditingTime.value=true;
}
function applyManualTime(){
  const parts=manualTime.value.split(":").map(Number);
  let total=0;
  if(parts.length===1) total=parts[0]*60;
  else if(parts.length===2) total=parts[0]*60+parts[1];
  if(total>0){
    timeLeft.value=total;
    const st=getDayState();
    st.timeLeft=total;
    persistState();
  }
  isEditingTime.value=false;
}
function onInlineTimeKey(e){
  if(e.key==="Enter")applyManualTime();
  else if(e.key==="Escape")isEditingTime.value=false;
}

/* --- helpers --- */
function ensureDefaultTask(){if(!taskInput.value.trim())taskInput.value="study";}
function playBeep(){
  const Ctx=window.AudioContext||window.webkitAudioContext; if(!Ctx)return;
  const ctx=new Ctx();
  function tone(freq,dur,delay=0){
    const osc=ctx.createOscillator();const gain=ctx.createGain();
    osc.type="triangle";osc.frequency.value=freq;osc.connect(gain);gain.connect(ctx.destination);
    const t=ctx.currentTime+delay/1000;
    gain.gain.setValueAtTime(0.001,t);
    gain.gain.exponentialRampToValueAtTime(0.25,t+0.01);
    gain.gain.exponentialRampToValueAtTime(0.001,t+dur/1000);
    osc.start(t);osc.stop(t+dur/1000);
  }
  tone(880,180,0);tone(660,220,220);
}

/* --- timer control --- */
function start(){
  if(isRunning.value)return;
  isRunning.value=true;
  interval=setInterval(()=>{
    if(timeLeft.value>0){
      timeLeft.value--;
      getDayState().timeLeft=timeLeft.value;
      persistState();
    } else {
      ensureDefaultTask();playBeep();
      applyCompletionForCurrentSelection();addCurrentInputToList();
      pause();resetOnlyTimer();
    }
  },1000);
}
function pause(){isRunning.value=false;clearInterval(interval);}
function resetOnlyTimer(){timeLeft.value=startMinutes*60;getDayState().timeLeft=timeLeft.value;persistState();}
function reset(){
  pause();const st=getDayState();
  if(st.completed>=TOTAL_MARKERS){st.completed=0;st.tasks=[];}
  st.timeLeft=startMinutes*60;timeLeft.value=st.timeLeft;
  editingIndex.value=null;editingText.value="";
  persistState();
}
function applyCompletionForCurrentSelection(){
  const id=accountId.value;const inc=k=>{const st=getDayState(k);st.completed=Math.min((st.completed??0)+1,TOTAL_MARKERS);};
  if(id==="both"){inc("both");inc("cat");inc("caramel");} else inc(id);persistState();
}
function skipForward(){
  ensureDefaultTask();applyCompletionForCurrentSelection();addCurrentInputToList();
  pause();resetOnlyTimer();
}

/* --- navigation --- */
function gotoPrevDay(){navigateToDay(addDaysJs(currentDate.value,-1));}
function gotoNextDay(){navigateToDay(addDaysJs(currentDate.value,1));}
function navigateToDay(d){
  pause();currentDate.value=stripTime(d);
  const st=getDayState();timeLeft.value=typeof st.timeLeft==="number"?st.timeLeft:startMinutes*60;
  editingIndex.value=null;editingText.value="";
}

/* --- account switch --- */
watch(accountId,()=>ensureDayState(accountId.value,currentDate.value));

/* --- lifecycle --- */
onMounted(()=>{applyTheme();timeLeft.value=getDayState().timeLeft;});
onUnmounted(()=>clearInterval(interval));
</script>

<template>
  <div class="flex items-center justify-center min-h-screen bg-black">
    <div class="relative w-[440px] h-[780px] bg-white dark:bg-gray-900 text-black dark:text-white shadow-2xl overflow-hidden rounded-3xl">
      <div class="h-full p-6 flex flex-col justify-start gap-6">

        <!-- Top bar -->
        <div class="flex justify-between items-center">
          <div class="flex items-center gap-2">
            <button @click="cat" class="p-2 rounded-xl hover:scale-110 active:scale-95 transition" :class="accountId==='cat' ? 'ring-2 ring-orange-500/60' : ''">
              <Cat class="w-6 h-6 text-gray-700 dark:text-gray-200"/>
            </button>
            <button @click="caramel" class="p-2 rounded-xl hover:scale-110 active:scale-95 transition" :class="accountId==='caramel' ? 'ring-2 ring-pink-500/60' : ''">
              <Flower class="w-6 h-6 text-gray-700 dark:text-gray-200"/>
            </button>
            <button @click="both" class="p-2 rounded-xl hover:scale-110 active:scale-95 transition" :class="accountId==='both' ? 'ring-2 ring-red-500/60' : ''">
              <Heart class="w-6 h-6 text-gray-700 dark:text-red-600"/>
            </button>
          </div>
          <button @click="toggleTheme" class="p-2 rounded-xl hover:scale-110 active:scale-95 transition">
            <Sun v-if="!isDark" class="w-7 h-7 text-yellow-500"/>
            <Moon v-else class="w-7 h-7 text-gray-100"/>
          </button>
        </div>

        <!-- Date navigation -->
        <div class="flex justify-between items-center mt-6">
          <button @click="gotoPrevDay" class="p-2 rounded-xl hover:scale-110 active:scale-95 transition">
            <ChevronLeft class="w-7 h-7 text-gray-700 dark:text-gray-200"/>
          </button>
          <span class="font-serif text-lg font-bold px-3 py-1 rounded-xl"
                :class="isTodayActive ? 'text-orange-800 dark:text-orange-800' : ''">
            {{ headerLabel }}
          </span>
          <button @click="gotoNextDay" class="p-2 rounded-xl hover:scale-110 active:scale-95 transition">
            <ChevronRight class="w-7 h-7 text-gray-700 dark:text-gray-200"/>
          </button>
        </div>

        <!-- Timer -->
        <div class="flex flex-col items-center justify-center gap-6">
          <div class="flex items-center justify-center">
            <!-- normal display -->
            <span
                v-if="!isEditingTime"
                @click="startInlineEditTime"
                class="font-thin-italic text-8xl text-gray-700 dark:text-gray-100 cursor-pointer select-none"
            >
              {{ formatTime() }}
            </span>
            <!-- edit mode -->
            <input
                v-else
                v-model="manualTime"
                @keyup="onInlineTimeKey"
                @blur="applyManualTime"
                class="text-8xl text-center font-thin-italic text-gray-700 dark:text-gray-100 bg-transparent focus:outline-none w-[10ch]"
                style="border:none;outline:none;"
                autofocus
            />
          </div>

          <div class="flex items-center justify-center gap-0.5">
            <template v-for="i in TOTAL_MARKERS" :key="i">
              <CircleStar v-if="i <= completed" class="w-6 h-6 text-gray-700 dark:text-gray-200"/>
              <Circle v-else class="w-6 h-6 text-gray-700 dark:text-gray-200"/>
            </template>
          </div>

          <div class="flex items-center justify-center gap-8">
            <Play v-if="!isRunning" class="w-12 h-12 text-gray-700 dark:text-gray-200 cursor-pointer" @click="start"/>
            <Pause v-else class="w-12 h-12 text-gray-700 dark:text-gray-200 cursor-pointer" @click="pause"/>
            <SkipForward class="w-10 h-10 text-gray-700 dark:text-gray-200 cursor-pointer" @click="skipForward"/>
            <RotateCcw class="w-10 h-10 text-gray-700 dark:text-gray-200 cursor-pointer" @click="reset"/>
          </div>

          <div class="flex justify-between items-center mt-10 gap-4">
            <component :is="currentAccountIcon" class="w-8 h-8 text-gray-700 dark:text-gray-100"/>
            <input
                type="text"
                placeholder="So what are we going to do now?"
                class="border-0 border-b font-serif text-gray-700 dark:text-gray-100 focus:outline-none w-72 pb-1"
                v-model="taskInput"
            />
          </div>

          <div class="flex justify-center mt-2">
            <div class="w-80 max-h-55 overflow-y-auto">
              <ul class="space-y-4 font-serif text-gray-800 dark:text-gray-100">
                <li v-for="(item, idx) in tasks" :key="idx" class="flex items-center justify-between gap-2">
                  <div class="flex items-center gap-2 w-full min-w-0">
                    <CircleStar class="w-5 h-5 text-gray-700 dark:text-gray-100"/>
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
                    <button v-if="editingIndex !== idx" @click="startEditing(idx)" class="p-1 rounded-lg hover:scale-110 active:scale-95 transition-transform">
                      <Edit3 class="w-5 h-5 text-blue-500 dark:text-blue-600"/>
                    </button>
                    <button @click="removeTask(idx)" class="p-1 rounded-lg hover:scale-110 active:scale-95 transition-transform">
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