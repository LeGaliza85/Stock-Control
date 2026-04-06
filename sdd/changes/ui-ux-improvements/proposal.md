# Proposal: UI/UX Improvements

## Intent
Enhance the application's feedback loops, loading states, and navigation polish to make the "Vintage Catalog" feel professional and a pleasure to use. Address the lack of visual confirmations and refine the existing design system.

## Scope

### In Scope
- Implement a global 'Toast' or 'Alert' system for flash messages.
- Add a Turbo progress bar for page transitions.
- Redesign 'No results' empty states with shared partials.
- Form polishing (refine inputs, buttons, and validation error styles).
- Add breadcrumbs for better navigation.

### Out of Scope
- Complete redesign of the application aesthetic.
- Changes to the underlying database schema or business logic.

## Approach
- **Layout:** Update `application.html.erb` to include flash message rendering and breadcrumbs structure.
- **Feedback:** Use Turbo and Stimulus (if necessary) to handle toast notifications automatically. Configure Turbo progress bar in `application.js`.
- **CSS System:** Expand `application.css` to define consistent component patterns for the newly introduced UI elements (toasts, empty states, refined forms).
- **Views:** Extract an `_empty_state.html.erb` partial and apply it to `productos/index` and other relevant lists.

## Affected Areas
| Area | Impact | Description |
|------|--------|-------------|
| `app/views/layouts/application.html.erb` | Modified | Add flash messages and breadcrumbs |
| `app/assets/stylesheets/application.css` | Modified | Add styles for toasts, forms, empty states |
| `app/javascript/application.js` | Modified | Configure Turbo progress bar |
| `app/views/productos/index.html.erb` | Modified | Update empty state to use new partial |
| `app/views/shared/_empty_state.html.erb` | New | Reusable empty state component |

## Risks
| Risk | Likelihood | Mitigation |
|------|------------|------------|
| CSS Regressions | Medium | Use scoped classes and test across main views (index, show, forms) |
| Turbo caching issues with flash messages | Low | Ensure flash messages are cleared or handled properly in Turbo Drive navigations |

## Rollback Plan
Revert changes to `application.html.erb`, `application.css`, and `application.js`. Remove the new empty state partial.

## Dependencies
- Hotwire (Turbo/Stimulus) already installed.

## Success Criteria
- [ ] Flash messages appear when creating, editing, or deleting a product.
- [ ] Turbo progress bar is visible during navigation.
- [ ] Empty states look professional and guide the user.
- [ ] Forms have consistent, polished styling.
