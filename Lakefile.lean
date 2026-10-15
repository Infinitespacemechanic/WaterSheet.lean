import Lake
open Lake DSL

package WaterSheet where
  --

lean_lib WaterSheet where
  roots := #[`WaterSheet, `WaterSheetQ]
  srcDir := "."

@[default_target]
lean_exe watersheet where
  root := `Main
