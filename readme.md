# WaterSheet

Rain can come down in drops, buckets, and pour... it's all mass, density and time from the free fall.

## Chassis

* mass, gravity, time - constant, never varied
* speed = free fall, not a Nat
* only density = hits per area varies
* same *kind* of mass on every square: `Sheet := Clock → Nat`

## The Pan

`Clock := Fin 720` - 720-face ruler
`sheetLeftover c : 0..3` - threes live here
    - `densityStack` + `spinFromAngle`
    - `0` = empty, `3` = torn / borrowed surface

## Four Operations

1. **Time** - `tickFade s = fun c => s c - 1`
   Rain stopped, vortex ages. `0-1=0`. Dead stays dead.
   Water lives here.

2. **Local hit** - `tickHitLocal s c`
   One drop, sprinkle, hand in bucket.
   Same free-fall speed, only leftover pattern differs.

3. **Pour** - `tickPour s = fun c => s c + sheetLeftover c`
   Drops no longer drops. Sheet of almost continuous rain.
   Mass from fall creates big area directly under where mass fell.

4. **Soap flag** - `needsSoap c = sheetLeftover c == 3`
   Borrowed surface to hold torn surface.
   Aeration in waterfall, bubble in pan. Only a flag.

## What it proves

```lean
fade_to_zero : ∀ s c, ∃ n, (iterate tickFade n s) c = 0
sheet_returns_to_smooth : ∀ s, ∃ N, iterate tickFade N s = fun _ => 0
