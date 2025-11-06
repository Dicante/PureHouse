# Frontend Service# Frontend Service# Frontend Service# PureHouse Frontend



Next.js 14 SSR application with TypeScript and Tailwind CSS



## Technical Overview> Next.js 14 SSR application with TypeScript and Tailwind CSS



Server-side rendered blog application built with Next.js 14 App Router, demonstrating modern React development practices and production-ready frontend architecture.



## Architecture Decisions## 🎯 Technical Overview> Next.js 14 SSR application with TypeScript and Tailwind CSSModern blog platform frontend built with Next.js 14, TypeScript, and Tailwind CSS.



### Framework: Next.js 14



**Chosen over Create React App because:**Server-side rendered blog application built with **Next.js 14 App Router**, demonstrating modern React development practices, TypeScript integration, and production-ready frontend architecture.

- Server-side rendering for SEO

- App Router for better patterns

- Built-in API proxy via rewrites

- Image optimization## 🏗️ Architecture Decisions## 🎯 Technical Overview## 🚀 Features

- Production-ready out of the box



### Routing Strategy

### Framework Choice: Next.js 14

File-system based routing with App Router:



```

app/**Why Next.js over Create React App:**Server-side rendered blog application built with **Next.js 14 App Router**, demonstrating modern React development practices, TypeScript integration, and production-ready frontend architecture.- **Server-Side Rendering**: Next.js App Router for optimal performance

├── page.tsx              # Home

├── layout.tsx            # Root layout- Server-side rendering for SEO optimization

└── posts/

    ├── [id]/page.tsx     # View post- App Router for better routing patterns- **Type Safety**: Full TypeScript implementation

    ├── [id]/edit/        # Edit post

    └── new/page.tsx      # Create post- Built-in API routes (rewrites for backend proxy)

```

- Image optimization out of the box## 🏗️ Architecture Decisions- **Tailwind CSS**: Utility-first styling for responsive design

### API Communication

- Production-ready with minimal configuration

Backend proxy via rewrites (no CORS issues):

- **Dynamic Routing**: Post creation, editing, and viewing

```typescript

// next.config.ts rewrites### Routing Strategy

'/api/:path*' → backend:3001/api/:path*

```### Framework Choice: Next.js 14- **Image Support**: Multiple cover image options



Benefits: Same-origin requests, environment-based switching**App Router Architecture**:



## Technical Implementation```- **API Integration**: Seamless backend communication



### Component Architectureapp/



Atomic design pattern with separation of concerns:├── page.tsx              # Home (list posts)**Why Next.js over Create React App:**- **Production Ready**: Optimized builds with Turbopack



```├── layout.tsx            # Root layout

components/

├── intro.tsx              # Hero section└── posts/- Server-side rendering for SEO optimization

├── header.tsx             # Navigation

├── hero-post.tsx          # Featured card    ├── [id]/

├── post-preview.tsx       # List item

└── cover-image.tsx        # Responsive images    │   ├── page.tsx      # View post- App Router for better routing patterns## 🛠️ Tech Stack

```

    │   └── edit/

### State Management

    │       └── page.tsx  # Edit post- Built-in API routes (rewrites for backend proxy)

Server Components + Client Components pattern:

- Reduced bundle size    └── new/

- Better SEO

- Faster page loads        └── page.tsx      # Create post- Image optimization out of the box- **Framework**: Next.js 14



### Styling```



Tailwind CSS utility-first approach:- Production-ready with minimal configuration- **Language**: TypeScript 5

- Mobile-first responsive design

- Consistent design system**Benefits**:

- No CSS modules needed

- File-system based routing- **Styling**: Tailwind CSS

## Integration Points

- Nested layouts for shared UI

### API Client (`lib/api.ts`)

- Dynamic routes with [id] pattern### Routing Strategy- **UI Components**: Custom React components

Centralized API calls with TypeScript interfaces:

- SEO-friendly URLs

```typescript

export async function getPosts() {- **Build Tool**: Turbopack (next-gen bundler)

  const res = await fetch('/api/posts');

  return res.json();### API Communication Pattern

}

```**App Router Architecture**:- **Runtime**: Node.js 18+



Benefits: Single source of truth, type safety, testable**Backend Proxy via Rewrites**:



## Containerization```



Multi-stage Docker build optimizes to ~180MB:```typescript

1. Dependencies stage

2. Builder stage (optimize assets)// next.config.tsapp/## 📦 Installation

3. Runtime stage (standalone mode)

rewrites: async () => [

## Deployment

  {├── page.tsx              # Home (list posts)

**Kubernetes specs:**

- 2 replicas for HA    source: '/api/:path*',

- Resource limits: 500m CPU, 512Mi RAM

- ClusterIP service on port 3000    destination: process.env.NEXT_PUBLIC_API_URL ├── layout.tsx            # Root layout```bash



**Environment:**      ? `${process.env.NEXT_PUBLIC_API_URL}/:path*`

- `NEXT_PUBLIC_API_URL`: Empty (uses rewrites)

- `NODE_ENV`: production      : 'http://localhost:3001/api/:path*'└── posts/npm install



## Skills Demonstrated  }



- Next.js 14 App Router]    ├── [id]/```

- React Hooks and composition

- TypeScript type safety```

- Tailwind CSS responsive design

- SEO optimization    │   ├── page.tsx      # View post

- Image optimization

- Multi-stage Docker builds**Design rationale**:

- Cloud-native configuration

- Same-origin requests (no CORS issues)    │   └── edit/## 🔧 Configuration

## Next.js Features Used

- Environment-based backend switching

- Image Component (auto optimization)

- Font Optimization- Fallback to localhost for development    │       └── page.tsx  # Edit post

- API Rewrites (backend proxy)

- Static Assets- Transparent to frontend code

- Metadata API

    └── new/Create a `.env.local` file in the root directory:

## Design Patterns

## 📊 Technical Implementation

- Container/Presentational

- Composition        └── page.tsx      # Create post

- Proxy Pattern

- Factory Pattern### Component Architecture



---``````bash



*Modern frontend with production-grade Next.js architecture and cloud-native practices.***Atomic Design Pattern**:


# API Configuration (optional)

```

components/**Benefits**:# Leave empty to use same-origin /api via rewrites

├── intro.tsx              # Hero section

├── header.tsx             # Site navigation- File-system based routingNEXT_PUBLIC_API_URL=

├── footer.tsx             # Site footer

├── hero-post.tsx          # Featured post card- Nested layouts for shared UI

├── post-preview.tsx       # Post list item

├── cover-image.tsx        # Responsive images- Dynamic routes with [id] pattern# For direct backend connection (development):

├── cover-selector.tsx     # Image picker

├── date-formatter.tsx     # Date formatting utility- SEO-friendly URLs# NEXT_PUBLIC_API_URL=http://localhost:3001

├── avatar.tsx             # Author avatar

└── container.tsx          # Layout wrapper```

```

### API Communication Pattern

**Separation of concerns**:

- Presentational components (UI only)### How API URL Works

- Smart components (data fetching)

- Utility components (formatting)**Backend Proxy via Rewrites**:



### State Management- **Empty/Not Set**: Uses same-origin `/api` (recommended for production with Ingress)



**Server Components + Client Components**:```typescript- **Set to URL**: Direct connection to backend (useful for separate deployments)



```typescript// next.config.ts

// Server component (default in App Router)

export default async function PostPage({ params }) {rewrites: async () => [## 🏃 Running the Application

  const post = await getPost(params.id);  // Fetch on server

  return <PostContent post={post} />;  {

}

    source: '/api/:path*',```bash

// Client component (interactive)

'use client'    destination: process.env.NEXT_PUBLIC_API_URL # Development mode with Turbopack

export function PostEditor() {

  const [title, setTitle] = useState('');      ? `${process.env.NEXT_PUBLIC_API_URL}/:path*`npm run dev

  // ...

}      : 'http://localhost:3001/api/:path*'

```

  }# Production build

**Benefits**:

- Reduced JavaScript bundle size]npm run build

- Better SEO (content rendered on server)

- Faster initial page load```



### Styling Approach# Start production server



**Tailwind CSS utility-first**:**Design rationale**:npm start

- No CSS modules or styled-components

- Responsive design with mobile-first breakpoints- Same-origin requests (no CORS issues)

- Dark mode ready (can be toggled)

- Consistent design system- Environment-based backend switching# Lint code



```tsx- Fallback to localhost for developmentnpm run lint

<div className="max-w-2xl mx-auto">

  <h1 className="text-5xl md:text-7xl font-bold">- Transparent to frontend code```

    {post.title}

  </h1>

</div>

```## 📊 Technical ImplementationThe application will be available at `http://localhost:3000`



## 🔗 Integration Points



### Backend API Communication### Component Architecture## 📁 Project Structure



**API Client** (`lib/api.ts`):



```typescript**Atomic Design Pattern**:```

// Centralized API calls

export async function getPosts() {app/

  const res = await fetch('/api/posts');

  return res.json();```├── page.tsx                # Home page (blog listing)

}

components/├── layout.tsx              # Root layout with metadata

export async function createPost(data: PostData) {

  const res = await fetch('/api/posts', {├── intro.tsx              # Hero section├── globals.css             # Global styles

    method: 'POST',

    body: JSON.stringify(data)├── header.tsx             # Site navigation├── interfaces.ts           # TypeScript interfaces

  });

  return res.json();├── footer.tsx             # Site footer├── components/             # Reusable UI components

}

```├── hero-post.tsx          # Featured post card│   ├── avatar.tsx



**Why this pattern**:├── post-preview.tsx       # Post list item│   ├── cover-image.tsx

- Single source of truth for API endpoints

- Easy to add authentication headers├── cover-image.tsx        # Responsive images│   ├── cover-selector.tsx

- Type-safe with TypeScript interfaces

- Testable in isolation├── cover-selector.tsx     # Image picker│   ├── date-formatter.tsx



## 🐳 Containerization├── date-formatter.tsx     # Date formatting utility│   ├── footer.tsx



**Multi-stage Docker build**:├── avatar.tsx             # Author avatar│   ├── header.tsx



```dockerfile└── container.tsx          # Layout wrapper│   ├── hero-post.tsx

Stage 1: Dependencies

- Install all npm packages```│   ├── intro.tsx



Stage 2: Builder│   └── post-preview.tsx

- Build Next.js production bundle

- Optimize assets and images**Separation of concerns**:├── lib/



Stage 3: Runtime- Presentational components (UI only)│   └── api.ts              # API client utilities

- Copy only .next/ and public/

- Use standalone output mode- Smart components (data fetching)└── posts/

- Run as non-root user

```- Utility components (formatting)    ├── layout.tsx          # Posts layout



**Image optimization**: ~180MB final image    ├── new/                # Create new post



## 🚀 Deployment### State Management    │   └── page.tsx



### Kubernetes Configuration    └── [id]/               # Dynamic post routes



**Deployment specs**:**Server Components + Client Components**:        ├── page.tsx        # View post

- 2 replicas for high availability

- Resource limits: 500m CPU, 512Mi memory        └── edit/           # Edit post

- Readiness probe on port 3000

- Rolling update with zero downtime```typescript            └── page.tsx



**Service**:// Server component (default in App Router)```

- ClusterIP with port 3000

- Accessed via Ingress at `/` pathexport default async function PostPage({ params }) {

- Session affinity for consistent routing

  const post = await getPost(params.id);  // Fetch on server## 🎨 Features

### Environment Configuration

  return <PostContent post={post} />;

**Build-time variables**:

```bash}### Post Management

NEXT_PUBLIC_API_URL=        # Empty uses rewrites

```- **Create**: Rich form for creating new blog posts



**Runtime variables**:// Client component (interactive)- **Edit**: Update existing posts with pre-filled data

```bash

PORT=3000                   # Server port'use client'- **View**: Beautiful post display with cover images

NODE_ENV=production         # Production optimizations

```export function PostEditor() {- **List**: Home page with featured and recent posts



## 💡 Technical Highlights  const [title, setTitle] = useState('');



### Skills Demonstrated  // ...### Cover Images



- ✅ **Next.js 14**: App Router, Server Components, API routes}- Multiple pre-loaded images to choose from

- ✅ **React**: Hooks, component composition, props pattern

- ✅ **TypeScript**: Interfaces, type safety across codebase```- Visual selector with preview

- ✅ **Tailwind CSS**: Utility-first responsive design

- ✅ **SEO**: Server-side rendering, meta tags, semantic HTML- Support for custom image URLs

- ✅ **Performance**: Image optimization, code splitting, caching

- ✅ **Containerization**: Multi-stage Docker builds**Benefits**:

- ✅ **Cloud Native**: Environment-based config, health checks

- Reduced JavaScript bundle size### Responsive Design

### Next.js Features Leveraged

- Better SEO (content rendered on server)- Mobile-first approach

- **Image Component**: Automatic optimization and lazy loading

- **Font Optimization**: Google Fonts loaded efficiently- Faster initial page load- Tailwind CSS utilities

- **API Rewrites**: Backend proxy without CORS

- **Static Assets**: Public folder for images- Optimized for all screen sizes

- **App Router**: Modern file-based routing

- **Metadata API**: SEO-friendly meta tags### Styling Approach



### Design Patterns Used## 🔗 API Endpoints Used



- **Container/Presentational**: Separation of data and UI**Tailwind CSS utility-first**:

- **Composition**: Small reusable components

- **Proxy Pattern**: API rewrites for backend communication- No CSS modules or styled-componentsThe frontend communicates with the backend via:

- **Factory Pattern**: API client abstraction

- Responsive design with mobile-first breakpoints

---

- Dark mode ready (can be toggled)- `GET /api/posts` - Fetch all posts

*This service demonstrates modern frontend development with production-grade Next.js architecture, type safety, and cloud-native deployment practices.*

- Consistent design system- `GET /api/posts/:id` - Fetch single post

- `POST /api/posts` - Create new post

```tsx- `PUT /api/posts/:id` - Update post

<div className="max-w-2xl mx-auto">- `DELETE /api/posts/:id` - Delete post

  <h1 className="text-5xl md:text-7xl font-bold">

    {post.title}## 🐳 Docker

  </h1>

</div>Build and run with Docker:

```

```bash

## 🔗 Integration Points# Build image

docker build -t purehouse-frontend .

### Backend API Communication

# Run container

**API Client** (`lib/api.ts`):docker run -p 3000:3000 purehouse-frontend

```

```typescript

// Centralized API calls## 🚀 Deployment

export async function getPosts() {

  const res = await fetch('/api/posts');### Production with Kubernetes

  return res.json();

}When deployed with Kubernetes + Ingress:

1. Leave `NEXT_PUBLIC_API_URL` empty

export async function createPost(data: PostData) {2. Configure Ingress to route `/api` to backend service

  const res = await fetch('/api/posts', {3. Frontend and backend share the same domain

    method: 'POST',

    body: JSON.stringify(data)### Vercel Deployment

  });

  return res.json();For quick deployment to Vercel:

}1. Set `NEXT_PUBLIC_API_URL` to your backend URL

```2. Push to GitHub

3. Connect repository to Vercel

**Why this pattern**:4. Deploy automatically

- Single source of truth for API endpoints

- Easy to add authentication headers## 🧪 Development Tips

- Type-safe with TypeScript interfaces

- Testable in isolation### Hot Reload

The app uses Turbopack for instant hot reloading during development.

## 🐳 Containerization

### API Rewrites

**Multi-stage Docker build**:In development, Next.js rewrites `/api/*` requests to `localhost:3001/api/*`. See `next.config.ts` for details.



```dockerfile### Type Safety

Stage 1: DependenciesAll API responses are typed via `interfaces.ts`. Update interfaces when backend schema changes.

- Install all npm packages

## 🔗 Related Services

Stage 2: Builder

- Build Next.js production bundle- **Backend**: `../purehouse-backend` - NestJS API

- Optimize assets and images- **Worker**: `../purehouse-worker` - Logging service



Stage 3: Runtime## 📚 Learn More

- Copy only .next/ and public/

- Use standalone output mode- [Next.js Documentation](https://nextjs.org/docs)

- Run as non-root user- [Tailwind CSS Documentation](https://tailwindcss.com/docs)

```- [TypeScript Documentation](https://www.typescriptlang.org/docs)



**Image optimization**: ~180MB final image## 📄 License



## 🚀 DeploymentMIT


### Kubernetes Configuration

**Deployment specs**:
- 2 replicas for high availability
- Resource limits: 500m CPU, 512Mi memory
- Readiness probe on port 3000
- Rolling update with zero downtime

**Service**:
- ClusterIP with port 3000
- Accessed via Ingress at `/` path
- Session affinity for consistent routing

### Environment Configuration

**Build-time variables**:
```bash
NEXT_PUBLIC_API_URL=        # Empty uses rewrites
```

**Runtime variables**:
```bash
PORT=3000                   # Server port
NODE_ENV=production         # Production optimizations
```

## 💡 Technical Highlights

### Skills Demonstrated

- ✅ **Next.js 14**: App Router, Server Components, API routes
- ✅ **React**: Hooks, component composition, props pattern
- ✅ **TypeScript**: Interfaces, type safety across codebase
- ✅ **Tailwind CSS**: Utility-first responsive design
- ✅ **SEO**: Server-side rendering, meta tags, semantic HTML
- ✅ **Performance**: Image optimization, code splitting, caching
- ✅ **Containerization**: Multi-stage Docker builds
- ✅ **Cloud Native**: Environment-based config, health checks

### Next.js Features Leveraged

- **Image Component**: Automatic optimization and lazy loading
- **Font Optimization**: Google Fonts loaded efficiently
- **API Rewrites**: Backend proxy without CORS
- **Static Assets**: Public folder for images
- **App Router**: Modern file-based routing
- **Metadata API**: SEO-friendly meta tags

### Design Patterns Used

- **Container/Presentational**: Separation of data and UI
- **Composition**: Small reusable components
- **Proxy Pattern**: API rewrites for backend communication
- **Factory Pattern**: API client abstraction

---

*This service demonstrates modern frontend development with production-grade Next.js architecture, type safety, and cloud-native deployment practices.*
