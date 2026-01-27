# Cake Plugin Developer Guide

## Overview

Cake plugins are lightweight Bash modules that extend the Cake system monitor with additional panels, tools, or data visualizations. Plugins are **first-class components** and are loaded dynamically at runtime.

This guide defines the **official plugin specification**, UI standards, and best practices. Plugins that follow this guide will integrate cleanly with Cake’s UI, themes, and configuration system.

---

## Plugin Goals

A Cake plugin should:

* Be **read-only by default** (no destructive actions)
* Render output quickly (non-blocking)
* Match Cake’s visual style
* Avoid external dependencies when possible
* Fail silently if unsupported data is unavailable

---

## Plugin Directory Layout

All plugins live in:

```
plugins/
├── cake_default.sh
├── hello_plugin.sh
└── example_plugin.sh
```

Plugins are sourced automatically at runtime.

---

## Required Plugin Interface

Every plugin **must** define the following symbols:

```bash
plugin_name="Human Readable Name"
plugin_draw() { }
```

### `plugin_name`

* Display name shown in menus and logs
* Should be concise and descriptive

### `plugin_draw()`

* Called once per refresh cycle
* Responsible for rendering all output
* Must not clear the screen

---

## Optional Metadata (Recommended)

Plugins may define optional metadata variables:

```bash
plugin_version="1.0"
plugin_author="Your Name"
plugin_description="Short description"
plugin_requires="/proc"
```

These are not yet enforced but are reserved for future tooling.

---

## UI & Styling Rules

Plugins **inherit Cake’s UI environment**. The following variables are guaranteed to exist:

```bash
R DIM BOLD
FG_TITLE FG_LABEL FG_VALUE FG_WARN
```

### Dividers & Layout

Use Unicode box-drawing characters when possible:

```text
┌──────────────── Cake Plugin ────────────────┐
│ Label        Value                           │
└─────────────────────────────────────────────┘
```

Avoid full-width separators that conflict with other panels.

### Do

* Align labels vertically
* Keep width ≤ 60 columns
* Use muted colors

### Do Not

* Call `clear`
* Move the cursor
* Change terminal modes
* Print raw ANSI resets excessively

---

## Performance Guidelines

* Avoid `sleep` inside plugins
* Avoid scanning large directories
* Cache expensive values if needed
* Plugins should complete in **<50ms**

Bad example:

```bash
ping -c5 example.com
```

Good example:

```bash
[[ -r /proc/loadavg ]] && awk '{print $1}' /proc/loadavg
```

---

## Error Handling

Plugins must fail gracefully.

Recommended pattern:

```bash
[[ ! -r /proc/somefile ]] && return
```

Never print error messages directly to the UI.

---

## Example Minimal Plugin

```bash
plugin_name="Minimal"

plugin_draw() {
  echo "┌──────── Minimal ────────┐"
  echo "│ Status     OK           │"
  echo "└────────────────────────┘"
}
```

---

## Example Advanced Plugin (Pattern)

```bash
plugin_name="Advanced"

plugin_draw() {
  local value=$(some_command 2>/dev/null)
  [[ -z "$value" ]] && value="N/A"

  printf "┌──────── Advanced ────────┐\n"
  printf "│ Value     %-12s │\n" "$value"
  printf "└─────────────────────────┘\n"
}
```

---

## Configuration Access

Plugins may read Cake configuration variables:

```bash
REFRESH_INTERVAL
RGB_MODE
THEME
```

Plugins **must not modify** these values directly.

---

## Security Model

Plugins:

* Run as the invoking user
* Must not require root
* Must not write outside `$HOME/.config/cake`

Network scanning, probing, or enumeration must be **explicitly user-invoked** via apps, not passive plugins.

---

## Versioning Policy

* Follow semantic versioning when used
* Breaking changes require a major version bump

---

## Testing Checklist

Before submitting a plugin:

* [ ] No external dependencies
* [ ] Works without root
* [ ] Handles missing files
* [ ] No screen clearing
* [ ] UI fits within Cake layout

---

## Roadmap (Planned)

* Plugin enable/disable menu
* Plugin metadata inspector
* Lint tool (`cake-plugin-lint`)
* Signed official plugins

---

## Final Notes

Cake plugins are intended to be **boring, reliable, and composable**. Visual flair is welcome, but clarity and stability always come first.

If your plugin feels like it belongs in a standalone app, it probably should be an **App**, not a plugin.
