# Home Sweet Home: Keyboard & Mouse

Keyboard and mouse support, with matching on-screen key prompts, for **Harvest Moon: Home Sweet Home Special
Edition** (Steam).

Powered by BepInEx and spite.

## Why this exists

This is the third one.

In the year of our lord and savior 2023, Natsume shipped Harvest Moon: The Winds of Anthos on PC with a yellow
banner on the store page that said *"requires a controller."* People complained. [A mod](https://github.com/wisdomcostseyes/woa-kbm)
fixed it.

In October 2025 they shipped Home Sweet Home Special Edition, a port of a mobile game, with the same banner, for forty
dollars. A game designed to be played by touching the screen with your fingers was declared unplayable with the
device sitting in front of the screen.

In October 2026 they shipped Echoes of Teradea with the same banner again, for fifty. [A mod](https://github.com/wisdomcostseyes/teradea-kbm)
fixed it before the first patch.

All three games are the same engine. All three ship a complete, bound, working **Keyboard&Mouse** control scheme
inside the input asset: this one has 45 keyboard and mouse bindings in it, WASD and all. All three then hand Unity a
list of six controller layouts as the only devices the game may see, and the keyboard isn't on it. The fix is the
same one-line idea each time, and this port took an evening because the other two had already been done.

The developers get the credit for the game. The keyboard gets its dignity back.

Download: [Nexus Mods](https://www.nexusmods.com/harvestmoonhomesweethomespecialedition) or the
[GitHub releases](https://github.com/wisdomcostseyes/hsh-kbm/releases).

## Install

1. Install **BepInEx 5 (x86)**: download `BepInEx_win_x86_5.4.23.5.zip` from the
   [BepInEx releases page](https://github.com/BepInEx/BepInEx/releases) and extract it into the game folder
   (`...\steamapps\common\Harvest Moon Home Sweet Home Special Edition\`, next to the game's exe). The game is a
   32-bit build, so it must be the **x86** package.
2. Run the game once so BepInEx creates its folders, then quit.
3. Extract this mod's zip into the same game folder. You should end up with
   `BepInEx\plugins\HshKbm\HshKbm.dll` and `BepInEx\plugins\HshKbm\keys\`.
4. Play. A controller can stay plugged in; both work at once and the prompts follow whichever you touched last.

To uninstall, delete `BepInEx\plugins\HshKbm`. To remove BepInEx too, delete `winhttp.dll`, `doorstop_config.ini`
and the `BepInEx` folder.

## Default keys

| Action | Keys |
|---|---|
| Move | W A S D |
| Camera | Mouse |
| Confirm / interact / use tool | **F**, Enter, left click |
| Cancel / back | **Esc**, right click |
| Item bag | **Tab** (or I) |
| Y prompts (sort, skip, ...) | **R** |
| Previous / next tab | **Q** / **E** |
| Dash | **Shift** (hold) |
| Camera zoom in / out | **Z** / mouse wheel |
| Camera reset / top-down view | **C** (or middle click) / **V** |
| Menu / options | **Esc** |
| Quick actions (d-pad), menu selectors | Arrow keys |
| Right stick in menus (lists, sub-tabs, pages) | Arrow keys |
| Walk instead of run | hold **Ctrl** |
| Release the mouse cursor | hold **Alt** |

The buttons are remappable in `BepInEx\config\HomeSweetHome.KeyboardMouse.cfg` (created on first launch). Each
entry lists keys separated by `;`; a bare name is a keyboard key (`e`, `leftShift`, `upArrow`...), anything in
angle brackets is a raw Unity Input System path such as `<Mouse>/leftButton`. Prompts follow your bindings
automatically. Movement (WASD) and the directional keys (arrows) are fixed, because their prompts are drawn as a
WASD cluster and an arrow cross. Mouse sensitivity and Y inversion are in the `[Mouse]` section.

## Known limits

- Tutorial pictures that are pre-rendered screenshots still show controller buttons.
- Menus are navigated with keys, not the mouse pointer. The game has no pointer UI to hook.

## How it works (for modders)

- **Why there's no keyboard support.** `InputSystem.settings.supportedDevices` is a whitelist of six gamepad
  layouts, so Unity never creates keyboard or mouse devices. The mod clears it at startup, erases the game's own
  keyboard/mouse template bindings and adds its own from the config so remapping has one source of truth.
- **Prompts.** Every glyph is a UI `Image` whose sprite is named `*icon_guide_*`. A hook on `Image.sprite` swaps in
  the matching blank shape from `keys\` (one PNG per original sprite name) and renders the key names into the boxes
  listed in the PNG's `.json` sidecar, using the game's own font. Text prompts go through `MessageManager.GetKeyAction`
  and a `TMP_Text.text` rewrite that also maps the font's private-use button characters via `MessageManager.keyAction`.
- **Startup rule.** Nothing may touch `UnityEngine.InputSystem` or register the prompt patches from the BepInEx
  chainloader: the game hangs at "Using Windows.Gaming.Input". Both happen from the `InputSystemManager.Awake` prefix.
- **Exit crash.** BepInEx 5.4.23 crashes this game on exit even with no plugins (MonoMod issue #329: on newer x86
  Mono, `SetMonoCorlibInternal` writes to the wrong offset and poisons `MonoAssembly.friend_assembly_names`;
  fixed upstream in MonoMod PR #330, not yet shipped in BepInEx 5). `MonoAssemblyRepair` in `Plugin.cs` restores the
  poisoned word at startup and at quit. It's a no-op once BepInEx ships a fixed MonoMod.
- **Mine glyphs.** The mine UI shows the left stick under a big red direction arrow (`ui_mine_icon_guide_L_*`). The
  generator finds the stick by colour and puts a single cap on it; the key letter carries the direction.

## Building

- .NET SDK 8 or newer. References resolve from the game's `Managed` folder and `BepInEx\core` (set `GameDir` in the
  csproj or pass `-p:GameDir=...`).
- `tools\deploy.ps1` builds and copies the DLL plus `assets\keys` into the game (game must be closed).
- `tools\package.ps1` builds `dist\HshKbm-<version>.zip` for release.
- `tools\make_keycaps.ps1` regenerates the blank shapes and their `.json` label sidecars from the originals in
  `reference\glyphs` (dump them with the `DumpGlyphs` config option). `tools\overlay_check.ps1` renders every shape
  over its original and reports the offset of each.

## Layout

| Path | What |
|---|---|
| `src/HshKbm/` | Plugin source (C#, .NET Standard 2.1, BepInEx 5 + HarmonyX). |
| `assets/keys/` | Blank key shapes, one per original glyph sprite name, each with a `.json` label layout. |
| `tools/` | Build, deploy, package and glyph-generation scripts. |

`reference/` (decompiled game code, dumped glyphs) is local only and git-ignored.

## License

MIT. The key images are original drawings made for this mod; no game assets are redistributed.
