# =========================================================
# Minimal React Site Builder
# Run from project root folder
# =========================================================

$root = (Get-Location).Path
$projectName = Split-Path $root -Leaf

if ($projectName -eq "React-Source") {

    Write-Host "[ERROR] Run this command from the project root, not inside React-Source."
    exit 1

}

$reactPath = Join-Path $root "React-Source"
$srcPath = Join-Path $reactPath "src"
$resourcesPath = Join-Path $reactPath "resources"
$cssPath = Join-Path $resourcesPath "css"

Write-Host ""
Write-Host "========================================="
Write-Host " MINIMAL REACT SITE BUILDER"
Write-Host "========================================="
Write-Host ""

if (-not (Test-Path $reactPath)) {

    New-Item -ItemType Directory -Path $reactPath | Out-Null
    Write-Host "[OK] React-Source created"

}

if (-not (Test-Path $srcPath)) {

    New-Item -ItemType Directory -Path $srcPath | Out-Null
    Write-Host "[OK] src created"

}

if (-not (Test-Path $cssPath)) {

    New-Item -ItemType Directory -Path $cssPath -Force | Out-Null
    Write-Host "[OK] resources/css created"

}

# =========================================================
# package.json
# =========================================================

@'
{
  "name": "react-site",
  "private": true,
  "version": "1.0.0",
  "type": "module",

  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },

  "dependencies": {
    "react": "19.2.0",
    "react-dom": "19.2.0"
  },

  "devDependencies": {
    "@vitejs/plugin-react": "5.1.1",
    "vite": "7.2.7"
  }
}
'@ | Set-Content (Join-Path $reactPath "package.json")

# =========================================================
# index.html
# =========================================================

@'
<!doctype html>
<html lang="nl">

<head>

    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />

    <title>React Site</title>

</head>

<body>

    <div id="root"></div>

    <script type="module" src="/src/main.jsx"></script>

</body>

</html>
'@ | Set-Content (Join-Path $reactPath "index.html")

# =========================================================
# vite.config.js
# =========================================================

@'
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig({

    plugins: [react()],

});
'@ | Set-Content (Join-Path $reactPath "vite.config.js")

# =========================================================
# app.css
# =========================================================

@'
/* Global app styles */
'@ | Set-Content (Join-Path $cssPath "app.css")

# =========================================================
# main.jsx
# =========================================================

@'
import React from "react";
import { createRoot } from "react-dom/client";

import "../resources/css/app.css";

import App from "./App.jsx";

createRoot(document.getElementById("root")).render(

    <React.StrictMode>

        <App />

    </React.StrictMode>

);
'@ | Set-Content (Join-Path $srcPath "main.jsx")

# =========================================================
# App.jsx
# =========================================================

@'
export default function App() {

    return (

        <main style={{
            padding: "40px",
            fontFamily: "Arial, sans-serif"
        }}>

            <h1>React site werkt</h1>

            <p>
                Deze minimale React/Vite site is aangemaakt.
            </p>

        </main>

    );

}
'@ | Set-Content (Join-Path $srcPath "App.jsx")

Write-Host ""
Write-Host "[OK] Minimal React site created in:"
Write-Host $reactPath
Write-Host ""

Write-Host "Next commands:"
Write-Host ""
Write-Host "cd React-Source"
Write-Host "npm install"
Write-Host "npm run dev"
Write-Host ""
Write-Host "Build:"
Write-Host "npm run build"
Write-Host ""
Write-Host "Deploy:"
Write-Host "Build-React-Laravel"
Write-Host ""