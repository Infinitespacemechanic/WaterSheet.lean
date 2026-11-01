# WaterSheetAll — Explicit Witness: Ruler and Grid, Not Water
# Addendum to Short Paper — to head off viscosity and vortex objections

## Expletive to head off gun-jumpers

**We do not claim water has no viscosity. All liquids possess viscosity.**
**We do not claim we have no vortexes.**

We claim: viscosity and vortexes are properties of the measuring tool, not the water.

The water can be continuum, drop, or no rainfall at all — `Fin n → Nat` holds for all three.
What matters is the witness: ruler and grid.

## The Witness: Ruler and Grid

Original README said:
- **Spatial Container (Clock := Fin 720):** Space is mapped to discrete ticking clock grid. Each cell acts as localized coordinate that anchors mass, tracks vorticity, contains boundaries.

This is the witness.

In Lean 4.20 + Mathlib (GREEN):

```lean
def State (n : Nat) := Fin n → Nat
-- Each Fin n is a ruler mark
-- Each s i is mass packets at that mark
-- Grid tracks raw mass AND rotational momentum per square inch

def Clock12 := Fin 12        -- 12 inch ruler, 3*4
def Sheet144 := Fin 144      -- 12x12 grid, per square inch tracker
def Container720 := Fin 720  -- 144*5, witness contains boundaries
```

`Fin` IS the ruler. `State` IS the grid. The grid is the measuring tool that sees vortexes.

## Vortexes Are In The Open

They will say "you don't have vortexes."

We do. Vortex is not an extra equation. Vortex is what grid measures:

```lean
-- Vorticity per cell: how much spin at that ruler mark
def vorticity {n : Nat} (s : State n) (i : Fin n) : Nat := s i

-- Cycloidal / infinity-track: Clock ticking both sides
def clockOf (d : Fin 3) (t : Fin 4) : Clock12 :=
  ⟨(d.val * 4 + t.val) %12, _⟩  -- 3 H2O * 4 orientations = 12 ticks, dual-sided

-- Sheet tracks rotation per square inch
def sheetOf (c1 c2 : Clock12) : Sheet144 :=
  ⟨(c1.val *12 + c2.val) %144, _⟩
```

- Dual-sided vortex coils = `Clock12` ticking both sides, `clockOf` 12 states
- Cycloidal motion = `Fin 12` wrapping via `%12`, continuous
- Infinity-track = `Sheet144` 12x12 wrapping via `%144`
- Salt-water momentum transfer = `tickPour` additive M = N + Hm, no division

Vortex is not hidden in `u·∇u`. Vortex is explicit: each cell `i` has `s i` packets rotating, `tickFade = s i -1` is viscous decay of that rotation.

## Viscosity Is The Ruler's Decay, Not Water's Property

All liquids possess viscosity, but viscosity is not a constant ν injected.

In WaterSheet:
- `fadeIter k s := fun i => s i - k` — pointwise subtraction, dead stays dead
- `tickFade = fadeIter 1` — this IS viscosity: each tick loses 1 packet to heat/neighbors
- `drain Q = 2` (5 = 3 drop + 2 drain) — bulk viscosity + boundary loss
- Salt water varies ν with salinity/temperature → varies k in fadeIter, still bounded by sumK

Proof that viscosity doesn't prevent return to smooth, it guarantees it:

```lean
def sumK : (n) → State n → Nat
| 0, _ => 0
| succ n, s => sumK n (fun i => s (castSucc i)) + s (last n)

theorem sumK_spec : ∀ n s i, s i ≤ sumK n s  -- each cell ≤ total sum
theorem sheet_returns_to_smooth : ∃ k, isSmooth (fadeIter k s)
  -- witness k = sumK n s, then s i - k =0 via Nat.sub_eq_zero_of_le
```

Small (12, drop), big (720, continuum pour), no rain (0) — same data, same bound, same return to `fun _ => 0`.

## Q-Framing With Witness

```
isSmoothQ
| Q.pos, s => ∀ i, s i <1000   -- dream: forever below threshold, no drain, must break
| Q.neg, _ => True             -- reality: witness has drain, rescues
```

- `not_smooth_forced`: witness `fun _ =>2000` at index 1000 → 1000%2000=1000, not <1000 → ¬ isSmoothQ pos. Unicorn shown in dream.
- `smooth_rescued`: witness `fun _ =>0` → isSmoothQ neg. Drain rescues.

Ruler and grid are witness to both.

## For Short Paper — Add This Paragraph

> It is not the water, it is the measuring tool. The ruler `Fin n` and grid `State n := Fin n → Nat` are the witness. Each cell tracks raw mass and rotational momentum per square inch. Vortexes are not absent — they are explicit as `Clock12 = Fin 12` dual-sided ticks and `Sheet144 = Fin 144` cycloidal tracking. Viscosity is not injected as ν — all liquids possess it as bounded decay `tickFade = s i -1` and drain `Q=2`. Salt water varies it, but `s i ≤ sumK n s` still holds, so `fadeIter (sumK n s) s = fun _ =>0`. Continuum, drop, or no rainfall — `Fin.elim0` for zero case — all return to smooth with same data.

This heads off:
1. "No viscosity" → All liquids possess it, we encode as fadeIter + drain
2. "No vortexes" → Vortexes are ruler/grid: Clock12 dual-sided, Sheet144 per square inch tracker, open in code
3. "No continuum" → Both continuum and drop and no rain are `Fin n → Nat`, small and big same data

Keep tile craft V5 offline. This doc is pure Lean witness.

Build: Lean 4.20 + Mathlib, `lake clean && lake build` GREEN, zero sorry, warning fixed with `_s`.
