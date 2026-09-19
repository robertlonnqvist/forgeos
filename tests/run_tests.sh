#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "========================================"
echo "      Running ForgeOS Test Suite        "
echo "========================================"
echo ""

TOTAL_FAILURES=0

run_suite() {
    local name="$1"
    local runner="$2"
    local test_script="$3"

    echo "▶ Running ${name}..."
    if "${runner}" "${test_script}"; then
        echo "✔ ${name} succeeded."
    else
        echo "✖ ${name} failed."
        TOTAL_FAILURES=$((TOTAL_FAILURES + 1))
    fi
    echo ""
}

# ForgeOS CLI Unit Tests
run_suite "ForgeOS CLI Unit Tests" bash "${SCRIPT_DIR}/test_forgeos_cli.sh"

# Bash Completion Tests
run_suite "Bash Completion Tests" bash "${SCRIPT_DIR}/test_bash_completion.sh"

# Zsh Completion Tests
if command -v zsh &>/dev/null; then
    run_suite "Zsh Completion Tests" zsh "${SCRIPT_DIR}/test_zsh_completion.sh"
else
    echo "⚠️ zsh is not installed, skipping Zsh completion tests."
    echo ""
fi

# 5. ShellCheck Static Analysis
if command -v shellcheck &>/dev/null; then
    echo "▶ Running ShellCheck Static Analysis..."
    if shellcheck \
        "${REPO_ROOT}/system_files/usr/bin/forgeos" \
        "${REPO_ROOT}/build_files/install.sh" \
        "${REPO_ROOT}/tests/run_tests.sh" \
        "${REPO_ROOT}/tests/test_forgeos_cli.sh" \
        "${REPO_ROOT}/tests/test_bash_completion.sh"; then
        echo "✔ ShellCheck static analysis passed with zero warnings."
    else
        echo "✖ ShellCheck static analysis failed."
        TOTAL_FAILURES=$((TOTAL_FAILURES + 1))
    fi
    echo ""
else
    echo "⚠️ shellcheck is not installed, skipping static analysis."
    echo ""
fi

echo "========================================"
if [[ ${TOTAL_FAILURES} -eq 0 ]]; then
    echo " 🎉 All test suites passed successfully!"
    echo "========================================"
    exit 0
else
    echo " ❌ ${TOTAL_FAILURES} test suite(s) failed."
    echo "========================================"
    exit 1
fi
