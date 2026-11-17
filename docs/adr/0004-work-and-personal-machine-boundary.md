---
status: accepted
date: 2026-11-16
---

# A hard boundary between work and personal machines

One repo sets up both work and personal machines, split by the `is_personal` prompt. Work machines are employer-owned, so they get only what is appropriate there. The rules, which the code doesn't make obvious:

- **Personal credentials never go on a work machine:** no personal 1Password, no personal Tailscale, no Little Snitch. Work machines use local SSH keys and the macOS Passwords app.
- **The personal agent layer and the werkbank core never go on a work machine,** the latter until there's written approval. A work machine's Claude Code and Codex config is its own, deliberately small setup. On work machines plain `claude` is the work setup; there's no separate Claude profile.
- **Paid personal licences are only used at work where the vendor's terms allow it.** Cases where the terms are unclear are settled with the vendor or paid for by the employer.
- **Shell history and dictation stay local.** Nothing on a work machine syncs history to a personal account, and work content isn't dictated through a personal cloud account.
- **This repo is public.** It names no employer, work project, internal host or work-only install command. Machine-specific values (work email, names) come from chezmoi's prompted data, not from the source.
