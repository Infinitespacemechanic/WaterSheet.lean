-- WaterSheetQ.lean
-- Extends WaterSheet.lean with q = environment
-- q = external force f in Navier-Stokes language
-- q < 0 = cold shop, good drainage, vent open
-- q = 0 = Clay condition, no external force
-- q > 0 = hot shop, bad drainage, forced blow-up (OpenAI Sept 8)
-- Update: q acts on teardrop container, not on abstract point

import WaterSheet

def envInfluence (q : Int) : Int := q -- shop air on teardrop skin

-- leftover with environment: mass + twist + air
-- mass = densityStack (0..2), twist = spinFromAngle (0..1) from friction in fall
def sheetLeftoverQ (q : Int) (c : Clock) : Int :=
  (containerOf c).mass + (containerOf c).spin + envInfluence q

-- drain depends on environment, like viscosity ν + shape + vent
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
  simp [sheetLeftoverQ, containerOf, densityStack, spinFromAngle, sharedByThree, onFace, envInfluence]

theorem sheetLeftoverQ_at_0 (q : Int) : sheetLeftoverQ q ⟨0, by simp⟩ = q := by
  simp [sheetLeftoverQ, containerOf, densityStack, spinFromAngle, sharedByThree, onFace, envInfluence]

theorem vent_saves_good_env : isSmoothQ (-1) ⟨60, by simp⟩ := by
  simp [isSmoothQ, sheetLeftoverQ_at_60, drainQ]

theorem clay_vent_smooth : isSmoothQ 0 ⟨60, by simp⟩ := by
  simp [isSmoothQ, sheetLeftoverQ_at_60, drainQ]

theorem base_three_at_one : sheetLeftover 1 = 3 := by
  simp [sheetLeftover, containerOf, densityStack, spinFromAngle, sharedByThree, onFace]

theorem downpour_needs_soap_at_one : needsSoap 1 = true := by
  simp [needsSoap, base_three_at_one]

theorem forced_blowup_at_one : sheetLeftoverQ 1 ⟨1, by simp⟩ = 4 := by
  simp [sheetLeftoverQ, containerOf, densityStack, spinFromAngle, sharedByThree, onFace, envInfluence]

theorem forced_not_smooth_at_one : ¬ isSmoothQ 1 ⟨1, by simp⟩ := by
  simp [isSmoothQ, forced_blowup_at_one, drainQ]

theorem good_env_rescues_one : isSmoothQ (-1) ⟨1, by simp⟩ := by
  simp [isSmoothQ, sheetLeftoverQ, containerOf, densityStack, spinFromAngle, sharedByThree, onFace, envInfluence, drainQ]

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

-- === Neighbor spill: teardrop twist transfers to quiet water ===
def tickSpillQ (q : Int) (s : SheetQ) (c : Clock) : SheetQ :=
  fun x => if x ∈ neighbor c then s x + (containerOf c).spin + envInfluence q
           else if x == c then s x + (containerOf c).mass
           else s x
