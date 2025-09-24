# CLDR Fix Troubleshooting Guide

This document provides troubleshooting steps for CLDR-related issues in Athens.

## Quick Diagnosis

If you encounter CLDR-related errors, run the verification script:

```bash
node verify-cldr-fix.js
```

This will test all components of the CLDR fix and identify any issues.

## Common Issues

### 1. "Cldr.load is not a function" Error

**Symptoms:**
- Karma tests fail with `TypeError: Cldr.load is not a function`
- Error occurs during js-joda locale initialization

**Causes:**
- Patch not applied to @js-joda/locale_en-us package
- CLDR library not loaded before js-joda
- Network issues preventing cldrjs download

**Solutions:**
1. **Verify patch is applied:**
   ```bash
   grep "Fix for Cldr.load is not a function" node_modules/@js-joda/locale_en-us/dist/index.js
   ```

2. **Re-apply patches:**
   ```bash
   npm run postinstall
   # or
   npx patch-package
   ```

3. **Check Karma configuration:**
   Ensure `cldrjs` is loaded before test files in `karma.conf.js`

### 2. Patch Not Applied After yarn install

**Symptoms:**
- `verify-cldr-fix.js` reports patch is not applied
- Fresh installs don't include the fix

**Causes:**
- `patch-package` not running automatically
- Missing postinstall script

**Solutions:**
1. **Check package.json:**
   ```json
   {
     "scripts": {
       "postinstall": "patch-package"
     },
     "devDependencies": {
       "patch-package": "^8.0.0"
     }
   }
   ```

2. **Manually run patch-package:**
   ```bash
   npx patch-package
   ```

### 3. CLDR Data Loading Failures

**Symptoms:**
- Console warnings about CLDR data loading
- Fallback implementations being used

**Causes:**
- Network issues loading cldrjs
- Missing CLDR initialization scripts
- Browser compatibility issues

**Solutions:**
1. **Check console for specific errors:**
   Open browser dev tools and look for CLDR-related messages

2. **Verify script loading order in Karma:**
   ```javascript
   files: [
     '../node_modules/cldrjs/dist/cldr.js',
     '../cldr-init.js',
     '../cldr-mock.js',
     'karma-test.js'
   ]
   ```

3. **Test CLDR manually:**
   ```javascript
   // In browser console
   console.log(typeof window.Cldr);
   console.log(typeof window.Cldr.load);
   ```

### 4. Locale-Specific Functionality Not Working

**Symptoms:**
- Date formatting falls back to generic formats
- Locale-aware features not working correctly

**Causes:**
- Incomplete CLDR data
- Missing locale-specific configuration

**Solutions:**
1. **Add required locale data to cldr-init.js:**
   ```javascript
   window.Cldr.load({
     supplemental: {
       likelySubtags: {
         'en': 'en-Latn-US',
         'ja': 'ja-Jpan-JP'  // Add other locales as needed
       }
     }
   });
   ```

2. **Update mock implementation:**
   Add locale-specific fallbacks in `cldr-mock.js`

### 5. Performance Issues

**Symptoms:**
- Slow test startup
- Timeouts during CLDR initialization

**Causes:**
- Large CLDR data files
- Network latency

**Solutions:**
1. **Optimize CLDR data:**
   Include only essential data in `cldr-init.js`

2. **Add timeout configuration:**
   ```javascript
   // In karma.conf.js
   browserSocketTimeout: 60000,
   browserNoActivityTimeout: 60000
   ```

## Debugging Steps

### 1. Enable Verbose Logging

Add this to your test setup to see detailed CLDR initialization:

```javascript
window.CLDR_DEBUG = true;
```

### 2. Manual CLDR Testing

Test CLDR functionality manually:

```javascript
// In browser console or test file
try {
  const joda = require('@js-joda/core');
  require('@js-joda/locale_en-us');
  
  // This should not throw an error
  const weekFields = joda.WeekFields.of(joda.DayOfWeek.MONDAY, 1);
  console.log('✅ CLDR fix working correctly');
} catch (error) {
  console.error('❌ CLDR fix not working:', error);
}
```

### 3. Check File Integrity

Verify all CLDR fix files are present and correct:

```bash
# Check patch file
ls -la patches/@js-joda+locale_en-us+4.15.1.patch

# Check init scripts
ls -la cldr-init.js cldr-mock.js

# Check karma config
grep -n "cldr" karma.conf.js
```

## Getting Help

If these troubleshooting steps don't resolve your issue:

1. **Run the verification script:** `node verify-cldr-fix.js`
2. **Check the browser console** for specific error messages
3. **Compare your setup** with the working configuration in this repository
4. **Create an issue** with:
   - Output of verification script
   - Browser console errors
   - Your environment details (OS, Node version, etc.)

## Prevention

To avoid CLDR issues in the future:

1. **Always run verification after dependencies change**
2. **Don't manually modify node_modules** - use patches instead
3. **Keep patch-package up to date**
4. **Test in multiple browsers** if supporting them
5. **Monitor console output** during test runs for warnings

## Related Files

- `patches/@js-joda+locale_en-us+4.15.1.patch` - Main fix
- `cldr-init.js` - Primary CLDR initialization
- `cldr-mock.js` - Fallback implementation
- `karma.conf.js` - Test configuration
- `verify-cldr-fix.js` - Diagnostic tool