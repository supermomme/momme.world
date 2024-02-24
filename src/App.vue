<script setup lang="ts">
import { ref } from "vue";
import CommandLine from "./components/CommandLine.vue";

const commandLine = ref<InstanceType<typeof CommandLine> | null>(null);

const commands = ref<InstanceType<typeof CommandLine>["$props"]["commands"]>([
  { command: "hello", commandDetection: 'FULL', run: () => `Hello World! I'm Momme :)\n\nType "whoami" for more information about this human.\nGet to know me on socials with command "social"\nOr explore this cli with the "help" command\n\nThis website is still WIP. Don't expect much.\n\nHappy hacking :)` },
  { command: "whoami", commandDetection: 'FULL', run: () => `I am Momme\nI do IT stuff\nWork at codeanker\nFlying FPV-Drones\nExperimenting with nixos, kubernetes, vpn and more\nIf you want to know more about specific projects, try to run "project <name>". Maybe you get lucky :)` },
  { command: "social", commandDetection: 'FULL', run: () => `You can find me on\nInstagram: @supermommej\nGithub: supermomme\nMastodon: @momme@cybre.town\n\nI'm not very active on socials, but I try to share some insights and projects there. Feel free to follow me :)` },
  { command: "project", commandDetection: 'BEGINS_WITH', run: (args) => {
    if (args === 'nixos') return `nixos a linux distribution with a unique package manager and configuration system. I'm using it to manage some of my servers. You can find most of my config on GitHub in the Repository "nix-config".`
    if (args === 'kubernetes') return `I'm experimenting with kubernetes to learn more about container orchestration and to host my own services. It's a complex system, but it's fun to work with. I use varios tools for deployment like pulumi or knative.`
    if (args === 'vpn') return `I'm using simple vpn-tools like tailscale or netbird to connect my devices and servers. It's a simple and fast vpn solution.`
    if (args === 'list') return '# Get more information about a specific project\nUsage: project <name>\nSome Projects:\n - nixos\n - kubernetes\n - vpn\n - fpv'
    return `I don't have a project called "${args}". Try to run "project list" to get more information about the available projects.`
  }},
  { command: "contact", commandDetection: 'FULL', run: () => `You can contact me via some of the following channels:\n Mail: momme@juergensen.me\nMatrix: @momme:chaos.jetzt\n\nGet in touch with me if you have any questions.`},
  { command: "exit", commandDetection: 'FULL', run: () => {
    window.close()
    return `Bye!`
  }},
  { command: "help", commandDetection: 'FULL', run: () => `Available commands:\n- hello\n- whoami\n- contact\n- social\n- project\n- setting speed\n- help\n\nType "help <command>" to get more information about a specific command` },
  { command: "help", commandDetection: 'BEGINS_WITH', run: (args) => {
    if (args === 'help') return '# Get more information about a specific command\nUsage: help <command>'
    if (args === 'hello') return `Prints a welcome message\nUsage: hello`
    if (args === 'whoami') return `Prints information about me\nUsage: whoami`
    if (args === 'contact') return `Prints information about me\nUsage: contact`
    if (args === 'social') return `Prints my social media links\nUsage: social`
    if (args === 'project') return `Get more information about a specific project\nUsage: project <name or "list">`
    if (args === 'setting speed') return `Set the speed of the terminal text animation\nUsage: setting speed <speed>`
    if (args === 'help') return `Get more information about a specific command`
    return `I don't have a command called "${args}". Try to run "help" to get more information about the available commands.`
  }},
  { command: "cat", commandDetection: 'FULL', run: () => `Meow!` },
  { command: "dog", commandDetection: 'FULL', run: () => `Woof!` },
  { command: "clear", commandDetection: 'FULL', run: () => {
    commandLine.value?.clearHistory()
    return null
  }},
  { command: "ls", commandDetection: 'FULL', run: () => `empty`},
  { command: "time", commandDetection: 'FULL', run: () => new Date().toLocaleTimeString('de') },
  { command: "date", commandDetection: 'FULL', run: () => new Date().toLocaleDateString('de') },
  { command: "echo", commandDetection: 'BEGINS_WITH', run: (args) => {
    return args || ''
  }},
  { command: "pwd", commandDetection: 'FULL', run: () => `world` },
  { command: "sleep", commandDetection: 'BEGINS_WITH', run: async (args) => {
    const time = parseInt(args || '')
    if (isNaN(time)) return `Usage: sleep <ms>`
    await new Promise((resolve) => {
      setTimeout(() => {
        resolve(null)
      }, time)
    })
    return null
  } },
  // { command: }
  // { command: ""}
  
]);

</script>

<template>
  <div class="w-full flex justify-center sm:px-6 sm:pt-8 h-[95vh]">
    <CommandLine ref="commandLine" class="max-w-3xl w-full max-h-full min-h-80" :commands="commands" initalCommand="hello" />
  </div>
</template>
