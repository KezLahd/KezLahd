#!/bin/zsh
# Renders the banner and every year card, light and dark, into assets/.
set -e
cd "${0:A:h}/.."
src=assets/src
for t in light dark; do
  swift tools/render.swift "$PWD/$src/hero.html#$t" assets/hero-$t.png 1200 460
  for y in $(grep -oE '^  "[0-9]{4}"' $src/years.js | tr -d ' "'); do
    mkdir -p assets/years
    swift tools/render.swift "$PWD/$src/card.html#$y-$t" assets/years/$y-$t.png 1200 630
  done
done
for f in assets/*.png assets/years/*.png; do sips --resampleWidth 2400 "$f" >/dev/null; done
echo rendered
