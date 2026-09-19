#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

show_help() {
    cat <<EOF
Usage: $(basename "$0") [options]

Run the ForgeOS test suite inside an isolated Podman container.

Options:
  -f, --full          Install zsh and shellcheck inside container for full test coverage (default)
  --fast              Run immediately without installing extra packages (skips zsh/shellcheck)
  -i, --image <name>  Container image to use (default: ubuntu:latest)
  -h, --help          Show this help message
EOF
}

IMAGE="${IMAGE:-ubuntu:latest}"
MODE="full"

while [[ $# -gt 0 ]]; do
    case "$1" in
        -f|--full)
            MODE="full"
            shift
            ;;
        --fast)
            MODE="fast"
            shift
            ;;
        -i|--image)
            if [[ -z "${2+x}" ]]; then
                echo "❌ Error: --image requires an argument." >&2
                exit 1
            fi
            IMAGE="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "❌ Error: Unknown option '$1'" >&2
            echo "Run '$(basename "$0") --help' for usage." >&2
            exit 1
            ;;
    esac
done

if ! command -v podman &>/dev/null; then
    echo "❌ Error: podman is not installed or not in PATH." >&2
    exit 1
fi

echo "🐳 Running ForgeOS test suite in container (${IMAGE})..."
echo ""

if [[ "${MODE}" == "full" ]]; then
    podman run --rm \
        -v "${REPO_ROOT}:/work:z" \
        -w /work \
        -e DEBIAN_FRONTEND=noninteractive \
        "${IMAGE}" bash -c '
            set -e
            echo "📦 Setting up container test environment (zsh, shellcheck)..."
            apt-get update -qq && apt-get install -y -qq --no-install-recommends zsh shellcheck sudo >/dev/null 2>&1 || true
            id -u runner &>/dev/null || useradd -m -u 1001 runner
            su runner -c "./tests/run_tests.sh"
        '
else
    podman run --rm \
        --userns=keep-id \
        -v "${REPO_ROOT}:/work:z" \
        -w /work \
        "${IMAGE}" ./tests/run_tests.sh
fi
