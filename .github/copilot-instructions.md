# GitHub Copilot Instructions for Athens

## Overview

Athens is an open-source knowledge graph application built with ClojureScript and React. It helps teams capture and synthesize knowledge using a graph database approach similar to Roam Research and Obsidian.

**⚠️ Note**: This project is no longer actively maintained but serves as a reference implementation.

## Technology Stack

### Core Technologies
- **ClojureScript**: Primary language for frontend logic
- **Re-frame**: State management pattern and framework
- **Reagent**: ClojureScript wrapper for React
- **Shadow-CLJS**: Build tool for ClojureScript compilation
- **Datascript**: In-memory database for graph data
- **React 17**: UI component framework
- **Chakra UI**: React component library for styling

### Development Tools
- **Node.js/Yarn**: Package management and build scripts
- **Playwright**: End-to-end testing framework
- **Karma**: Unit test runner
- **Babel**: JavaScript/TypeScript transpilation
- **Electron**: Desktop application wrapper

### Backend/Data
- **Fluree**: Optional graph database backend
- **Clojure**: Server-side logic
- **HTTP Kit**: Web server
- **Compojure**: Routing library

## Project Structure

```
athens/
├── src/
│   ├── cljs/athens/          # ClojureScript source
│   │   ├── core.cljs         # Main app initialization
│   │   ├── db.cljs           # Database layer and schema
│   │   ├── events.cljs       # Re-frame events
│   │   ├── subs.cljs         # Re-frame subscriptions
│   │   ├── views.cljs        # Main UI components
│   │   ├── components.cljs   # Reagent components
│   │   └── views/            # Page-specific views
│   ├── js/components/        # React/TypeScript components
│   │   ├── Icons/            # SVG icon components
│   │   └── ...               # Various UI components
│   ├── cljc/                 # Shared Clojure/ClojureScript code
│   └── clj/                  # Server-side Clojure code
├── test/
│   ├── athens/              # ClojureScript tests
│   └── e2e/                 # Playwright end-to-end tests
├── resources/public/        # Static assets
├── shadow-cljs.edn         # Build configuration
├── deps.edn                # Clojure dependencies
└── package.json            # Node.js dependencies
```

## Coding Conventions

### ClojureScript/Clojure Style
- Use **kebab-case** for function and variable names
- Use **PascalCase** for React components
- Follow standard Clojure indentation (2 spaces)
- Use `defn` for functions, `def` for constants
- Prefer `let` bindings over deeply nested function calls
- Use meaningful, descriptive names

### Re-frame Patterns
- **Events**: Use namespaced keywords (e.g., `::create-page`, `::delete-block`)
- **Subscriptions**: Follow query patterns (e.g., `[:page/title page-uid]`)
- **Effects**: Use descriptive effect names in `reg-fx`
- **Coeffects**: Use `reg-cofx` for dependency injection

### React/TypeScript Components
- Use **functional components** with hooks
- Export components using named exports
- Use **TypeScript** for type safety
- Follow Chakra UI component patterns
- Use `createIcon` helper for SVG icons

### Database Patterns (Datascript)
- Use `:db/id` for entity references
- Follow EAV (Entity-Attribute-Value) model
- Use `:db.unique/identity` for unique attributes
- Prefer transaction functions over direct assertions

## Key Architectural Patterns

### 1. Graph Database Structure
```clojure
;; Entities are connected in a graph
{:db/id 1
 :node/title "Page Title"
 :block/uid "abc123"
 :block/string "Content"
 :block/children [{:db/id 2}...]
 :block/refs [{:db/id 3}...]}
```

### 2. Re-frame Event Flow
```clojure
;; Events modify app state
(rf/reg-event-fx
  ::create-block
  (fn [{:keys [db]} [_ parent-uid position]]
    {:db (assoc-in db [:some :path] value)
     :dispatch-later [{:ms 100 :dispatch [::focus-block new-uid]}]}))
```

### 3. React Component Integration
```clojure
;; Reagent components can use React components
[:> ReactComponent {:prop "value"}
  [reagent-child-component]]
```

### 4. Interop with JavaScript
```clojure
;; Use shadow-cljs require syntax for npm modules
(:require ["@chakra-ui/react" :as chakra])

;; Call JS functions with proper conversion
(js/someFunction (clj->js {:key "value"}))
```

## Common Development Tasks

### Adding New Features
1. **Events**: Define in `events.cljs` with proper effects
2. **Subscriptions**: Add reactive queries in `subs.cljs`
3. **Components**: Create in `views/` or `src/js/components/`
4. **Tests**: Add corresponding tests in `test/athens/`

### Working with the Database
- Use `@athens.db/dsdb` to access current database
- Create queries with Datascript query syntax
- Use graph operations for block manipulation
- Handle undo/redo through event history

### Styling Approach
- Prefer **Chakra UI** components over custom CSS
- Use theme tokens for consistent spacing/colors
- Apply responsive design with Chakra's responsive props
- Custom styles go in `src/cljs/athens/style.cljs`

## Build and Development Commands

```bash
# Install dependencies
yarn install

# Development server with hot reloading
yarn dev

# Build for production
yarn prod

# Run tests
yarn client:test          # Unit tests
yarn client:e2e          # End-to-end tests
yarn server:test         # Server tests

# Code quality
yarn lint                # ClojureScript linting
yarn style              # Code style checking
yarn carve              # Remove unused code
```

## Testing Guidelines

### Unit Tests (ClojureScript)
- Use `cljs.test` for testing framework
- Test pure functions and data transformations
- Mock external dependencies and side effects
- Place tests in `test/athens/` matching source structure

### End-to-End Tests (Playwright)
- Test complete user workflows
- Use page object pattern for reusability
- Focus on critical paths and edge cases
- Tests are in `test/e2e/` with `.spec.ts` extension

### Test Patterns
```clojure
;; ClojureScript test example
(deftest parse-block-test
  (testing "parses block references correctly"
    (is (= expected-result (parse-block input-string)))))
```

```typescript
// Playwright test example
test('can create and edit a block', async ({ page }) => {
  await page.goto('/');
  await page.click('[data-testid="create-block"]');
  await page.fill('[data-testid="block-input"]', 'Test content');
  await expect(page.locator('[data-testid="block-content"]')).toHaveText('Test content');
});
```

## Important Files and Modules

### Core Application Files
- `src/cljs/athens/core.cljs` - App initialization and routing
- `src/cljs/athens/db.cljs` - Database schema and seed data
- `src/cljs/athens/events.cljs` - Main event handlers
- `src/cljs/athens/subs.cljs` - Reactive subscriptions
- `src/cljs/athens/views.cljs` - Root component and routing

### Key Utility Modules
- `src/cljs/athens/util.cljs` - General utility functions
- `src/cljs/athens/patterns.cljs` - Text parsing and regex patterns
- `src/cljs/athens/router.cljs` - URL routing logic
- `src/cljc/athens/common_db.cljs` - Shared database utilities

### React Components
- `src/js/components/Icons/Icons.tsx` - SVG icon components
- `src/js/components/Block/` - Block editing components
- `src/js/components/Page/` - Page-level components

## Development Best Practices

### Performance Considerations
- Use `react-window` for virtualizing large lists
- Implement proper React keys for list items
- Use Re-frame subscriptions for fine-grained reactivity
- Minimize database queries in render functions

### Error Handling
- Use React error boundaries for component errors
- Handle async errors in Re-frame effects
- Provide meaningful error messages to users
- Log errors appropriately (check Sentry integration)

### Code Organization
- Keep components small and focused
- Extract common patterns into utility functions
- Use namespaces to group related functionality
- Document complex algorithms and business logic

## Debugging Tips

### ClojureScript Debugging
- Use `js/console.log` for basic debugging
- Use Re-frame-10x browser extension for state inspection
- Use `tap>` for development-time logging
- Chrome DevTools work with source maps

### React Debugging
- Use React DevTools browser extension
- Add `data-testid` attributes for testing
- Use proper component display names
- Profile performance with React DevTools Profiler

## Integration Patterns

### External Libraries
- Use shadow-cljs `:npm-deps` in `shadow-cljs.edn`
- Import with proper namespace aliases
- Handle JS/ClojureScript data conversion carefully
- Document any special setup requirements

### API Integration
- Use `cljs-http` for HTTP requests
- Handle async operations through Re-frame effects
- Implement proper error handling for network requests
- Cache data appropriately in app state

Remember: This is a complex, mature codebase with many interconnected parts. When making changes, consider the impact on the graph data structure, Re-frame state flow, and user experience patterns established throughout the application.