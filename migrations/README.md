# Migrations

One-off changes that bring an **existing** machine to the state a fresh install
would produce (remove a package, move a config, enable a service, ...).

- Name: `<unix-timestamp>.sh` (`date +%s`), so they run in creation order.
- `task update` runs every migration not yet recorded in
  `~/.local/state/workstation-setup/migrations/`.
- A fresh install records all existing migrations as done without running them.
- Migrations must be safe to run on a machine that is already in the target state.
