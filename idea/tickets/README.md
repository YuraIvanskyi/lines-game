# Tickets

Local tracker for the port. GitHub issues are not the source of truth.

- Specs: `idea/tickets/LG-###.md`
- Status: [BOARD.md](BOARD.md) only. Ticket files do not carry a second status line.
- Order and exits: [../plan.md](../plan.md)
- Rules that bind a ticket: [../decisions.md](../decisions.md)
- Shapes for the rules package and the board painter: [../port-patterns.md](../port-patterns.md)
- iPhone checks: [../ios-device.md](../ios-device.md)

## Status meanings

| Status | Meaning |
| --- | --- |
| backlog | Spec exists. The phase is not open, or a dependency is still open. |
| ready | Active phase, dependencies `done`. Nobody is on it. |
| doing | Someone is implementing it. |
| blocked | Stopped on a named decision, bug, or `iPhone check`. Say which, on the board. Code that is ready for the owner stays here until they confirm the phone section. |
| done | Acceptance in the ticket is met. |
| dropped | Will not be built. Say why on the board. |

## Taking a ticket

1. Set the row to `doing`.
2. Implement only that ticket, in `app/` or `packages/rules/` as the spec says. Do not edit the Pygame prototype unless the ticket says to.
3. Set the row to `done` or `blocked`.
4. When the phase exit in the plan is true, move the active phase forward and set the newly unblocked tickets to `ready`.

One `doing` ticket at a time unless two tickets share no files.
