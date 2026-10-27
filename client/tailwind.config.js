/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        saffron: {
          50: '#FFF8E1',
          100: '#FFECB3',
          200: '#FFE082',
          300: '#FFD54F',
          400: '#FFCA28',
          500: '#FF9800',
          600: '#FB8C00',
          700: '#F57C00',
          800: '#EF6C00',
          900: '#E65100',
        },
        gold: {
          light: '#F4E5A8',
          DEFAULT: '#D4AF37',
          dark: '#AA820A',
        },
        cream: {
          light: '#FFFDF9',
          DEFAULT: '#FFF8EC',
          dark: '#F5ECDF',
        },
        devotional: {
          dark: '#140A02',
          card: '#1F1206',
          border: '#331D08',
        }
      },
      fontFamily: {
        sans: ['Plus Jakarta Sans', '-apple-system', 'BlinkMacSystemFont', 'Segoe UI', 'Roboto', 'sans-serif'],
      },
    },
  },
  plugins: [],
}
