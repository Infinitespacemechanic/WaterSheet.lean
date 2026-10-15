import Lake
open Lake DSL

package WaterSheet where
  --

@[default_target]
lean_lib WaterSheet where
  roots := #[`WaterSheet, `WaterSheetQ]

@[default_target]
lean_exe watersheet where
  root := `Main
