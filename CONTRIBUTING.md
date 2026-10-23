# Contributing

Thanks for helping. Bug reports, translations and pull requests are all welcome.

## Reporting a bug

[Open an issue](https://github.com/weslleycabral/omarchy-ideas/issues) and include:

- your Omarchy version (`omarchy version`)
- what you did, what you expected, and what happened instead
- which AI agent CLIs you have installed, if the problem involves the correction or the title
- shell errors, if there are any: `journalctl --user -b | grep -i ideas`

## Development setup

The plugin runs straight from its folder, so the git checkout is the installed plugin.

1. Fork the repository, then clone your fork into the Omarchy plugins folder:

   ```bash
   git clone https://github.com/<you>/omarchy-ideas.git ~/.config/omarchy/plugins/weslleycabral.ideas
   omarchy plugin enable weslleycabral.ideas right
   ```

   If you installed the plugin with `omarchy plugin add`, that folder already exists. Remove it first, or add your fork as a remote of the existing checkout.

2. Put the command on your PATH so you can drive the plugin from a terminal:

   ```bash
   ln -s ~/.config/omarchy/plugins/weslleycabral.ideas/bin/ideas ~/.local/bin/ideas
   ```

3. Reload after each change:

   - `BarWidget.qml` reloads on its own when you save it.
   - `Ideas.qml` and `I18n.js` belong to an overlay that stays loaded, so restart the shell to see your changes: `omarchy restart shell`.
   - `bin/ideas` needs no reload, since each call runs the current file.

4. Check the manifest before you open a pull request:

   ```bash
   omarchy plugin validate ~/.config/omarchy/plugins/weslleycabral.ideas
   ```

## Project layout

| File | What it does |
|---|---|
| `manifest.json` | Plugin manifest: id, kinds (`overlay` and `bar-widget`), entry points, version |
| `BarWidget.qml` | The lightbulb in the bar, with the idea count in its tooltip |
| `Ideas.qml` | The dialog: list, single idea and new idea |
| `I18n.js` | Interface text in every supported language |
| `bin/ideas` | Python CLI: saves, deletes and lists ideas, and runs the AI agents |
| `docs/` | Images used by the README |

Ideas live in `~/.local/share/omarchy-ideas/ideas.json` and settings in `~/.config/omarchy-ideas/settings.json`. Only `bin/ideas` writes these files, under a file lock. The QML side reads them and calls `bin/ideas` for every change.

## Adding a language

Interface text lives in two places:

1. **`I18n.js`**: copy the `en` block, rename it to the two-letter code of the new language (for example `de`), and translate every value. Keep `%1` placeholders where they are. `dateFormat` uses [Qt date format](https://doc.qt.io/qt-6/qml-qtqml-qt.html#formatDateTime-method) codes.
2. **`bin/ideas`**: add the code to `LANGS` and add the translated notification to `MESSAGES`. This is the text shown when no AI agent answers.

Then try it with `ideas lang de` and `omarchy restart shell`. List the language in the README too.

The AI prompt does not need translating. It is written in English and tells the agent to answer in whatever language the idea is written in.

## Adding an AI agent

Add an entry to `agents()` in `bin/ideas`. The command must run without any interaction, take the prompt as an argument and print the answer to stdout (or to a file, as `codex` does). Agents are tried in list order, and the first one whose answer contains a valid `{"title": ..., "text": ...}` object wins.

## Pull requests

- Keep each pull request focused on one change.
- Match the surrounding style: two-space indentation in QML and JS, four spaces in Python.
- Describe how you tested it, with a screenshot if the interface changed.
- Add a line under `Unreleased` in `CHANGELOG.md`.

## Releasing (maintainers)

1. Bump `version` in `manifest.json`, following [Semantic Versioning](https://semver.org).
2. Move the `Unreleased` entries in `CHANGELOG.md` under the new version and date.
3. Commit, tag and publish:

   ```bash
   git tag v1.2.0 && git push --follow-tags
   gh release create v1.2.0 --notes-from-tag
   ```
