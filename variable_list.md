# Variable list

Participant-level data are not included. The released scripts expect an
authorized compatible analytic dataset containing the following variables.

| Variable | Description | Final use |
|---|---|---|
| `grade_cat2` | Grade 2 or higher citrate toxicity (0/1) | Outcome |
| `combine3` | 0 Neither, 1 Either alone, 2 Concurrent | Categorical exposure |
| `i_ca_bin` | Minimum ionized calcium <=1.0 mmol/L | Group derivation |
| `i_k_bin` | Minimum ionized potassium <=3.0 mmol/L | Group derivation |
| `i_ca_min` | Minimum ionized calcium during apheresis, mmol/L | Continuous exposure |
| `i_k_min` | Minimum ionized potassium during apheresis, mmol/L | Continuous exposure |
| `age` | Age, years | Adjustment and Table 1 |
| `sex` | 0 female, 1 male | Adjustment and Table 1 |
| `tbv` | Total blood volume, mL | Adjustment and Table 1 |
| `height` | Height, cm | Table 1 |
| `weight` | Body weight, kg | Table 1 |
| `pre_cd34` | Pre-apheresis CD34+ count, /uL | Table 1 |
| `i_ca_pre` | Ionized calcium at the start of apheresis, mmol/L | Table 1 |
| `i_k_pre` | Ionized potassium at the start of apheresis, mmol/L | Table 1 |
| `tp` | Total protein, g/dL | Table 1 |
| `alb` | Albumin, g/dL | Table 1 |
| `flow_rate` | Maximum blood flow, mL/min | Table 2 |
| `inf_rate` | ACD-A infusion rate, mL/min | Table 2 |
| `time` | Processing time, min | Table 2 |
| `acd` | Total ACD-A volume, mL | Table 2 |
| `proc_vol` | Processed blood volume, mL | Table 2 |
| `gluconate` | Calcium gluconate administered, mg | Table 2 |

The public Stata import and cleaning scripts also refer to source-column names
needed to create these analysis variables. The source data remain private.
