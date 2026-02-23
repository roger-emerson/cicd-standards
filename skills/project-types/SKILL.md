---
name: Project Types
description: This skill activates when discussing project architecture, framework selection, TypeScript configuration, or Cloudflare Workers setup. Use when user mentions "React Vite", "Next.js", "Hono", "project structure", "TypeScript config", "wrangler setup", or needs guidance on project organization.
version: 2.0.0
---

# Project Architecture Types

Understand the three supported project architectures for Cloudflare Workers deployment, their configurations, and when to use each.

## Supported Architectures (7 Types)

### 1. React + Vite + Cloudflare Workers

**Best for**: Single-page applications with API backend

**Stack**:
- **Frontend**: React 18+ with Vite 6+ build tool
- **Backend**: Cloudflare Workers for API routes
- **Styling**: CSS Modules, Tailwind, or vanilla CSS
- **State**: React hooks, Context API, or external state management

**When to use**:
- Marketing websites with contact forms
- Dashboards with API integration
- E-commerce frontends
- Portfolio sites with dynamic content

**Key characteristics**:
- Fast HMR (Hot Module Replacement) in development
- Optimized production builds
- Static assets served from Workers
- API routes handled by Worker code

### 2. Next.js 15 + OpenNext + Cloudflare

**Best for**: Full-stack applications with SSR/SSG

**Stack**:
- **Framework**: Next.js 15 with App Router
- **Adapter**: `@opennextjs/cloudflare` for Workers compatibility
- **Styling**: Tailwind CSS v4 (CSS-first config)
- **UI**: shadcn/ui, Radix UI, or custom components

**When to use**:
- SEO-critical applications
- Dynamic server-rendered pages
- Multi-page applications
- Content-heavy sites (blogs, docs)

**Key characteristics**:
- Server-side rendering on edge
- API routes via Next.js
- Image optimization
- File-based routing

### 3. Hono + Cloudflare Workers

**Best for**: Lightweight API-only services

**Stack**:
- **Framework**: Hono (ultra-fast web framework)
- **Runtime**: Cloudflare Workers only
- **Validation**: Zod or custom validators
- **Database**: D1, KV, R2, or external APIs

**When to use**:
- REST APIs
- Webhooks
- Proxy services
- Microservices

**Key characteristics**:
- Smallest bundle size
- Fastest cold starts
- No frontend bundling
- Pure serverless API

### 4. Cloudflare Pages (Astro / SolidStart / Remix)

**Best for**: Static-first sites with server-side features via Pages Functions

**Stack**:
- **Framework**: Astro 5+, SolidStart, or Remix
- **Adapter**: `@astrojs/cloudflare`, `solid-start-cloudflare-pages`, or `@remix-run/cloudflare-pages`
- **Deploy**: Cloudflare Pages (not Workers)
- **Functions**: Pages Functions for server-side logic

**When to use**:
- Content-heavy websites with partial server rendering
- Multi-framework (Astro islands)
- Projects preferring Pages over Workers
- Sites with built-in asset optimization

**Key characteristics**:
- Uses `wrangler pages deploy` instead of `wrangler deploy`
- Static assets served from Cloudflare CDN
- Pages Functions for API routes
- Automatic preview deployments on PRs

#### Subtype: Next.js Static Export

Next.js projects using `output: "export"` (without OpenNext) produce static HTML/CSS/JS files — functionally identical to any other static site generator. These are classified as **pages**, not **nextjs**.

**Detection logic**:
- `package.json` has `next` dependency
- `next.config.ts/js/mjs` has `output: "export"`
- NO `@opennextjs/cloudflare` dependency
- Output directory is typically `out/`

**Why pages, not nextjs?** The `nextjs` classification is reserved for full SSR via OpenNext. Static export produces plain files with no server-side rendering — it's deployed the same way as Astro or Vite: `wrangler pages deploy out/`.

**Template**: Uses `templates/workflows/pages.yml` with `{{OUTPUT_DIR}}` set to `out`.

### 5. Workers + Durable Objects

**Best for**: Stateful serverless applications requiring consistency guarantees

**Stack**:
- **Framework**: Hono or raw Worker
- **State**: Durable Objects for coordination, consistency, and real-time
- **Storage**: Durable Object storage, D1, or KV
- **Runtime**: Cloudflare Workers

**When to use**:
- Real-time collaboration features
- Rate limiting with strong consistency
- WebSocket connections with state
- Distributed locking or coordination

**Key characteristics**:
- Durable Objects declared in `wrangler.toml` `[durable_objects]`
- Migration steps required in deploy job
- State persists across requests within an object
- Bindings connect Workers to Durable Objects

### 6. Workers + R2

**Best for**: Storage-heavy applications with object storage needs

**Stack**:
- **Framework**: Hono or raw Worker
- **Storage**: R2 for objects/files, optionally D1 for metadata
- **Runtime**: Cloudflare Workers

**When to use**:
- File upload/download services
- Image processing pipelines
- Backup and archival systems
- S3-compatible storage needs

**Key characteristics**:
- R2 buckets declared in `wrangler.toml` `[[r2_buckets]]`
- No egress fees on reads
- S3-compatible API available
- Bucket validation in deploy workflow

### 7. Generic (Non-Cloudflare)

**Best for**: Projects not deploying to Cloudflare — standard Node.js, Docker, or any platform

**Stack**:
- **Framework**: Any (Express, Fastify, NestJS, plain Node.js, etc.)
- **Deploy**: Docker, npm publish, or custom deploy scripts
- **Runtime**: Node.js, Docker, or any platform

**When to use**:
- Non-Cloudflare projects that still benefit from the 3-job CI pattern
- Docker-based deployments
- npm package publishing
- Any project wanting standardized CI structure

**Key characteristics**:
- Same 3-job pattern (resolve-env → ci-gate → deploy)
- Deploy job uses project's own deploy mechanism
- No Cloudflare-specific configuration
- Wrangler not required

## Configuration Patterns

### React + Vite + Workers

#### Directory Structure

```
project/
├── src/
│   ├── components/           # React components
│   ├── pages/                # Page components
│   ├── workers/              # Cloudflare Worker code
│   │   └── index.ts          # Worker entry point
│   ├── App.tsx
│   └── main.tsx
├── public/                   # Static assets
├── .github/workflows/
│   └── deploy.yml
├── tsconfig.json             # Frontend TypeScript config
├── tsconfig.worker.json      # Worker TypeScript config
├── vite.config.ts
├── wrangler.toml
└── package.json
```

#### TypeScript Configuration

**Frontend** (`tsconfig.json`):
```json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "jsx": "react-jsx",
    "moduleResolution": "bundler",
    "strict": true,
    "noEmit": true,
    "skipLibCheck": true
  },
  "include": ["src/**/*.ts", "src/**/*.tsx"],
  "exclude": ["src/workers"]
}
```

**Worker** (`tsconfig.worker.json`):
```json
{
  "compilerOptions": {
    "target": "ES2021",
    "module": "ESNext",
    "lib": ["ES2021"],
    "types": ["@cloudflare/workers-types"],
    "strict": true,
    "noEmit": true,
    "skipLibCheck": true
  },
  "include": ["src/workers/**/*.ts"]
}
```

#### Wrangler Configuration

```toml
name = "project-name"
main = "src/workers/index.ts"
compatibility_date = "2024-12-01"
workers_dev = false

[assets]
directory = "./dist"
run_worker_first = ["/api/*"]

[observability]
enabled = true
head_sampling_rate = 1

[observability.logs]
enabled = true
invocation_logs = true
head_sampling_rate = 1

[env.development]
name = "project-name-dev"
workers_dev = false
```

**How it works**:
1. Vite builds React app to `dist/`
2. Worker serves static files from `dist/`
3. API routes (`/api/*`) handled by Worker first
4. Everything else served as static assets

#### Package.json Scripts

```json
{
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "typecheck": "tsc --noEmit && tsc --project tsconfig.worker.json --noEmit",
    "deploy": "wrangler deploy"
  },
  "dependencies": {
    "react": "^18.3.1",
    "react-dom": "^18.3.1"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.3.4",
    "@cloudflare/workers-types": "^4.20250117.0",
    "typescript": "^5.9.3",
    "vite": "^6.0.5",
    "wrangler": "^4.65.0"
  }
}
```

### Next.js + OpenNext

#### Directory Structure

```
project/
├── src/
│   ├── app/                  # Next.js App Router
│   │   ├── api/              # API routes
│   │   ├── layout.tsx
│   │   └── page.tsx
│   ├── components/           # React components
│   └── lib/                  # Utilities
├── .github/workflows/
│   └── deploy.yml
├── tsconfig.json
├── wrangler.jsonc            # JSONC format for comments
├── next.config.js
└── package.json
```

#### TypeScript Configuration

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "jsx": "preserve",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,
    "noEmit": true,
    "paths": {
      "@/*": ["./src/*"]
    },
    "plugins": [
      {
        "name": "next"
      }
    ]
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
```

#### Wrangler Configuration

```jsonc
{
  "name": "project-name",
  "main": ".open-next/worker.js",
  "compatibility_date": "2025-04-14",
  "compatibility_flags": ["nodejs_compat", "global_fetch_strictly_public"],
  "workers_dev": false,
  "assets": {
    "directory": ".open-next/assets",
    "binding": "ASSETS"
  },
  "services": [
    {
      "binding": "WORKER_SELF_REFERENCE",
      "service": "project-name"
    }
  ],
  "observability": {
    "enabled": true,
    "head_sampling_rate": 0.1,
    "logs": {
      "enabled": true,
      "invocation_logs": true,
      "head_sampling_rate": 0.1
    }
  },
  "env": {
    "development": {
      "name": "project-name-dev",
      "workers_dev": false,
      "services": [
        {
          "binding": "WORKER_SELF_REFERENCE",
          "service": "project-name-dev"
        }
      ]
    }
  }
}
```

#### Package.json Scripts

```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "preview": "opennextjs-cloudflare build && opennextjs-cloudflare preview",
    "deploy": "opennextjs-cloudflare build && opennextjs-cloudflare deploy",
    "deploy:dev": "opennextjs-cloudflare build && opennextjs-cloudflare deploy --env development",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": {
    "next": "^15.3.0",
    "react": "^19.0.0",
    "react-dom": "^19.0.0"
  },
  "devDependencies": {
    "@opennextjs/cloudflare": "^1.0.0",
    "@types/react": "^19.0.0",
    "typescript": "^5.9.3",
    "wrangler": "^4.65.0"
  }
}
```

### Hono Only

#### Directory Structure

```
project/
├── src/
│   ├── index.ts              # Hono app entry point
│   ├── routes/               # Route handlers
│   └── middleware/           # Custom middleware
├── .github/workflows/
│   └── deploy.yml
├── tsconfig.json
├── wrangler.toml
└── package.json
```

#### TypeScript Configuration

```json
{
  "compilerOptions": {
    "target": "ES2021",
    "module": "ESNext",
    "lib": ["ES2021"],
    "types": ["@cloudflare/workers-types"],
    "moduleResolution": "node",
    "strict": true,
    "noEmit": true,
    "skipLibCheck": true
  },
  "include": ["src/**/*.ts"]
}
```

#### Wrangler Configuration

```toml
name = "project-name"
main = "src/index.ts"
compatibility_date = "2024-12-01"
workers_dev = false

[observability]
enabled = true
head_sampling_rate = 1

[observability.logs]
enabled = true
invocation_logs = true
head_sampling_rate = 1

[env.development]
name = "project-name-dev"
workers_dev = false
```

#### Package.json Scripts

```json
{
  "scripts": {
    "dev": "wrangler dev",
    "deploy": "wrangler deploy",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": {
    "hono": "^4.0.0"
  },
  "devDependencies": {
    "@cloudflare/workers-types": "^4.20250117.0",
    "typescript": "^5.9.3",
    "wrangler": "^4.65.0"
  }
}
```

### Cloudflare Pages (Astro)

#### Directory Structure

```
project/
├── src/
│   ├── pages/                # Astro pages (file-based routing)
│   ├── components/           # UI components (Astro, React, etc.)
│   ├── layouts/              # Page layouts
│   └── content/              # Content collections
├── public/                   # Static assets
├── functions/                # Pages Functions (optional)
├── .github/workflows/
│   └── deploy.yml
├── astro.config.mjs
├── tsconfig.json
├── wrangler.toml             # Pages config
└── package.json
```

#### Wrangler Configuration (Pages)

```toml
name = "project-name"
pages_build_output_dir = "./dist"
compatibility_date = "2024-12-01"
```

#### Package.json Scripts

```json
{
  "scripts": {
    "dev": "astro dev",
    "build": "astro build",
    "preview": "astro preview",
    "typecheck": "astro check && tsc --noEmit",
    "deploy": "wrangler pages deploy dist"
  },
  "dependencies": {
    "astro": "^5.0.0",
    "@astrojs/cloudflare": "^12.0.0"
  }
}
```

### Workers + Durable Objects

#### Directory Structure

```
project/
├── src/
│   ├── index.ts              # Worker entry (routes requests)
│   ├── durable-objects/      # Durable Object classes
│   │   └── counter.ts        # Example DO class
│   └── routes/               # API routes
├── .github/workflows/
│   └── deploy.yml
├── tsconfig.json
├── wrangler.toml
└── package.json
```

#### Wrangler Configuration

```toml
name = "project-name"
main = "src/index.ts"
compatibility_date = "2024-12-01"
workers_dev = false

[durable_objects]
bindings = [
  { name = "COUNTER", class_name = "Counter" }
]

[[migrations]]
tag = "v1"
new_classes = ["Counter"]

[observability]
enabled = true
head_sampling_rate = 1

[env.development]
name = "project-name-dev"
workers_dev = false
```

### Workers + R2

#### Directory Structure

```
project/
├── src/
│   ├── index.ts              # Worker entry
│   └── routes/               # API routes (upload, download, list)
├── .github/workflows/
│   └── deploy.yml
├── tsconfig.json
├── wrangler.toml
└── package.json
```

#### Wrangler Configuration

```toml
name = "project-name"
main = "src/index.ts"
compatibility_date = "2024-12-01"
workers_dev = false

[[r2_buckets]]
binding = "BUCKET"
bucket_name = "project-bucket"

[env.development]
name = "project-name-dev"
workers_dev = false

[[env.development.r2_buckets]]
binding = "BUCKET"
bucket_name = "project-bucket-dev"
```

### Generic (Non-Cloudflare)

#### Directory Structure

```
project/
├── src/                      # Application source
├── tests/                    # Test suite
├── .github/workflows/
│   └── deploy.yml
├── Dockerfile                # Optional — for Docker-based deploy
├── tsconfig.json
└── package.json
```

#### Package.json Scripts

```json
{
  "scripts": {
    "dev": "node --watch src/index.ts",
    "build": "tsc",
    "test": "vitest run",
    "typecheck": "tsc --noEmit",
    "deploy": "echo 'Add your deploy script here'"
  }
}
```

## Project Detection Logic

### How to Identify Project Type

**React + Vite + Workers**:
```bash
✓ package.json has "vite" dependency
✓ package.json has "react" dependency
✓ src/workers/ directory exists OR wrangler.toml has [assets]
✓ vite.config.ts/js exists
```

**Next.js + OpenNext**:
```bash
✓ package.json has "next" dependency
✓ package.json has "@opennextjs/cloudflare" dependency
✓ src/app/ or app/ directory exists
✓ next.config.js exists
```

**Hono Only**:
```bash
✓ package.json has "hono" dependency
✓ No "react", "next", "vite" dependencies
✓ wrangler.toml exists with main entry
✓ No assets configuration
```

**Cloudflare Pages (Astro)**:
```bash
✓ package.json has "astro" dependency
✓ package.json has "@astrojs/cloudflare" adapter
✓ astro.config.mjs/ts exists
✓ src/pages/ directory exists
```

**Cloudflare Pages (Next.js Static Export)**:
```bash
✓ package.json has "next" dependency
✓ next.config.ts/js/mjs has output: "export"
✗ NO @opennextjs/cloudflare dependency
✓ Output directory is out/
```

**Cloudflare Pages (SolidStart/Remix)**:
```bash
✓ package.json has "solid-start" or "@remix-run/cloudflare-pages"
✓ Cloudflare Pages adapter installed
✓ app.config.ts or remix.config.js exists
```

**Workers + Durable Objects**:
```bash
✓ wrangler.toml has [durable_objects] section
✓ wrangler.toml has [[migrations]] section
✓ Source contains Durable Object class exports
```

**Workers + R2**:
```bash
✓ wrangler.toml has [[r2_buckets]] section
✓ R2 binding used in worker code
```

**Generic (Non-Cloudflare)**:
```bash
✗ No wrangler.toml and no wrangler.jsonc
✗ No @cloudflare/* dependencies
✓ package.json exists
✓ Has build/test scripts
```

### Detection Priority

When multiple indicators match, use this priority order:
1. Pages (Astro/SolidStart/Remix) — if Pages adapter found
2. Next.js + OpenNext — if next + opennext found
3. React + Vite + Workers — if vite + react + wrangler found
4. Workers + Durable Objects — if durable_objects in wrangler
5. Workers + R2 — if r2_buckets in wrangler
6. Hono Only — if hono dependency
7. Generic — fallback when no Cloudflare indicators

### Ambiguous Cases

**If multiple frameworks detected**:
- Ask user which is primary
- Default to most complex (Next.js > React+Vite > Hono)

**If no framework detected**:
- Check for index.html → React+Vite
- Check for fetch handler → Hono
- Ask user to specify

## Common Files Across All Types

### .nvmrc

```
22
```

All projects use Node 22.

### .gitignore

```
node_modules/
dist/
.open-next/
.wrangler/
*.log
.env
.DS_Store
```

### GitHub Actions Workflow

All use the same 3-job pattern:
- resolve-env
- ci-gate (with typecheck)
- deploy

Only deployment command changes based on project type.

## Migration Paths

### From React SPA to React+Vite+Workers

1. Add `src/workers/` directory
2. Move API logic to Worker
3. Update `wrangler.toml` with assets
4. Add Worker TypeScript config
5. Update deploy workflow

### From Next.js to Next.js+OpenNext

1. Install `@opennextjs/cloudflare`
2. Create `wrangler.jsonc`
3. Update package.json scripts
4. Update deploy workflow
5. Test preview build

### From Express API to Hono

1. Replace Express with Hono
2. Migrate middleware
3. Update route handlers
4. Create `wrangler.toml`
5. Remove Node.js-specific code

## Best Practices

### Always Include

- TypeScript configuration (all types)
- `.nvmrc` for Node version pinning
- Observability in wrangler.toml
- Development environment config
- README with setup instructions

### Project-Specific

**React+Vite**:
- Separate Worker code from frontend
- Use CSS Modules or Tailwind for styling
- Configure Vite plugins appropriately

**Next.js**:
- Use App Router (not Pages)
- Configure image optimization
- Set up proper metadata

**Hono**:
- Keep dependencies minimal
- Use middleware for cross-cutting concerns
- Return proper HTTP status codes

## Troubleshooting

### Build errors in CI

**React+Vite**: Check that `dist/` is in .gitignore
**Next.js**: Ensure OpenNext is installed
**Hono**: Verify TypeScript types are correct

### Worker not responding

**React+Vite**: Check `run_worker_first` in wrangler.toml
**Next.js**: Verify WORKER_SELF_REFERENCE binding
**Hono**: Check main entry point in wrangler.toml

### Type errors

- Run `npm run typecheck` locally
- Check `@cloudflare/workers-types` version
- Verify tsconfig includes are correct

## References

- See `ci-patterns` skill for workflow details
- See `enforcement-rules` skill for compliance rules
- Vite docs: https://vitejs.dev
- Next.js docs: https://nextjs.org
- Hono docs: https://hono.dev
- Astro docs: https://astro.build
- OpenNext docs: https://opennext.js.org
- Cloudflare Pages: https://developers.cloudflare.com/pages
- Durable Objects: https://developers.cloudflare.com/durable-objects
- R2: https://developers.cloudflare.com/r2
