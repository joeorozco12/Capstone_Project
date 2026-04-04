# Project Name
LED Operating Point Solver - Automotive White LED

## Purpose
Given a set of drive conditions and a thermal stack, compute the
steady-state operating point for an automotive white LED and check
whether that point is within allowable electrical, thermal, optical,
and color limits.

## Problem Statement
Engineers currently read digitized curves manually in Mathcad or by
eye from datasheets. The iterative thermal solve (IF -> Tj -> derate
-> re-check) is done manually and is error-prone. There is no
deterministic, repeatable record of the design margin check.

## Users
Electrical engineers designing LED drive circuits for exterior
automotive lighting.

## Primary Use Case
Engineer inputs a drive current, ambient temperature, and thermal
stack. Tool solves for junction temperature, derated allowable
current, relative flux, color coordinates, and reports margin
against all limits. MATLAB generates all plots from tool outputs.

## Inputs
* IF_input         Forward current setpoint (mA)
* T_ambient        Ambient temperature (degC)
* Rth_jc           Junction-to-case thermal resistance (degC/W)
* Rth_cb           Case-to-board thermal resistance (degC/W)
* Rth_ba           Board-to-ambient thermal resistance (degC/W)
* part_id          String identifier selecting which curve set to load
* curve_data_dir   Path to directory containing digitized curve JSON files

## Input Constraints
* IF_input:    1 to 1000 mA, float, required
* T_ambient:   -40 to 125 degC, float, required
* Rth_jc:      0.1 to 50 degC/W, float, required
* Rth_cb:      0 to 20 degC/W, float, required
* Rth_ba:      0 to 50 degC/W, float, required
* part_id:     non-empty string matching a subdirectory in curve_data_dir
* curve_data_dir: valid directory path containing expected JSON files

## Outputs
* Tj_solved          Junction temperature at converged operating point (degC)
* VF_at_Tj           Forward voltage corrected for Tj (V)
* P_diss             Power dissipated at operating point (W)
* flux_relative      Relative luminous flux normalized to reference condition
* cx_at_point        CIE x chromaticity coordinate at operating point
* cy_at_point        CIE y chromaticity coordinate at operating point
* IF_max_derated     Maximum allowable forward current at T_ambient (mA)
* margin_current     IF_max_derated minus IF_input (mA)
* in_color_bin       Boolean: True if (cx, cy) is within part bin boundaries
* warnings           List of warning strings (empty list if none)
* status             "PASS" or "FAIL"

## Output Requirements
* All float outputs rounded to 4 significant figures
* status is PASS only if: Tj < Tj_max, IF_input <= IF_max_derated,
  in_color_bin is True, and warnings list is empty
* Output written to both stdout (human-readable) and a JSON file
* JSON filename: <part_id>_<IF_input>mA_<T_ambient>C_result.json
* Warnings must be emitted whenever extrapolation occurs

## Functional Requirements
* FR1: Load digitized curve data from JSON files for the specified part
* FR2: Interpolate VF from IF-vs-VF curve at IF_input
* FR3: Solve Tj iteratively using thermal stack and P_diss until convergence
        (convergence criterion: delta_Tj < 0.01 degC between iterations,
        max 100 iterations)
* FR4: Apply Tj correction to VF using relative-VF-vs-Tj curve
* FR5: Apply Tj correction to relative flux using flux-vs-Tj curve
* FR6: Apply IF correction to relative flux using flux-vs-IF curve
* FR7: Look up maximum derated current at T_ambient from derating curve
* FR8: Look up chromaticity shift at IF_input and Tj from shift curves
* FR9: Check (cx, cy) against part bin polygon boundary
* FR10: Emit warnings for any extrapolation beyond curve data range
* FR11: Write JSON output file
* FR12: Print human-readable summary to stdout

## Non-Functional Requirements
* NFR1: Python only (3.9 or later)
* NFR2: No GUI
* NFR3: Deterministic outputs for identical inputs
* NFR4: Headless execution
* NFR5: Dependencies limited to: numpy, scipy, json, pathlib, argparse
* NFR6: Thermal solve must converge or raise a clear RuntimeError
* NFR7: All interpolation uses scipy.interpolate.interp1d with
        bounds_error=False and fill_value=None (NaN on out-of-range)
        so extrapolation is detectable and flagged, not silently applied

## Out of Scope
* PDF datasheet parsing or automatic curve digitization
* GUI or interactive plotting (MATLAB handles all plots)
* Multi-LED string or array calculations
* Transient or pulsed thermal analysis
* Reliability or lumen maintenance lifetime projection
* Automatic bin selection or binning optimization

## Dependencies
* Python 3.9+
* numpy
* scipy
* Digitized curve JSON files (produced externally via WebPlotDigitizer)

## Curve JSON File Schema
Each curve is a separate JSON file in curve_data_dir/<part_id>/.
Required files per part:
  if_vf.json            - IF (mA) vs VF (V)
  flux_vs_if.json       - IF (mA) vs relative flux (normalized)
  flux_vs_tj.json       - Tj (degC) vs relative flux (normalized)
  vf_vs_tj.json         - Tj (degC) vs relative VF (normalized)
  derating.json         - T_ambient (degC) vs IF_max (mA)
  chroma_shift_if.json  - IF (mA) vs [delta_cx, delta_cy]
  chroma_shift_tj.json  - Tj (degC) vs [delta_cx, delta_cy]
  bin_boundary.json     - ordered list of [x, y] polygon vertices (CIE 1931)
  reference.json        - reference conditions and nominal cx0, cy0

JSON Format for 1D curves (x vs scalar y):
  { "x": [x0, x1, ...], "y": [y0, y1, ...] }

JSON Format for 1D curves (x vs [y1, y2]):
  { "x": [x0, x1, ...], "y": [[y0a, y0b], [y1a, y1b], ...] }

JSON Format for bin_boundary:
  { "vertices": [[x0,y0], [x1,y1], ..., [xN,yN]] }

JSON Format for reference.json:
  {
    "IF_ref_mA": 350,
    "Tj_ref_degC": 25,
    "cx0": 0.3000,
    "cy0": 0.3200,
    "Tj_max_degC": 150
  }

## Validation Criteria
* VC1: With a flat thermal stack (Rth_total = 0), Tj must equal T_ambient
* VC2: At reference IF and Tj=25degC, relative flux must equal 1.0
* VC3: Derating check: IF_input above IF_max_derated must produce FAIL
* VC4: Known VF interpolation: at IF=350mA on a fixture curve,
        VF must match hand-calculated value within 0.001V
* VC5: Chromaticity outside bin polygon must produce in_color_bin=False
* VC6: Extrapolation beyond curve range must produce a warning in output

## Acceptance Criteria
* All six validation criteria pass against fixture data
* JSON output file is produced for every successful run
* FAIL status is never silently suppressed
* Warnings list is never silently suppressed

## Open Questions
* None at project start. Flag any that arise during implementation.
