module.exports = {
  mode: 'jit',
  purge: [
    './js/**/*.js',
    '../lib/*_web/**/*.*ex'
  ],
  darkMode: false,
  theme: {},
  variants: {
    extend: {
      backgroundColor: ['active'],
    },
  },
  plugins: [require('@tailwindcss/forms')],
};
