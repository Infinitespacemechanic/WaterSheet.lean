# VORTEX_FROM_EXIT.md

## Definition

Old: tickPour = add 1428, tickFade = -1 to 0, tickSpill = move ≤2 to neighbors.

New:

```
structure VortexCell where
  mass : Nat   -- H_m at hand
  spin : Nat   -- circulation / charge
  from : Nat   -- rain, pour, ions
  exit : Nat   -- Q = 2, pipe diameter / wire

def tickVortex (c : VortexCell) : VortexCell :=
  -- add from, add spin, subtract exit Q, saturate at 0
```

Same proofs: sumK bounds, returns to 0.

## Mapping

- Ditch: From = 4-8" rain sheet, Vortex = drain eye, Exit = 90 ft culvert
- Tray: From = pour, Vortex = churn, Exit = lip spill
- Cell: From = metal giving ions, Vortex = charge on glass, Exit = wire to meter
- Tile V5: From = 5 lb salt water, Vortex = dual coils 1200 RPM, Exit = thrust / voltage

BandCycle: inlet 3, drain 2, net bounded iff k ≥ 3 fade ticks per pour.
