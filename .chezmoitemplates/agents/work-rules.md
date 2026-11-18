# Work machine: global rules

These rules apply in every repository on this machine. A repository's own
CLAUDE.md or AGENTS.md adds to them and wins where they disagree.

- This is a work machine. Don't use or mention personal accounts, personal
  repositories or personal tools here.
- Never put secrets, credentials or customer data into code, commits, logs or
  prompts to external services. `.env` files stay out of version control.
- Ask before anything that leaves this machine or is hard to undo: pushing,
  opening or merging pull requests, publishing packages, deleting branches,
  force-pushing, or running database migrations against shared environments.
- Follow the repository's existing conventions (formatting, tests, commit style)
  before your own preferences. Run the tests that cover a change before calling
  it done, and say plainly when you couldn't.
