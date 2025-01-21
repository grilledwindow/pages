/** @type {import('tailwindcss').Config} */
module.exports = {
  mode: 'jit',
  content: ['./public/**/*.html', './templates/**/*.html'],
  theme: {
    fontFamily: {
      sans: 'Inter, Cotham, Poppins, sans-serif',
      serif: 'Bagnard, serif',
      mono: 'Plex, monospace',
    },
    extend: {},
  },
  plugins: [],
}

