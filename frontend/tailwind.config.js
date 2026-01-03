export default {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  darkMode: 'class',
  theme: {
    screens: {
      xs: '375px',
      sm: '428px',
      md: '768px',
      lg: '1024px'
    },
    extend: {
      colors: {
        dark: {
          bg: '#000000',
          card: '#1c1c1e',
          'card-light': '#2c2c2e',
          border: '#3a3a3c',
          'border-light': '#48484a',
          text: {
            primary: '#ffffff',
            secondary: '#98989f',
            muted: '#636366'
          }
        },
        habit: {
          purple: '#a855f7',
          red: '#ef4444',
          blue: '#3b82f6',
          green: '#10b981',
          yellow: '#f59e0b',
          pink: '#ec4899',
          indigo: '#6366f1',
          teal: '#14b8a6',
          orange: '#f97316',
          gray: '#6b7280'
        }
      },
      animation: {
        'slide-up': 'slideUp 0.3s cubic-bezier(0.32, 0.72, 0, 1)',
        'slide-down': 'slideDown 0.3s cubic-bezier(0.32, 0.72, 0, 1)',
        'fade-in': 'fadeIn 0.2s ease-out',
        'scale-in': 'scaleIn 0.2s cubic-bezier(0.32, 0.72, 0, 1)'
      },
      keyframes: {
        slideUp: {
          '0%': { transform: 'translateY(100%)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' }
        },
        slideDown: {
          '0%': { transform: 'translateY(-100%)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' }
        },
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' }
        },
        scaleIn: {
          '0%': { transform: 'scale(0.95)', opacity: '0' },
          '100%': { transform: 'scale(1)', opacity: '1' }
        }
      },
      backdropBlur: {
        xs: '2px',
        sm: '4px',
        md: '12px',
        lg: '16px',
        xl: '24px'
      }
    }
  },
  plugins: []
}

