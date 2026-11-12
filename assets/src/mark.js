// The |< mark, fitted into live type as the K of Kieran: the mark is scaled to the font's cap height and drawn at its
// stem weight, so it sits in the word like any other letter. The full stop is a navy square of the same weight.
window.fitMark = (el) => {
  const cs = getComputedStyle(el), size = parseFloat(cs.fontSize);
  const c = document.createElement('canvas'); c.width = c.height = Math.ceil(size * 2);
  const ctx = c.getContext('2d', { willReadFrequently: true });
  ctx.font = `${cs.fontWeight} ${size}px ${cs.fontFamily}`;
  // WebKit's text metrics give advance widths, not ink, so the stem is measured by drawing an l and counting pixels.
  ctx.fillText('l', size * 0.5, size * 1.5);
  const row = ctx.getImageData(0, Math.round(size * 1.3), c.width, 1).data;
  let w = 0; for (let i = 3; i < row.length; i += 4) w += row[i] / 255;
  // The mark's own proportions, in units of an 84-unit stem: a 9 gap, then a < 32 deep and 50 tall, raised 6.
  const A = ctx.measureText('H').actualBoundingBoxAscent, s = A / 84;
  const t = Math.atan(25 / 32), miter = (w / 2) / Math.sin(t);
  const vx = w + 9 * s + miter, vy = A - 6 * s - 25 * s, ex = vx + 32 * s;
  const W = ex + (w / 2) * Math.sin(t);
  const K = `<svg viewBox="0 0 ${W} ${A}" width="${W}" height="${A}" style="vertical-align:baseline;margin-right:${0.05 * size}px;overflow:visible">
    <path d="M${w / 2} 0V${A}" stroke="var(--ink)" stroke-width="${w}" fill="none"/>
    <path d="M${ex} ${vy - 25 * s}L${vx} ${vy}L${ex} ${vy + 25 * s}" stroke="var(--accent)" stroke-width="${w}" fill="none" stroke-linejoin="miter"/></svg>`;
  const dot = `<span style="display:inline-block;width:${w}px;height:${w}px;background:var(--accent);margin-left:${0.05 * size}px"></span>`;
  const text = el.textContent;
  el.innerHTML = (text.startsWith('K') ? K + text.slice(1) : text).replace(/\.$/, dot);
};
