-- WaterSheetStray.lean
-- Locks stray math: Pi/3 throttling constant, residual, clock 12, refusal floor, bubble detector, mass at hand
-- Theory shared, construction (how to throttle Pi/3, tile build, reductions) reserved
-- Paper abstraction inside UPT/ZRT/HRT chassis, mass never true zero, holds at 1 until exact

namespace WaterSheetStray

def pi_div_three : Float := 3.1415926535 / 3.0
def residual_pi3 : Float := pi_div_three - 1.0

def holds_at_one (n : Nat) : Nat :=
  if n = 0 then 1 else n

theorem holds_at_one_ge_one (n : Nat) : holds_at_one n ≥ 1 := by
  unfold holds_at_one
  cases n with
  | zero =>
    exact Nat.le_refl 1
  | succ m =>
    exact Nat.succ_le_succ (Nat.zero_le m)

def fade_saturates_at_one (n m : Nat) : Nat :=
  if m ≥ n then 1 else n - m

def Clock12 := Fin 12
def clock_positions : List Nat := [1, 3, 6, 9, 12]
def clock_residual_paid_every_tick : Float := residual_pi3
def tick_1s_per_s : Nat := 1

def Bubble := Fin 5
def bubble_detector : Bubble → Nat := fun _ => 1

theorem bubble_detector_ge_one (b : Bubble) : bubble_detector b ≥ 1 := by
  unfold bubble_detector
  exact Nat.le_refl 1

def bubble_count : Nat := 5

def mass_at_hand (N Hm : Nat) : Nat := N + Hm

theorem mass_at_hand_monotone (N Hm : Nat) : mass_at_hand N Hm ≥ N := by
  unfold mass_at_hand
  exact Nat.le_add_right N Hm

def slope_gives_length : Nat := 90
def culvert_size_caps_Q : Nat := 8
def power_from_moving_mass (rho g Q H : Nat) : Nat := rho * g * Q * H

def no_resistance_is_fastest : Prop := True

def State (n : Nat) := Fin n → Nat
def sumK_bound (n : Nat) (_s : State n) : Nat := n + 1

def fadeIter : Nat → {n : Nat} → State n → State n
| 0, _, s => s
| Nat.succ k, _, s => fadeIter k (fun i => if s i = 0 then 0 else s i - 1)

end WaterSheetStray
