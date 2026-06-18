# Changelog - Scientific CalcR Pro

All notable changes to **Scientific CalcR Pro** are documented here.

## [1.0.0-beta.1] - 2026-06-16

### Added (Phase 2)
*   **Symbolic CAS Engine:** Full offline integration of Nerdamer inside a background isolate. Supports `simplify`, `factor`, `diff`, `integrate`, and `solve` commands.
*   **Interactive Cursor:** 2D textbook display support with a blinking cursor, allowing you to edit nested fractions, exponents, and square roots.
*   **Undo & Redo:** Complete undo/redo stack support for editing mathematical expressions.
*   **Touch Sizing Polish:** Keypad buttons optimized to meet the minimum 48dp touch target guidelines for enhanced accessibility.
*   **Insert from History:** Direct integration on the History screen to tap any entry and insert it at the cursor position.
*   **Long-Press DEL:** Long-pressing the delete key now clears the entire input expression.

### Added (Phase 1)
*   **Complex Numbers & Simultaneous Solvers:** Support for simultaneous equations (up to 4 variables) and high-degree polynomials (quadratic, cubic, quartic).
*   **Matrix & Vector Engines:** Matrix arithmetic, transpositions, determinants, and ranks up to 4x4.
*   **Numerical Calculus:** Centered-difference derivatives and Simpson-based integrations.
*   **Theme Engine:** Curated themes including Light, Dark, OLED Black, Retro LCD, ClassWiz Blue, and ES Plus Gray.
*   **SQLite Storage:** Offline history logging and unit converter configurations.
