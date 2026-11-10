#!/bin/bash
# Lab3 E6 -- C vulnerable validator vs SPARK validator, 12 common test cases
C_BIN=./c_ref/validate
SPARK_BIN=./validator/bin/compare_harness

run_case () {
  local label="$1"
  local input="$2"
  echo "=== Case: $label ==="
  echo "--- C ---"
  "$C_BIN" "$input"
  echo "exit_code=$?"
  echo "--- SPARK ---"
  "$SPARK_BIN" "$input"
  echo "exit_code=$?"
  echo
}

run_case "valid_short"        "hello"
run_case "empty"              ""
run_case "exactly_max_64"     "$(printf 'a%.0s' {1..64})"
run_case "max_plus_one_65"    "$(printf 'a%.0s' {1..65})"
run_case "too_long_100"       "$(printf 'A%.0s' {1..100})"
run_case "too_long_200"       "$(printf 'A%.0s' {1..200})"
run_case "space_char"         "hello world"
run_case "shell_metachar"     "test;rm -rf"
run_case "format_string"      "%n%n%n%n%n%n%n%n"
run_case "sql_quote"          "name';DROP--"
run_case "path_traversal"     "../../etc/passwd"
run_case "massive_overflow_517" "$(printf 'A%.0s' {1..517})"

