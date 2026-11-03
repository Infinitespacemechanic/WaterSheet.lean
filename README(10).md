# WaterSheet v2: Solve with the drain in the frame, then show this is reality

**Core idea:** Same mass, nothing free.

Old model: Pour + Fade + Spill — counted mass, no direction.
New model: From + Vortex + Exit — same mass, natural.

- **From** = sheet catchment (rain, tray pour, ions)
- **Vortex** = air-core that holds open (ditch drain, red tray churn, coil)
- **Exit** = 90 ft south culvert, tray lip, wire to meter, drain Q=2

Finite state: `State n := Fin n -> Nat`, `sumK n s` bounds everything, `fadeIter (sumK n s) s = fun _ => 0` — returns to smooth when mass at hand is gone.

**Theorems (Lean, zero sorry):**
- `sheet_returns_to_smooth` via `sumK`
- `bandCycle_bounded_iff k ≥ 3`
- `twenty_gap_bounded`
- `spill_bounded_two`

No infinite ocean. Reality has a drain.

## Figures (video/photo witnesses)

1. Ditch vortex — River Park, FL, 4-8" rain, high tide, road underwater, exit 90 ft south. Flow AND backup, same drain.
2. Red tray sheet — bounded container, spill at lip.
3. Displacement — hand puts anode in, water moves.
4. Power — 0.5 V dry, 0.846 V wet on dual-pane hurricane glass. Large positive tower is cathode.

All plumbing: sink, toilet, culvert, propellant tank, 12x12x6" tile (15 lb = 5 lb water + 10 lb hardware, 30-42 lb lift).

Mass at hand, nothing free. P = ρ g Q H or V*I from ions, countable.

