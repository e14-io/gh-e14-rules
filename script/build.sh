#!/usr/bin/env bash

platforms=(
  "darwin-amd64,x86_64-apple-darwin"
  "darwin-arm64,aarch64-apple-darwin"
  "linux-amd64,x86_64-unknown-linux-gnu"
  "linux-arm64,aarch64-unknown-linux-gnu"
  "windows-amd64,x86_64-pc-windows-msvc"
)

mkdir -p dist

for p in "${platforms[@]}"; do
  filename="${p%,*}"
  target="${p#*,}"
  os="${filename%-*}"

  ext=""
  if [ "$os" = "windows" ]; then
    ext=".exe"
  fi

  deno compile --allow-read --allow-net --allow-run \
    --output dist/${filename}${ext} \
    --target ${target} \
    gh-e14-rules.ts
done
