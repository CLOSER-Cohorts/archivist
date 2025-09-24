const path = require("path");

module.exports = {
  // Babel configuration
  babel: {
    plugins: [
      ["@babel/plugin-proposal-private-property-in-object", { loose: true }],
      ["@babel/plugin-proposal-private-methods", { loose: true }],
      ["@babel/plugin-proposal-class-properties", { loose: true }]
    ]
  },

  // Webpack configuration (if needed)
  webpack: {
    alias: {
      // Example: Add custom aliases for cleaner imports
      "@components": path.resolve(__dirname, "src/components"),
      "@utils": path.resolve(__dirname, "src/utils")
    }
  },

  // ESLint configuration override
  eslint: {
    enable: true,
    mode: "extends",
    configure: {
      rules: {
        // Example: Custom ESLint rules
        "no-console": "warn"
      }
    }
  },

  // Tailwind CSS integration (if you're using it)
  style: {
    postcss: {
      plugins: [
        require("tailwindcss"),
        require("autoprefixer")
      ]
    }
  }
};