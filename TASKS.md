# Task Execution Rules
* Tasks must be atomic
* Tasks must be completed one at a time
* Each task must have explicit validation
* Do not proceed to the next task until the current one passes validation
* If a task is blocked, mark it blocked and state why
* If the task sequence must change, update TASKS.md deliberately

## Task Status Legend
* NOT STARTED
* IN PROGRESS
* BLOCKED
* COMPLETE

==================================================
Task ID         T01
Title           Create project entry point and directory structure
Status          NOT STARTED
Objective       Establish the repo layout and a runnable entry point
                that accepts CLI arguments matching SPEC inputs.
Inputs
* SPEC.md (input definitions)
Output
* led_solver.py       - main entry point
* curves/             - empty directory placeholder for curve data
* tests/              - empty directory for test fixtures
* requirements.txt    - pinned dependency list
Implementation Notes
* Use argparse for all inputs defined in SPEC.md
* Do not implement any calculation logic in this task
* Entry point should parse args and print them back to stdout to confirm
* requirements.txt must include: numpy, scipy
Validation
* Method: CLI run
* Input: python led_solver.py --part_id test --IF_input 350
         --T_ambient 25 --Rth_jc 5 --Rth_cb 1 --Rth_ba 10
         --curve_data_dir ./curves
* Expected Result: parsed arguments printed to stdout, no exceptions
Done Criteria
* led_solver.py exists and is runnable
* All seven CLI arguments are accepted without error
* requirements.txt exists with numpy and scipy listed
* curves/ and tests/ directories exist
Notes
* None

==================================================
Task ID         T02
Title           Implement curve loader
Status          NOT STARTED
Objective       Load and validate all required JSON curve files for a
                given part_id from curve_data_dir.
Inputs
* SPEC.md (curve JSON schema)
* curves/<part_id>/ directory with required JSON files
Output
* curves.py module with load_curves(part_id, curve_data_dir) function
  returning a dict of named curve arrays
Implementation Notes
* Required files are exactly those listed in SPEC.md
* Raise FileNotFoundError with the missing filename if any file is absent
* Raise ValueError if any JSON file fails schema validation
* Return a dict with keys matching the JSON filenames (without extension)
* Parse all x/y arrays into numpy arrays at load time
Validation
* Method: unit test with fixture data
* Input: fixture directory tests/fixture_part/ with all required JSON files
* Expected Result: load_curves returns dict with all 9 expected keys,
  all values are numpy arrays, no exceptions
Done Criteria
* load_curves() returns correct structure for valid fixture data
* Missing file raises FileNotFoundError naming the missing file
* Malformed JSON raises ValueError
* No calculation logic in this module
Notes
* Create tests/fixture_part/ with minimal valid JSON fixture files
  as part of this task

==================================================
Task ID         T03
Title           Implement input validation
Status          NOT STARTED
Objective       Validate all CLI inputs against SPEC constraints before
                any calculation begins.
Inputs
* SPEC.md (input constraints section)
* Parsed argparse namespace from T01
Output
* validation.py module with validate_inputs(args) function
  raising ValueError with a descriptive message on any violation
Implementation Notes
* Check every constraint listed in SPEC.md input constraints section
* Raise ValueError with the parameter name and violated constraint
* Do not access curve files in this module
* Validation must be callable independently of the rest of the solver
Validation
* Method: unit test
* Input: IF_input = -5 (out of range)
* Expected Result: ValueError raised mentioning IF_input
* Input: T_ambient = 200 (out of range)
* Expected Result: ValueError raised mentioning T_ambient
* Input: all valid values
* Expected Result: no exception
Done Criteria
* All seven SPEC input constraints enforced
* Each violation raises ValueError with clear message
* Valid inputs produce no exception
Notes
* None

==================================================
Task ID         T04
Title           Implement 1D curve interpolation utility
Status          NOT STARTED
Objective       Provide a single reusable interpolation function used
                by all subsequent calculation tasks.
Inputs
* SPEC.md (NFR7 interpolation requirement)
Output
* interp.py module with interpolate(x_data, y_data, x_query) function
  returning (y_value, extrapolated_flag)
Implementation Notes
* Use scipy.interpolate.interp1d with bounds_error=False,
  fill_value=nan
* extrapolated_flag is True if x_query is outside [min(x_data), max(x_data)]
* If y_value is NaN (fill_value triggered), raise ValueError
* Function must handle both scalar y and per-row 2-element y (for chroma)
* Keep this function pure: no file I/O, no global state
Validation
* Method: unit test with known values
* Input: x=[0,1,2], y=[0,10,20], query=1.0
* Expected Result: (10.0, False)
* Input: x=[0,1,2], y=[0,10,20], query=2.5
* Expected Result: raises ValueError (out of range)
* Input: x=[0,1,2], y=[0,10,20], query=-0.5
* Expected Result: raises ValueError (out of range)
Done Criteria
* Correct interpolation for in-range query
* extrapolated_flag correctly set when query is near but inside boundary
* ValueError raised for out-of-range query
* Pure function with no side effects
Notes
* This is the only interpolation path in the project

==================================================
Task ID         T05
Title           Implement VF interpolation at IF_input
Status          NOT STARTED
Objective       Compute forward voltage at the input drive current
                using the IF-vs-VF curve.
Inputs
* interp.py (T04)
* curves dict from T02, key: if_vf
* IF_input (float, mA)
Output
* Function get_vf(IF_input, curves) returning (VF, extrapolated_flag)
  added to a new module: electrical.py
Implementation Notes
* Call interpolate() from interp.py; do not re-implement interpolation
* Return raw VF in volts; do not apply temperature corrections here
* Temperature correction is a separate task (T07)
Validation
* Method: unit test with fixture curve
* Input: fixture if_vf curve, IF_input = value at known x point
* Expected Result: VF matches fixture y value within 0.001 V
Done Criteria
* Function returns correct VF for fixture data
* Extrapolation flag is passed through
* No temperature logic in this function
Notes
* None

==================================================
Task ID         T06
Title           Implement iterative thermal solve
Status          NOT STARTED
Objective       Solve for junction temperature iteratively using
                the thermal stack and power dissipation.
Inputs
* electrical.py get_vf() from T05
* interp.py (T04)
* curves dict key: vf_vs_tj
* IF_input, T_ambient, Rth_jc, Rth_cb, Rth_ba
Output
* Function solve_tj(IF_input, T_ambient, Rth_jc, Rth_cb, Rth_ba, curves)
  returning (Tj_converged, VF_final, P_diss, warnings)
  added to thermal.py
Implementation Notes
* Rth_total = Rth_jc + Rth_cb + Rth_ba
* Initial guess: Tj_0 = T_ambient
* Each iteration:
    1. Get VF at current Tj using vf_vs_tj correction applied to VF at IF
    2. P_diss = IF_input/1000 * VF
    3. Tj_new = T_ambient + P_diss * Rth_total
    4. Check convergence: abs(Tj_new - Tj_old) < 0.01
* Raise RuntimeError if not converged after 100 iterations
* Collect extrapolation warnings from each interp call
* vf_vs_tj curve is relative; multiply base VF by relative value
Validation
* Method: deterministic reference case (VC1 from SPEC)
* Input: Rth_jc=0, Rth_cb=0, Rth_ba=0, T_ambient=25, IF_input=350
* Expected Result: Tj_converged == 25.0 (within 0.01)
Done Criteria
* Flat thermal stack produces Tj == T_ambient
* Convergence error raised if loop exceeds 100 iterations
* Warnings list contains extrapolation messages when applicable
* P_diss is computed from final converged VF and IF_input
Notes
* None

==================================================
Task ID         T07
Title           Implement optical output calculations
Status          NOT STARTED
Objective       Compute relative luminous flux at the solved operating
                point using both IF and Tj correction curves.
Inputs
* interp.py (T04)
* curves dict keys: flux_vs_if, flux_vs_tj
* IF_input (mA)
* Tj_converged from T06
Output
* Function get_flux(IF_input, Tj_converged, curves) returning
  (flux_relative, warnings) added to optical.py
Implementation Notes
* flux_vs_if gives relative flux at IF, normalized at reference IF
* flux_vs_tj gives relative flux at Tj, normalized at reference Tj
* Combined: flux_relative = flux_vs_if(IF) * flux_vs_tj(Tj)
* Reference condition normalization is per reference.json
* Collect and return all extrapolation warnings
Validation
* Method: unit test at reference condition (VC2 from SPEC)
* Input: IF_input = IF_ref from reference.json, Tj = Tj_ref from reference.json
* Expected Result: flux_relative == 1.0 within 0.001
Done Criteria
* Returns 1.0 at reference condition
* Extrapolation warnings passed through
* No thermal or electrical logic in this module
Notes
* None

==================================================
Task ID         T08
Title           Implement derating check
Status          NOT STARTED
Objective       Look up the maximum allowable forward current at
                T_ambient and compute margin against IF_input.
Inputs
* interp.py (T04)
* curves dict key: derating
* IF_input (mA)
* T_ambient (degC)
Output
* Function get_derating(IF_input, T_ambient, curves) returning
  (IF_max_derated, margin_current, derate_extrapolated)
  added to electrical.py
Implementation Notes
* IF_max_derated = interpolate derating curve at T_ambient
* margin_current = IF_max_derated - IF_input
* derate_extrapolated = True if T_ambient was outside curve range
Validation
* Method: unit test (VC3 from SPEC)
* Input: IF_input above IF_max_derated for a given T_ambient
* Expected Result: margin_current is negative
Done Criteria
* Correct IF_max_derated returned for fixture data
* Negative margin correctly computed when IF_input exceeds limit
* Extrapolation flag returned correctly
Notes
* None

==================================================
Task ID         T09
Title           Implement chromaticity shift calculation
Status          NOT STARTED
Objective       Compute the operating chromaticity coordinate by
                applying IF and Tj shifts to the nominal bin center.
Inputs
* interp.py (T04)
* curves dict keys: chroma_shift_if, chroma_shift_tj, reference
* IF_input (mA)
* Tj_converged (degC)
Output
* Function get_chromaticity(IF_input, Tj_converged, curves) returning
  (cx, cy, warnings) added to color.py
Implementation Notes
* cx = cx0 + delta_cx_IF(IF_input) + delta_cx_Tj(Tj_converged)
* cy = cy0 + delta_cy_IF(IF_input) + delta_cy_Tj(Tj_converged)
* cx0, cy0 from reference.json
* chroma_shift_if and chroma_shift_tj have 2-element y vectors [dcx, dcy]
* Collect and return extrapolation warnings
Validation
* Method: unit test at reference condition
* Input: IF_input = IF_ref, Tj = Tj_ref, both shift curves return [0,0]
* Expected Result: cx == cx0, cy == cy0
Done Criteria
* Returns nominal coordinates at reference condition with zero shifts
* Extrapolation warnings passed through
* No thermal or electrical logic in this module
Notes
* None

==================================================
Task ID         T10
Title           Implement color bin check
Status          NOT STARTED
Objective       Determine whether the computed (cx, cy) coordinate
                falls within the part bin boundary polygon.
Inputs
* color.py (T09)
* curves dict key: bin_boundary
* cx, cy from T09
Output
* Function check_bin(cx, cy, curves) returning in_color_bin (bool)
  added to color.py
Implementation Notes
* Use matplotlib.path.Path or shapely for point-in-polygon test
* Prefer matplotlib.path.Path to avoid adding shapely as a dependency
* Boundary is a closed polygon; the last vertex connects to the first
* A point exactly on the boundary is treated as inside (in_color_bin=True)
Validation
* Method: unit test (VC5 from SPEC)
* Input: point known to be outside fixture polygon
* Expected Result: in_color_bin = False
* Input: point known to be inside fixture polygon
* Expected Result: in_color_bin = True
Done Criteria
* Inside point returns True
* Outside point returns False
* No interpolation or calculation logic in this function
Notes
* matplotlib is acceptable as a dependency for Path; add to requirements.txt
  if not already present

==================================================
Task ID         T11
Title           Implement status and warning aggregation
Status          NOT STARTED
Objective       Collect all outputs and warnings from prior modules,
                determine PASS/FAIL status, and assemble the result dict.
Inputs
* All prior calculation modules (T05 through T10)
* reference.json data (Tj_max)
Output
* Function assemble_result(inputs, Tj, VF, P_diss, flux,
  cx, cy, IF_max_derated, margin, in_bin, all_warnings) returning
  result dict matching SPEC output fields
  added to report.py
Implementation Notes
* status = PASS if all conditions true:
    - Tj_converged < Tj_max_degC
    - margin_current >= 0
    - in_color_bin == True
    - warnings list is empty
* Round all float outputs to 4 significant figures
* Do not suppress any warnings
* Include all input values in the result dict for traceability
Validation
* Method: unit test
* Input: all passing conditions
* Expected Result: status = "PASS", warnings = []
* Input: Tj > Tj_max
* Expected Result: status = "FAIL"
Done Criteria
* PASS only when all four conditions are met
* FAIL when any condition is violated
* Warnings list is never None; always a list (empty or populated)
Notes
* None

==================================================
Task ID         T12
Title           Implement JSON output file writer
Status          NOT STARTED
Objective       Write the result dict to a JSON file with the
                filename format specified in SPEC.md.
Inputs
* report.py assemble_result() output (T11)
* part_id, IF_input, T_ambient (for filename)
Output
* Function write_result_json(result, part_id, IF_input, T_ambient,
  output_dir) writing JSON file to output_dir
  added to report.py
Implementation Notes
* Filename: <part_id>_<IF_input>mA_<T_ambient>C_result.json
* Use json.dump with indent=2
* Create output_dir if it does not exist
* Raise IOError if write fails
Validation
* Method: deterministic file check
* Input: fixture result dict, known part_id, IF_input, T_ambient
* Expected Result: file created with correct filename, valid JSON,
  contents match input dict
Done Criteria
* File created at correct path
* File content is valid JSON matching input dict
* Output directory created if absent
Notes
* None

==================================================
Task ID         T13
Title           Integrate all modules into led_solver.py
Status          NOT STARTED
Objective       Wire all modules into the main entry point so a
                single CLI invocation runs the full solve pipeline.
Inputs
* All prior modules (T01 through T12)
Output
* Updated led_solver.py that:
    1. Parses CLI args
    2. Validates inputs
    3. Loads curves
    4. Runs thermal solve
    5. Runs optical calculation
    6. Runs derating check
    7. Runs chromaticity calculation
    8. Runs bin check
    9. Assembles result
    10. Writes JSON output
    11. Prints human-readable summary to stdout
Implementation Notes
* Call each module function in the order above
* Collect all warnings across all calls into a single list
* Print summary table to stdout: one labeled row per SPEC output field
* Do not duplicate logic from any module
Validation
* Method: CLI end-to-end run with fixture data
* Input: fixture_part at reference condition (IF=IF_ref, T_ambient=25,
  flat thermal stack)
* Expected Result: status=PASS, flux_relative~=1.0, JSON file created
Done Criteria
* Single CLI invocation produces correct stdout output and JSON file
* All six SPEC validation criteria pass
* No module logic reimplemented in led_solver.py
Notes
* None

==================================================
Task ID         T14
Title           Write deterministic test suite
Status          NOT STARTED
Objective       Create a test script that runs all six SPEC validation
                criteria against fixture data and reports PASS/FAIL
                for each.
Inputs
* led_solver.py (T13)
* tests/fixture_part/ fixture data
Output
* tests/run_validation.py script that prints pass/fail for each VC
Implementation Notes
* Test each VC from SPEC.md independently
* Do not use pytest; use plain Python assert statements and try/except
* Print: "VC1: PASS" or "VC1: FAIL - <reason>" for each criterion
* Exit with code 0 if all pass, code 1 if any fail
* Do not mock; use real fixture JSON files
Validation
* Method: run tests/run_validation.py
* Expected Result: all six VC lines print PASS, exit code 0
Done Criteria
* All six validation criteria tested explicitly
* No test relies on mocking or patching
* Exit code is machine-checkable
Notes
* None

==================================================
Task ID         T15
Title           Write README.md
Status          NOT STARTED
Objective       Document how to install, run, and validate the tool.
Inputs
* SPEC.md
* led_solver.py (T13)
* tests/run_validation.py (T14)
Output
* README.md
Implementation Notes
* Include: purpose, requirements, file list, how to run, example CLI,
  how to add a new part (curve JSON files), how to validate
* Do not repeat SPEC.md verbatim; summarize for a working engineer
* Include the curve JSON schema and an example reference.json
Validation
* Method: manual review
* Expected Result: a new engineer can run the tool from README alone
Done Criteria
* All SPEC inputs described with units and ranges
* Example CLI command shown
* Validation instructions included
* Curve JSON format documented with example
Notes
* None
