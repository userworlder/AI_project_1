import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useSidebarStore = defineStore('sidebar', () => {
  const collapsed = ref(false)

  const toggle = () => {
    collapsed.value = !collapsed.value
  }

  return {
    collapsed,
    toggle
  }
})
