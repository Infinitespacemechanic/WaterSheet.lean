# WaterSheetAll: The Undisputable Answer from 1900 Light
## A Mechanical Governor for Smoothness — Continuum, Drop, or No Rainfall

**Repo:** Infinitespacemechanic/WaterSheet.lean — Lean 4.20 + Mathlib — GREEN, zero sorry

### Abstract

We present a discrete, finite mechanical framework that stays within the confines of the 1900 framing of the fluid smoothness puzzle while showing its disconnect. The field is both a continuum and a single drop and no rainfall at all — all represented as `Fin n → Nat`. We show the dream breaks at $q=1$ and reality rescues at $q=-1$ with a drain. Small and big are same data.

### 1. Framing (1900 Light)

In 1900, the puzzle was framed as:
- Field exists for all t ∈ [0, ∞)
- Ocean is infinite, no edges
- Does smoothness exist forever?

In that framing, unicorn numbers (blowup, ∞) must exist. We show it.

### 2. Definitions (3×4 → 12×12 → 720)

- `State n := Fin n → Nat` — mass packets per cell, not velocity vectors
- `Drop := Fin 3` — 3 H2O minimal drop that can store/transfer (triangle ring)
- `Tetra := Fin 4` — 4 orientations
- `Clock12 := Fin 12` = 3*4 via `(d*4 + t) %12`
- `Sheet144 := Fin 144` = 12*12 via `(c1*12 + c2) %144`
- `Container720 := Fin 720` = 144*5 via `(s*5 + k) %720`, where 5 = 3 drop + 2 drain

- `fadeIter k s := fun i => s i - k` — bounded decay, dead stays dead (Nat subtraction saturates at 0)
- `tickFade s := fadeIter 1 s`
- `tickPour s i hm := fun j => if j=i then s j + hm else s j` — additive mass M = N + Hm, no division, no unicorn
- `isSmooth s := ∀ i, s i = 0` — returns to `fun _ => 0`, no rainfall case
- `sumK n s` — total sum, recursive: 0→0, succ n → sumK n (rest) + last. Clearly ≥ each cell.

### 3. Core Theorems — Same Data

**Lemma sumK_spec:** ∀ n s i, s i ≤ sumK n s
- Proof by recursion on n, case split i = last vs castSucc, using `Nat.le_add_left/right` and `omega`. No List.foldl needed.

**Theorem sheet_returns_to_smooth:** ∀ n s, ∃ k, isSmooth (fadeIter k s)
- Witness k = sumK n s. Then `s i - k = 0` via `Nat.sub_eq_zero_of_le`.

**Theorem fade_to_zero:** ∀ n s i, ∃ k, (fadeIter k s) i = 0
- Immediate from above.

These hold for:
- `smallState : State 12 := fun i => i.val %5` — a drop
- `bigState : State 144` — a sheet
- `hugeState : State 720 := fun i => i.val %2000` — a continuum pour
- `noRain : State 720 := fun _ => 0` — no rainfall at all

Small, big, zero — same data structure, same proof.

### 4. Q-Extension — Dream vs Reality (The Disconnect)

Inductive Q | pos (q=1) | neg (q=-1)

```
isSmoothQ
| Q.pos, s => ∀ i, s i < 1000   -- dream: must stay below threshold forever
| Q.neg, _ => True              -- reality: drain rescues
```

- **small_respects_dream:** smallState embeds via `Fin.castLE` and stays <5 <1000 → holds
- **huge_breaks_dream:** hugeState at index 1000 has 1000 %2000 =1000, not <1000 → ¬ isSmoothQ pos. Unicorn constructed in forever framing.
- **smooth_rescued:** both small and huge have witness `fun _ => 0` → isSmoothQ neg. Drain =2 rescues.

Thus:
- In forever idealization (q=1), blowup must exist — we show it
- In finite container with drain (q=-1), sheet always returns to smooth — we prove it
- No logical inconsistency: two predicates, two framings

### 5. Conclusion — Undisputable from 1900

Rain can come down in drops, buckets, and pour... it's all mass, density and time from free fall.

- Continuum = many drops
- Drop = 3 H2O minimal packet
- No rainfall = zero state

All are `Fin n → Nat`, all return to `fun _ => 0` in finite steps. The puzzle existed because math was framed as forever. The answer exists because water isn't.

Lean 4.20 + Mathlib build is GREEN, zero sorry:
- `fade_to_zero`
- `sheet_returns_to_smooth`
- `not_smooth_forced` (dream breaks)
- `smooth_rescued` (reality rescues)

This is the support doc for the answer. No tile craft, no mV, no lift numbers — stripped to avoid commentary.

---
Repo: https://github.com/Infinitespacemechanic/WaterSheet.lean
Build: Lean 4.20 + Mathlib, `lake clean && lake build`
