# Lab 3 — E7 (bonus): Functional Property Proof

## The property
Beyond "no runtime error" (absence of overflow/exception), `Input_Validator.Validate`
is specified with a genuine functional security property in its `Post` contract
(`validator/src/input_validator.ads`, line 96):

- If `Status = Accepted`, then `Length = Input'Length` (bounded, non-overflowing)
  **and** every character copied into `Buffer` belongs to `Allowed_Char`
  (letters, digits, `_`, `-`, `.` only) — i.e. no dangerous/injection character
  ever reaches the buffer on an accepted input.
- If `Status` is any rejection code, `Length = 0` and `Buffer` is left untouched
  — a rejected input stores nothing.

This is a *functional correctness/security* property (what the validator
guarantees about its output), not merely "the code doesn't crash."

## Proof
`gnatprove -P validator.gpr --mode=prove --report=all` (run by the team,
trace in `traces/gnatprove_prove.txt`) discharges this postcondition with
zero unproved checks:

    info: postcondition proved --> input_validator.ads:96:08
    Success: all checks proved (22 checks).

## What this does / does not guarantee
- Proved: the validation logic itself cannot accept a too-long or
  disallowed-character input, and cannot leak partial buffer contents on
  rejection.
- Not covered by this proof: the caller's use of `Buffer`/`Length` downstream
  (e.g. if a caller ignored `Status` and used `Buffer` anyway), the OS/runtime
  environment, or timing side channels.
