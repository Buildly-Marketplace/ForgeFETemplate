import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it } from 'vitest';
import App from '../../src/App.jsx';

/**
 * Guards the three UI hooks BUILDLY.yaml declares.
 *
 * The Robot suite checks the same contract against a real browser, but that
 * needs Docker and about a minute. These run in milliseconds, so a rename that
 * would break marketplace CI fails here first.
 */
describe('marketplace UI hooks', () => {
  it('renders the app root', () => {
    render(<App />);
    expect(screen.getByTestId('app-root')).toBeInTheDocument();
  });

  it('keeps the panel out of the document until the primary action is used', () => {
    render(<App />);
    expect(screen.queryByTestId('panel')).not.toBeInTheDocument();
  });

  it('reveals the panel when the primary action is clicked', async () => {
    const user = userEvent.setup();
    render(<App />);

    await user.click(screen.getByTestId('primary-action'));

    expect(screen.getByTestId('panel')).toBeVisible();
  });

  it('toggles the panel back off', async () => {
    const user = userEvent.setup();
    render(<App />);
    const action = screen.getByTestId('primary-action');

    await user.click(action);
    await user.click(action);

    expect(screen.queryByTestId('panel')).not.toBeInTheDocument();
  });
});
