# Beta Test Plan - Scientific CalcR Pro

This test plan defines the objectives, scopes, and validation checklists for the Scientific CalcR Pro public beta testing.

---

## 1. Beta Objectives
*   Verify UI rendering scaling across various Android screen sizes and densities (targeting Redmi Note 9 as a baseline).
*   Assess real-world battery impact during prolonged graphing sessions.
*   Confirm QuickJS CAS stability and memory limits (<100MB RAM).
*   Identify any UX confusion around the Shift/Alpha keyboard combinations.

---

## 2. Beta Scope & User Segments
*   **Segment A (High School Students):** Focus on algebra, basic trigonometry, and logarithms.
*   **Segment B (STEM University Students):** Focus on matrices, complex numbers, numerical calculus, and CAS.
*   **Segment C (Engineers & Researchers):** Focus on large vectors, unit converter, formula vault, and multi-function graphing.

---

## 3. Test Cases & Verification Checklist

### Phase 1: Basic Arithmetic & UX
*   [ ] Input standard expressions using brackets, verify 2D textbook rendering.
*   [ ] Test long-pressing **DEL** clears the display.
*   [ ] Test cursor movement (arrow keys) and inserting/deleting inside fractions and powers.
*   [ ] Test **Undo** and **Redo** buttons with at least 10 inputs.

### Phase 2: Scientific & CAS Operations
*   [ ] Enter CAS mode and run `simplify((x^2 - 1)/(x - 1))`, verify it yields `1+x`.
*   [ ] Run `factor(x^2 - 5x + 6)`, verify it yields `(-2+x)*(-3+x)`.
*   [ ] Compute derivatives: `diff(x^3, x)`.
*   [ ] Solve algebraic system: `solve(x^2 - 4 = 0, x)`.

### Phase 3: Graphing Engine
*   [ ] Plot $y = \sin(x)$ and $y = \cos(x)$ simultaneously.
*   [ ] Verify smooth 60 FPS panning and pinch-to-zoom.
*   [ ] Long press on the graph to open the Trace tooltip; move the cursor and verify coordinate values update.
*   [ ] Verify dashed vertical asymptotes are plotted for $y = \tan(x)$ at $\pm \frac{\pi}{2}$.

### Phase 4: Non-functional verification
*   [ ] Check app memory in Android Developer settings, ensure memory usage is consistently < 100 MB.
*   [ ] Verify the app operates without an active internet connection.
*   [ ] Toggle **Exam Mode** and verify history lists are locked and converters locked.
