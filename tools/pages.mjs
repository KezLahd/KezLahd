// Writes years/<year>.md for every year in assets/src/pages.js, around the images tools/render.sh draws.
import fs from 'fs';
global.window = {};
eval(fs.readFileSync(new URL('../assets/src/pages.js', import.meta.url), 'utf8'));
const years = Object.keys(window.PAGES).sort();
const pic = (path, alt) => `<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../assets/years/${path}-dark.png">
  <img src="../assets/years/${path}-light.png" alt="${alt.replace(/"/g, '&quot;')}" width="100%">
</picture>`;
const link = (href, path, alt) => `<a href="${href}">\n${pic(path, alt)}\n</a>`;
for (const y of years) {
  const p = window.PAGES[y], i = years.indexOf(y), prev = years[i - 1], next = years[i + 1];
  const out = [`<sub><a href="../README.md">← Kieran Jackson</a></sub>`, '', pic(y, `${p.title}`), '', `# ${p.title}`, '', `**${p.sub}**`, '', p.intro, '',
    '## The work', '', pic(`${y}/work`, p.work.map(([t, l]) => `${t}: ${l}`).join(' '))];
  if (p.roles.length) out.push('', '## Where', '', ...p.roles.map((r, n) => link(r.url, `${y}/role-${n}`, `${r.name}, ${r.role}. ${r.line}`)));
  out.push('', '## Built in public', '', ...p.projects.map((r, n) => link(`https://github.com/KezLahd/${r.repo}`, `${y}/project-${n}`, `${r.name} (${r.month}): ${r.line}`)),
    '', `<sub>Plus ${['no', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine'][p.privateCount] ?? p.privateCount} private repos.</sub>`);
  if (p.claude) out.push('', '## Built with Claude', '', p.claudeIntro, '', pic(`${y}/claude`, p.claude.stats.map(([n, l]) => `${n} ${l}`).join(', ') + '. ' + p.claude.note));
  out.push('', `## ${p.toolsTitle}`, '', pic(`${y}/tools`, p.tools.join(', ')), '', '<br/>', '',
    `<sub>${[prev && `<a href="${prev}.md">← ${window.PAGES[prev].title}</a>`, next && `<a href="${next}.md">${window.PAGES[next].title} →</a>`].filter(Boolean).join(' · ')}</sub>`, '');
  fs.writeFileSync(new URL(`../years/${y}.md`, import.meta.url), out.join('\n'));
}
console.log('wrote', years.join(', '));
