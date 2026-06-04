#!/bin/sh

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$SCRIPT_DIR"

SKIP_EXISTING=0

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
    secret_path=$1
    secret_value=$2

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

    SECRET_SOURCE="$secret_tmp" EDITOR="$editor_tmp" agenix_cmd -e "$secret_path"

    rm -f "$secret_tmp" "$editor_tmp"
    trap - EXIT HUP INT TERM
}

ask_secret() {
    secret_path=$1
    prompt=$2

    if [ -f "$secret_path" ]; then
        if [ "$SKIP_EXISTING" -eq 1 ]; then
            echo "Skipping existing $SCRIPT_DIR/$secret_path"
            return
        fi

        printf '%s already exists. Overwrite it? [y/N]: ' "$SCRIPT_DIR/$secret_path"
        read -r answer
        case "$answer" in
            [Yy]|[Yy][Ee][Ss])
                ;;
            *)
                echo "Skipping $SCRIPT_DIR/$secret_path"
                return
                ;;
        esac
    fi

    printf '%s' "$prompt"
    IFS= read -r -s secret_value
    printf '\n'

    if [ -z "$secret_value" ]; then
        echo "No value entered, nothing changed."
        return
    fi

    write_secret "$secret_path" "$secret_value"
    echo "Saved $SCRIPT_DIR/$secret_path"
}

ask_secret "neoplatform-token.age" "Neoplatform API key for opencode: "
ask_secret "custom-token.age" "Custom provider API key: "

echo ""
echo "--- VM SSH passwords ---"
ask_secret "vm-ai-neoplatform.age" "Password for ai-neoplatform: "
ask_secret "vm-ai-skyori.age" "Password for ai-skyori: "
ask_secret "vm-ai-proinfoservice.age" "Password for ai-proinfoservice: "
ask_secret "vm-ai-timepath.age" "Password for ai-timepath: "
ask_secret "zai-token.age" "Z.AI Web Search API key: "

echo "Rebuild the system to apply: sudo nixos-rebuild switch --flake /etc/nixos#<host>"
