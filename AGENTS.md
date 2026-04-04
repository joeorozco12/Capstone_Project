# Agent Operating Rules

## Core Constraints
* Python only
* No GUI
* Deterministic outputs
* Headless execution
* Simple, testable implementations over clever or complex ones

## Execution Discipline
* Read AGENTS.md before doing any work
* Read SPEC.md before making implementation decisions
* Read TASKS.md before executing work
* Execute exactly one task at a time
* Do not combine tasks
* Do not work ahead
* Do not introduce features not defined in SPEC.md
* Do not refactor unrelated code while completing a task
* Do not change interfaces, filenames, or architecture without
  a task or spec update that explicitly requires it

## Task Requirements
* Every task must include:
    * Objective
    * Inputs
    * Output
    * Implementation Notes
    * Validation
    * Done Criteria
* Do not execute tasks that are underspecified
* Do not proceed if validation is missing
* Stop and flag unclear dependencies, conflicting requirements,
  or missing acceptance criteria

## Validation Rules
* Every completed task must have a concrete pass/fail validation
* Prefer deterministic tests, fixtures, and known reference cases
* Validate the smallest unit possible before integration
* If validation fails, stop and resolve before proceeding
* Do not mark a task complete without satisfying Done Criteria

## Code Rules
* Keep modules focused and single-purpose
* Separate parsing, computation, I/O, and validation
* Minimize side effects
* Avoid hidden state
* Prefer explicit inputs and outputs
* Add error handling for invalid input and predictable failures
* Keep output formatting stable and machine-checkable

## File Change Rules
* Only modify files required for the current task
* Create new files only if justified by the current task
* Keep the repo structure clean and minimal
* Do not delete files unless the task explicitly requires it

## Domain Rules (Automotive LED)
* All currents in milliamps (mA) unless explicitly noted otherwise
* All temperatures in Celsius (degC)
* All voltages in volts (V)
* All luminous flux values are relative (normalized to 1.0 at reference condition)
* Reference condition for normalization is always explicitly stated in SPEC.md
* Chromaticity coordinates are CIE 1931 (x, y)
* Do not extrapolate beyond the range of digitized curve data without flagging a warning
* Thermal solve is iterative: IF -> Tj -> derate -> converge; do not short-circuit this loop
* Color bin boundaries come from part-specific data; do not hardcode generic values

## Failure Handling
* If a task fails, document:
    * what failed
    * likely cause
    * corrective action
* Record meaningful failures in PROCESS_LOG.md
* Record reusable takeaways in LESSONS_LEARNED.md

## Completion Standard
* A task is complete only when:
    * the specified output exists
    * validation passes
    * done criteria are satisfied
    * any required documentation updates are made
