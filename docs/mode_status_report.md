# Mode Status Report

The following is an audit of all mode buttons available on the Scientific CalcR Pro Casio keyboard, detailing their status and functionality:

- **MATRIX**: Functional. Configured on the `4` key via `SHIFT`. Taps trigger `CalculatorMode.matrix` via the Riverpod provider state.
- **VECTOR**: Functional. Configured on the `5` key via `SHIFT`. Taps trigger `CalculatorMode.vector` via the Riverpod provider state.
- **STAT**: Functional. Configured on the `6` key via `SHIFT`. Taps trigger `CalculatorMode.statistics` via the Riverpod provider state.
- **CMPLX**: Functional. Configured on the `2` key via `SHIFT`. Taps trigger `CalculatorMode.complex` via the Riverpod provider state.
- **BASE**: Functional. Configured on the `3` key via `SHIFT`. Taps trigger `CalculatorMode.baseN` via the Riverpod provider state.
- **EQUATION**: Functional. Configured on the `(` key via `SHIFT`. Taps trigger `CalculatorMode.equation` via the Riverpod provider state.
- **GRAPH**: Functional. Configured on the `)` key via `SHIFT`. Taps trigger navigation to the dedicated `GraphScreen`.
- **CAS**: Functional. Configured on the `S⇔D` key via `SHIFT`. Taps trigger `CalculatorMode.cas` via the Riverpod provider state.
- **CONST**: Functional. Configured on the `7` key via `SHIFT`. Taps trigger navigation to the `ConstantsScreen`.
- **CONV**: Functional. Configured on the `8` key via `SHIFT`. Taps trigger navigation to the `UnitConverterScreen`.

All mode switches correctly interface with `CalculatorNotifier` state or perform navigator pushes where appropriate. No mode buttons remain non-functional.
