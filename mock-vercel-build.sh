#!/usr/bin/env bash
# Mock vercel build for testing when network connectivity is limited

set -e

echo "🧪 Mock Vercel Build Process"
echo "============================"

# Create necessary directories
mkdir -p vercel-static/athens
mkdir -p vercel-static/clerk

# Build JS components (this should work without network)
echo "Building JavaScript components..."
yarn components

# Create a simple mock Athens client  
echo "Creating mock Athens web client..."
cat > vercel-static/athens/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Athens Research - Mock Build</title>
    <style>
        body {
            font-family: system-ui, -apple-system, sans-serif;
            max-width: 800px;
            margin: 2rem auto;
            padding: 1rem;
            background: #f8f9fa;
        }
        .header {
            background: white;
            padding: 2rem;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            margin-bottom: 2rem;
        }
        .status {
            background: #d4edda;
            border: 1px solid #c3e6cb;
            color: #155724;
            padding: 1rem;
            border-radius: 4px;
            margin: 1rem 0;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>Athens Research</h1>
        <p>Knowledge graph for research and notetaking</p>
        <div class="status">
            ✅ Vercel deployment configured successfully!<br>
            📝 This is a mock build for testing purposes.<br>
            🔧 JavaScript components compiled successfully.
        </div>
    </div>
    <nav>
        <p><a href="/">← Back to main navigation</a></p>
        <p><a href="/clerk/">View Clerk Notebooks</a></p>
    </nav>
    
    <h2>Build Information</h2>
    <ul>
        <li>Build Date: $(date)</li>
        <li>Components: Built with Babel</li>
        <li>Status: Mock build successful</li>
    </ul>
</body>
</html>
EOF

# Create a simple Clerk index
echo "Creating mock Clerk notebooks..."
cat > vercel-static/clerk/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Clerk Notebooks - Athens</title>
    <style>
        body {
            font-family: system-ui, -apple-system, sans-serif;
            max-width: 800px;
            margin: 2rem auto;
            padding: 1rem;
        }
    </style>
</head>
<body>
    <h1>Clerk Notebooks</h1>
    <p>This would contain Clerk notebook outputs when the full build is available.</p>
    <p><a href="/">← Back to main navigation</a></p>
</body>
</html>
EOF

echo "✅ Mock Vercel build completed successfully!"
echo "📁 Output directory: vercel-static/"
echo "🌐 Main app: vercel-static/athens/index.html"
echo "📚 Clerk notebooks: vercel-static/clerk/index.html"