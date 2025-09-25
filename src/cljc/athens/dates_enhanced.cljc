(ns athens.dates-enhanced
  "Enhanced date handling with multiple fallback strategies
   This provides alternatives to js-joda/tick for more reliable date operations"
  (:require
    [clojure.string :as string]
    #?(:cljs [cljs.reader :as reader])
    #?(:cljs [goog.i18n.DateTimeFormat :as goog-dtf])
    #?(:cljs [goog.date :as goog-date])))

;; Enhanced date formatters with fallback strategies
(def enhanced-formatters
  "Multiple formatting strategies for maximum compatibility"
  {:us-date     "MM-dd-yyyy"
   :title-date  "LLLL dd, yyyy"  
   :display     "LLLL dd, yyyy h:mma"
   :iso         "yyyy-MM-dd"
   :compact     "MMM d, yy"})

#?(:cljs
   (defn- try-luxon-format
     "Attempt to use Luxon for date formatting if available"
     [date-obj format-str]
     (when (and (exists? js/window.luxon)
                (.-DateTime js/window.luxon))
       (try
         (let [luxon-dt (-> js/window.luxon
                           (.-DateTime)
                           (.fromJSDate date-obj))]
           (.toFormat luxon-dt format-str))
         (catch js/Error _e nil)))))

#?(:cljs
   (defn- try-intl-format
     "Use native Intl.DateTimeFormat for locale-aware formatting"
     [date-obj locale options]
     (when (and (exists? js/Intl)
                (.-DateTimeFormat js/Intl))
       (try
         (let [formatter (js/Intl.DateTimeFormat. locale (clj->js options))]
           (.format formatter date-obj))
         (catch js/Error _e nil)))))

#?(:cljs
   (defn- custom-format-date
     "Custom date formatting as ultimate fallback"
     [date-obj format-type]
     (let [months ["January" "February" "March" "April" "May" "June"
                   "July" "August" "September" "October" "November" "December"]
           month (.getMonth date-obj)
           day (.getDate date-obj)
           year (.getFullYear date-obj)
           hours (.getHours date-obj)
           minutes (.getMinutes date-obj)
           am-pm (if (< hours 12) "am" "pm")
           display-hour (if (= 0 (mod hours 12)) 12 (mod hours 12))]
       (case format-type
         :title-date (str (nth months month) " " day ", " year)
         :us-date (str (string/join "-" [(format "%02d" (inc month))
                                        (format "%02d" day) 
                                        year]))
         :display (str (nth months month) " " day ", " year " "
                      display-hour ":" (format "%02d" minutes) am-pm)
         :iso (str year "-" (format "%02d" (inc month)) "-" (format "%02d" day))
         :compact (str (subs (nth months month) 0 3) " " day ", " (subs (str year) 2))
         (.toString date-obj)))))

(defn enhanced-format-date
  "Enhanced date formatting with multiple fallback strategies"
  ([date-obj] (enhanced-format-date date-obj :title-date))
  ([date-obj format-type]
   #?(:clj
      ;; JVM: Use java.time (built-in, reliable)
      (let [formatter (case format-type
                       :us-date "MM-dd-yyyy"
                       :title-date "LLLL dd, yyyy"
                       :display "LLLL dd, yyyy h:mma"
                       :iso "yyyy-MM-dd"
                       :compact "MMM d, yy"
                       "yyyy-MM-dd")]
        (try
          (.format (java.time.format.DateTimeFormatter/ofPattern formatter) date-obj)
          (catch Exception _e (.toString date-obj))))
      
      :cljs
      ;; ClojureScript: Multiple fallback strategies
      (let [js-date (cond
                     (string? date-obj) (js/Date. date-obj)
                     (number? date-obj) (js/Date. date-obj)
                     :else date-obj)]
        (or
         ;; Strategy 1: Try Luxon if available
         (try-luxon-format js-date (get enhanced-formatters format-type))
         
         ;; Strategy 2: Try native Intl API
         (case format-type
           :title-date (try-intl-format js-date "en-US" 
                                       {:month "long" :day "numeric" :year "numeric"})
           :display (try-intl-format js-date "en-US" 
                                    {:month "long" :day "numeric" :year "numeric"
                                     :hour "numeric" :minute "2-digit"})
           :us-date (try-intl-format js-date "en-CA" {:dateStyle "short"})
           nil)
         
         ;; Strategy 3: Custom implementation (always works)
         (custom-format-date js-date format-type))))))

(defn get-enhanced-day
  "Enhanced version of get-day with multiple date library support"
  ([] (get-enhanced-day 0))
  ([offset]
   (let [today #?(:clj (java.time.LocalDate/now)
                  :cljs (js/Date.))
         target-date #?(:clj (.plusDays today offset)
                        :cljs (js/Date. (.getTime today) 
                                       (+ (.getDate today) offset)))]
     {:uid   (enhanced-format-date target-date :us-date)
      :title (enhanced-format-date target-date :title-date)
      :inst  #?(:clj (.toInstant (.atStartOfDay target-date (java.time.ZoneOffset/UTC)))
                :cljs target-date)})))

(defn enhanced-uid-to-date
  "Parse date UID with enhanced error handling and multiple strategies"
  [uid]
  (when (and uid (string? uid))
    (try
      (let [[m d y] (string/split uid #"-")]
        (when (and m d y 
                   (re-matches #"\d{2}" m)
                   (re-matches #"\d{2}" d) 
                   (re-matches #"\d{4}" y))
          #?(:clj 
             (java.time.LocalDate/of (parse-long y) (parse-long m) (parse-long d))
             :cljs
             (js/Date. (parse-long y) (dec (parse-long m)) (parse-long d)))))
      (catch #?(:cljs :default :clj Exception) _e
        nil))))

(defn enhanced-title-to-date
  "Parse date title with multiple parsing strategies"
  [title]
  (when (and title (string? title))
    (try
      #?(:clj
         ;; Use java.time parsing
         (java.time.LocalDate/parse title 
           (java.time.format.DateTimeFormatter/ofPattern "LLLL dd, yyyy"))
         
         :cljs
         ;; Multiple parsing strategies for ClojureScript
         (or
          ;; Strategy 1: Try native Date parsing
          (let [parsed (js/Date. title)]
            (when (not (js/isNaN (.getTime parsed)))
              parsed))
          
          ;; Strategy 2: Manual parsing for "Month DD, YYYY" format
          (let [pattern #"(\w+)\s+(\d{1,2}),\s+(\d{4})"
                matches (re-find pattern title)]
            (when matches
              (let [[_ month-name day year] matches
                    months {"January" 0 "February" 1 "March" 2 "April" 3
                           "May" 4 "June" 5 "July" 6 "August" 7
                           "September" 8 "October" 9 "November" 10 "December" 11}
                    month-num (get months month-name)]
                (when month-num
                  (js/Date. (parse-long year) month-num (parse-long day))))))
          
          nil))
      (catch #?(:cljs :default :clj Exception) _e
        nil))))

(defn enhanced-date-string  
  "Enhanced date string formatting with fallbacks"
  [timestamp]
  (if (not timestamp)
    [:span "(unknown date)"]
    (try
      (let [date-obj #?(:clj (java.time.Instant/ofEpochMilli timestamp)
                        :cljs (js/Date. timestamp))
            formatted (enhanced-format-date date-obj :display)]
        (-> formatted
            (string/replace #"AM" "am")
            (string/replace #"PM" "pm")))
      (catch #?(:cljs :default :clj Exception) _e
        [:span "(invalid date)"]))))

(defn enhanced-is-daily-note
  "Enhanced daily note detection with better validation"
  [uid]
  (boolean (and uid 
                (string? uid)
                (re-matches #"\d{2}-\d{2}-\d{4}" uid)
                (enhanced-uid-to-date uid))))

;; Utility function to check which date strategies are available
#?(:cljs
   (defn available-date-strategies
     "Check which date handling strategies are available in current environment"
     []
     (let [strategies {}]
       (assoc strategies
              :luxon (boolean (and (exists? js/window.luxon)
                                  (.-DateTime js/window.luxon)))
              :intl (boolean (and (exists? js/Intl)
                                 (.-DateTimeFormat js/Intl)))
              :athens-fallback (boolean (exists? js/window.AthensDateFallback))
              :native-date true))))

;; Performance monitoring for date operations
#?(:cljs
   (defn monitor-date-performance
     "Monitor and log date operation performance"
     [operation-name f]
     (let [start (js/Date.now)]
       (try
         (let [result (f)]
           (let [duration (- (js/Date.now) start)]
             (when (> duration 10) ; Log slow operations
               (.log js/console (str "⏱️ Date operation '" operation-name "' took " duration "ms")))
             result))
         (catch js/Error e
           (.error js/console (str "❌ Date operation '" operation-name "' failed:") e)
           nil)))))

;; Export compatibility functions for existing code
(def get-day get-enhanced-day)
(def uid-to-date enhanced-uid-to-date)
(def title-to-date enhanced-title-to-date)
(def date-string enhanced-date-string)
(def is-daily-note enhanced-is-daily-note)