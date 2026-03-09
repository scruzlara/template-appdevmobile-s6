#!/usr/bin/env bash
# patch-speckit.sh — Injecte le bloc d'archivage d'évaluation dans les commandes speckit
# BUT S6 AppDevMobile 2025-2026
#
# Usage : bash scripts/patch-speckit.sh
# À exécuter une seule fois, après `specify init . --ai <agent>`

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BLOCK_FILE="$SCRIPT_DIR/archivage-block.md"

# Phases de workflow à patcher (on cherche ces mots dans les noms de fichiers)
WORKFLOW_PHASES=("constitution" "specify" "plan" "tasks" "implement")

# Marqueur pour ne pas patcher deux fois
MARKER="ÉVALUATION — NE PAS MODIFIER NI SUPPRIMER"

# Répertoires de commandes par agent
# Format : "répertoire:type" (type = md ou toml)
AGENT_DIRS=(
    ".claude/commands:md"
    ".github/agents:md"
    ".codex/commands:md"
    ".cursor/commands:md"
    ".opencode/command:md"
    ".gemini/commands:toml"
    ".qwen/commands:toml"
)

echo "=== Patch dispositif d'évaluation AppDevMobile ==="
echo "Répertoire du dépôt : $REPO_ROOT"
echo ""

patched_count=0
skipped_count=0
notfound_count=0

patch_file() {
    local filepath="$1"
    local phase_name="$2"

    if grep -q "$MARKER" "$filepath" 2>/dev/null; then
        echo "  [DÉJÀ PATCHÉ] $(basename "$filepath")"
        ((skipped_count++)) || true
        return
    fi

    echo "" >> "$filepath"
    cat "$BLOCK_FILE" >> "$filepath"

    # Remplacer les placeholders de phase
    sed -i.bak "s/<NOM_DE_LA_PHASE>/$phase_name/g" "$filepath"
    sed -i.bak "s/<nom_phase>/$phase_name/g" "$filepath"
    rm -f "${filepath}.bak"

    echo "  [PATCHÉ] $(basename "$filepath")"
    ((patched_count++)) || true
}

# Pour chaque répertoire agent déclaré
for entry in "${AGENT_DIRS[@]}"; do
    dir="${entry%%:*}"
    type="${entry##*:}"
    full_dir="$REPO_ROOT/$dir"

    [[ -d "$full_dir" ]] || continue

    echo "Agent trouvé : $dir"

    for phase in "${WORKFLOW_PHASES[@]}"; do
        # Chercher tout fichier dont le nom contient le nom de la phase
        found=0
        while IFS= read -r -d '' filepath; do
            patch_file "$filepath" "$phase"
            found=1
        done < <(find "$full_dir" -maxdepth 1 -type f -iname "*${phase}*" -print0 2>/dev/null)

        if [[ $found -eq 0 ]]; then
            echo "  [NON TROUVÉ] aucun fichier contenant '${phase}' dans $dir"
            ((notfound_count++)) || true
        fi
    done
    echo ""
done

echo "=== Résultat ==="
echo "  Fichiers patchés  : $patched_count"
echo "  Déjà patchés      : $skipped_count"
echo "  Non trouvés       : $notfound_count"
echo ""

if [[ $patched_count -eq 0 && $skipped_count -eq 0 ]]; then
    echo "ATTENTION : Aucune commande speckit trouvée."
    echo "Vérifiez que vous avez bien exécuté 'specify init . --ai <agent>' avant ce script."
    exit 1
fi

if [[ $patched_count -gt 0 ]]; then
    echo "Patch appliqué. Committez les changements :"
    echo "  git add ."
    echo "  git commit -m \"eval: bloc d'archivage injecté dans les commandes speckit\""
    echo "  git push"
fi
