# Consoles

Saved SQL / JavaScript / MongoDB consoles of this workspace, one file each.
Managed by Mako: the app writes here on every explicit save, and anything
committed here (from a clone, a terminal, the agent) shows up in the app on
the next push.

- `consoles/<folder>/<name>.sql` is visible to the whole workspace;
  `users/<handle>/consoles/…` is that person's private console.
- Leading `-- key: value` comment lines are metadata (`connection`,
  `database`, `description`, `schedule`, `timezone`); the first blank
  line ends them. `<name>.chart.json` next to a file is its chart.
- Extension = language: `.sql`, `.js`, `.mongodb.js`.
