# ForgeFETemplate

A Buildly Marketplace **frontend** starter template.

Ships with a React reference implementation, but the scaffolding around it --
`BUILDLY.yaml`, `ops/startup.sh`, Robot Framework E2E, marketplace screenshots,
CI, and the `.ai` / `.github` / `devdocs` conventions -- is framework-agnostic.
Swap in Vue, Angular, Svelte or React Native Web and the contract holds.

> Building a backend or service instead? Use
> [ForgeAppTemplate](https://github.com/Buildly-Marketplace/ForgeAppTemplate).

---

## Quick Start

```bash
npm install
./ops/startup.sh start node
```

Open http://localhost:8000. Stop with `./ops/startup.sh stop node`.

Or run everything in containers, exactly as CI does:

```bash
./ops/startup.sh start docker
```

---

## The Contract

Three things make a submission valid. Keep them and you can change everything else.

### 1. npm scripts

`ops/startup.sh`, `ops/Dockerfile.app` and CI all invoke these by name:

| Script | Purpose |
|--------|---------|
| `npm run dev` | Dev server, honouring `--port` or `$PORT` |
| `npm run build` | Production build into `frontend.build_dir` |
| `npm test` | Unit / component tests |
| `npm run lint` | Optional; skipped via `--if-present` |

### 2. UI test hooks

`BUILDLY.yaml` declares three `data-testid` attributes, and both the unit tests
and the Robot suites assert on them:

| Hook | Element |
|------|---------|
| `app-root` | Main application container |
| `primary-action` | Primary call-to-action button |
| `panel` | Content revealed by the primary action |

Render `panel` conditionally rather than hiding it with CSS -- the smoke test
asserts it is absent before the click.

### 3. `frontend.build_dir`

Must match where `npm run build` actually writes:

| Framework | Directory |
|-----------|-----------|
| Vite (React, Vue, Svelte) | `dist` |
| Create React App | `build` |
| Angular | `dist/<project-name>` |
| Next.js (static export) | `out` |

A mismatch produces an empty nginx image that 404s while the dev server works
fine -- the most common way a submission fails CI.

---

## Testing

```bash
npm test                        # unit / component -- milliseconds
./scripts/test-e2e-docker.sh    # E2E against the real production build
./scripts/screenshots-docker.sh # regenerate marketplace screenshots
```

For a faster local loop against the dev server:

```bash
./ops/startup.sh start node
./scripts/test-e2e-node.sh
```

Robot Framework and Playwright are Python tools, but they drive only the **test
runner**. The application is pure JavaScript and never imports them; the Docker
path removes the local Python requirement entirely.

See [devdocs/04_testing.md](devdocs/04_testing.md) for the full strategy.

---

## Swapping the Framework

1. Replace `src/` and the framework deps in `package.json`.
2. Keep the four npm script names above.
3. Put the three `data-testid` hooks on the equivalent elements.
4. Set `frontend.framework` and `frontend.build_dir` in `BUILDLY.yaml` (and
   `BUILD_DIR` in `ops/docker-compose.yml` if it is not `dist`).
5. Rewrite `tests/unit/` for your framework's testing library.

`tests/robot/`, `ops/`, `scripts/` and `.github/` need no changes -- they talk
to the app over HTTP and know nothing about how it was built.

### React Native

For React Native, target **React Native Web** so there is a URL for Playwright
to open. Expo builds one with `npx expo export --platform web`; point
`frontend.build_dir` at its output and set `dev` to `npx expo start --web`.
Native-only builds cannot satisfy the E2E and screenshot requirements.

---

## Layout

```
.ai/                    # Agent policy and prompts
.github/                # CI, issue and PR templates, Copilot instructions
devdocs/                # Testing guide, manifest reference, work-item templates
marketplace/screenshots # Canonical listing screenshots (generated, tracked)
ops/                    # startup.sh, Dockerfiles, compose, nginx, standards
scripts/                # E2E and screenshot runners (docker + node)
src/                    # Application source -- replace this
tests/unit/             # Component tests
tests/robot/            # Robot Framework E2E suites
BUILDLY.yaml            # Marketplace manifest
```

---

## App Control

`./ops/startup.sh <command> [mode] [--port N]`

| | |
|-|-|
| Commands | `start`, `stop`, `restart`, `status` |
| Modes | `node` (default), `docker` |

```bash
./ops/startup.sh start node --port 8080
./ops/startup.sh status docker
./ops/startup.sh stop node
```

---

## CI

Every push and PR runs three jobs:

- **Lint & Unit Tests** — `npm ci`, lint, build, `npm test`
- **E2E Tests & Screenshots** — Docker-first, uploads Robot reports and screenshots
- **Validate BUILDLY.yaml** — manifest schema, lockfile presence, UI hooks exist in `src/`

---

## License

MIT — see [LICENSE](LICENSE).
