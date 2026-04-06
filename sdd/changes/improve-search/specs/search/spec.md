# Delta for Search

## MODIFIED Requirements

### Requirement: Text Search for Products
(Previously: The system filtered products by manually splitting text into terms and matching them against name, description, code, and category using SQL `LIKE`.)

The system MUST search for products using a robust full-text search mechanism powered by `pg_search`.
The system MUST support "fuzzy" matching, allowing for minor typos using trigram similarity (`pg_trgm`).
The system MUST ignore accents and diacritics when performing searches (`unaccent`).
The system MUST search across the `nombre`, `descripcion`, and `codigo` fields of the product, as well as the `nombre` field of the associated `categoria`.

#### Scenario: User searches with typos
- GIVEN a product exists with the name "Destornillador"
- WHEN the user searches for "destornillador" (without accents)
- THEN the product "Destornillador" MUST appear in the results.
- WHEN the user searches for "destorniyador" (typo)
- THEN the product "Destornillador" SHOULD appear in the results if the trigram similarity meets the threshold.

#### Scenario: Search combines multiple fields
- GIVEN a product exists with description "Herramienta manual" and category "Ferretería"
- WHEN the user searches for "herramienta ferreteria"
- THEN the product MUST be returned in the search results.