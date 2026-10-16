-- WaterSheet.lean
-- Views: pan, sprinkle, pouring, waterfall, hand in bucket, aeration
-- Chassis: mass, gravity, time. Speed = free fall, constant, not a Nat.
-- Only density = hits per area varies.
-- Update: every drop is a teardrop container with twist from friction in fall.

def Clock := Fin 720 -- 720-face ruler, per square inch container lattice

-- Geometry of the ruler
def onFace (c : Clock) : Bool := c.val % 60 == 0 -- onFace = two metals aligned
def sharedByThree (c : Clock) : Bool := c.val % 3 == 0

-- === Container as teardrop ===
-- Mass inside container
def densityStack (c : Clock) : Nat := if sharedByThree c then 0 else (3 - c.val % 3) % 3 -- 0..2

-- Twist inside container: angular momentum from free-fall friction
-- onFace = no extra twist (odd duck flag), off-face = 1 twist
-- Every drop has this, friction on skin → torque
def spinFromAngle (c : Clock) : Nat := if onFace c then 0 else 1 -- 0..1 twist

-- Real container: teardrop, not sphere. Mass + twist
structure Container where
  mass : Nat -- densityStack
  spin : Nat -- angular momentum from fall
deriving DecidableEq, Repr

def containerOf (c : Clock) : Container where
  mass := densityStack c
  spin := spinFromAngle c

-- Mass-energy from mass in nature: leftover = mass + spin, threes live here, 0..3
-- 0.5mm smallest raindrop (spillway), 9.7mm largest verified Oklahoma 2012, breaks above ~10mm
-- Same kind of mass on every square: bounded packet, water jet cuts steel at speed
def sheetLeftover (c : Clock) : Nat :=
  (containerOf c).mass + (containerOf c).spin -- 0..3, still bounded

-- Same kind of mass on every square: Sheet is Clock → Nat
-- The write is still sheetLeftover c = 0..3. If you want drop itself same mass, add 1 in hit and keep leftover only for soap/spin.
def Sheet := Clock → Nat

-- Combining IS size — no extra size param
-- 1 drop = drop, many drops combined = bucket / pour
-- Size emergent from addition, still bounded by maxVal * n, still fades to smooth
def combinedMass (cells : List Clock) (s : Sheet) : Nat :=
  cells.foldl (fun acc c => acc + s c) 0

-- Time: rain stopped, vortex ages. 0-1=0, dead stays dead. Water lives here.
def tickFade (s : Sheet) : Sheet := fun c => s c - 1

-- Local hit: one teardrop drop, same free-fall speed, only leftover pattern differs
-- Hand in bucket, single raindrop, sprinkle — mass-energy + twist focused at tip
def tickHitLocal (s : Sheet) (c : Clock) : Sheet :=
  fun x => if x == c then s x + sheetLeftover x else s x

-- Pouring: drops no longer drops, sheet of almost continuous rain
-- Mass from fall creates big area directly under where mass fell
-- Many teardrops combining = pour, same twist adds, cuts like waterjet
def tickPour (s : Sheet) : Sheet :=
  fun c => s c + sheetLeftover c

-- Borrowed surface: leftover-3 wants a bag to hold torn surface
-- Aeration in waterfall, bubble in pan, teardrop needs soap film to hold 3
def needsSoap (c : Clock) : Bool := sheetLeftover c == 3

-- Helpers — broken math → ∞, exact measurement → maxVal finite, fades to 0
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
-- === Neighbor spill: teardrop twist transfers to quiet water ===
-- 0.5mm spillway, mass-energy + angular momentum moves to next container
-- This is how vortex eye forms, tornado locks, waterjet cuts a line

def neighbor (c : Clock) : List Clock :=
  [⟨(c.val + 1) % 720, by simp⟩, ⟨(c.val + 719) % 720, by simp; omega⟩]

def tickSpill (s : Sheet) (c : Clock) : Sheet :=
  fun x => if x ∈ neighbor c then s x + (containerOf c).spin else if x == c then s x + (containerOf c).mass else s x
-- mass stays in hit cell, spin (twist from friction) spills 0.5mm to neighbors
-- single drop -> rotation in quiet water, many combined -> eyewall jet

-- Spill still bounded: mass 0..2 + spin 0..1 = 0..3 per cell, fade still works
theorem spill_bounded (s : Sheet) (c x : Clock) : tickSpill s c x ≤ s x + 3 := by
  simp [tickSpill, containerOf, densityStack, spinFromAngle]
  omega
