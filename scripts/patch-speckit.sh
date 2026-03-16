#!/usr/bin/env bash
# patch-speckit.sh — Injecte le bloc d'archivage d'évaluation dans les commandes speckit
#                    et crée la commande /speckit.checkpoint pour chaque agent détecté
# BUT S6 AppDevMobile 2025-2026
#
# Usage : bash scripts/patch-speckit.sh
# À exécuter une seule fois, après `specify init . --ai <agent>`

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BLOCK_FILE="$SCRIPT_DIR/archivage-block.md"
CHECKPOINT_FILE="$SCRIPT_DIR/checkpoint-block.md"

# Phases de workflow à patcher (on cherche ces mots dans les noms de fichiers)
WORKFLOW_PHASES=("constitution" "specify" "plan" "tasks" "implement")

# Marqueur pour ne pas patcher deux fois
MARKER="ÉVALUATION — NE PAS MODIFIER NI SUPPRIMER"
CHECKPOINT_MARKER="ÉVALUATION] Archivage de prompts"

# Répertoires de commandes par agent
# Format : "répertoire:type:suffixe_checkpoint"
# suffixe_checkpoint = extension + suffixe du nom de fichier checkpoint pour cet agent
AGENT_DIRS=(
    ".claude/commands:md:checkpoint.md"
    ".github/agents:md:checkpoint.agent.md"
    ".codex/commands:md:checkpoint.md"
    ".cursor/commands:md:checkpoint.md"
    ".opencode/command:md:checkpoint.md"
    ".gemini/commands:toml:checkpoint.md"
    ".qwen/commands:toml:checkpoint.md"
)

echo "=== Patch dispositif d'évaluation AppDevMobile ==="
echo "Répertoire du dépôt : $REPO_ROOT"
echo ""

patched_count=0
skipped_count=0
notfound_count=0
checkpoint_count=0

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

create_checkpoint() {
    local full_dir="$1"
    local checkpoint_filename="$2"
    local checkpoint_path="$full_dir/$checkpoint_filename"

    if [[ -f "$checkpoint_path" ]] && grep -q "$CHECKPOINT_MARKER" "$checkpoint_path" 2>/dev/null; then
        echo "  [CHECKPOINT DÉJÀ CRÉÉ] $checkpoint_filename"
        return
    fi

    cat "$CHECKPOINT_FILE" > "$checkpoint_path"
    echo "  [CHECKPOINT CRÉÉ] $checkpoint_filename"
    ((checkpoint_count++)) || true
}

# Pour chaque répertoire agent déclaré
for entry in "${AGENT_DIRS[@]}"; do
    IFS=':' read -r dir type checkpoint_filename <<< "$entry"
    full_dir="$REPO_ROOT/$dir"

    [[ -d "$full_dir" ]] || continue

    echo "Agent trouvé : $dir"

    # Patcher les commandes de workflow
    for phase in "${WORKFLOW_PHASES[@]}"; do
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

    # Créer la commande checkpoint
    create_checkpoint "$full_dir" "$checkpoint_filename"
    echo ""
done

echo "=== Résultat ==="
echo "  Fichiers patchés       : $patched_count"
echo "  Déjà patchés           : $skipped_count"
echo "  Non trouvés            : $notfound_count"
echo "  Commandes checkpoint   : $checkpoint_count"
echo ""

if [[ $patched_count -eq 0 && $skipped_count -eq 0 ]]; then
    echo "ATTENTION : Aucune commande speckit trouvée."
    echo "Vérifiez que vous avez bien exécuté 'specify init . --ai <agent>' avant ce script."
    exit 1
fi

if [[ $patched_count -gt 0 || $checkpoint_count -gt 0 ]]; then
    echo "Patch appliqué. Committez les changements :"
    echo "  git add ."
    echo "  git commit -m \"eval: bloc d'archivage et commande checkpoint injectés\""
    echo "  git push"
fi
