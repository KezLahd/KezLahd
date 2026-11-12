# Adding a year

1. Add the year to `assets/src/years.js` (its card: dates, three stats, GitHub contributions per month).
2. Add the year to `assets/src/pages.js` (its page: intro, the work, roles, projects, Claude stats, tools).
3. Run `tools/render.sh` to draw every image, light and dark, then `node tools/pages.mjs` to write `years/<year>.md`.
4. Put the new card at the top of the main README.
