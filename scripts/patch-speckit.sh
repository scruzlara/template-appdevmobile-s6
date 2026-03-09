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

# Commandes speckit à patcher (phases de workflow, pas les utilitaires)
WORKFLOW_COMMANDS=("constitution" "specify" "plan" "tasks" "implement")

# Marqueur pour ne pas patcher deux fois
MARKER="ÉVALUATION — NE PAS MODIFIER NI SUPPRIMER"

# Répertoires de commandes par agent (format Markdown)
MARKDOWN_DIRS=(
    ".claude/commands"
    ".github/agents"
    ".codex/commands"
    ".cursor/commands"
    ".opencode/command"
)

# Répertoires de commandes par agent (format TOML — Gemini, Qwen)
# Pour ces agents, le bloc est injecté différemment
TOML_DIRS=(
    ".gemini/commands"
    ".qwen/commands"
)

echo "=== Patch dispositif d'évaluation AppDevMobile ==="
echo "Répertoire du dépôt : $REPO_ROOT"
echo ""

patched_count=0
skipped_count=0
notfound_count=0

patch_markdown_file() {
    local filepath="$1"
    local phase_name="$2"

    if [[ ! -f "$filepath" ]]; then
        echo "  [NON TROUVÉ] $filepath"
        ((notfound_count++)) || true
        return
    fi

    if grep -q "$MARKER" "$filepath" 2>/dev/null; then
        echo "  [DÉJÀ PATCHÉ] $filepath"
        ((skipped_count++)) || true
        return
    fi

    # Ajouter le bloc en fin de fichier
    echo "" >> "$filepath"
    cat "$BLOCK_FILE" >> "$filepath"

    # Remplacer le placeholder de phase
    sed -i.bak "s/<NOM_DE_LA_PHASE>/$phase_name/g" "$filepath"
    sed -i.bak "s/<nom_phase>/$phase_name/g" "$filepath"
    rm -f "${filepath}.bak"

    echo "  [PATCHÉ] $filepath"
    ((patched_count++)) || true
}

patch_toml_file() {
    local filepath="$1"
    local phase_name="$2"

    if [[ ! -f "$filepath" ]]; then
        echo "  [NON TROUVÉ] $filepath"
        ((notfound_count++)) || true
        return
    fi

    if grep -q "$MARKER" "$filepath" 2>/dev/null; then
        echo "  [DÉJÀ PATCHÉ] $filepath"
        ((skipped_count++)) || true
        return
    fi

    # Pour les fichiers TOML, le bloc est ajouté dans une section [eval]
    # La plupart des agents TOML acceptent du Markdown dans les sections de contenu
    cat >> "$filepath" << TOML_BLOCK

# --- ÉVALUATION — NE PAS MODIFIER NI SUPPRIMER ---
# Bloc d'archivage obligatoire — BUT S6 AppDevMobile
# Voir scripts/archivage-block.md pour le contenu complet
# L'agent doit exécuter ce bloc à chaque fin de phase $phase_name :
# 1. Mettre à jour journal/speckit-log.md (format défini dans archivage-block.md)
# 2. git add journal/speckit-log.md
# 3. git commit -m "[speckit:$phase_name] journal mis à jour"
# 4. git push
TOML_BLOCK

    echo "  [PATCHÉ-TOML] $filepath"
    ((patched_count++)) || true
}

# Traitement des répertoires Markdown
for dir in "${MARKDOWN_DIRS[@]}"; do
    full_dir="$REPO_ROOT/$dir"
    if [[ -d "$full_dir" ]]; then
        echo "Agent trouvé : $dir"
        for cmd in "${WORKFLOW_COMMANDS[@]}"; do
            patch_markdown_file "$full_dir/${cmd}.md" "$cmd"
        done
        echo ""
    fi
done

# Traitement des répertoires TOML
for dir in "${TOML_DIRS[@]}"; do
    full_dir="$REPO_ROOT/$dir"
    if [[ -d "$full_dir" ]]; then
        echo "Agent trouvé (TOML) : $dir"
        for cmd in "${WORKFLOW_COMMANDS[@]}"; do
            # Gemini peut utiliser .md ou .toml
            if [[ -f "$full_dir/${cmd}.md" ]]; then
                patch_markdown_file "$full_dir/${cmd}.md" "$cmd"
            elif [[ -f "$full_dir/${cmd}.toml" ]]; then
                patch_toml_file "$full_dir/${cmd}.toml" "$cmd"
            else
                echo "  [NON TROUVÉ] $full_dir/${cmd}.{md,toml}"
                ((notfound_count++)) || true
            fi
        done
        echo ""
    fi
done

echo "=== Résultat ==="
echo "  Fichiers patchés  : $patched_count"
echo "  Déjà patchés      : $skipped_count"
echo "  Non trouvés       : $notfound_count"
echo ""

if [[ $patched_count -eq 0 && $skipped_count -eq 0 ]]; then
    echo "ATTENTION : Aucun répertoire de commandes speckit trouvé."
    echo "Vérifiez que vous avez bien exécuté 'specify init . --ai <agent>' avant ce script."
    exit 1
fi

if [[ $patched_count -gt 0 ]]; then
    echo "Patch appliqué. Committez les changements :"
    echo "  git add ."
    echo "  git commit -m \"eval: bloc d'archivage injecté dans les commandes speckit\""
    echo "  git push"
fi
