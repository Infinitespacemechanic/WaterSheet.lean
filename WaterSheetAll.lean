-- WaterSheetAll.lean - merged for lean4web MathlibDemo
-- Paste this whole file into MathlibDemo.lean

def Clock := Fin 720
def onFace (c : Clock) : Bool := c.val % 60 == 0
def sharedByThree (c : Clock) : Bool := c.val % 3 == 0
def densityStack (c : Clock) : Nat := if sharedByThree c then 0 else (3 - c.val % 3) % 3
def spinFromAngle (c : Clock) : Nat := if onFace c then 0 else 1
def sheetLeftover (c : Clock) : Nat := densityStack c + spinFromAngle c
def Sheet := Clock → Nat
def tickFade (s : Sheet) : Sheet := fun c => s c - 1
def tickHitLocal (s : Sheet) (c : Clock) : Sheet := fun x => if x == c then s x + sheetLeftover x else s x
def tickPour (s : Sheet) : Sheet := fun c => s c + sheetLeftover c
def needsSoap (c : Clock) : Bool := sheetLeftover c == 3

theorem iterate_fade_eq (n : Nat) (s : Sheet) (c : Clock) : (Nat.iterate tickFade n s) c = s c - n := by
  induction n generalizing s with
  | zero => simp [Nat.iterate]
  | succ n ih => calc _ = (Nat.iterate tickFade n (tickFade s)) c := by rw [Nat.iterate_succ']
      _ = _ := by simp [ih, tickFade, Nat.sub_sub]; omega

theorem fade_to_zero (s : Sheet) (c : Clock) : ∃ n, (Nat.iterate tickFade n s) c = 0 := by
  use s c; rw [iterate_fade_eq]; simp

def allClocks : List Clock := List.finRange 720
def maxGo (s : Sheet) : List Clock → Nat → Nat
  | [], acc => acc
  | c :: cs, acc => maxGo s cs (Nat.max acc (s c))
def maxVal (s : Sheet) : Nat := maxGo s allClocks 0

theorem maxGo_mono (s : Sheet) (l : List Clock) (acc : Nat) : acc ≤ maxGo s l acc := by
  induction l generalizing acc with | nil => simp [maxGo] | cons hd tl ih => simp [maxGo]; exact Nat.le_trans (Nat.le_max_left _ _) (ih _)

theorem maxGo_ge_of_mem (s : Sheet) (l : List Clock) (acc : Nat) (c : Clock) (hmem : c ∈ l) : s c ≤ maxGo s l acc := by
  induction l generalizing acc with
  | nil => simp at hmem
  | cons hd tl ih => simp [maxGo]; by_cases heq : c = hd
    · subst heq; exact Nat.le_trans (Nat.le_max_right _ _) (maxGo_mono s tl _)
    · exact ih _ (by simp [heq] at hmem; exact hmem)

theorem le_maxVal (s : Sheet) (c : Clock) : s c ≤ maxVal s := by
  unfold maxVal; exact maxGo_ge_of_mem s allClocks 0 c (by simp [allClocks, List.mem_finRange])

theorem sheet_returns_to_smooth (s : Sheet) : ∃ N, (Nat.iterate tickFade N s) = fun _ => 0 := by
  use maxVal s; funext c; rw [iterate_fade_eq]; have h := le_maxVal s c; omega

-- Q extension
def envInfluence (q : Int) : Int := q
def sheetLeftoverQ (q : Int) (c : Clock) : Int := (densityStack c : Int) + (spinFromAngle c : Int) + envInfluence q
def drainQ (q : Int) : Nat := if q < 0 then 2 else 1
def SheetQ := Clock → Int
def tickFadeQ (q : Int) (s : SheetQ) : SheetQ := fun c => s c - (drainQ q : Int)
def tickPourQ (q : Int) (s : SheetQ) : SheetQ := fun c => s c + sheetLeftoverQ q c
def needsSoapQ (q : Int) (c : Clock) : Bool := sheetLeftoverQ q c == 3
def isSmoothQ (q : Int) (c : Clock) : Prop := sheetLeftoverQ q c ≤ (drainQ q : Int)

theorem sheetLeftoverQ_at_60 (q : Int) : sheetLeftoverQ q ⟨60, by simp⟩ = q := by simp [sheetLeftoverQ, densityStack, spinFromAngle, sharedByThree, onFace, envInfluence]
theorem forced_blowup_at_one : sheetLeftoverQ 1 ⟨1, by simp⟩ = 4 := by simp [sheetLeftoverQ, densityStack, spinFromAngle, sharedByThree, onFace, envInfluence]
theorem forced_not_smooth_at_one : ¬ isSmoothQ 1 ⟨1, by simp⟩ := by simp [isSmoothQ, forced_blowup_at_one, drainQ]
theorem good_env_rescues_one : isSmoothQ (-1) ⟨1, by simp⟩ := by simp [isSmoothQ, sheetLeftoverQ, densityStack, spinFromAngle, sharedByThree, onFace, envInfluence, drainQ]
theorem vent_saves_good_env : isSmoothQ (-1) ⟨60, by simp⟩ := by simp [isSmoothQ, sheetLeftoverQ_at_60, drainQ]
theorem clay_vent_smooth : isSmoothQ 0 ⟨60, by simp⟩ := by simp [isSmoothQ, sheetLeftoverQ_at_60, drainQ]
