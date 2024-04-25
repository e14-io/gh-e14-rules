#!/usr/bin/env bash

platforms=(
  "darwin-amd64,x86_64-apple-darwin"
  "darwin-arm64,aarch64-apple-darwin"
  "linux-amd64,x86_64-unknown-linux-gnu"
  "linux-arm64,aarch64-unknown-linux-gnu"
  "windows-amd64,x86_64-pc-windows-msvc"
)
assets=()

prerelease=""
draft_release=""

if [[ $GH_RELEASE_TAG = *-draft ]]; then
  draft_release="--draft"
elif [[ $GH_RELEASE_TAG = *-* ]]; then
  prerelease="--prerelease"
fi

mkdir -p dist

for p in "${platforms[@]}"; do
  basename="${p%,*}"
  target="${p#*,}"
  os="${basename%-*}"

  ext=""
  if [ "$os" = "windows" ]; then
    ext=".exe"
  fi

  filename="dist/${basename}${ext}"

  deno compile --allow-read --allow-net --allow-run \
    --output ${filename} \
    --target ${target} \
    gh-e14-rules.ts

  assets+=("$filename")
done

echo $GH_RELEASE_TAG
if gh release view "$GH_RELEASE_TAG" >/dev/null; then
  echo "Uploading assets to an existing release..."
  gh release upload "$GH_RELEASE_TAG" "${assets[@]}" --clobber
else
  echo "Creating release and uploading assets..."
  gh release create "$GH_RELEASE_TAG" $prerelease $draft_release --generate-notes "${assets[@]}"
fi
