---
status: accepted
date: 2026-11-16
---

# Code lives inside the dev environment, and host tools reach it remotely

Repositories are cloned inside the NixOS VM or WSL distro, not into a folder shared from the host. The GUI tools on the host work against them remotely:
- Rex over SSH;
- the Claude desktop app's SSH and WSL sessions;
- the ChatGPT desktop app's Codex SSH projects and WSL agent;
- VS Code Remote-SSH or WSL;
- JetBrains Gateway.

Shared folders are slow for file watching and `node_modules`. JetBrains doesn't support network-mounted projects, and the whole point of the environment is that toolchains run in one place. Working full-screen inside the VM's own desktop was also rejected: the host's GUI apps and window manager stay the daily driver.

## Consequences

- **git and `gh` credentials live in the dev environment.** Claude desktop turns SSH agent forwarding off, so a host-only key isn't enough. Work environments get a local SSH key; personal ones may forward the 1Password agent in Rex sessions instead.
- **Clipboard goes over OSC 52, and browser logins use device codes or pasted codes.** No tool forwards "open this URL" to the host.
- **Visual Studio is the exception.** It needs project files on Windows, so .NET projects that need it get a Windows-side checkout. Everything else uses VS Code with the C# extension in WSL.
