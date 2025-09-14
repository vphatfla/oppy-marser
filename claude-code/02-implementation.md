# Static Site Generation Implementation Design

## Critical Implementation Requirement: True Static Generation

**IMPORTANT**: This must be a true static site generator, not a Single Page Application (SPA). All content must be processed and HTML pages generated at **build time**, not at runtime.

### Static Generation Requirements
- **Build-time Processing**: All markdown files converted to HTML during `npm run build`
- **Pre-rendered Pages**: Complete static HTML files generated for each route/page
- **Zero Runtime Dependencies**: No JavaScript required for content display
- **CDN Compatible**: Pure static files deployable to S3 + CloudFront
- **No Server Required**: Files served directly from CDN without backend processing

### Anti-Pattern: Runtime Content Loading
The following approaches are **NOT ACCEPTABLE** for static generation:
- Using `fetch()` to load markdown files at runtime
- Client-side markdown processing in the browser
- Dynamic content loading in component lifecycle hooks
- Requiring a server to serve content files

## Layout Structure

### Page Layout
The application follows a standard three-section layout:
- **Header** - Fixed navigation and branding
- **Body** - Pre-rendered content area with static HTML
- **Footer** - Copyright and legal information

### Header Design
```
┌─────────────────────────────────────────────────────────────────┐
│ vphatfla                              [Home] [Blog] [Work] [Contact] │
└─────────────────────────────────────────────────────────────────┘
```

**Components:**
- Left: Site title "vphatfla" (currently hardcoded)
- Right: Navigation links (Home, Blog, Work, Contact)
- Links navigate to pre-generated static HTML pages via Vue Router

### Footer Design
**Current Implementation:**
- Footer component exists (AppFooter.vue) but specific content not documented
- Integrated into main app layout
- Consistent across all pages

### Content Area
- Pre-rendered static HTML content for optimal performance
- Content generated from markdown at build time
- Responsive layout adapting to content type
- Clean typography optimized for readability

## Typography

### Font Stack
```scss
font-family: -apple-system, "SF Pro Display", "Gill Sans", sans-serif;
```

**Hierarchy:**
1. **Primary**: San Francisco (Apple system font)
2. **Fallback**: Gill Sans
3. **Generic**: sans-serif

## Color Scheme

### Default Theme (Light)
- **Background**: White (`#ffffff`)
- **Text**: Black (`#000000`)
- **Accent**: To be defined per brand requirements

### Future Theme Support
- Dark mode implementation planned
- CSS custom properties for theme switching
- Consistent contrast ratios maintained

## Styling Architecture

### SASS Organization
```
styles/
├── abstracts/
│   ├── _variables.scss    # Global variables and theme colors
│   ├── _mixins.scss      # Reusable mixins
│   └── _functions.scss   # Utility functions
├── base/
│   ├── _reset.scss       # CSS reset/normalize
│   ├── _typography.scss  # Font definitions and text styles
│   └── _global.scss      # Global base styles
├── layout/
│   ├── _header.scss      # Header component styles
│   ├── _footer.scss      # Footer component styles
│   └── _main.scss        # Main content area
├── components/
│   └── _navigation.scss  # Navigation component styles
└── main.scss            # Main import file
```

### Bootstrap Integration
- **Minimal usage**: Utilize only essential utility classes
- **Custom variables**: Override Bootstrap defaults with brand colors
- **Selective imports**: Import only required Bootstrap modules
- **SASS integration**: Leverage Bootstrap's SASS variables and mixins

### Global Design Principles

#### Reusability
- CSS custom properties for theme values
- SASS mixins for repeated patterns
- Modular component architecture

#### Scalability
- BEM methodology for consistent naming
- Component-scoped styles with global utilities
- Responsive design patterns

#### Maintainability
- Clear file organization and naming conventions
- Comprehensive variable system
- Documented mixins and functions

## Implementation Notes

### Responsive Behavior
- Mobile-first responsive design
- Flexible navigation (hamburger menu on mobile)
- Optimized typography scaling across devices

### Performance Considerations
- Minimal CSS bundle size
- Efficient SASS compilation
- Purged unused Bootstrap components

### Accessibility
- Semantic HTML structure
- ARIA labels for navigation
- High contrast color combinations
- Keyboard navigation support

## Static Content Generation Architecture

### Build-time Content Processing
All content must be processed during the build phase to generate static HTML files:

```
Build Process:
1. Scan src/md/ directory for all markdown files
2. Process each markdown file with frontmatter parsing
3. Convert markdown to optimized HTML
4. Generate static HTML pages for each route
5. Create navigation and index files
6. Output complete static site to dist/
```

### Content Structure
All page content is authored in Markdown format and stored in the `docs/` directory:

```
docs/
├── Home.md              # Homepage content
├── Contact.md           # Contact page content
├── Work.md              # Work page content
└── blog/                # Blog posts directory
    └── YouHaveTime.md   # Individual blog posts
```

**Build Artifacts:**
```
src/pages/generated/         # Auto-generated Vue components
├── Contact.vue
├── Home.vue
├── Work.vue
├── BlogIndex.vue            # Auto-generated blog index page
└── blog/
    └── YouHaveTime.vue
src/generated-routes.js      # Auto-generated route definitions
```

### Frontmatter Support
Markdown files support YAML frontmatter for metadata:

**Blog Posts:**
```yaml
---
title: "Post Title"
date: "2024-01-15"
tags: ["javascript", "vue"]
excerpt: "Brief description"
slug: "post-title"
---
```

**Work Items:**
```yaml
---
title: "Project Name"
date: "2024-01-10"
technologies: ["Vue.js", "SASS"]
status: "Completed"
slug: "project-name"
---
```

### Static Generation Implementation Approach

#### Selected Implementation: markdown-it + gray-matter + Vue Components
**Final Decision**: Build-time conversion of Markdown files to Vue components with embedded HTML

**Technical Stack:**
- **markdown-it**: Robust markdown parser with plugin ecosystem
- **gray-matter**: Professional frontmatter parsing
- **Vue 3**: Component framework for layout and interactivity
- **Vite**: Build system with optimized static generation

**Process Overview:**
1. **Build Script**: Node.js script processes all markdown files
2. **Content Discovery**: Glob pattern matching finds all `docs/*.md` files
3. **Frontmatter Parsing**: gray-matter extracts YAML/TOML/JSON metadata
4. **HTML Generation**: markdown-it converts content with syntax highlighting
5. **Component Creation**: Generate Vue components with embedded HTML
6. **Route Generation**: Automatic routing based on file structure
7. **Static Build**: Vite bundles everything into static HTML files

**Why This Approach:**
- ✅ True static generation (no runtime dependencies)
- ✅ Maintains Vue.js development experience
- ✅ Professional-grade markdown processing
- ✅ Flexible frontmatter metadata support
- ✅ Plugin ecosystem for extensibility
- ✅ SEO optimization with meta tag generation
- ✅ Compatible with existing SASS + Bootstrap styling

**Alternative Options Considered:**
- **VitePress**: Too opinionated, locks into specific patterns
- **Custom Vite Plugin**: Overly complex for requirements
- **Astro**: Additional framework complexity not needed

### Build Output Structure
The static generation process must produce:

```
dist/
├── index.html              # Homepage (from home.md)
├── blog/
│   ├── index.html         # Blog listing page
│   └── [slug]/
│       └── index.html     # Individual blog posts
├── work/
│   ├── index.html         # Work portfolio page
│   └── [slug]/
│       └── index.html     # Individual work items
├── contact/
│   └── index.html         # Contact page (from contact.md)
├── assets/                # Optimized CSS/JS/images
├── sitemap.xml           # SEO sitemap
└── 404.html              # Error page
```

### Content Processing Workflow
1. **Build Trigger**: Run `npm run build-docs && npm run build` command
2. **Content Discovery**: Scan `docs/` for all markdown files using glob patterns
3. **Metadata Extraction**: Parse frontmatter with gray-matter (YAML/TOML/JSON)
4. **HTML Generation**: Convert markdown to optimized HTML with markdown-it
5. **Component Generation**: Create Vue components with embedded HTML content
6. **Route Generation**: Auto-generate route definitions from file structure
7. **Static Build**: Vite bundles Vue components into static HTML files
8. **Asset Optimization**: Bundle and optimize CSS/JS/images
9. **Static Output**: Produce deployment-ready static files in `dist/`

### Performance Benefits
- **Zero Client-side Processing**: All content pre-rendered as HTML
- **Optimal Caching**: Static files cached indefinitely at CDN edge
- **Fast Initial Load**: No JavaScript required for content display
- **SEO Optimized**: Complete HTML content available to crawlers
- **Offline Capable**: Static files work without network connectivity

This approach ensures true static generation compatible with S3 + CloudFront deployment as specified in the architecture requirements.