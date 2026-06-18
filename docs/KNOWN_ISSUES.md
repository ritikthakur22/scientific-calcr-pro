# Known Issues - Scientific CalcR Pro v1.0.0-beta.1

Below is the list of identified minor issues in **Scientific CalcR Pro** that do not affect core calculator accuracy or usability but will be addressed in future releases:

1.  **First CAS Latency (QuickJS Warm-Up):** The very first symbolic calculation in a session takes ~150–200 ms to compile and initialize the QuickJS engine inside the background isolate. Subsequent evaluations take <10 ms.
2.  **Lexicographical Term Order in CAS:** Nerdamer outputs factored polynomials in algebraic lexicographical order (e.g. `(-2+x)*(-3+x)` instead of standard `(x-2)*(x-3)`). The mathematical values are 100% correct, but the output order may vary from textbooks.
3.  **Landscape Layout in Keyboard:** On extremely small devices (width < 320dp) in landscape mode, the keycaps might compress slightly. Scrolling the display or utilizing tablet mode is recommended.
4.  **Implicit Log Base Warning:** Writing a single-parameter logarithm like `log(x)` currently resolves as log base 10 by default in the parser preprocessing. To use custom bases, type `log(base, x)` (e.g. `log(2, 8)`).
