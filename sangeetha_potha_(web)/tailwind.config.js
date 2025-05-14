/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        accent: '#C8B400',
        primary: {
          50: '#fafaf5',
          100: '#f5f5e0',
          200: '#ebebc2',
          300: '#e0e0a3',
          400: '#d6d685',
          500: '#cccc66',
          600: '#a3a352',
          700: '#7a7a3d',
          800: '#525229',
          900: '#292914',
        },
        secondary: {
          50: '#f2f2f2',
          100: '#e6e6e6',
          200: '#cccccc',
          300: '#b3b3b3',
          400: '#999999',
          500: '#808080',
          600: '#666666',
          700: '#4d4d4d',
          800: '#333333',
          900: '#1a1a1a',
        }
      },
      boxShadow: {
        'accent': '0 4px 6px -1px rgba(200, 180, 0, 0.1), 0 2px 4px -1px rgba(200, 180, 0, 0.06)',
      },
      animation: {
        'fade-in': 'fadeIn 0.5s ease-out',
        'slide-up': 'slideUp 0.3s ease-out',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { transform: 'translateY(10px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
      },
    },
  },
  plugins: [],
};