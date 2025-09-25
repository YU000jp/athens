# Clojars Access Restriction Solutions

The issue with `repo.clojars.org` access restrictions can be resolved through multiple approaches. Here are comprehensive solutions that eliminate the dependency on Clojars for the core CLDR functionality.

## 🎯 Problem Analysis

The error occurs because:
1. Some Clojure dependencies are only available on Clojars (not Maven Central)
2. Network restrictions prevent access to `repo.clojars.org`
3. The `tick/tick` library (main date/time dependency) requires Clojars access

## 🚀 Solution 1: JavaScript-Only Date Handling (Recommended)

Since the CLDR issue is primarily in browser tests, we can eliminate Clojure date dependencies entirely for the frontend.

### Implementation:

**Step 1**: Create a JavaScript-only date handling module that doesn't require Clojure dependencies:

```javascript
// browser-date-handler.js
window.AthensDateHandler = {
  // US date format: MM-dd-yyyy
  formatUSDate: function(date) {
    const d = new Date(date);
    const month = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    const year = d.getFullYear();
    return `${month}-${day}-${year}`;
  },
  
  // Title format: October 15, 2023
  formatTitle: function(date) {
    const d = new Date(date);
    const options = { 
      year: 'numeric', 
      month: 'long', 
      day: 'numeric' 
    };
    return d.toLocaleDateString('en-US', options);
  },
  
  // Parse UID format (MM-dd-yyyy)
  parseUID: function(uid) {
    if (!uid || typeof uid !== 'string') return null;
    const match = uid.match(/^(\d{2})-(\d{2})-(\d{4})$/);
    if (!match) return null;
    const [_, month, day, year] = match;
    return new Date(parseInt(year), parseInt(month) - 1, parseInt(day));
  },
  
  // Current date operations
  getToday: function() {
    return new Date();
  },
  
  getDayWithOffset: function(offset) {
    const date = new Date();
    date.setDate(date.getDate() + offset);
    return {
      uid: this.formatUSDate(date),
      title: this.formatTitle(date),
      inst: date
    };
  }
};
```

**Step 2**: Update Karma to use JavaScript-only approach:

```javascript
// karma-no-clojars.conf.js - Clojars-free configuration
module.exports = function (config) {
  config.set({
    browsers: ['ChromeHeadless'],
    basePath: 'target',
    files: [
      // JavaScript-only date handling (no Clojure dependencies)
      '../browser-date-handler.js',
      
      // Enhanced CLDR with JavaScript fallbacks
      '../cldr-enhanced-init.js',
      
      // Main test file
      'karma-test.js'
    ],
    frameworks: ['cljs-test'],
    // ... rest of configuration
  });
};
```

## 🔧 Solution 2: Maven Central Only Dependencies

Modify `deps.edn` to prioritize Maven Central and provide alternatives for Clojars-only libraries:

```clojure
{:mvn/repos
 {"central"   {:url "https://repo1.maven.org/maven2/"}
  "sonatype"  {:url "https://oss.sonatype.org/content/repositories/public/"}
  "maven2"    {:url "https://repo.maven.apache.org/maven2/"}
  ;; Remove or comment out clojars when access is restricted
  ;;"clojars"   {:url "https://repo.clojars.org/"}
  }

 :deps
 {;; Core dependencies (available on Maven Central)
  org.clojure/clojure                   #:mvn{:version "1.11.1"}
  org.clojure/clojurescript             #:mvn{:version "1.11.60"}
  
  ;; Alternative to tick/tick - use java.time directly
  ;; tick/tick                             #:mvn{:version "0.5.0-RC5"}
  cljc.java-time/cljc.java-time         #:mvn{:version "0.1.9"}
  
  ;; Alternative to denistakeda/posh - use re-frame subscriptions
  ;; denistakeda/posh                      #:mvn{:version "0.5.8"}
  
  ;; Alternative to metosin libraries - use built-in alternatives
  ;; metosin/reitit                        #:mvn{:version "0.5.13"}
  ;; metosin/komponentit                   #:mvn{:version "0.3.10"}
  
  ;; Keep Maven Central available libraries
  com.rpl/specter                       #:mvn{:version "1.1.3"}
  com.taoensso/sente                    #:mvn{:version "1.16.2"}
  
  ;; ... rest of dependencies
  }
}
```

## 🌟 Solution 3: Hybrid Approach (Browser + JVM)

Use JavaScript for browser/testing and keep Clojure for server-side where Clojars might be available:

### Browser-side date handling:
```clojure
(ns athens.dates.browser
  "Browser-optimized date handling without external dependencies")

(defn format-us-date [date]
  #?(:cljs 
     (let [js-date (js/Date. date)]
       (.formatUSDate js/window.AthensDateHandler js-date))
     :clj 
     ;; Fallback for JVM
     (str date)))

(defn parse-uid [uid]
  #?(:cljs
     (.parseUID js/window.AthensDateHandler uid)
     :clj
     ;; JVM implementation
     nil))
```

## 🛠️ Solution 4: Offline Dependencies

Download required libraries manually and include them in the project:

1. **Download tick library manually**:
   - Get the JAR from GitHub releases
   - Include in `resources/` directory
   - Reference as local dependency

2. **Local dependency configuration**:
```clojure
{:deps 
 {tick/tick {:local/root "resources/tick-0.5.0-RC5.jar"}
  ;; ... other local dependencies
 }
}
```

## 📦 Solution 5: NPM-Based Date Handling

Since Luxon is already available in package.json, create a ClojureScript wrapper:

```clojure
(ns athens.dates.luxon
  "Luxon-based date handling for ClojureScript")

(def luxon (js/require "luxon"))

(defn format-date [date format-type]
  (let [dt (.fromJSDate (.-DateTime luxon) (js/Date. date))]
    (case format-type
      :us-date (.toFormat dt "MM-dd-yyyy")
      :title (.toFormat dt "LLLL dd, yyyy")
      (.toString dt))))

(defn parse-date [date-string]
  (let [dt (.fromISO (.-DateTime luxon) date-string)]
    (when (.isValid dt)
      (.toJSDate dt))))
```

## 🎯 Recommended Implementation Order

### Immediate (No Clojars needed):
1. Implement JavaScript-only date handling
2. Update Karma configuration to use browser-date-handler.js
3. Test with enhanced CLDR fallbacks

### Short-term:
1. Create hybrid browser/JVM approach
2. Use Luxon wrapper for ClojureScript
3. Keep server-side Clojure minimal

### Long-term:
1. Migrate away from Clojars-dependent libraries
2. Use Maven Central alternatives
3. Implement offline dependency management

## 🔍 Testing the Solution

```bash
# Test without Clojars access
node verify-no-clojars-solution.js

# Verify JavaScript-only date handling
node test-browser-date-handler.js

# Run tests with restricted network
npm run test:no-clojars
```

## 📋 Benefits of Each Solution

| Solution | Setup Time | Reliability | Performance | Future-Proof |
|----------|------------|-------------|-------------|-------------|
| JavaScript-only | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| Maven Central only | ⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ |
| Hybrid approach | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| Offline deps | ⭐ | ⭐⭐ | ⭐⭐ | ⭐ |
| NPM-based | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |

The **JavaScript-only** approach is recommended as it completely eliminates the Clojars dependency while maintaining full functionality for browser tests.