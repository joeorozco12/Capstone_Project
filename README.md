# Project Name
LED Operating Point Solver - Automotive White LED

## Purpose
Computes the steady-state operating point for an automotive white LED
given drive current, ambient temperature, and thermal stack. Reports
junction temperature, flux, chromaticity, derating margin, and
PASS/FAIL status. MATLAB consumes the JSON output to generate plots.

## Requirements
* Python 3.9 or later
* numpy
* scipy
* matplotlib (for bin boundary check only)

Install dependencies:

```bash
pip install -r requirements.txt
```

## Files
* led_solver.py          Main entry point
* curves.py              Curve loader
* validation.py          Input validation
* interp.py              Interpolation utility
* electrical.py          VF and derating functions
* thermal.py             Iterative thermal solve
* optical.py             Flux calculation
* color.py               Chromaticity and bin check
* report.py              Result assembly and JSON output
* requirements.txt       Pinned dependencies
* curves/                Curve data directory (one subdir per part)
* tests/                 Fixture data and validation script
* SPEC.md                Full requirements
* TASKS.md               Build task list
* AGENTS.md              Agent operating rules
* PROCESS_LOG.md         Build log
* LESSONS_LEARNED.md     Reusable lessons

## How to Run
```bash
python led_solver.py \
  --part_id NVSW119BT \
  --IF_input 350 \
  --T_ambient 85 \
  --Rth_jc 5.0 \
  --Rth_cb 1.0 \
  --Rth_ba 12.0 \
  --curve_data_dir ./curves
```

## How to Add a New Part
1. Create directory: curves/<part_id>/
2. Add all required JSON files (see Curve JSON Schema below)
3. Run validation suite to confirm curves load correctly

## Curve JSON Schema
All curves digitized via WebPlotDigitizer and saved as JSON.

1D scalar curve (e.g. if_vf.json):

```json
{ "x": [100, 200, 350, 500], "y": [2.85, 2.95, 3.10, 3.22] }
```

1D vector curve (e.g. chroma_shift_if.json):

```json
{ "x": [100, 350, 700], "y": [[0.001, -0.002], [0.0, 0.0], [-0.003, 0.004]] }
```

Bin boundary (bin_boundary.json):

```json
{ "vertices": [[0.290, 0.280], [0.320, 0.280], [0.320, 0.340], [0.290, 0.340]] }
```

Reference conditions (reference.json):

```json
{
  "IF_ref_mA": 350,
  "Tj_ref_degC": 25,
  "cx0": 0.3000,
  "cy0": 0.3200,
  "Tj_max_degC": 150
}
```

## How to Validate
```bash
python tests/run_validation.py
```

Expected output:

```text
VC1: PASS
VC2: PASS
VC3: PASS
VC4: PASS
VC5: PASS
VC6: PASS
All validation criteria passed.
```

## Known Constraints
* Extrapolation beyond curve data range is not silently applied;
  a warning is emitted and status is set to FAIL
* Pulsed/transient thermal analysis is out of scope
* Multi-LED string analysis is out of scope
* Curve digitization is performed externally (WebPlotDigitizer)
* MATLAB generates all plots from the JSON output file

## Project Workflow
1. Read QUICKSTART.md
2. Read AGENTS.md
3. Read SPEC.md
4. Execute TASKS.md one task at a time
5. Validate each task before proceeding
