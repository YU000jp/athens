#!/usr/bin/env bash

# Handle different build strategies for Vercel
set -e

echo "🏗️  Athens Vercel Build"
echo "======================="

# Define build functions
function build_components_only() {
    echo "📦 Building JavaScript components..."
    yarn components
    
    echo "📁 Creating component-based build..."
    mkdir -p vercel-static/athens
    mkdir -p vercel-static/clerk
    
    # Copy any existing static resources
    if [ -d "resources/public" ]; then
        echo "📋 Copying static resources..."
        cp -R resources/public/* vercel-static/athens/ 2>/dev/null || echo "No static resources to copy"
    fi
    
    # Create a simple HTML page that loads components
    cat > vercel-static/athens/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Athens Research</title>
    <style>
        body {
            font-family: system-ui, -apple-system, sans-serif;
            max-width: 800px;
            margin: 2rem auto;
            padding: 1rem;
            background: #f8f9fa;
        }
        .status {
            background: #fff3cd;
            border: 1px solid #ffeaa7;
            color: #856404;
            padding: 1rem;
            border-radius: 4px;
            margin: 1rem 0;
        }
    </style>
</head>
<body>
    <h1>Athens Research</h1>
    <p>Knowledge graph for research and notetaking</p>
    <div class="status">
        ⚠️ This is a preview build with limited functionality.<br>
        📦 JavaScript components compiled successfully.<br>
        🔧 ClojureScript compilation was not available in this environment.
    </div>
    <p>For full functionality, please run Athens locally or in an environment with complete network access.</p>
</body>
</html>
EOF

    # Simple Clerk placeholder
    cat > vercel-static/clerk/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Clerk Notebooks - Athens</title>
</head>
<body>
    <h1>Clerk Notebooks</h1>
    <p>Clerk notebooks are not available in this preview build.</p>
    <p><a href="../athens/">← Back to Athens</a></p>
</body>
</html>
EOF

    echo "✅ Components-only build completed!"
}

function build_mock() {
    echo "🧪 Running mock build..."
    ./mock-vercel-build.sh
}

# Get build mode from environment or default to mock
ATHENS_BUILD_MODE=${ATHENS_BUILD_MODE:-"mock"}

echo "Build mode: ${ATHENS_BUILD_MODE}"

case "$ATHENS_BUILD_MODE" in
    "full")
        echo "🎯 Attempting full Athens build..."
        if yarn notebooks:static && yarn client:web:static; then
            echo "✅ Full build completed successfully!"
        else
            echo "❌ Full build failed, falling back to components build"
            build_components_only
        fi
        ;;
    "partial"|"components-only")
        echo "⚠️  Building with components only (no ClojureScript compilation)..."
        build_components_only
        ;;
    "mock")
        echo "🧪 Using mock build..."
        build_mock
        ;;
    *)
        echo "⚠️  Unknown build mode, using mock build"
        build_mock
        ;;
esac