---
description: "Use when implementing, changing, testing, or explaining Azul gameplay rules, turns, scoring, or game flow."
applyTo:
  - "azul/**/*.as"
  - "azul/**/*.asc"
  - "azul/**/*.asm"
  - "_libraries/**/*.as"
  - "_libraries/**/*.asc"
  - "_libraries/**/*.asm"
---

# Azul gameplay rules

- The project's authoritative rules source is [`azul/Azul Rules NL.pdf`](../../azul/Azul%20Rules%20NL.pdf). Read and follow it before implementing or changing gameplay rules. The document is in Dutch; translate the relevant passages as needed rather than relying on memory or assumptions.
- Implement the standard base game described in that PDF. Do not introduce expansions, house rules, or alternate interpretations unless the user requests them.
- `azul/` contains the game itself, and `_libraries/` contains shared libraries. Other folders are sample projects and experiments; do not use them as sources of Azul game rules or architecture.
- In `azul/`, `azul.as` is the main game entry point; `azulShow.as` is the loading splash screen. The numbered `azul*.asc` files are game components called from the main entry. Preserve their responsibilities and call order when changing game flow.
- When a requested change depends on a rule, identify the relevant PDF page or section in your reasoning or response. Summarize the rule in your own words; do not reproduce lengthy passages.
- If the PDF is ambiguous, incomplete, or appears inconsistent with the requested behavior, explain the uncertainty and ask the user before choosing a rule variant. Use online sources only to clarify unresolved details, and distinguish those sources from the project's rule authority.
- Before changing a mechanic, inspect the existing Azul game flow and related code so the implementation remains consistent across turns, rounds, scoring, and game end.
- When practical, validate rule behavior with focused tests or concrete examples, especially for edge cases. Do not claim a rule is implemented or validated unless the code and checks support that claim.
