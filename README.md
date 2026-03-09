# [NOM DU PROJET] — BUT S6 AppDevMobile 2025-2026

> **Étudiant :** Prénom Nom
> **Groupe :**
> **Agent IA utilisé :** Claude Code / Gemini CLI / Codex CLI / GitHub Copilot *(rayer les mentions inutiles)*

---

## Mise en place du projet (à faire une seule fois)

### 1. Cloner ce dépôt

GitHub Classroom vous a fourni l'URL de votre dépôt personnel. Clonez-le :

```bash
git clone <url-de-votre-depot>
cd <nom-du-depot>
```

### 2. Installer speckit

```bash
pip install uv   # si uv n'est pas installé
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
```

### 3. Initialiser speckit pour votre agent

Choisissez **un seul** agent et exécutez la commande correspondante :

```bash
# Claude Code
specify init . --ai claude

# Gemini CLI
specify init . --ai gemini

# Codex CLI
specify init . --ai codex

# GitHub Copilot
specify init . --ai copilot
```

### 4. Appliquer le dispositif d'évaluation

```bash
bash scripts/patch-speckit.sh
```

Ce script ajoute le bloc d'archivage obligatoire aux commandes speckit. **Ne pas modifier ni supprimer ce bloc.**

### 5. Committer la configuration initiale

```bash
git add .
git commit -m "init: configuration speckit + dispositif d'évaluation"
git push
```

---

## Workflow de développement

Suivez les phases speckit dans l'ordre, en utilisant les commandes slash de votre agent :

| Commande | Phase | Livrable journal obligatoire |
|---|---|---|
| `/constitution` | Principes du projet | Oui |
| `/specify` | Description fonctionnelle | Oui |
| `/plan` | Architecture technique | Oui |
| `/tasks` | Liste de tâches | Oui |
| `/implement` | Implémentation | Oui (à chaque itération) |

**À chaque fin de phase, votre agent doit :**
1. Écrire une entrée dans `journal/speckit-log.md`
2. Committer et pusher le journal

---

## Structure du dépôt

```
.
├── journal/
│   └── speckit-log.md        ← votre journal de développement (évalué)
├── scripts/
│   └── patch-speckit.sh      ← script de configuration (ne pas modifier)
├── src/                      ← votre code (généré lors du développement)
├── specs/                    ← spécifications générées par speckit
├── CLAUDE.md                 ← instructions pour Claude Code
└── README.md                 ← ce fichier
```

---

## Évaluation

Le journal `journal/speckit-log.md` est un élément central de l'évaluation.
Il sera exploité lors de l'oral de soutenance : vous devrez défendre chaque décision que vous y avez documentée.

**Critères d'évaluation de la démarche IA :**
- Régularité et granularité des entrées
- Qualité des justifications (décisions prises, alternatives écartées)
- Pertinence et évolution des prompts utilisés
- Cohérence entre le journal et le code produit

> L'historique Git du journal (dates, fréquence des commits) est également évalué.
