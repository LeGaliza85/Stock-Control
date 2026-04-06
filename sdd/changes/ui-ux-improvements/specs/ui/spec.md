# Delta for UI/UX

## ADDED Requirements

### Requirement: Global Flash Messages
The system MUST display flash messages for successful and erroneous operations.

#### Scenario: Successful product creation
- GIVEN a user is on the new product form
- WHEN they submit a valid product
- THEN a success flash message MUST appear on the screen
- AND it SHOULD disappear automatically after a few seconds

### Requirement: Turbo Progress Bar
The system MUST provide visual feedback during Turbo Drive navigations.

#### Scenario: Navigating between pages
- GIVEN a user clicks a link to another page
- WHEN the network request is processing
- THEN a progress bar MUST appear at the top of the viewport

### Requirement: Empty States
The system MUST display a helpful empty state when lists yield no results.

#### Scenario: Viewing an empty product list
- GIVEN there are no products in the database
- WHEN the user visits the products index
- THEN a "No results" empty state component MUST be displayed
- AND it MUST contain a button to "Create new product"

### Requirement: Breadcrumbs Navigation
The system SHOULD display breadcrumbs to indicate the current page hierarchy.

#### Scenario: Viewing a specific product
- GIVEN a user is on a product's show page
- WHEN they look at the top of the page
- THEN they MUST see breadcrumbs like "Home > Products > [Product Name]"

## MODIFIED Requirements

### Requirement: Form Styling
Forms MUST use consistent, polished input and button styles adhering to the Vintage Catalog aesthetic.
(Previously: Forms used default, unpolished browser styles or basic CSS.)
