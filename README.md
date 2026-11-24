# JobGuard Web UI Tests (Robot Framework + Playwright Browser library)

[![Robot UI tests](https://github.com/tony-tran-qa/My_JobGuard_TestWithRobotAndPlaywright/actions/workflows/robot.yml/badge.svg)](https://github.com/tony-tran-qa/My_JobGuard_TestWithRobotAndPlaywright/actions/workflows/robot.yml)

UI-layer tests for the JobGuard React web app (`006_My_JobGuard_ReactApp`), written with
Robot Framework and the Browser library (Playwright).

## What is covered

| Suite | Covers |
|---|---|
| `01_smoke.robot` | app loads, six tabs, no LinkedIn branding in the header, Vet button state, blacklisted company blocked without an API call |
| `02_blacklist.robot` | defaults, warning banner, add, remove, persistence across reload, export file, import merge and dedupe, invalid import |
| `03_agencies.robot` | add, change type, remove, duplicate handling, export, import, Scan Records |
| `04_records_favorites.robot` | seeded Records and Favorites, search, firm-type tags and filters, export, import without duplicates |
| `05_backup_restore.robot` | full backup contents, API key never exported, restore merge, restore twice, bad files |

Every test starts in a fresh browser context, so localStorage is empty and tests do not depend on each other.
Records and favorites are seeded from `data/*.json` into localStorage, so no Anthropic API key or network is needed.

## Not covered (on purpose)

- Live vetting against the Anthropic API (costs money, non-deterministic). The blacklist block path is covered because it never calls the API.
- The "Choose Backup/Export Folder" picker and folder autosave. They use a native browser dialog that Playwright cannot drive.
- Visual layout and styling.

## Setup (once)

```
pip install -r requirements.txt
rfbrowser init
```

## Run

1. Start the app in its own project folder:

   ```
   cd ..\006_My_JobGuard_ReactApp
   npm run dev
   ```

2. In this folder:

   ```
   robot --outputdir results tests
   ```

   Useful variations:

   ```
   robot --outputdir results --variable HEADLESS:False tests            # watch the browser
   robot --outputdir results tests\02_blacklist.robot                   # one suite
   robot --outputdir results --test "Add Entry Manually" tests          # one test
   robot --outputdir results --variable BASE_URL:http://localhost:5174/ tests
   ```

Reports: `results\report.html` and `results\log.html`. Downloaded export files are kept in `results\downloads`.

## How the tests find things

Most selectors are CSS classes or visible text. The export buttons and file inputs have `data-testid`
attributes in the React app (`export-blacklist`, `export-records`, `export-favorites`, `export-agencies`,
`export-all`, `import-<tab>`, `restore-input`). Keep those when changing the app, because the
tests depend on them.

## Layout

```
tests/       the .robot suites
resources/   shared keywords (common.resource)
data/        seed and import files
results/     output (not committed)
```

## CI

`.github/workflows/robot.yml` runs the whole suite on every push to `main`, on pull requests, and on demand (Actions tab > Robot UI tests > Run workflow).

What it does: checks out this repo and the latest `main` of `My_JobGuard_ReactApp`, installs both, starts the app on `127.0.0.1:5173`, and runs `robot --outputdir results tests` headless on Ubuntu. `log.html`, `report.html`, `output.xml` and the downloaded export files are attached to each run as the `robot-results` artifact (Actions run page > Artifacts), kept for 90 days.

Notes:
- The tests always run against the latest web app `main`. A change in the web app repo does not trigger this workflow by itself. Use Run workflow (or push here) to rerun.
- The suite needs no API key and no network beyond installing packages: the app is seeded through localStorage.

## Git operations

Commands are for PowerShell, run from the project root folder. Any terminal works as long as it is in that folder: the VS Code terminal (Terminal > New Terminal, opens in the project root), a standalone PowerShell or Windows Terminal window (`cd` to the project folder first), or Command Prompt or Git Bash (same commands, except `Add-Content` is PowerShell only). Check with `pwd` before running git.

This repo is `https://github.com/tony-tran-qa/My_JobGuard_TestWithRobotAndPlaywright`, branch `main`.

### First-time setup

| Command | When to use it |
|---|---|
| `git init` | Once, in a new project folder, to start tracking it. |
| `git add .` | Stage every change. Files matched by `.gitignore` are skipped. |
| `git status` | Always before committing. Check that no `results`, `output.xml`, `log.html` or `report.html` files are listed. |
| `git commit -m "message"` | Save the staged changes as a commit. |
| `git branch -M main` | Rename the default branch from `master` to `main` (once, before the first push). |
| `git remote add origin <url>` | Link the local folder to the GitHub repo (once). |
| `git push -u origin main` | First push. Sets `main` to track `origin/main`. |

### Everyday changes

| Command | When to use it |
|---|---|
| `git status` | See what changed and what is staged. |
| `git diff` | See the exact line changes before staging. |
| `git add <file>` | Stage one file instead of everything. |
| `git commit -m "message"` | Commit after staging. |
| `git push` | Send commits to GitHub. |
| `git pull` | Get changes from GitHub. Run it before starting work if you edit from more than one machine. |
| `git log --oneline` | Review recent commits. |

### Stop tracking a file but keep it on disk

Use this when a file was committed by mistake or should now be ignored (Robot output, local config):

```
git rm --cached <file>
Add-Content .gitignore "<file>"
git add .gitignore
git commit -m "Untrack <file>"
git push
```

Use `git rm --cached -r <folder>` for a folder. Adding a name to `.gitignore` alone does not untrack a file that is already committed. Use `git rm <file>` (no `--cached`) to delete a file from both git and disk. Anything already pushed stays in the commit history.

### Check what is ignored

```
git check-ignore -v output.xml
```

Use it to confirm which `.gitignore` rule is hiding a file. Robot writes `output.xml`, `log.html` and `report.html` after every run, and they are ignored in the project root and in any subfolder.

## Known warnings and errors

Things that look alarming but are expected or easy to fix.

| Message | Meaning | What to do |
|---|---|---|
| `warning: in the working copy of '<file>', LF will be replaced by CRLF the next time Git touches it` | Windows line endings. The repo stores LF and Git converts to CRLF in your working folder. Common on every `git add` on Windows. | Nothing. It is harmless and does not change the content. To silence it: `git config core.autocrlf true`. |
| Branch is called `master` after `git init` | Older Git default. GitHub repos here use `main`. | `git branch -M main` before the first push. |
| Browser sign-in window opens on first `git push` | Git Credential Manager asks for GitHub login. | Sign in as `tony-tran-qa`. The push then continues. |
| `output.xml`, `log.html` or `report.html` still shows in `git status` | The file was committed or staged before it was ignored. | See "Stop tracking a file but keep it on disk" above. |
| `remote origin already exists` | The remote was already added. | `git remote set-url origin <url>` to change it. |
| `Updates were rejected` or `fetch first` on push | GitHub has commits you don't have locally. | `git pull --rebase`, then `git push`. |
| GitHub repo page has no About gear | The About box only appears once the repo has a first commit. | Push first, then edit the description on the repo page. |
| `Download` or `Promise To Wait For Download` timeout in a test | The app did not trigger a download, usually because the dev server is not running at the base URL. | Start the app with `npm run dev` in the React project and rerun. |
