# Yazi

Blazing-fast Rust terminal file manager. Config: [`common/hm/yazi.nix`](common/hm/yazi.nix).
Theme: **VS Code Dark Modern** (`956MB/vscode-dark-modern`).

## Launch

| cmd | action |
| --- | --- |
| `zz` | open yazi — **on quit the shell cds into the dir you ended in** |
| `zz <path>` | open at `<path>` |

`zz` is the cwd-on-exit wrapper (a function, not a plain alias). Quitting yazi drops your
shell exactly where you navigated — the main reason to use the wrapper over running `yazi` directly.

## Move

| key | action |
| --- | --- |
| `h j k l` / arrows | left / down / up / right |
| `l` / `Enter` | enter dir · open file |
| `h` / `Backspace` | parent dir |
| `g g` / `G` | top / bottom |
| `<C-u>` / `<C-d>` | half-page up / down |
| `<C-b>` / `<C-f>` | full page up / down (`K` / `J` alias this) |

## Select

| key | action |
| --- | --- |
| `Space` | toggle item under cursor |
| `v` | visual mode (select on move) |
| `V` | visual mode — unset |
| `<C-a>` / `<C-r>` | select all / invert |

## Files

| key | action |
| --- | --- |
| `y` / `x` | yank (copy) / cut |
| `Y` / `X` | cancel yank |
| `p` / `P` | paste / paste (overwrite) |
| `d` / `D` | trash / delete (permanent) |
| `a` | create (trailing `/` → directory) |
| `r` | rename |
| `o` | open with… |
| `.` | toggle hidden files |

## Find

| key | action |
| --- | --- |
| `f` | smart-filter current dir (type, `Esc` to clear) |
| `Tab` | toggle preview pane |

## Tabs

| key | action |
| --- | --- |
| `t` | new tab (current dir) |
| `1`–`9` | switch to tab N |
| `[` / `]` | prev / next tab |

## Misc

`?` help · `:` command line · `q` quit · `<Esc>` cancel

## Switch theme variant

In [`common/hm/yazi.nix`](common/hm/yazi.nix) change the flavor attr + `theme.flavor.dark`, and point the
`vscode-yazi` input in [`flake.nix`](flake.nix) at the matching repo. Variants:

- `vscode-dark-plus` → `github:956MB/vscode-dark-plus.yazi`
- `vscode-light-modern` → `github:956MB/vscode-light-modern.yazi`
- `vscode-light-plus` → `github:956MB/vscode-light-plus.yazi`

Then run `build` (or `nix flake lock` if you changed the input URL).

> Applies to the `wsl` host. `hydenix` uses its own HM module set (`hydenix/modules/hm`),
> so import `common/hm/yazi.nix` there too if you want it on the desktop.
