# Static Blog Frontend Template

A clean Vue.js template ready for static site generation implementation.

## Current State

This is a cleaned-up template with all runtime content loading removed. It's ready for implementing a proper static site generator.

## Structure

```
src/
├── components/          # Reusable Vue components
│   ├── AppHeader.vue   # Site header with navigation
│   └── AppFooter.vue   # Site footer
├── views/              # Page templates (placeholders)
│   ├── Home.vue        # Homepage template
│   ├── Blog.vue        # Blog listing template  
│   ├── Work.vue        # Work portfolio template
│   └── Contact.vue     # Contact page template
├── styles/             # SASS stylesheets
│   └── main.scss       # Main stylesheet
├── md/                 # Markdown content (source)
│   ├── home.md         # Homepage content
│   ├── contact.md      # Contact page content
│   ├── blog/           # Blog posts
│   └── work/           # Work portfolio items
├── App.vue             # Root application component
└── main.js             # Application entry point
```

## Dependencies

**Runtime Dependencies:**
- `vue` - Vue.js 3 framework
- `bootstrap` - CSS framework for styling

**Development Dependencies:**
- `vite` - Build tool and dev server
- `@vitejs/plugin-vue` - Vue.js plugin for Vite
- `sass` - CSS preprocessor

## Removed Dependencies

The following runtime dependencies were removed as they're not needed for static generation:
- `vue-router` - Router (static sites don't need client-side routing)
- `gray-matter` - Frontmatter parser (will be used at build-time)
- `markdown-it` - Markdown processor (will be used at build-time)

## Next Steps

To implement static generation, choose one of these approaches:

### Option 1: VitePress (Recommended)
```bash
npm install vitepress
```
- Migrate content to VitePress structure
- Configure VitePress for custom theme using existing components

### Option 2: Custom Vite Plugin
- Create a Vite plugin for build-time markdown processing
- Generate static HTML pages during `vite build`

### Option 3: Astro
```bash
npm create astro@latest
```
- Migrate to Astro with Vue integration
- Use existing Vue components as Astro components

## Development

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

## Content Management

Content is stored in `src/md/` directory:
- `home.md` - Homepage content
- `contact.md` - Contact page content
- `blog/*.md` - Blog posts with frontmatter
- `work/*.md` - Work portfolio items with frontmatter

The static site generator will process these files and generate the corresponding HTML pages.
