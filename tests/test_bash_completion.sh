#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
COMPLETION_FILE="${REPO_ROOT}/system_files/usr/share/bash-completion/completions/forgeos"
ORIGINAL_PATH="$PATH"

PASSED=0
FAILED=0

pass() {
    echo "  [PASS] $1"
    PASSED=$((PASSED + 1))
}

fail() {
    echo "  [FAIL] $1: $2"
    FAILED=$((FAILED + 1))
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local desc="$3"
    if [[ " $haystack " == *" $needle "* ]]; then
        pass "$desc"
    else
        fail "$desc" "Expected '$haystack' to contain '$needle'"
    fi
}

assert_not_contains() {
    local haystack="$1"
    local needle="$2"
    local desc="$3"
    if [[ " $haystack " != *" $needle "* ]]; then
        pass "$desc"
    else
        fail "$desc" "Expected '$haystack' NOT to contain '$needle'"
    fi
}

assert_equals() {
    local actual="$1"
    local expected="$2"
    local desc="$3"
    if [[ "$actual" == "$expected" ]]; then
        pass "$desc"
    else
        fail "$desc" "Expected '$expected', got '$actual'"
    fi
}

assert_empty() {
    local actual="$1"
    local desc="$2"
    if [[ -z "$actual" ]]; then
        pass "$desc"
    else
        fail "$desc" "Expected empty result, got '$actual'"
    fi
}

echo "Running Bash completion tests for forgeos..."

# 1. Syntax Check
if bash -n "${COMPLETION_FILE}"; then
    pass "Bash completion file syntax is valid"
else
    fail "Bash completion file syntax check" "Syntax errors found"
fi

# shellcheck source=/dev/null
source "${COMPLETION_FILE}"

# 2. Test Default Completions (COMP_CWORD=1, cur="")
PATH="/usr/bin:/bin"
unset _FORGEOS_CACHED_TARGETS
COMP_WORDS=("forgeos" "")
COMP_CWORD=1
COMPREPLY=()
_forgeos_completions
result="${COMPREPLY[*]}"

assert_contains "$result" "-h" "First argument suggestions include -h"
assert_contains "$result" "--help" "First argument suggestions include --help"
assert_contains "$result" "update" "First argument suggestions include update"
assert_contains "$result" "clean-system" "First argument suggestions include clean-system"

# 3. Test Option Flag Completions (cur="-")
unset _FORGEOS_CACHED_TARGETS
COMP_WORDS=("forgeos" "-")
COMP_CWORD=1
COMPREPLY=()
_forgeos_completions
result="${COMPREPLY[*]}"

assert_contains "$result" "-h" "Flag prefix '-' suggests -h"
assert_contains "$result" "--help" "Flag prefix '-' suggests --help"
assert_not_contains "$result" "update" "Flag prefix '-' does not suggest update"
assert_not_contains "$result" "clean-system" "Flag prefix '-' does not suggest clean-system"

# 4. Test Option Flag Completions (cur="--")
unset _FORGEOS_CACHED_TARGETS
COMP_WORDS=("forgeos" "--")
COMP_CWORD=1
COMPREPLY=()
_forgeos_completions
result="${COMPREPLY[*]}"

assert_equals "$result" "--help" "Flag prefix '--' uniquely suggests --help"

# 5. Test Partial Prefix Completion (cur="up")
unset _FORGEOS_CACHED_TARGETS
COMP_WORDS=("forgeos" "up")
COMP_CWORD=1
COMPREPLY=()
_forgeos_completions
result="${COMPREPLY[*]}"

assert_equals "$result" "update" "Prefix 'up' uniquely suggests update"

# 6. Test Partial Prefix Completion (cur="clean")
unset _FORGEOS_CACHED_TARGETS
COMP_WORDS=("forgeos" "clean")
COMP_CWORD=1
COMPREPLY=()
_forgeos_completions
result="${COMPREPLY[*]}"

assert_equals "$result" "clean-system" "Prefix 'clean' uniquely suggests clean-system"

# 7. Test Suppression of Completions after Target (COMP_CWORD=2)
unset _FORGEOS_CACHED_TARGETS
COMP_WORDS=("forgeos" "update" "")
COMP_CWORD=2
COMPREPLY=()
_forgeos_completions
result="${COMPREPLY[*]}"

assert_empty "$result" "No completions suggested after target 'update'"

# 8. Test Suppression of Completions after Flag (COMP_CWORD=2)
unset _FORGEOS_CACHED_TARGETS
COMP_WORDS=("forgeos" "--help" "")
COMP_CWORD=2
COMPREPLY=()
_forgeos_completions
result="${COMPREPLY[*]}"

assert_empty "$result" "No completions suggested after flag '--help'"

# 9. Test Suppression at Higher Argument Positions (COMP_CWORD=3)
unset _FORGEOS_CACHED_TARGETS
COMP_WORDS=("forgeos" "update" "extra" "")
COMP_CWORD=3
COMPREPLY=()
_forgeos_completions
result="${COMPREPLY[*]}"

assert_empty "$result" "No completions suggested at COMP_CWORD=3"

# 10. Test Dynamic Target Discovery from Custom Binary
tmpdir=$(mktemp -d)
cat << 'EOF' > "$tmpdir/forgeos"
#!/usr/bin/env bash
target_update() { :; }
target_clean-system() { :; }
target_custom-pkg() { :; }
EOF
chmod +x "$tmpdir/forgeos"

PATH="$tmpdir:$ORIGINAL_PATH"
unset _FORGEOS_CACHED_TARGETS
COMP_WORDS=("forgeos" "")
COMP_CWORD=1
COMPREPLY=()
_forgeos_completions
result="${COMPREPLY[*]}"
rm -rf "$tmpdir"
PATH="$ORIGINAL_PATH"

assert_contains "$result" "custom-pkg" "Dynamic target 'custom-pkg' discovered from forgeos script in PATH"

echo "Bash completion test summary: ${PASSED} passed, ${FAILED} failed."
if [[ ${FAILED} -gt 0 ]]; then
    exit 1
fi
