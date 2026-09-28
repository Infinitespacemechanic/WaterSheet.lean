-- WaterSheet.lean
-- Views: pan, sprinkle, pouring, waterfall, hand in bucket, aeration
-- Chassis: mass, gravity, time. Speed = free fall, constant, not a Nat.
-- Only density = hits per area varies.

def Clock := Fin 720 -- 720-face ruler

def onFace (c : Clock) : Bool := c.val % 60 == 0
def sharedByThree (c : Clock) : Bool := c.val % 3 == 0
def densityStack (c : Clock) : Nat := if sharedByThree c then 0 else (3 - c.val % 3) % 3
def spinFromAngle (c : Clock) : Nat := if onFace c then 0 else 1
def sheetLeftover (c : Clock) : Nat := densityStack c + spinFromAngle c -- threes live here, 0..3

-- Same kind of mass on every square: Sheet is Clock → Nat
-- The write is still sheetLeftover c = 0..3. If you want drop itself same mass, add 1 in hit and keep leftover only for soap/spin.
def Sheet := Clock → Nat

-- Time: rain stopped, vortex ages. 0-1=0, dead stays dead. Water lives here.
def tickFade (s : Sheet) : Sheet := fun c => s c - 1

-- Local hit: one drop, same free-fall speed, only leftover pattern differs
-- Hand in bucket, single raindrop, sprinkle
def tickHitLocal (s : Sheet) (c : Clock) : Sheet :=
  fun x => if x == c then s x + sheetLeftover x else s x

-- Pouring: drops no longer drops, sheet of almost continuous rain
-- Mass from fall creates big area directly under where mass fell
def tickPour (s : Sheet) : Sheet :=
  fun c => s c + sheetLeftover c

-- Borrowed surface: leftover-3 wants a bag to hold torn surface
-- Aeration in waterfall, bubble in pan
def needsSoap (c : Clock) : Bool := sheetLeftover c == 3

-- Helpers
theorem iterate_fade_eq (n : Nat) (s : Sheet) (c : Clock) :
    (Nat.iterate tickFade n s) c = s c - n := by
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

theorem maxGo_ge_of_mem (s : Sheet) (l : List Clock) (acc : Nat) (c : Clock)
    (hmem : c ∈ l) : s c ≤ maxGo s l acc := by
  induction l generalizing acc with
  | nil => simp at hmem
  | cons hd tl ih => simp [maxGo]; by_cases heq : c = hd
    · subst heq; exact Nat.le_trans (Nat.le_max_right _ _) (maxGo_mono s tl _)
    · exact ih _ (by simp [heq] at hmem; exact hmem)

theorem le_maxVal (s : Sheet) (c : Clock) : s c ≤ maxVal s := by
  unfold maxVal; exact maxGo_ge_of_mem s allClocks 0 c (by simp [allClocks, List.mem_finRange])

theorem sheet_returns_to_smooth (s : Sheet) : ∃ N, (Nat.iterate tickFade N s) = fun _ => 0 := by
  use maxVal s; funext c; rw [iterate_fade_eq]; have h := le_maxVal s c; omega
