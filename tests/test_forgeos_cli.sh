#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
FORGEOS_BIN="${REPO_ROOT}/system_files/usr/bin/forgeos"

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
        fail "$desc" "Expected output to contain '$needle'"
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

echo "Running ForgeOS CLI unit tests..."

# 1. File Permissions and Syntax Checks
if [[ -f "${FORGEOS_BIN}" ]]; then
    pass "forgeos binary exists"
else
    fail "forgeos binary exists" "File not found at ${FORGEOS_BIN}"
fi

if [[ -x "${FORGEOS_BIN}" ]]; then
    pass "forgeos binary has executable permission"
else
    fail "forgeos binary has executable permission" "File is not executable"
fi

if bash -n "${FORGEOS_BIN}"; then
    pass "forgeos bash syntax is valid"
else
    fail "forgeos bash syntax is valid" "Syntax check failed"
fi

# 2. Root Guard Check
# shellcheck disable=SC2016
root_output=$(sed 's/\${EUID}/0/' "${FORGEOS_BIN}" | bash 2>&1 || true)
assert_contains "$root_output" "must not be run directly as root" "Root guard prevents execution when EUID=0"

# 3. Help and Usage Flags
help_out_short=$("${FORGEOS_BIN}" -h 2>&1 || true)
assert_contains "$help_out_short" "Usage: forgeos <target> [options]" "forgeos -h displays usage"
assert_contains "$help_out_short" "Available targets:" "forgeos -h lists available targets"

help_out_long=$("${FORGEOS_BIN}" --help 2>&1 || true)
assert_contains "$help_out_long" "Usage: forgeos <target> [options]" "forgeos --help displays usage"

help_out_empty=$("${FORGEOS_BIN}" 2>&1 || true)
assert_contains "$help_out_empty" "Usage: forgeos <target> [options]" "forgeos with no arguments displays usage"

# 4. Unknown Target Handling
unknown_out=$("${FORGEOS_BIN}" non-existent-target 2>&1 || true)
assert_contains "$unknown_out" "Unknown target 'non-existent-target'" "Unknown target outputs error message"
assert_contains "$unknown_out" "Run 'forgeos --help'" "Unknown target suggests running --help"

# 5. Target Execution with Mocks (Target: update)
mock_dir=$(mktemp -d)
log_file="${mock_dir}/calls.log"

# Mock sudo, bootc, flatpak, brew
cat << 'EOF' > "${mock_dir}/sudo"
#!/usr/bin/env bash
echo "sudo $*" >> "${LOG_FILE}"
"$@"
EOF

cat << 'EOF' > "${mock_dir}/bootc"
#!/usr/bin/env bash
echo "bootc $*" >> "${LOG_FILE}"
EOF

cat << 'EOF' > "${mock_dir}/flatpak"
#!/usr/bin/env bash
echo "flatpak $*" >> "${LOG_FILE}"
EOF

cat << 'EOF' > "${mock_dir}/brew"
#!/usr/bin/env bash
echo "brew $*" >> "${LOG_FILE}"
EOF

chmod +x "${mock_dir}/"*

update_out=$(LOG_FILE="${log_file}" PATH="${mock_dir}:${PATH}" "${FORGEOS_BIN}" update 2>&1)
assert_contains "$update_out" "Running forgeos update..." "forgeos update prints startup message"
assert_contains "$update_out" "Update complete!" "forgeos update prints completion message"

logged_calls=$(cat "${log_file}")
assert_contains "$logged_calls" "sudo bootc upgrade" "forgeos update runs 'sudo bootc upgrade'"
assert_contains "$logged_calls" "bootc upgrade" "forgeos update executes bootc upgrade"
assert_contains "$logged_calls" "flatpak update -y" "forgeos update runs 'flatpak update -y'"
assert_contains "$logged_calls" "brew update" "forgeos update runs 'brew update'"
assert_contains "$logged_calls" "brew upgrade" "forgeos update runs 'brew upgrade'"

# 6. Target: update without Homebrew
rm -f "${mock_dir}/brew" "${log_file}"
no_brew_path=$(echo "$PATH" | tr ':' '\n' | grep -v 'brew' | tr '\n' ':' | sed 's/:$//')
update_no_brew_out=$(LOG_FILE="${log_file}" PATH="${mock_dir}:${no_brew_path}" "${FORGEOS_BIN}" update 2>&1)
assert_contains "$update_no_brew_out" "Homebrew is not installed or not in PATH, skipping." "forgeos update handles missing Homebrew gracefully"

# 7. Target Execution with Mocks (Target: clean-system)
cat << 'EOF' > "${mock_dir}/brew"
#!/usr/bin/env bash
echo "brew $*" >> "${LOG_FILE}"
EOF
cat << 'EOF' > "${mock_dir}/podman"
#!/usr/bin/env bash
echo "podman $*" >> "${LOG_FILE}"
EOF
cat << 'EOF' > "${mock_dir}/ostree"
#!/usr/bin/env bash
echo "ostree $*" >> "${LOG_FILE}"
EOF
chmod +x "${mock_dir}/"*
: > "${log_file}"

clean_out=$(LOG_FILE="${log_file}" PATH="${mock_dir}:${PATH}" "${FORGEOS_BIN}" clean-system 2>&1)
assert_contains "$clean_out" "Running forgeos clean-system..." "forgeos clean-system prints startup message"
assert_contains "$clean_out" "System cleanup complete!" "forgeos clean-system prints completion message"

logged_clean_calls=$(cat "${log_file}")
assert_contains "$logged_clean_calls" "podman system prune -f" "forgeos clean-system runs 'podman system prune -f'"
assert_contains "$logged_clean_calls" "sudo ostree admin cleanup" "forgeos clean-system runs 'sudo ostree admin cleanup'"
assert_contains "$logged_clean_calls" "ostree admin cleanup" "forgeos clean-system executes ostree admin cleanup"
assert_contains "$logged_clean_calls" "flatpak uninstall --unused -y" "forgeos clean-system runs 'flatpak uninstall --unused -y'"
assert_contains "$logged_clean_calls" "brew cleanup --prune=all" "forgeos clean-system runs 'brew cleanup --prune=all'"

# 8. Target: clean-system without Homebrew
rm -f "${mock_dir}/brew" "${log_file}"
clean_no_brew_out=$(LOG_FILE="${log_file}" PATH="${mock_dir}:${no_brew_path}" "${FORGEOS_BIN}" clean-system 2>&1)
assert_contains "$clean_no_brew_out" "Homebrew is not installed or not in PATH, skipping." "forgeos clean-system handles missing Homebrew gracefully"

rm -rf "${mock_dir}"

echo "ForgeOS CLI test summary: ${PASSED} passed, ${FAILED} failed."
if [[ ${FAILED} -gt 0 ]]; then
    exit 1
fi
