#!/usr/bin/env node
// Claude Code Statusline - GSD Edition
// Shows: model | current task | directory | context usage

const fs = require('fs');
const path = require('path');
const os = require('os');

// Read JSON from stdin
let input = '';
// Timeout guard: if stdin doesn't close within 3s (e.g. pipe issues on
// Windows/Git Bash), exit silently instead of hanging. See #775.
const stdinTimeout = setTimeout(() => process.exit(0), 3000);
process.stdin.setEncoding('utf8');
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
  clearTimeout(stdinTimeout);
  try {
    const data = JSON.parse(input);
    const model = data.model?.display_name || 'Claude';
    const version = (typeof data.version === 'string' && data.version) ? data.version : '';
    // Effort / thinking level
    const effortLevel = data.effort?.level || null;
    const thinkingEnabled = data.thinking?.enabled || false;
    let effortSeg = '';
    if (effortLevel) {
      const effortColors = {
        low:    '\x1b[2;36m',   // dim cyan
        medium: '\x1b[36m',     // cyan
        high:   '\x1b[33m',     // yellow
        xhigh:  '\x1b[38;5;208m', // orange
        max:    '\x1b[1;31m',   // bold red
      };
      const effortEmoji = {
        low: '▽', medium: '◇', high: '◆', xhigh: '⬡', max: '⬢',
      };
      const col = effortColors[effortLevel] || '\x1b[36m';
      const sym = effortEmoji[effortLevel] || '◇';
      effortSeg = ` ${col}${sym} ${effortLevel}\x1b[0m`;
    } else if (thinkingEnabled) {
      effortSeg = ` \x1b[36m◇ thinking\x1b[0m`;
    }
    const dir = data.workspace?.current_dir || process.cwd();
    const session = data.session_id || '';
    const remaining = data.context_window?.remaining_percentage;

    // Context window display (shows USED percentage scaled to usable context)
    // Claude Code reserves ~16.5% for autocompact buffer, so usable context
    // is 83.5% of the total window. We normalize to show 100% at that point.
    const AUTO_COMPACT_BUFFER_PCT = 16.5;
    let ctx = '';
    if (remaining != null) {
      // Normalize: subtract buffer from remaining, scale to usable range
      const usableRemaining = Math.max(0, ((remaining - AUTO_COMPACT_BUFFER_PCT) / (100 - AUTO_COMPACT_BUFFER_PCT)) * 100);
      const used = Math.max(0, Math.min(100, Math.round(100 - usableRemaining)));

      // Write context metrics to bridge file for the context-monitor PostToolUse hook.
      // The monitor reads this file to inject agent-facing warnings when context is low.
      if (session) {
        try {
          const bridgePath = path.join(os.tmpdir(), `claude-ctx-${session}.json`);
          const bridgeData = JSON.stringify({
            session_id: session,
            remaining_percentage: remaining,
            used_pct: used,
            timestamp: Math.floor(Date.now() / 1000)
          });
          fs.writeFileSync(bridgePath, bridgeData);
        } catch (e) {
          // Silent fail -- bridge is best-effort, don't break statusline
        }
      }

      // Build progress bar (10 segments)
      const filled = Math.floor(used / 10);
      const bar = '█'.repeat(filled) + '░'.repeat(10 - filled);

      // Color based on usable context thresholds
      if (used < 50) {
        ctx = `\x1b[32m${bar} ${used}%\x1b[0m`;
      } else if (used < 65) {
        ctx = `\x1b[33m${bar} ${used}%\x1b[0m`;
      } else if (used < 80) {
        ctx = `\x1b[38;5;208m${bar} ${used}%\x1b[0m`;
      } else {
        ctx = `\x1b[5;31m💀 ${bar} ${used}%\x1b[0m`;
      }
    }

    // Current task from todos
    let task = '';
    const homeDir = os.homedir();
    // Respect CLAUDE_CONFIG_DIR for custom config directory setups (#870)
    const claudeDir = process.env.CLAUDE_CONFIG_DIR || path.join(homeDir, '.claude');
    const todosDir = path.join(claudeDir, 'todos');
    if (session && fs.existsSync(todosDir)) {
      try {
        const files = fs.readdirSync(todosDir)
          .filter(f => f.startsWith(session) && f.includes('-agent-') && f.endsWith('.json'))
          .map(f => ({ name: f, mtime: fs.statSync(path.join(todosDir, f)).mtime }))
          .sort((a, b) => b.mtime - a.mtime);

        if (files.length > 0) {
          try {
            const todos = JSON.parse(fs.readFileSync(path.join(todosDir, files[0].name), 'utf8'));
            const inProgress = todos.find(t => t.status === 'in_progress');
            if (inProgress) task = inProgress.activeForm || '';
          } catch (e) {}
        }
      } catch (e) {
        // Silently fail on file system errors - don't break statusline
      }
    }

    // GSD update available?
    let gsdUpdate = '';
    const cacheFile = path.join(claudeDir, 'cache', 'gsd-update-check.json');
    if (fs.existsSync(cacheFile)) {
      try {
        const cache = JSON.parse(fs.readFileSync(cacheFile, 'utf8'));
        if (cache.update_available) {
          gsdUpdate = '\x1b[33m⬆ /gsd:update\x1b[0m │ ';
        }
      } catch (e) {}
    }

    // Build dim secondary segments
    const DIM = '\x1b[2m';
    const RST = '\x1b[0m';
    const SEP = ` ${DIM}│${RST} `;

    // Cache token display
    let cacheInfo = '';
    const currentUsage = data.context_window?.current_usage;
    if (currentUsage != null) {
      const cacheWrite = currentUsage.cache_creation_input_tokens || 0;
      const cacheRead = currentUsage.cache_read_input_tokens || 0;
      if (cacheWrite > 0 || cacheRead > 0) {
        const fmtK = n => n >= 1000 ? `${(n / 1000).toFixed(1)}k` : String(n);
        const parts = [];
        if (cacheWrite > 0) parts.push(`\x1b[36m+${fmtK(cacheWrite)}\x1b[0m`);
        if (cacheRead > 0)  parts.push(`\x1b[32m~${fmtK(cacheRead)}\x1b[0m`);
        cacheInfo = ` ${DIM}cache:${RST}${parts.join(' ')}`;
      }
    }

    const dirname = path.basename(dir);
    const versionSeg = version ? `${SEP}${DIM}v${version}${RST}` : '';

    // 5h rate limit usage (Pro/Max only; absent until first API response)
    let fiveHourSeg = '';
    const fiveHour = data.rate_limits?.five_hour;
    if (fiveHour?.used_percentage != null) {
      const pct = Math.max(0, Math.min(100, Math.round(fiveHour.used_percentage)));
      const filled5h = Math.floor(pct / 10);
      const bar5h = '█'.repeat(filled5h) + '░'.repeat(10 - filled5h);
      const col = pct < 50 ? '\x1b[32m' : pct < 65 ? '\x1b[33m' : pct < 80 ? '\x1b[38;5;208m' : '\x1b[31m';
      let reset = '';
      if (fiveHour.resets_at) {
        const minsLeft = Math.max(0, Math.round(fiveHour.resets_at * 1000 - Date.now()) / 60000);
        reset = ` (${Math.floor(minsLeft / 60)}h${Math.round(minsLeft % 60)}m)`;
      }
      fiveHourSeg = `${SEP}${col}5h ${bar5h} ${pct}%${reset}${RST}`;
    }

    // Output
    const ctxSeg = ctx ? `${SEP}${ctx}` : '';
    const mainLine = task
      ? `${gsdUpdate}${DIM}${model}${RST}${effortSeg}${versionSeg}${SEP}\x1b[1m${task}${RST}${SEP}${DIM}${dirname}${RST}${ctxSeg}${cacheInfo}`
      : `${gsdUpdate}${DIM}${model}${RST}${effortSeg}${versionSeg}${SEP}${DIM}${dirname}${RST}${ctxSeg}${cacheInfo}`;

    process.stdout.write(`${mainLine}${fiveHourSeg}`);
  } catch (e) {
    // Silent fail - don't break statusline on parse errors
  }
});
