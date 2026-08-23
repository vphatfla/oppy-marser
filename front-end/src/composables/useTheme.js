import { ref, computed, onMounted, onUnmounted } from 'vue'

const THEME_KEY = 'theme'
const media = window.matchMedia('(prefers-color-scheme: dark)')

function readInitialTheme() {
  // Prefer whatever the anti-flash inline script in index.html already applied,
  // so we never re-decide the theme with a second, potentially drifting logic path.
  const applied = document.documentElement.dataset.theme
  if (applied === 'light' || applied === 'dark') return applied

  const stored = localStorage.getItem(THEME_KEY)
  if (stored === 'light' || stored === 'dark') return stored

  return media.matches ? 'dark' : 'light'
}

export function useTheme() {
  const theme = ref(readInitialTheme())

  function applyTheme(value) {
    document.documentElement.dataset.theme = value
  }

  function toggleTheme() {
    theme.value = theme.value === 'dark' ? 'light' : 'dark'
    applyTheme(theme.value)
    localStorage.setItem(THEME_KEY, theme.value)
  }

  function handleOsChange(e) {
    // Only follow the OS live if the user never made an explicit choice.
    if (localStorage.getItem(THEME_KEY) === null) {
      theme.value = e.matches ? 'dark' : 'light'
      applyTheme(theme.value)
    }
  }

  onMounted(() => media.addEventListener('change', handleOsChange))
  onUnmounted(() => media.removeEventListener('change', handleOsChange))

  return { theme, toggleTheme, isDark: computed(() => theme.value === 'dark') }
}
