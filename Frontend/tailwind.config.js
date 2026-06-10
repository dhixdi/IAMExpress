/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        navy: {
          950: '#0F2D52',
          900: '#1E3A5F',
          800: '#2A4D7A',
        },
        amber: {
          brand: '#E8A020',
          light: '#FEF3C7',
        },
        status: {
          created:      { bg: '#F3F4F6', text: '#374151', border: '#D1D5DB' },
          received:     { bg: '#DBEAFE', text: '#1E40AF', border: '#93C5FD' },
          linehaul:     { bg: '#EDE9FE', text: '#5B21B6', border: '#A78BFA' },
          pickedup:     { bg: '#E0E7FF', text: '#3730A3', border: '#818CF8' },
          transit:      { bg: '#FEF3C7', text: '#92400E', border: '#FCD34D' },
          arrived:      { bg: '#CCFBF1', text: '#065F46', border: '#5EEAD4' },
          courier:      { bg: '#FFEDD5', text: '#9A3412', border: '#FDBA74' },
          outdelivery:  { bg: '#FED7AA', text: '#7C2D12', border: '#FB923C' },
          delivered:    { bg: '#DCFCE7', text: '#14532D', border: '#86EFAC' },
          failed:       { bg: '#FEE2E2', text: '#7F1D1D', border: '#FCA5A5' },
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
      boxShadow: {
        card: '0 1px 3px rgba(0,0,0,0.08), 0 1px 2px rgba(0,0,0,0.04)',
        'card-hover': '0 4px 12px rgba(0,0,0,0.10), 0 2px 4px rgba(0,0,0,0.06)',
      },
      borderRadius: {
        sm: '4px',
        md: '6px',
        lg: '8px',
        xl: '12px',
      },
    },
  },
  plugins: [],
}
