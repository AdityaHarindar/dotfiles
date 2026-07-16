#!/usr/bin/env node
// Per-subagent row override: shows the subagent's own model next to its name/desc.
// Companion to gsd-statusline.js, which only ever sees the top-level session model.

let input = '';
const stdinTimeout = setTimeout(() => process.exit(0), 3000);
process.stdin.setEncoding('utf8');
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
  clearTimeout(stdinTimeout);
  try {
    const data = JSON.parse(input);
    const tasks = data.tasks || [];
    const DIM = '\x1b[2m';
    const RST = '\x1b[0m';
    const MODEL_COL = '\x1b[36m';

    const fmtK = n => (n >= 1000 ? `${(n / 1000).toFixed(1)}k` : String(n));
    const lines = tasks.map(t => {
      const model = t.model || 'model?';
      const name = t.name || t.label || 'agent';
      const desc = t.description ? ` ${DIM}· ${t.description}${RST}` : '';
      let tokSeg = '';
      if (t.tokenCount != null) {
        const pct = t.contextWindowSize
          ? ` ${Math.round((t.tokenCount / t.contextWindowSize) * 100)}%`
          : '';
        tokSeg = ` ${DIM}${fmtK(t.tokenCount)}${pct}${RST}`;
      }
      const content = `${MODEL_COL}[${model}]${RST} ${name}${desc}${tokSeg}`;
      return JSON.stringify({ id: t.id, content });
    });

    if (lines.length) process.stdout.write(lines.join('\n') + '\n');
  } catch (e) {
    // Silent fail - don't break the agent panel on parse errors
  }
});
