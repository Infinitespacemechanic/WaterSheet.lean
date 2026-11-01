import Mathlib

def State (n : Nat) := Fin n → Nat

def fadeIter {n : Nat} (k : Nat) (s : State n) : State n :=
  fun i => s i - k

def isSmooth {n : Nat} (s : State n) : Prop := ∀ i, s i = 0

def sumK : (n : Nat) → State n → Nat
| 0, _ => 0
| Nat.succ n, s => sumK n (fun i => s (Fin.castSucc i)) + s (Fin.last n)

def sumK_spec : ∀ (n : Nat) (s : State n) (i : Fin n), s i ≤ sumK n s
| 0, _, i => Fin.elim0 i
| Nat.succ n, s, i => by
  by_cases h : i.val = n
  · have heq : i = Fin.last n := Fin.ext h
    rw [heq]
    unfold sumK
    exact Nat.le_add_left _ _
  · have hi_lt : i.val < n := by omega
    let j : Fin n := ⟨i.val, hi_lt⟩
    have hij : Fin.castSucc j = i := by ext; rfl
    calc
      s i = (fun k => s (Fin.castSucc k)) j := by rw [← hij]; rfl
      _ ≤ sumK n (fun k => s (Fin.castSucc k)) := sumK_spec n _ j
      _ ≤ sumK n (fun k => s (Fin.castSucc k)) + s (Fin.last n) := Nat.le_add_right _ _

theorem sheet_returns_to_smooth {n : Nat} (s : State n) :
  ∃ k, isSmooth (fadeIter k s) := by
  use sumK n s
  intro i
  unfold fadeIter
  exact Nat.sub_eq_zero_of_le (sumK_spec n s i)

-- === DISCONNECT TEST: small and big are same data ===

-- Small: 12 = 3*4 clock
def smallState : State 12 := fun i => i.val % 5  -- small pour, max 4

-- Big: 144 = 12*12 sheet
def bigState : State 144 := fun i => i.val % 50  -- bigger pour, max 49

-- Huge: 720 = 144*5 container
def hugeState : State 720 := fun i => i.val % 2000  -- heavy downpour, crosses 1000 threshold

-- Same theorem, different size - small data proof
theorem small_returns : ∃ k, isSmooth (fadeIter k smallState) :=
  sheet_returns_to_smooth smallState

theorem big_returns : ∃ k, isSmooth (fadeIter k bigState) :=
  sheet_returns_to_smooth bigState

theorem huge_returns : ∃ k, isSmooth (fadeIter k hugeState) :=
  sheet_returns_to_smooth hugeState

-- Concrete witnesses
#eval sumK 12 smallState  -- should be ≤ 12*4 = 48
#eval sumK 144 bigState   -- ≤ 144*49
#eval sumK 720 hugeState  -- finite, even for heavy pour

-- Q-extension: framing test
inductive Q : Type | pos : Q | neg : Q

def isSmoothQ : Q -> State 720 -> Prop
| Q.pos, s => ∀ i, s i < 1000  -- dream: must stay <1000 forever
| Q.neg, _ => True             -- reality: drain rescues

-- Small data respects dream threshold
theorem small_respects_dream : isSmoothQ Q.pos (fun i => smallState (Fin.castLE (by decide) i) : State 720) := by
  intro i
  unfold isSmoothQ
  -- smallState max 4 < 1000
  have : smallState (Fin.castLE (by decide) i) < 5 := by
    unfold smallState
    have : (Fin.castLE (by decide) i).val % 5 < 5 := Nat.mod_lt _ (by decide)
    exact this
  omega

-- Big data breaks dream, same data structure
theorem huge_breaks_dream : ¬ isSmoothQ Q.pos hugeState := by
  intro h
  have h0 : hugeState ⟨1000, by decide⟩ < 1000 := h ⟨1000, by decide⟩
  unfold hugeState at h0
  have : (1000 : Nat) % 2000 = 1000 := by decide
  omega

-- But reality rescues both: same drain logic
theorem huge_rescued : isSmoothQ Q.neg hugeState := trivial
theorem small_rescued : isSmoothQ Q.neg (fun _ => smallState ⟨0, by decide⟩ : State 720) := trivial

-- The disconnect: framing
-- In puzzle framing (forever, infinite ocean), you ask: does small stay smooth and does big stay smooth forever?
-- Answer: small does (isSmoothQ pos), big doesn't (¬ isSmoothQ pos) - so dream says blowup exists
-- In real framing (finite container, drain, return to zero), both small and big return to smooth - same data, same proof

#check small_returns
#check big_returns
#check huge_returns
#check small_respects_dream
#check huge_breaks_dream
