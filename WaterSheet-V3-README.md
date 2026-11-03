# WaterSheet v2: One vortex made by water from free fall following the slope to the sea

**Core:** Same mass, nothing free. Mass at hand.

Old: Pour + Fade + Spill — counted mass, no direction.
New: From + Vortex + Exit — same mass, natural.

- **From** = free fall (rain, tray pour, ions giving up)
- **Vortex** = hacks the infall (air-core that holds open, churn in tray, coil)
- **Exit** = 90 ft south culvert, tray lip, wire to meter — drain Q=2

## Slope gives us the length

Slope = stretchout length $L$ = 90 ft to exit that keeps air-core open. Finite $L$ bounds growth — same drain/fade accounting that forces return to zero in Lean: `State n := Fin n -> Nat`, `sumK n s` finite, `fadeIter (sumK n s) s = fun _ => 0`.

No slope, no vortex, no power.

## Vortex only exists when there is slope to drain

- Ditch empty now, river full — mass moved, not created.
- Vortex hacks the infall of mass: $m g H$ → $m v^2$ → $Q$ out. When water no longer in ditch, vortex gone.
- Puzzle = always full ditch, no tide effects — tests boundedness: `bandCycle_bounded_iff k ≥ 3`, `twenty_gap_bounded`, `spill_bounded_two`.
- Reality = 14" in 24h + full moon high tide = record, overtakes 8" pipe to a mile, road underwater. Same drain, flow AND backup.

Possible and impossible in same ditch. Possible = exit open, rescued. Impossible = exit blocked, floods.

## Figures — video/photo witnesses

1. **Ditch vortex** — River Park, FL — 4-8" then 14" in 24h, high tide + full moon, road underwater, exit 90 ft south, ditch empty now, river full. (media/vortex_ditch_displacement.mp4)
2. **Red tray sheet** — short depth sheet, bounded container, spill at lip. (media/rain_sheet_red_tray.mp4)
3. **Displacement** — hand puts anode in, water moves, gravel shifts. $M = N + H_m$.
4. **Power** — 0.5 V dry, 0.846 V wet on dual-pane hurricane glass, large positive tower = energy maker, metals giving up ions. (media/power_846.png)

All plumbing: sink, toilet, culvert, propellant tank, 12x12x6" tile (15 lb = 5 lb water + 10 lb hardware, 30-42 lb lift).

P = ρ g Q H or V*I from ions, countable. Short depth in sheet, 40 days and nights in one day when slope overtaken.

## Theorems (Lean, zero sorry)

- `sheet_returns_to_smooth` via `sumK`
- `bandCycle_bounded_iff k ≥ 3`
- `twenty_gap_bounded`
- `spill_bounded_two`

No infinite ocean. Reality has a drain and a slope that gives length.
