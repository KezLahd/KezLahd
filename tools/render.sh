#!/bin/zsh
# Renders the banner and every year card, light and dark, into assets/.
set -e
cd "${0:A:h}/.."
src=assets/src
for t in light dark; do
  swift tools/render.swift "$PWD/$src/hero.html#$t" assets/hero-$t.png 1200 300
  for y in $(grep -oE '^  "[0-9]{4}"' $src/years.js | tr -d ' "'); do
    mkdir -p assets/years
    swift tools/render.swift "$PWD/$src/card.html#$y-$t" assets/years/$y-$t.png 1200 760
  done
done
# Each year's page sections, from assets/src/pages.js
for t in light dark; do
  for y in $(grep -oE '^  "[0-9]{4}"' $src/pages.js | tr -d ' "'); do
    d=assets/years/$y; mkdir -p $d
    np=$(node -e "global.window={};eval(require('fs').readFileSync('$src/pages.js','utf8'));const p=window.PAGES['$y'];console.log(p.projects.length, p.roles.length, p.claude?1:0)")
    set -- ${=np}
    swift tools/render.swift "$PWD/$src/section.html#$y-$t-work" $d/work-$t.png 1200 0
    swift tools/render.swift "$PWD/$src/section.html#$y-$t-tools" $d/tools-$t.png 1200 0
    [ $3 = 1 ] && swift tools/render.swift "$PWD/$src/section.html#$y-$t-claude" $d/claude-$t.png 1200 0
    for i in $(seq 0 $(($1 - 1))); do swift tools/render.swift "$PWD/$src/section.html#$y-$t-project-$i" $d/project-$i-$t.png 1200 0; done
    [ $2 -gt 0 ] && for i in $(seq 0 $(($2 - 1))); do swift tools/render.swift "$PWD/$src/section.html#$y-$t-role-$i" $d/role-$i-$t.png 1200 0; done
  done
done
for f in assets/*.png assets/years/*.png assets/years/*/*.png; do sips --resampleWidth 2400 "$f" >/dev/null; done
echo rendered
