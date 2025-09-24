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

## Athens-Specific Utilities and Helpers

### Block Manipulation Utilities
```clojure
;; Key utilities in athens.util namespace
(defn embed-uid->original-uid 
  "Converts embed block UID back to original"
  [uid])

(defn recursively-modify-block-for-embed
  "Modifies block tree for embedding context"
  [block embed-id])

(defn get-caret-position
  "Gets cursor position in block editor"
  [textarea])
```

### Pattern Matching and Text Processing
```clojure
;; athens.patterns namespace for content parsing
(defn date [str]
  "Matches date patterns like '02-14-2023'"
  (re-find #"(?=\d{2}-\d{2}-\d{4}).*" str))

(defn date-block-string [str] 
  "Matches full date strings like 'February 14th, 2023'"
  (re-find #"\b(?:January|February|...|December)\s\d{1,2}(?:st|nd|rd|th),\s\d{4}\b" str))

(defn block-ref? [str]
  "Checks if string contains block reference ((uid))"
  (re-find #"\(\([a-zA-Z0-9_-]+\)\)" str))

(defn page-ref? [str]
  "Checks if string contains page reference [[title]]"
  (re-find #"\[\[.*\]\]" str))
```

### Graph Traversal and Analysis
```clojure
;; Common graph operations
(defn get-block-ancestry
  "Gets all parent blocks up to page level"
  [dsdb uid])

(defn get-block-descendants
  "Gets all child blocks recursively"  
  [dsdb uid])

(defn find-shortest-path
  "Finds connection path between two blocks"
  [dsdb from-uid to-uid])

(defn get-orphaned-blocks
  "Finds blocks with no parents (potential data issues)"
  [dsdb])
```

## Development Workflow Specifics

### Hot Reloading and Development
```bash
# Start development with hot reloading
yarn dev  # Starts shadow-cljs with :app, :renderer, :main builds

# Available dev URLs
http://localhost:3000      # Web client
http://localhost:9630      # Shadow-CLJS dashboard
http://localhost:8777      # nREPL server
```

### Code Quality Tools Configuration
```clojure
;; .clj-kondo/config.edn - Linting rules
{:linters {:unresolved-namespace {:exclude [clojure.string]}
           :unused-referred-var {:exclude {clojure.test [is deftest testing]}}
           :unsorted-required-namespaces {:level :warning}}
 :lint-as {day8.re-frame.tracing/fn-traced clojure.core/fn
           reagent.core/with-let clojure.core/let}}
```

### Build Optimization Flags
```clojure
;; shadow-cljs.edn development settings
:dev {:compiler-options 
      {:closure-defines {re-frame.trace.trace-enabled? true
                        day8.re-frame.tracing.trace-enabled? true
                        goog.DEBUG true}
       :warnings {:redef false}}}

;; Production optimizations  
:release {:build-options 
          {:ns-aliases {day8.re-frame.tracing day8.re-frame.tracing-stubs}}}
```

## Athens UI/UX Patterns

### Block Editor Behavior
```clojure
;; Key bindings and interactions
:enter     -> Create new block
:shift+enter -> New line within block  
:tab       -> Indent block (make child)
:shift+tab -> Unindent block (move up level)
:backspace -> Delete block if empty, merge with previous if at start
:cmd+k     -> Quick block search and navigation
:cmd+j     -> Jump to date page
```

### Search and Navigation
```clojure
;; Athens search patterns (Athena)
"[[page name"    -> Search for page by name
"((block content" -> Search for block by content  
"TODO:"          -> Search for task blocks
"/template"      -> Insert template
"/date"          -> Insert date reference
```

### Keyboard Navigation Conventions
```clojure
;; Block selection and editing
(rf/reg-event-fx
  ::navigate-block
  (fn [{:keys [db]} [_ direction uid]]
    (case direction
      :up    (focus-previous-block uid)
      :down  (focus-next-block uid) 
      :left  (move-to-parent uid)
      :right (move-to-first-child uid))))
```

## Error Handling and Monitoring

### Sentry Integration Patterns
```clojure
;; Error boundary for React components
(defn error-boundary [component]
  [re-com/error-boundary
   {:on-error (fn [error info]
                (sentry/capture-exception error info))}
   component])

;; Traced functions for performance monitoring
(sentry-m/defntrace expensive-operation
  [large-data]
  ;; Function automatically gets tracing
  (process-large-dataset large-data))
```

### Database Integrity Checks
```clojure
;; Validation functions
(defn validate-block-structure [block]
  (and (:block/uid block)
       (:block/string block)
       (or (nil? (:block/children block))
           (every? #(contains? % :block/uid) (:block/children block)))))

(defn check-graph-consistency [dsdb]
  ;; Verify all block references point to existing blocks
  ;; Check for orphaned blocks
  ;; Validate parent-child relationships
  )
```

## Advanced ClojureScript Techniques

### Macro Usage in Athens
```clojure
;; Common macro patterns used in Athens
(athens.common.sentry/defntrace function-name
  "Automatically traces function execution"
  [args]
  body)

(day8.re-frame.tracing/fn-traced 
  "Traces anonymous function execution"
  [args] 
  body)
```

### Specter for Data Transformation
```clojure
;; Advanced data manipulation with Specter
(:require [com.rpl.specter :as s])

(defn update-blocks-recursively [block-tree transform-fn]
  (s/transform 
    (specter-recursive-path #(contains? % :block/children))
    transform-fn
    block-tree))

(defn find-blocks-with-property [blocks property-key]
  (s/select 
    [s/ALL 
     (s/pred #(contains? (:block/properties %) property-key))]
    blocks))
```

## Mobile and Responsive Considerations

### Chakra UI Responsive Props
```clojure
;; Responsive design patterns
[:> Box {:width {:base "100%" :md "80%" :lg "60%"}
         :padding {:base 2 :md 4 :lg 6}
         :fontSize {:base "sm" :md "md" :lg "lg"}}]

;; Mobile-specific block editing
(defn mobile-block-editor [block]
  [:div.mobile-editor
   {:style {:touch-action "manipulation"  ;; Better mobile scrolling
            :user-select "text"}}         ;; Allow text selection
   [block-content block]])
```

### Touch and Gesture Handling
```typescript
// Mobile gesture patterns in TypeScript components
export const BlockDrag = ({ block, onDrag }: BlockDragProps) => {
  const sensors = useSensors(
    useSensor(PointerSensor, {
      activationConstraint: {
        distance: 8, // Minimum drag distance
      },
    })
  );
  
  return (
    <DragOverlay>
      <BlockComponent block={block} />
    </DragOverlay>
  );
};
```

## Athens-Specific Domain Concepts

### Block and Page System
Athens is built around a hierarchical block-based structure where every piece of content is a block:

```clojure
;; Core block structure
{:db/id 123
 :block/uid "abc123def"           ;; Unique identifier (9-char random string)
 :block/string "Block content"    ;; The actual text content
 :block/order 0                   ;; Position among siblings
 :block/children [{:db/id 124}]   ;; References to child blocks
 :block/refs [{:db/id 125}]       ;; References to other blocks/pages
 :block/open? true}               ;; Whether block is expanded

;; Page structure (special kind of block)
{:db/id 456
 :node/title "Page Title"         ;; Page title (unique)
 :block/children [{:db/id 123}]}  ;; Top-level blocks in the page
```

### Block References and Bidirectional Linking
```clojure
;; Block reference syntax in content: ((block-uid))
;; Page reference syntax in content: [[Page Title]]
;; Both create bidirectional links automatically

;; Query for backlinks to a page
(d/q '[:find ?b
       :in $ ?title
       :where
       [?page :node/title ?title]
       [?b :block/refs ?page]]
     @dsdb "Target Page")
```

### Property System (v2+ Schema)
```clojure
;; Properties are special block relationships
{:db/id 789
 :block/property-of {:db/id 123}  ;; Parent block
 :block/key {:db/id 456}          ;; Property name (references another block)
 :block/string "Property value"}   ;; Property value

;; Query properties of a block
(d/q '[:find ?key-title ?value
       :in $ ?block-id
       :where
       [?prop :block/property-of ?block-id]
       [?prop :block/key ?key]
       [?key :node/title ?key-title]
       [?prop :block/string ?value]]
     @dsdb block-id)
```

## Advanced Architectural Patterns

### 1. Datascript Query Patterns
```clojure
;; Common queries used throughout Athens
(defn get-block-document
  "Gets complete block tree starting from root"
  [dsdb uid]
  (d/pull @dsdb '[* {:block/children ...}] [:block/uid uid]))

(defn get-parents-recursively
  "Gets all parent blocks up to page level"
  [dsdb uid]
  (d/q '[:find ?parent-uid
         :in $ % ?uid
         :where
         (parent ?uid ?parent-uid)]
       @dsdb parent-rules uid))

;; Recursive rule for parent traversal
(def parent-rules
  '[[(parent ?child-uid ?parent-uid)
     [?child :block/uid ?child-uid]
     [?parent :block/children ?child]
     [?parent :block/uid ?parent-uid]]
    [(parent ?child-uid ?ancestor-uid)
     (parent ?child-uid ?parent-uid)
     (parent ?parent-uid ?ancestor-uid)]])
```

### 2. Graph Operations and Transactions
```clojure
;; Atomic operations for graph changes
(ns athens.common-events.graph.ops)

(defn create-block-op
  "Creates a new block with proper relationships"
  [{:keys [new-uid parent-uid order string]}]
  {:block/uid new-uid
   :block/string string
   :block/order order
   :create/time (common.utils/now-ts)})

(defn move-block-op
  "Moves block between locations atomically"
  [source-uid target-parent-uid new-order]
  ;; Complex transaction handling parent updates,
  ;; order adjustments, and reference maintenance
  )
```

### 3. Re-frame Effect Patterns
```clojure
;; Custom effects for Athens operations
(rf/reg-fx
  :transact!
  (fn [tx-data]
    (d/transact! @athens.db/dsdb tx-data)))

(rf/reg-fx
  :dispatch-debounced
  (fn [{:keys [key dispatch timeout]}]
    ;; Debounced dispatch for search/autosave
    ))

;; Event with multiple effects
(rf/reg-event-fx
  ::create-block-and-focus
  (fn [{:keys [db]} [_ parent-uid position text]]
    (let [new-uid (athens.util/gen-block-uid)
          block-op (create-block-op {:new-uid new-uid 
                                     :parent-uid parent-uid
                                     :order position
                                     :string text})]
      {:transact! [block-op]
       :dispatch [::focus-block new-uid]
       :fx [[:dispatch-later [{:ms 100 
                               :dispatch [::update-selection-state]}]]]})))
```

### 4. Component Composition Patterns
```clojure
;; Higher-order component for block editing
(defn with-block-editing [component]
  (fn [props]
    (let [editing? (rf/subscribe [:editing/uid (:block/uid props)])]
      [component (assoc props :editing? @editing?)])))

;; Block component with editing state
(defn block-component
  [{:block/keys [uid string children] :as block}]
  [:div.block
   [block-bullet block]
   [block-content block]
   (when-not (empty? children)
     [:div.block-children
      (for [child children]
        ^{:key (:block/uid child)}
        [block-component child])])])
```

### 5. Selection and Focus Management
```clojure
;; Selection state management
(rf/reg-sub
  :selection/blocks
  (fn [db _]
    (get-in db [:selection :blocks])))

(rf/reg-event-fx
  ::select-block-range
  (fn [{:keys [db]} [_ start-uid end-uid]]
    (let [block-range (get-blocks-between start-uid end-uid)]
      {:db (assoc-in db [:selection :blocks] block-range)
       :dispatch [::update-selection-ui]})))
```

## Configuration and Build Patterns

### Shadow-CLJS Configuration
```clojure
;; Key shadow-cljs.edn patterns
{:builds {
   :app {:target :browser
         :modules {:app {:init-fn athens.core/init}}
         :dev {:compiler-options 
               {:closure-defines {re-frame.trace.trace-enabled? true}
                :warnings {:redef false}}}
         :release {:build-options 
                   {:ns-aliases {day8.re-frame.tracing day8.re-frame.tracing-stubs}}}}}}
```

### Babel Configuration for React/TypeScript
```javascript
// Key patterns in babel.config.js
module.exports = {
  plugins: [
    // Custom plugin for Shadow-CLJS compatibility
    replaceDirectoryImports,
    // Module resolution for component library
    ["module-resolver", {alias: {"@": "./src/js/components"}}]
  ]
}
```

### ClojureScript Interop Best Practices
```clojure
;; Importing npm modules
(:require ["@chakra-ui/react" :as chakra :refer [Box Button]])

;; Using React components in Reagent
[:> chakra/Button {:onClick handle-click 
                   :variant "outline"} 
 "Click me"]

;; Converting between JS and ClojureScript data
(defn js-props->clj [js-props]
  (js->clj js-props :keywordize-keys true))

(defn clj-data->js [clj-data]
  (clj->js clj-data))
```

## Testing Patterns and Examples

### Datascript Database Testing
```clojure
(deftest block-creation-test
  (testing "creating a new block updates graph correctly"
    (let [conn (d/create-conn schema)
          parent-uid "parent123"
          new-uid "child456"]
      
      ;; Setup: Create parent block
      (d/transact! conn [{:block/uid parent-uid
                          :block/string "Parent"}])
      
      ;; Action: Add child block
      (d/transact! conn [{:block/uid new-uid
                          :block/string "Child"
                          :block/order 0}
                         {:db/id [:block/uid parent-uid]
                          :block/children [[:block/uid new-uid]]}])
      
      ;; Assert: Verify relationships
      (let [parent (d/pull @conn '[* {:block/children [*]}] 
                          [:block/uid parent-uid])]
        (is (= 1 (count (:block/children parent))))
        (is (= new-uid (-> parent :block/children first :block/uid)))))))
```

### E2E Testing Patterns
```typescript
// Playwright patterns specific to Athens
test('block editing and navigation', async ({ page }) => {
  await page.goto('/');
  
  // Wait for Athens to initialize
  await page.waitForSelector('[data-testid="app-container"]');
  
  // Create a new block
  await page.keyboard.press('Enter');
  await page.fill('[data-testid="block-input"]', 'Test block content');
  
  // Verify block creation
  await expect(page.locator('.block-content')).toContainText('Test block content');
  
  // Test block navigation
  await page.keyboard.press('ArrowUp');
  await expect(page.locator('.block-editor-active')).toBeVisible();
});
```

## Performance and Optimization

### Subscription Optimization
```clojure
;; Efficient subscriptions using path-based queries
(rf/reg-sub
  :block/string
  (fn [db [_ uid]]
    ;; Direct path lookup instead of full query
    (get-in db [:athens/dsdb-data :block/uid uid :block/string])))

;; Memoized subscriptions for expensive computations
(rf/reg-sub
  :block/children-sorted
  :<- [:block/children]
  (fn [children _]
    (sort-by :block/order children)))
```

### React Component Optimization
```typescript
// Memoized React components
export const BlockComponent = React.memo(({ block, depth }) => {
  // Only re-render when block data or depth changes
  return (
    <div className="block" style={{ marginLeft: `${depth * 20}px` }}>
      {block.string}
    </div>
  );
}, (prevProps, nextProps) => {
  return prevProps.block.uid === nextProps.block.uid && 
         prevProps.depth === nextProps.depth;
});
```

## Common Gotchas and Solutions

### 1. UID Generation and Uniqueness
```clojure
;; Always use Athens' UID generation
(defn gen-block-uid []
  (random-uuid))  ;; 9-character random string

;; Don't create blocks without proper UIDs
```

### 2. Datascript Transaction Ordering
```clojure
;; Transactions must be in correct order for references
[{:block/uid "parent"}     ;; Create parent first
 {:block/uid "child"}      ;; Create child second  
 {:db/id [:block/uid "parent"]
  :block/children [[:block/uid "child"]]}]  ;; Link them third
```

### 3. Re-frame Subscription Dependencies
```clojure
;; Use :<- syntax for dependent subscriptions
(rf/reg-sub
  :derived-data
  :<- [:base-data]
  :<- [:other-data]  
  (fn [[base-data other-data] _]
    (combine base-data other-data)))
```

## Athens Type System and Protocols

### Block Type Dispatch System
```clojure
;; Athens uses multimethods for block type rendering
(defmulti block-type->protocol
  "Returns BlockTypeProtocol for rendering based on block type"
  (fn [k _args-map] k))

;; Block type examples
(defmethod block-type->protocol "[[athens/task]]" [_ args]
  ;; Task block rendering logic
  )

(defmethod block-type->protocol "[[athens/query]]" [_ args]
  ;; Query block rendering logic  
  )

;; Type dispatcher with feature flags
(defn if-not-disabled [block-type feature-flags]
  (let [type->ff {"[[athens/task]]" :tasks
                  "[[athens/query]]" :queries}]
    (if-let [ff (type->ff block-type)]
      (and (feature-flags ff) block-type)
      block-type)))
```

### Block Editing Protocols
```clojure
;; Editor behavior dispatch based on block content
(defprotocol BlockEditingBehavior
  (handle-keydown [this event block-uid])
  (handle-paste [this event block-uid])
  (get-completion-suggestions [this text cursor-pos]))
```

## Advanced Re-frame Patterns

### Custom Interceptors
```clojure
;; Persistence interceptor for Athens data
(def persist-db
  "Saves the :athens/persist key to localStorage"
  (rf/->interceptor
    :id    :persist
    :after (fn [{:keys [coeffects effects] :as context}]
             (let [k      :athens/persist
                   before (-> coeffects :db k)
                   after  (-> effects :db k)]
               (when (and after (not (identical? before after)))
                 (util/local-storage-set! k after)))
             context)))

;; Sentry monitoring interceptor
(defn sentry-span [span-name]
  (rf/->interceptor
    :id     :sentry-span
    :before (fn [context]
              (sentry/start-span span-name context))
    :after  (fn [context]
              (sentry/finish-span context))))
```

### Advanced Event Patterns
```clojure
;; Multi-stage event handling with async flow
(rf/reg-event-fx
  ::complex-block-operation
  [(sentry-span "block-operation") persist-db]
  (fn [{:keys [db]} [_ operation-data]]
    {:db (update-db-stage-1 db operation-data)
     :async-flow {:id :block-op
                  :rules [{:when :seen? 
                           :events ::stage-1-complete
                           :dispatch [::stage-2 operation-data]}]}}))

;; Debounced events for performance
(rf/reg-fx
  :dispatch-debounced
  (fn [{:keys [key dispatch timeout]}]
    (js/clearTimeout (get @debounce-timeouts key))
    (swap! debounce-timeouts assoc key
           (js/setTimeout #(rf/dispatch dispatch) timeout))))
```

## Keyboard and Input Handling Patterns

### Block Editor Key Bindings
```clojure
;; Complex keyboard event handling in blocks
(defn handle-keydown-event
  "Comprehensive keyboard event handler for block editing"
  [e uid]
  (let [key (.. e -key)
        {:keys [shift meta ctrl alt]} (modifier-keys e)
        target (.. e -target)
        {:keys [start end]} (get-selection-offsets target)]
    
    (case key
      "Enter"     (handle-enter e uid shift)
      "Tab"       (handle-tab e uid shift)
      "Backspace" (handle-backspace e uid start end)
      "ArrowUp"   (handle-arrow-navigation e uid :up)
      "ArrowDown" (handle-arrow-navigation e uid :down)
      ;; Shortcut combinations
      (when (and meta (= key "k"))
        (dispatch [::open-command-palette uid]))
      (when (and meta shift (= key "k"))
        (dispatch [::open-block-search uid])))))

;; Caret position utilities
(defn get-caret-position [textarea]
  (let [position (.-selectionStart textarea)
        coordinates (getCaretCoordinates textarea position)]
    {:position position
     :left (.-left coordinates)
     :top (.-top coordinates)
     :height (.-height coordinates)}))
```

### Autocomplete and Slash Commands
```clojure
;; Slash command system
(def slash-commands
  {"date"     {:icon CalendarNowIcon :dispatch [::insert-date]}
   "time"     {:icon TimeNowIcon :dispatch [::insert-time]}  
   "todo"     {:icon CheckboxIcon :dispatch [::insert-task]}
   "template" {:icon TemplateIcon :dispatch [::show-templates]}
   "embed"    {:icon BlockEmbedIcon :dispatch [::show-block-search]}
   "youtube"  {:icon YoutubeIcon :dispatch [::insert-youtube]}})

;; Autocomplete trigger patterns
(defn detect-autocomplete-trigger [text cursor-pos]
  (let [before-cursor (subs text 0 cursor-pos)]
    (cond
      (re-find #"\[\[[^]]*$" before-cursor) :page-search
      (re-find #"\(\([^)]*$" before-cursor) :block-search  
      (re-find #"#[^#\s]*$" before-cursor) :tag-search
      (re-find #"@[^@\s]*$" before-cursor) :user-mention
      (re-find #"/[^/\s]*$" before-cursor) :slash-command)))
```

## Graph Database Advanced Patterns

### Complex Datascript Queries
```clojure
;; Recursive queries for block hierarchies
(defn get-block-tree-with-depth [dsdb root-uid max-depth]
  (d/q '[:find ?uid ?string ?order ?depth
         :in $ % ?root-uid ?max-depth
         :where
         (block-tree ?root-uid ?uid ?depth)
         [(<= ?depth ?max-depth)]
         [?e :block/uid ?uid]
         [?e :block/string ?string]
         [?e :block/order ?order]]
       @dsdb
       '[[(block-tree ?parent ?child 0)
          [?p :block/uid ?parent]
          [?p :block/children ?c]
          [?c :block/uid ?child]]
         [(block-tree ?parent ?descendant ?depth)
          (block-tree ?parent ?child ?d1)
          (block-tree ?child ?descendant ?d2)
          [(+ ?d1 ?d2 1) ?depth]]]
       root-uid max-depth))

;; Graph analysis queries
(defn find-orphaned-blocks [dsdb]
  "Find blocks that have no parent and aren't pages"
  (d/q '[:find ?uid
         :where
         [?b :block/uid ?uid]
         (not [?parent :block/children ?b])
         (not [?b :node/title])]
       @dsdb))

;; Reference tracking
(defn get-backlinks [dsdb target-uid]
  (d/q '[:find ?referrer-uid ?ref-context
         :in $ ?target-uid
         :where
         [?target :block/uid ?target-uid]
         [?referrer :block/refs ?target]
         [?referrer :block/uid ?referrer-uid]
         [?referrer :block/string ?ref-context]]
       @dsdb target-uid))
```

### Transaction Optimization
```clojure
;; Batched transaction patterns
(defn batch-block-updates [dsdb updates]
  "Efficiently update multiple blocks in a single transaction"
  (let [tx-data (for [{:keys [uid changes]} updates]
                  (merge {:db/id [:block/uid uid]} changes))]
    (d/transact! dsdb tx-data)))

;; Conditional transactions
(defn safe-block-update [dsdb uid update-fn]
  "Only update block if it exists and passes validation"
  (when-let [block (d/pull @dsdb '[*] [:block/uid uid])]
    (let [updated-block (update-fn block)]
      (when (validate-block-structure updated-block)
        (d/transact! dsdb [updated-block])))))
```

## Component Lifecycle and State Management

### Reagent Component Patterns
```clojure
;; Component with local state and cleanup
(defn block-editor-component [block-data]
  (let [local-state (r/atom {:editing? false :temp-value ""})
        cleanup-fn (atom nil)]
    
    (r/create-class
     {:component-did-mount
      (fn [this]
        (let [node (r/dom-node this)]
          (reset! cleanup-fn 
                  (add-event-listener node "keydown" handle-keydown))))
      
      :component-will-unmount  
      (fn [this]
        (when @cleanup-fn (@cleanup-fn)))
      
      :reagent-render
      (fn [block-data]
        [:div.block-editor
         {:class (when (:editing? @local-state) "editing")}
         [block-content block-data local-state]])})))

;; Higher-order component patterns
(defn with-presence-tracking [component]
  "HOC that tracks user presence on component"
  (fn [props]
    (let [presence-id (random-uuid)]
      (r/create-class
       {:component-did-mount
        (fn [] (dispatch [::track-presence presence-id]))
        
        :component-will-unmount
        (fn [] (dispatch [::untrack-presence presence-id]))
        
        :reagent-render  
        (fn [props]
          [component (assoc props :presence-id presence-id)])}))))
```

### React Hook Integration
```typescript
// Custom hooks for Athens-specific functionality
export const useBlockFocus = (blockUid: string) => {
  const [isFocused, setIsFocused] = useState(false);
  
  useEffect(() => {
    const handleFocus = (event: CustomEvent) => {
      setIsFocused(event.detail.uid === blockUid);
    };
    
    document.addEventListener('athens:block-focus', handleFocus);
    return () => document.removeEventListener('athens:block-focus', handleFocus);
  }, [blockUid]);
  
  return isFocused;
};

export const useBlockPresence = (blockUid: string) => {
  const [users, setUsers] = useState([]);
  
  useEffect(() => {
    // Subscribe to presence updates for this block
    const unsubscribe = subscribeToBlockPresence(blockUid, setUsers);
    return unsubscribe;
  }, [blockUid]);
  
  return users;
};
```

## Testing Strategies and Patterns

### Advanced E2E Test Patterns
```typescript
// Page object model for Athens
export class AthensPage {
  constructor(private page: Page) {}
  
  async createBlock(text: string, parent?: string) {
    if (parent) {
      await this.page.click(`[data-uid="${parent}"] .block-bullet`);
      await this.page.keyboard.press('Tab');
    } else {
      await this.page.keyboard.press('Enter');
    }
    await this.page.fill('.block-input-textarea >> nth=-1', text);
  }
  
  async navigateToBlock(uid: string) {
    await this.page.keyboard.press('Meta+K');
    await this.page.fill('[data-testid="athena-input"]', `((${uid}))`);
    await this.page.keyboard.press('Enter');
  }
  
  async waitForBlockToLoad(uid: string) {
    await this.page.waitForSelector(`[data-uid="${uid}"]`);
  }
  
  async getBlockText(uid: string): Promise<string> {
    return this.page.textContent(`[data-uid="${uid}"] .block-content`);
  }
}

// Integration test patterns
test.describe('Block operations', () => {
  let athens: AthensPage;
  
  test.beforeEach(async ({ page }) => {
    athens = new AthensPage(page);
    await page.goto('/');
    await athens.waitForAppToLoad();
  });
  
  test('hierarchical block creation and navigation', async () => {
    const parentUid = await athens.createBlock('Parent block');
    const childUid = await athens.createBlock('Child block', parentUid);
    
    await athens.navigateToBlock(childUid);
    await expect(athens.getBlockText(childUid)).toBe('Child block');
    
    // Verify parent-child relationship
    const parentText = await athens.getBlockText(parentUid);
    expect(parentText).toBe('Parent block');
  });
});
```

### Property-Based Testing
```clojure
;; Property-based tests for graph operations
(defspec block-operations-preserve-graph-integrity
  100
  (prop/for-all [operations (gen/vector graph-operation-gen 1 10)]
    (let [initial-db (create-test-db)
          final-db (reduce apply-operation initial-db operations)]
      (and (valid-graph-structure? final-db)
           (no-orphaned-blocks? final-db)
           (consistent-references? final-db)))))

;; Generators for Athens data structures
(def block-gen
  (gen/let [uid gen/string-alphanumeric
            string gen/string
            order gen/nat]
    {:block/uid uid
     :block/string string  
     :block/order order}))
```

Remember: This is a complex, mature codebase with many interconnected parts. When making changes, consider the impact on the graph data structure, Re-frame state flow, and user experience patterns established throughout the application.