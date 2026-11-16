#!/usr/bin/env node
// aerospace-desk: role-based workspaces for AeroSpace that adapt to the screens attached.
//
//   aerospace-desk arrange          sort known apps on workspaces 1-3 (Hyper+A; also at start and on screen changes)
//   aerospace-desk arrange --all    the same, plus windows you moved to workspaces 4-10 (Hyper+Shift+A)
//   aerospace-desk watch            place new windows and re-arrange when screens change (AeroSpace starts it)
//   aerospace-desk size width 1/3   size the focused window to a fraction of its screen (Hyper+Z X C V B)
//   aerospace-desk profile          print the screens, the profile and the plan
//
// Workspaces: 1 web and research, 2 code (editors, IDEs, Rex, Claude, Codex), 3 comms, 4 VMs.
// Workspaces 4-10 are yours: arrange never takes a window off them (only --all does), so a browser you move next
// to a VM stays there. New windows go to their role's workspace, except Cmd+N style windows: a new window that
// opens next to a window of the same role stays where it is.
// Profiles, picked from the screens attached:
//   single  one screen, or the MacBook plus one regular monitor: web and code are separate workspaces
//           (Hyper+1 / Hyper+2, Hyper+Tab flips back). Comms goes on the MacBook screen when it is open.
//   wide    an ultrawide (21:9 or wider): web and code side by side on workspace 2 (workspace 1 stays empty).
//           On 32:9 the AI apps get a third column; on 21:9 they stack with the code column.
//   multi   two or more external monitors: web on one, code on the widest, comms on the MacBook or a third one.
// VMs (workspace 4) go on the main screen, or with two externals on the widest one.
// With several windows of one role in a row, they stack into one column (accordion; Hyper+J/K cycles them).
// Terminals are never moved: they open where you are. Floating windows are left alone.
// Config: ~/.aerospace.toml. Log: ~/Library/Logs/aerospace-desk.log.

import { appendFileSync, existsSync, readFileSync, writeFileSync } from "node:fs";
import { homedir, tmpdir } from "node:os";
import { spawn, spawnSync } from "node:child_process";

type Role = "web" | "code" | "ai" | "comms" | "vm";
const ROLE_ORDER: Role[] = ["web", "code", "ai", "comms", "vm"];
const SORTED = new Set(["1", "2", "3"]); // arrange takes windows off these only (see above)

// Bundle ids (aerospace list-apps --format '%{app-bundle-id}'). First match wins.
const APPS: [RegExp, Role][] = [
  [/^(app\.zen-browser\.zen|com\.google\.Chrome|com\.apple\.Safari|org\.mozilla\.firefox|company\.thebrowser\.Browser|md\.obsidian)$/, "web"],
  [/^(com\.anthropic\.claudefordesktop|com\.openai\.codex|com\.openai\.chat)$/, "ai"],
  [/^(com\.superlogical\.rex|com\.todesktop\.230313mzl4w4u92|com\.microsoft\.VSCode|com\.apple\.dt\.Xcode)$/, "code"],
  [/^com\.jetbrains\.(?!toolbox$)/, "code"],
  [/^(com\.vmware\.fusion|com\.parallels\.desktop\.console|com\.utmapp\.UTM|org\.virtualbox\.app\.VirtualBox)$/, "vm"],
  [/^(net\.whatsapp\.WhatsApp|us\.zoom\.xos|com\.microsoft\.teams2|com\.tinyspeck\.slackmacgap|com\.hnc\.Discord|org\.whispersystems\.signal-desktop|com\.tdesktop\.Telegram|ru\.keepcoder\.Telegram|com\.teamspeak\.5\.client|com\.apple\.MobileSMS|com\.apple\.FaceTime|com\.fastmail\.mac\.Fastmail|com\.microsoft\.Outlook|com\.apple\.mail)$/, "comms"],
];
const roleOf = (bundle: string) => APPS.find(([re]) => re.test(bundle))?.[1];

const GAP = 8;         // must match [gaps] in ~/.aerospace.toml (outer and inner)
const ULTRAWIDE = 2.1; // width/height; 21:9 monitors are ~2.4, 32:9 ~3.6, 16:9 1.78
const SUPERWIDE = 3;   // room for three columns
const LOG = `${homedir()}/Library/Logs/aerospace-desk.log`;
const PIDFILE = `${tmpdir()}/aerospace-desk.pid`;

const log = (msg: string) => appendFileSync(LOG, `${new Date().toISOString()} ${msg}\n`);

function run(...cmd: string[]) {
  const r = spawnSync(cmd[0], cmd.slice(1), { encoding: "utf8" });
  return { ok: r.status === 0, out: (r.stdout ?? "").trim(), err: (r.stderr ?? r.error?.message ?? "").trim() };
}
const aero = (...args: string[]) => run("aerospace", ...args);
const notify = (msg: string) =>
  run("osascript", "-e", `display notification ${JSON.stringify(msg)} with title "AeroSpace"`);

// ---------- screens ----------
type Monitor = { id: number; name: string; builtIn: boolean; aspect: number; usableWidth: number; usableHeight: number };

function monitors(): Monitor[] {
  // AppKit gives the sizes (no permissions needed); AeroSpace maps its monitors onto NSScreen indexes.
  const sizes: number[][] = JSON.parse(run("osascript", "-l", "JavaScript", "-e", `
    ObjC.import('AppKit');
    const s = $.NSScreen.screens, out = [];
    for (let i = 0; i < s.count; i++) { const o = s.objectAtIndex(i), f = o.frame.size, v = o.visibleFrame.size; out.push([f.width, f.height, v.width, v.height]); }
    JSON.stringify(out);`).out || "[]");
  return aero("list-monitors", "--format", "%{monitor-id}|%{monitor-name}|%{monitor-appkit-nsscreen-screens-id}").out
    .split("\n").filter(Boolean).map(line => {
      const [id, name, screen] = line.split("|");
      const [w, h, vw, vh] = sizes[Number(screen) - 1] ?? [16, 10, 1600, 1000];
      return { id: Number(id), name, builtIn: /built-in/i.test(name), aspect: w / h, usableWidth: vw - 2 * GAP, usableHeight: vh - 2 * GAP };
    });
}

type Plan = { profile: "single" | "wide" | "multi"; ws: Record<Role, string>; screens: Record<string, Monitor> };

function plan(ms: Monitor[]): Plan {
  const external = ms.filter(m => !m.builtIn).sort((a, b) => a.id - b.id);
  const builtIn = ms.find(m => m.builtIn);
  if (external.length >= 2) {
    const code = external.reduce((a, b) => (b.usableWidth > a.usableWidth ? b : a));
    const web = external.find(m => m !== code)!;
    const comms = builtIn ?? external.find(m => m !== code && m !== web) ?? web;
    return { profile: "multi", ws: { web: "1", code: "2", ai: "2", comms: "3", vm: "4" }, screens: { 1: web, 2: code, 3: comms, 4: code } };
  }
  const main = external[0] ?? builtIn ?? ms[0];
  const comms = builtIn && builtIn !== main ? builtIn : main;
  if (main.aspect >= ULTRAWIDE) return { profile: "wide", ws: { web: "2", code: "2", ai: "2", comms: "3", vm: "4" }, screens: { 1: main, 2: main, 3: comms, 4: main } };
  return { profile: "single", ws: { web: "1", code: "2", ai: "2", comms: "3", vm: "4" }, screens: { 1: main, 2: main, 3: comms, 4: main } };
}

const signature = () => aero("list-monitors", "--format", "%{monitor-id}|%{monitor-name}").out;

// ---------- windows ----------
type Win = { id: string; bundle: string; ws: string; floating: boolean };

const windows = (): Win[] =>
  aero("list-windows", "--all", "--format", "%{window-id}|%{app-bundle-id}|%{workspace}|%{window-layout}").out
    .split("\n").filter(Boolean).map(l => { const [id, bundle, ws, layout] = l.split("|"); return { id, bundle, ws, floating: layout === "floating" }; });

const fractionPx = (frac: number, usable: number) => Math.round(frac * (usable + GAP) - GAP);

// Rebuild one workspace: its known windows in role order, one column per role, sized by screen.
function build(ws: string, wins: Win[], m: Monitor, p: Plan) {
  const cols: string[][] = [];
  const colRoles: Role[] = [];
  for (const r of ROLE_ORDER) {
    const ids = wins.filter(w => roleOf(w.bundle) === r).map(w => w.id);
    if (!ids.length) continue;
    // 21:9 has room for two columns: the AI apps stack with the code column.
    if (r === "ai" && p.profile === "wide" && m.aspect < SUPERWIDE && cols.length >= 2) cols[cols.length - 1].push(...ids);
    else { cols.push(ids); colRoles.push(r); }
  }
  if (!cols.length) return;
  const all = cols.flat();
  // Moved windows are appended on the right in move order, so stage them elsewhere and bring them back in order.
  for (const id of all) aero("move-node-to-workspace", "--window-id", id, "desk-staging");
  aero("flatten-workspace-tree", "--workspace", ws);
  for (const id of all) aero("move-node-to-workspace", "--window-id", id, ws);
  const wide = m.aspect >= ULTRAWIDE;
  if (cols.length === 1) {
    // One role on the workspace: side by side on an ultrawide, one at a time (accordion) elsewhere.
    aero("layout", "--window-id", all[0], wide ? "h_tiles" : "h_accordion");
    return;
  }
  aero("layout", "--window-id", all[0], "h_tiles");
  for (const col of cols) {
    col.slice(1).forEach((id, i) => aero(i === 0 ? "join-with" : "move", "--window-id", id, "left"));
    if (col.length > 1) aero("layout", "--window-id", col[0], "v_accordion");
  }
  aero("balance-sizes", "--workspace", ws);
  if (cols.length === 3) aero("resize", "--window-id", cols[1][0], "width", String(fractionPx(0.4, m.usableWidth)));
  // Two columns: web takes a third next to code; without web, the AI column takes a third next to code.
  if (cols.length === 2) aero("resize", "--window-id", cols[colRoles[0] === "web" ? 0 : 1][0], "width", String(fractionPx(1 / 3, m.usableWidth)));
}

function arrange(p = plan(monitors()), all = false) {
  const focused = aero("list-windows", "--focused", "--format", "%{window-id}").out;
  for (const [ws, m] of Object.entries(p.screens)) aero("move-workspace-to-monitor", "--workspace", ws, String(m.id));
  const targets = new Map<string, Win[]>();
  for (const w of windows()) {
    const r = roleOf(w.bundle);
    if (!r || w.floating) continue;
    const ws = p.ws[r];
    if (!all && !SORTED.has(w.ws) && w.ws !== ws) continue; // you put it there
    targets.set(ws, [...(targets.get(ws) ?? []), w]);
  }
  for (const [ws, wins] of targets) build(ws, wins, p.screens[ws], p);
  if (focused) aero("focus", "--window-id", focused);
  log(`arranged: ${p.profile} on ${Object.values(p.screens).map(m => m.name).join(", ")}`);
}

// A new window of a known app: send it to its workspace and rebuild that workspace if it holds several columns.
// `prev` is the window focused before this one appeared.
function place(e: { windowId: number; appBundleId: string; workspace: string }, p: Plan, prev?: string) {
  const r = roleOf(e.appBundleId);
  if (!r) return;
  const id = String(e.windowId);
  const all = windows();
  const me = all.find(w => w.id === id);
  if (!me || me.floating) return;
  const ws = p.ws[r];
  const before = all.find(w => w.id === prev);
  // Opened next to a window of the same role (Cmd+N) on one of your workspaces: leave it there.
  if (me.ws !== ws && !SORTED.has(me.ws) && before?.ws === me.ws && roleOf(before.bundle) === r) return;
  const there = all.filter(w => w.ws === ws && !w.floating && roleOf(w.bundle));
  const roles = new Set(there.map(w => roleOf(w.bundle)));
  roles.add(r);
  if (roles.size === 1) {
    if (me.ws !== ws) aero("move-node-to-workspace", "--focus-follows-window", "--window-id", id, ws);
    return;
  }
  // Several columns. AeroSpace puts a new window right after the focused one, inside its column if it has one.
  // So when that window has the same role (Cmd+N in the browser), only a lone column needs joining. Anything else
  // (opened from the Dock, from another workspace) rebuilds the workspace, which takes about a second.
  if (me.ws === ws && before?.ws === ws && roleOf(before.bundle) === r) {
    const parent = aero("list-windows", "--workspace", ws, "--format", "%{window-id}|%{window-parent-container-layout}").out
      .split("\n").find(l => l.startsWith(`${id}|`))?.split("|")[1] ?? "";
    if (!parent.startsWith("v_")) { aero("join-with", "--window-id", id, "left"); aero("layout", "--window-id", id, "v_accordion"); }
    return;
  }
  build(ws, me.ws === ws ? there : [...there, me], p.screens[ws], p);
  aero("focus", "--window-id", id);
}

function alive(pid: number) { try { process.kill(pid, 0); return true; } catch { return false; } }

async function watch() {
  if (existsSync(PIDFILE) && alive(Number(readFileSync(PIDFILE, "utf8")))) return;
  writeFileSync(PIDFILE, String(process.pid));
  let p = plan(monitors());
  if (!process.argv.includes("--no-arrange")) arrange(p);
  let sig = signature(), arrangedSig = sig;
  let pending: ReturnType<typeof setTimeout> | undefined;
  setInterval(() => {
    const s = signature();
    if (s === sig || !s) return;
    sig = s;
    clearTimeout(pending);
    // Let macOS settle the new screen layout first.
    // A screen that blinks off and on again (sleep, input switch) ends where it started: nothing to do.
    pending = setTimeout(() => {
      const now = signature();
      if (now === arrangedSig) return;
      arrangedSig = now; p = plan(monitors()); arrange(p);
    }, 2000);
  }, 3000);
  const sub = spawn("aerospace", ["subscribe", "--no-send-initial", "window-detected", "focus-changed"], { stdio: ["ignore", "pipe", "ignore"] });
  sub.stdout.setEncoding("utf8");
  const focus: string[] = []; // most recent last
  let buf = "";
  for await (const chunk of sub.stdout) {
    buf += chunk;
    let nl;
    while ((nl = buf.indexOf("\n")) >= 0) {
      const line = buf.slice(0, nl); buf = buf.slice(nl + 1);
      try {
        const e = JSON.parse(line);
        if (e._event === "focus-changed") { if (e.windowId) focus.push(String(e.windowId)); focus.splice(0, focus.length - 5); continue; }
        if (e._event === "window-detected") place(e, p, focus.findLast(f => f !== String(e.windowId)));
      } catch (err) { log(`place failed: ${err} (${line})`); }
    }
  }
  log("subscribe ended (AeroSpace quit or restarted); exiting");
  process.exit(0);
}

function size(dim: string, frac: string) {
  if (dim !== "width" && dim !== "height") throw new Error("usage: aerospace-desk size width|height <fraction>");
  const [num, den = 1] = frac.split("/").map(Number);
  const layout = aero("list-windows", "--focused", "--format", "%{window-layout}").out;
  if (layout.includes("accordion")) return notify("Sizes only work in tiles layout: in accordion every window is full size. Hyper+T or Hyper+/ switches to tiles.");
  if (layout === "floating") return notify("Floating windows can't be sized by AeroSpace. Hyper+Shift+Space tiles it.");
  const id = Number(aero("list-monitors", "--focused", "--format", "%{monitor-id}").out);
  const m = monitors().find(x => x.id === id) ?? monitors()[0];
  const r = aero("resize", dim, String(fractionPx(num / den, dim === "width" ? m.usableWidth : m.usableHeight)));
  if (!r.ok) notify(r.err || "resize failed");
}

const [cmd, ...args] = process.argv.slice(2);
switch (cmd) {
  case "arrange":
    arrange(undefined, args.includes("--all"));
    // After a config reload AeroSpace doesn't rerun after-startup-command, so make sure the watcher runs.
    if (!(existsSync(PIDFILE) && alive(Number(readFileSync(PIDFILE, "utf8")))))
      spawn(process.execPath, [import.meta.filename, "watch", "--no-arrange"], { stdio: "ignore", detached: true }).unref();
    break;
  case "watch": await watch(); break;
  case "size": size(args[0], args[1]); break;
  case "profile": { const ms = monitors(); console.log(JSON.stringify({ monitors: ms, plan: plan(ms) }, null, 2)); break; }
  default: console.error("usage: aerospace-desk arrange | watch | size width|height <fraction> | profile"); process.exit(2);
}
