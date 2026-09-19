#!/usr/bin/env zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
COMPLETION_FILE="${REPO_ROOT}/system_files/usr/share/zsh/site-functions/_forgeos"
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
    if [[ "$haystack" == *"$needle"* ]]; then
        pass "$desc"
    else
        fail "$desc" "Expected '$haystack' to contain '$needle'"
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

echo "Running Zsh completion tests for forgeos..."

# 1. Syntax Check
if zsh -n "${COMPLETION_FILE}"; then
    pass "Zsh completion file syntax is valid"
else
    fail "Zsh completion file syntax check" "Syntax errors found"
fi

# 2. Compinit Autoload Check
fpath=("$(dirname "${COMPLETION_FILE}")" "${fpath[@]}")
autoload -Uz compinit
compinit -D
autoload -Uz _forgeos

fn_type=$(type _forgeos 2>/dev/null || true)
assert_contains "$fn_type" "_forgeos is an autoload shell function" "Zsh autoloads _forgeos correctly via compinit"

# 3. Argument Specification Check
captured_args=()
_describe() { :; }
_arguments() {
    captured_args+=("$@")
    return 0
}

source "${COMPLETION_FILE}"
_forgeos

all_args="${captured_args[*]}"
assert_contains "$all_args" "(-h --help)" "Argument specification includes mutually exclusive -h / --help flags"
assert_contains "$all_args" "1:target:_describe -t targets" "Argument specification routes 1st positional argument to targets"
assert_contains "$all_args" "*:: :->args" "Argument specification handles subsequent arguments"

# 4. Default Target Descriptions Check
captured_items=()
_describe() {
    local varname="$4"
    eval "captured_items=(\"\${${varname}[@]}\")"
}
_arguments() {
    for arg in "$@"; do
        if [[ "$arg" == 1:*:* ]]; then
            local action="${arg#1:*:}"
            eval "$action"
        fi
    done
    return 0
}

# Run without forgeos in PATH to verify fallback descriptions
PATH="/usr/bin:/bin"
source "${COMPLETION_FILE}"
_forgeos
PATH="$ORIGINAL_PATH"

items_str=$(printf "%s\n" "${captured_items[@]}")
assert_contains "$items_str" "update:Upgrade bootc system, Flatpaks, and Homebrew packages" "Default update description is provided"
assert_contains "$items_str" "clean-system:Prune Podman resources, clean bootc deployments, Flatpaks, Homebrew" "Default clean-system description is provided"

# 5. Dynamic Target Discovery and Custom Descriptions
tmpdir=$(mktemp -d)
cat << 'EOF' > "$tmpdir/forgeos"
#!/usr/bin/env bash
target_update() { :; }
target_clean-system() { :; }
target_backup() { :; }
EOF
chmod +x "$tmpdir/forgeos"

captured_items=()
PATH="$tmpdir:$ORIGINAL_PATH"
source "${COMPLETION_FILE}"
_forgeos
rm -rf "$tmpdir"
PATH="$ORIGINAL_PATH"

items_str=$(printf "%s\n" "${captured_items[@]}")
assert_contains "$items_str" "update:Upgrade bootc system, Flatpaks, and Homebrew packages" "Dynamic parsing preserves update description"
assert_contains "$items_str" "clean-system:Prune Podman resources, clean bootc deployments, Flatpaks, Homebrew" "Dynamic parsing preserves clean-system description"
assert_contains "$items_str" "backup:Custom target" "Dynamic parsing adds custom target with fallback description"

echo "Zsh completion test summary: ${PASSED} passed, ${FAILED} failed."
if [[ ${FAILED} -gt 0 ]]; then
    exit 1
fi
