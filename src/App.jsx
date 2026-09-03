import { useState } from 'react';

/**
 * Reference implementation of the three UI hooks the marketplace requires.
 *
 * BUILDLY.yaml declares `app-root`, `primary-action` and `panel` under
 * ui_hooks, and tests/robot/smoke.robot asserts on exactly those selectors.
 * Replace everything you see here with your own app -- just keep the three
 * data-testid attributes on the equivalent elements, or CI will fail.
 */
export default function App() {
  const [panelOpen, setPanelOpen] = useState(false);

  return (
    <main className="app" data-testid="app-root">
      <header className="app__header">
        <h1 className="app__title">ForgeFETemplate</h1>
        <p className="app__subtitle">
          A Buildly Marketplace frontend starter. Swap the framework, keep the
          contract.
        </p>
      </header>

      <button
        type="button"
        className="app__action"
        data-testid="primary-action"
        onClick={() => setPanelOpen((open) => !open)}
        aria-expanded={panelOpen}
        aria-controls="forge-panel"
      >
        {panelOpen ? 'Hide details' : 'Show details'}
      </button>

      {/*
        Mounted only when open: the smoke test asserts the panel is NOT visible
        before the primary action is clicked, so it must not merely be hidden
        behind a class the test cannot see through.
      */}
      {panelOpen && (
        <section className="app__panel" id="forge-panel" data-testid="panel">
          <h2>You are wired up</h2>
          <p>
            This panel is what the E2E suite waits for after clicking the
            primary action, and what the second marketplace screenshot
            captures.
          </p>
          <ul>
            <li>
              <code>./ops/startup.sh start node</code> — run locally
            </li>
            <li>
              <code>./scripts/test-e2e-docker.sh</code> — run the E2E suite
            </li>
            <li>
              <code>./scripts/screenshots-docker.sh</code> — regenerate listing
              screenshots
            </li>
          </ul>
        </section>
      )}
    </main>
  );
}
