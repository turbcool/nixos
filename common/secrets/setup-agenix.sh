#!/bin/sh

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$SCRIPT_DIR"

SKIP_EXISTING=0
SECRET_PATH="openai-token.age"

for arg in "$@"; do
    case "$arg" in
        --skip-existing)
            SKIP_EXISTING=1
            ;;
        *)
            echo "Unknown option: $arg" >&2
            echo "Usage: $0 [--skip-existing]" >&2
            exit 1
            ;;
    esac
done

agenix_cmd() {
    if command -v agenix >/dev/null 2>&1; then
        agenix "$@"
        return
    fi

    nix shell github:ryantm/agenix -c agenix "$@"
}

write_secret() {
    secret_value=$1

    umask 077

    secret_tmp=$(mktemp)
    editor_tmp=$(mktemp)
    trap 'rm -f "$secret_tmp" "$editor_tmp"' EXIT HUP INT TERM

    printf '%s' "$secret_value" > "$secret_tmp"
    cat > "$editor_tmp" <<'EOF'
#!/bin/sh
cp "$SECRET_SOURCE" "$1"
EOF
    chmod 700 "$editor_tmp"

    SECRET_SOURCE="$secret_tmp" EDITOR="$editor_tmp" agenix_cmd -e "$SECRET_PATH"

    rm -f "$secret_tmp" "$editor_tmp"
    trap - EXIT HUP INT TERM
}

if [ -f "$SECRET_PATH" ]; then
    if [ "$SKIP_EXISTING" -eq 1 ]; then
        echo "Skipping existing $SCRIPT_DIR/$SECRET_PATH"
        exit 0
    fi

    printf '%s already exists. Overwrite it? [y/N]: ' "$SCRIPT_DIR/$SECRET_PATH"
    read -r answer
    case "$answer" in
        [Yy]|[Yy][Ee][Ss])
            ;;
        *)
            echo "Skipping $SCRIPT_DIR/$SECRET_PATH"
            exit 0
            ;;
    esac
fi

printf 'OpenAI-compatible API key for opencode: '
IFS= read -r -s secret_value
printf '\n'

if [ -z "$secret_value" ]; then
    echo "No value entered, nothing changed."
    exit 0
fi

write_secret "$secret_value"

echo "Saved $SCRIPT_DIR/$SECRET_PATH"
echo "Rebuild the system to apply it: sudo nixos-rebuild switch --flake /etc/nixos#<host>"
