name: frontend-skill
description: Build responsive and modular frontend UIs using Next.js, including pages, components, layouts, and styling.
---

# Frontend Skill

## Instructions

1. **Page Creation**
   - Create pages using Next.js App Router  
   - Implement dynamic routes and nested layouts  
   - Ensure proper data fetching patterns (Server Components, Client Components)  

2. **Component Development**
   - Build reusable and modular components  
   - Pass props and manage state effectively  
   - Use conditional rendering and composition patterns  

3. **Layout & Styling**
   - Structure layouts for responsiveness and accessibility  
   - Use Tailwind CSS, CSS Modules, or styled-components  
   - Implement consistent spacing, typography, and color schemes  

4. **Frontend Best Practices**
   - Optimize rendering and avoid unnecessary re-renders  
   - Lazy-load components when appropriate  
   - Keep code modular, readable, and maintainable  
   - Follow accessibility (a11y) standards  

## Best Practices
- Mobile-first and responsive design  
- Keep components small and reusable  
- Follow Next.js conventions for layouts and routing  
- Use semantic HTML and accessible attributes  
- Optimize performance by code splitting and lazy loading  

## Example Usage

```jsx
// pages/index.jsx
import Header from '../components/Header'
import Hero from '../components/Hero'
import Footer from '../components/Footer'

export default function HomePage() {
  return (
    <div className="flex flex-col min-h-screen">
      <Header />
      <main className="flex-grow">
        <Hero title="Welcome to Next.js App" subtitle="Build fast and responsive UIs" />
      </main>
      <Footer />
    </div>
  )
}

// components/Hero.jsx
export default function Hero({ title, subtitle }) {
  return (
    <section className="text-center py-20 bg-gradient-to-r from-blue-500 to-purple-600 text-white">
      <h1 className="text-4xl font-bold">{title}</h1>
      <p className="mt-4 text-lg">{subtitle}</p>
    </section>
  )
}
