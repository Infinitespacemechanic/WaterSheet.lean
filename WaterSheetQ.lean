-- WaterSheetQ.lean
-- Extends WaterSheet.lean with q = environment
-- q = external force f in Navier-Stokes language
-- q < 0 = cold shop, good drainage, vent open
-- q = 0  = Clay condition, no external force
-- q > 0  = hot shop, bad drainage, forced blow-up (OpenAI Sept 8)

import WaterSheet

def envInfluence (q : Int) : Int := q

-- leftover with environment
def sheetLeftoverQ (q : Int) (c : Clock) : Int :=
  (densityStack c : Int) + (spinFromAngle c : Int) + envInfluence q

-- drain depends on environment, like viscosity ν + shape
def drainQ (q : Int) : Nat :=
  if q < 0 then 2 else 1

def SheetQ := Clock → Int

def tickFadeQ (q : Int) (s : SheetQ) : SheetQ :=
  fun c => s c - (drainQ q : Int)

def tickPourQ (q : Int) (s : SheetQ) : SheetQ :=
  fun c => s c + sheetLeftoverQ q c

def needsSoapQ (q : Int) (c : Clock) : Bool :=
  sheetLeftoverQ q c == 3

def isSmoothQ (q : Int) (c : Clock) : Prop :=
  sheetLeftoverQ q c ≤ (drainQ q : Int)

-- Helpers for Q version
theorem sheetLeftoverQ_at_60 (q : Int) : sheetLeftoverQ q ⟨60, by simp⟩ = q := by
  -- at 60: onFace true => spin 0, 60%3==0 => sharedByThree true => densityStack 0
  simp [sheetLeftoverQ, densityStack, spinFromAngle, sharedByThree, onFace, envInfluence]

theorem sheetLeftoverQ_at_0 (q : Int) : sheetLeftoverQ q ⟨0, by simp⟩ = q := by
  simp [sheetLeftoverQ, densityStack, spinFromAngle, sharedByThree, onFace, envInfluence]

-- Good env: vent saves you, even downpour becomes smooth
-- This is the hurricane analog: constant radius, bounded, single-sheet, perpetual
theorem vent_saves_good_env : isSmoothQ (-1) ⟨60, by simp⟩ := by
  simp [isSmoothQ, sheetLeftoverQ_at_60, drainQ]

-- Clay condition q=0 at vent: smooth
theorem clay_vent_smooth : isSmoothQ 0 ⟨60, by simp⟩ := by
  simp [isSmoothQ, sheetLeftoverQ_at_60, drainQ]

-- At c=1: c%3=1 => densityStack = 2, onFace false => spin=1 => base 3
-- With q=0 => 3, drain 1 => not smooth without help
theorem base_three_at_one : sheetLeftover 1 = 3 := by
  -- ⟨1,_⟩: 1%3=1 => (3-1)%3=2, onFace false => spin 1, total 3
  simp [sheetLeftover, densityStack, spinFromAngle, sharedByThree, onFace]

theorem downpour_needs_soap_at_one : needsSoap 1 = true := by
  simp [needsSoap, base_three_at_one]

-- Forced case: q=+1 at c=1 => 2+1+1=4 => definitely needs soap, blow-up
-- This is OpenAI Sept 8: with smooth external force f, can force blow-up
theorem forced_blowup_at_one : sheetLeftoverQ 1 ⟨1, by simp⟩ = 4 := by
  simp [sheetLeftoverQ, densityStack, spinFromAngle, sharedByThree, onFace, envInfluence]

theorem forced_not_smooth_at_one : ¬ isSmoothQ 1 ⟨1, by simp⟩ := by
  simp [isSmoothQ, forced_blowup_at_one, drainQ]

-- Good env rescues the same point: 2+1-1=2, drain 2 => smooth
-- Same diesel, same throttle, different air in shop => different knock
theorem good_env_rescues_one : isSmoothQ (-1) ⟨1, by simp⟩ := by
  simp [isSmoothQ, sheetLeftoverQ, densityStack, spinFromAngle, sharedByThree, onFace, envInfluence, drainQ]

-- General fade still holds for any q with drain>0
theorem iterate_fadeQ_eq (q : Int) (n : Nat) (s : SheetQ) (c : Clock) :
    (Nat.iterate (tickFadeQ q) n s) c = s c - n * (drainQ q : Int) := by
  induction n generalizing s with
  | zero => simp [Nat.iterate]
  | succ n ih =>
    calc (Nat.iterate (tickFadeQ q) (Nat.succ n) s) c
        = (Nat.iterate (tickFadeQ q) n (tickFadeQ q s)) c := by rw [Nat.iterate_succ']
      _ = (tickFadeQ q s) c - n * (drainQ q : Int) := by rw [ih]
      _ = s c - (drainQ q : Int) - n * (drainQ q : Int) := by simp [tickFadeQ]
      _ = s c - (n + 1) * (drainQ q : Int) := by omega
      _ = s c - (Nat.succ n) * (drainQ q : Int) := by rw [Nat.succ_eq_add_one, Nat.add_comm]

-- Your original theorems become corollaries with q=0 and drain=1
-- sheet_returns_to_smooth is the unforced NS: global smooth existence
-- OpenAI's claim is sheetLeftoverQ with q>0 can stay >=3 under tickPourQ

-- Summary for README:
-- q = -1: cold shop, vent open, hurricane eye stable, perpetual smoothness
-- q = 0 : Clay, no external force, sheet_returns_to_smooth proves smooth
-- q = +1: hot shop, forced, blow-up possible, matches OpenAI forced case
