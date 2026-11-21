import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  darkMode: "class",
  theme: {
    extend: {
      colors: {
        brand: {
          navy: "#0A1026",
          navySecondary: "#141A32",
          navyCard: "#191E35",
          purple: "#8875FF",
          lavender: "#B9A9FF",
          teal: "#50D6C2",
          text: "#F6F5FF",
          muted: "#A5A9BC",
          border: "#303451",
          error: "#FF6B81",
        },
      },
      fontFamily: {
        sans: ["var(--font-sora)", "sans-serif"],
      },
      borderRadius: {
        "tk-card": "16px",
        "tk-btn": "12px",
      },
      boxShadow: {
        "purple-glow": "0 0 25px -5px rgba(136, 117, 255, 0.3)",
        "teal-glow": "0 0 25px -5px rgba(80, 214, 194, 0.3)",
      },
    },
  },
  plugins: [],
};
export default config;
