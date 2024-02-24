<script setup lang="ts">
import { computed, onMounted, ref } from "vue";
import { onKeyDown } from '@vueuse/core'

const props = defineProps<{
  commands: {
    command: string,
    commandDetection: 'FULL' | 'BEGINS_WITH',
    run: (args?: string) => string
  }[],
  initalCommand?: string
}>()

const commandInput = ref("");
const speed = ref(25)
const commandInputRef = ref<HTMLInputElement | null>(null);
const scrollRef = ref<HTMLDivElement | null>(null);

const defaultCommands = ref<{
  command: string,
  commandDetection: 'FULL' | 'BEGINS_WITH',
  run: (args?: string) => string
}[]>([
  { command: "setting speed", commandDetection: 'BEGINS_WITH', run: (args) => {
    const newSpeed = parseInt(args || 'help')
    if (isNaN(newSpeed) || args === 'help') return '# Set the speed of the terminal text animation in MS. Default 25ms.\nUsage: setting speed <speed>'
    speed.value = newSpeed
    return `Speed set to ${newSpeed}ms`
  }}
]);

const allCommands = computed(() => {
  return [...props.commands, ...defaultCommands.value]
})

const fullHistory = ref<{command: string, args: string, result: string}[]>([]);

const filteredHistory = computed(() => {
  return fullHistory.value.filter((c) => c.command.length > 0)
})

const historyIndex = ref(filteredHistory.value.length);

const commandRunning = ref(false)

function scrollToBottom() {
  if (scrollRef.value) scrollRef.value.scrollTop = scrollRef.value?.scrollHeight;
}

async function runCommand() {
  commandRunning.value = true;

  if (commandInput.value.length === 0) {
    fullHistory.value.push({ command: "", args: "", result: "" });
    commandRunning.value = false;
    scrollToBottom()
    return;
  }

  const command = allCommands.value.find((c) => {
    if (c.commandDetection === 'FULL') return c.command === commandInput.value;
    if (c.commandDetection === 'BEGINS_WITH') return commandInput.value.startsWith(c.command);
    return false
  }) || {
    command: commandInput.value,
    run: () => `bash: command not found: ${commandInput.value}`
  };

  const commandArgs = commandInput.value.replace(command.command, "").trim();
  const fullResult = command.run(commandArgs)
  fullHistory.value.push({ command: command.command, args: commandArgs, result: "" });
  await new Promise((resolve) => {
    let interval: number;
    const keyListener = onKeyDown('Enter', (e) => {
      console.log(e.key)
      clearInterval(interval);
      fullHistory.value[fullHistory.value.length - 1].result = fullResult;
      resolve(null);
      keyListener()
    })
    interval = setInterval(() => {
      fullHistory.value[fullHistory.value.length - 1].result += fullResult[fullHistory.value[fullHistory.value.length - 1].result.length];
      if (fullHistory.value[fullHistory.value.length - 1].result.length === fullResult.length) {
        clearInterval(interval);
        keyListener()
        resolve(null);
      }
    }, speed.value);
  })
  commandInput.value = "";
  historyIndex.value = filteredHistory.value.length;
  commandRunning.value = false;
  setTimeout(() => {
    commandInputRef.value?.focus()
    scrollToBottom()
  }, 0)
}

function historyPrev() {
  historyIndex.value = historyIndex.value - 1;
  if (historyIndex.value < 0) {
    historyIndex.value = 0;
    // White flash?
  } else {
    const command = filteredHistory.value[historyIndex.value]
    commandInput.value = `${command.command} ${command.args}`.trim();
  }
}

function historyNext() {
  historyIndex.value = historyIndex.value + 1;
  if (historyIndex.value >= filteredHistory.value.length) {
    historyIndex.value = filteredHistory.value.length ;
    commandInput.value = "";
  } else {
    const command = filteredHistory.value[historyIndex.value]
    commandInput.value = `${command.command} ${command.args}`.trim();
  }
}

onMounted(() => {
  if (props.initalCommand) {
    commandInput.value = props.initalCommand;
    runCommand();
  }
})
</script>

<template>
  <div
    class="flex flex-col font-con bg-black text-white w-full h-full rounded-md px-6 pb-6"
    @click="commandInputRef?.focus()"
  >
    <div class="flex justify-center w-full py-3">bash ~ momme@world</div>
    <div class="overflow-y-auto h-full" ref="scrollRef">
      <template v-for="item in fullHistory">
        <div>momme@world~$ {{ `${item.command} ${item.args}`.trim() }}</div>
        <div v-for="line in item.result.split('\n')">{{ item.result.length > 1 && line.length === 0 ? '&#8203;' : line }}</div>
      </template>
      <div class="flex gap-3" v-if="!commandRunning">
        momme@world~$
        <input
          ref="commandInputRef"
          type="text"
          class="bg-transparent border-none w-full outline-none"
          v-model="commandInput"
          @keypress.enter="runCommand"
          @keydown.down.prevent="historyNext"
          @keydown.up.prevent="historyPrev"
        />
      </div>
    </div>
  </div>
</template>

<style scoped>
.font-con {
  font-family: Consolas, Monaco, "Andale Mono", "Ubuntu Mono", monospace;
}
</style>
