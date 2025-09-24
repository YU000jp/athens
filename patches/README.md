# JS-Joda CLDR Fix

This patch fixes a build error that occurs in Karma tests where `Cldr.load is not a function`.

## Problem

The error occurred in the `@js-joda/locale_en-us` package when running tests in a browser/Karma environment. The CLDR library was not being properly initialized, resulting in `Cldr` being an empty object instead of the proper constructor function with required methods.

## Error Details

```
Chrome Headless ERROR
  Uncaught TypeError: Cldr.load is not a function
  at karma-test.js:99560:9
  
  TypeError: Cldr.load is not a function
      at new WeekFields (karma-test.js:111655:272)
      at WeekFields.ofFirstDayOfWeekMinDays (karma-test.js:111657:259)
      at WeekFields.of (karma-test.js:111655:444)
```

## Solution

The patch adds fallback logic to ensure the `Cldr` object is properly initialized:

1. Checks if `Cldr` object has the required `load` function
2. If not, attempts to require `cldrjs` directly (Node.js environment)
3. Falls back to a no-op stub for browser environments where require might fail

## Files Modified

- `patches/@js-joda+locale_en-us+4.15.1.patch` - The actual patch file
- `package.json` - Added postinstall script to apply patches automatically

## Usage

The patch is automatically applied after `yarn install` thanks to the `patch-package` postinstall script.

To verify the fix is working correctly, run:

```bash
node verify-cldr-fix.js
```

## Testing

The fix has been tested in Node.js environment and should resolve the Karma test issues.

For troubleshooting CLDR-related problems, see [CLDR_TROUBLESHOOTING.md](../CLDR_TROUBLESHOOTING.md).