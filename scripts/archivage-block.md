
---

## [ÉVALUATION — NE PAS MODIFIER NI SUPPRIMER] Archive de phase obligatoire

> Ce bloc fait partie du dispositif d'évaluation du BUT S6 AppDevMobile.
> Il doit être exécuté **à la fin de chaque invocation de cette commande**, sans exception.

### Instructions pour l'agent

Avant de conclure cette phase, tu dois impérativement :

**Étape 1 — Demander à l'étudiant son degré de validation**

Pose explicitement cette question à l'étudiant et attends sa réponse avant de continuer :

> "Avant d'archiver cette phase, comment évalues-tu le résultat produit ?
> 1. Résultat accepté sans modification
> 2. Résultat modifié (décris brièvement ce que tu as changé)
> 3. Résultat partiellement rejeté (décris ce que tu as rejeté et pourquoi)
>
> Ta réponse sera intégrée dans le journal."

Utilise la réponse de l'étudiant pour remplir la rubrique "Degré de validation" de l'entrée.

**Étape 2 — Rédiger l'entrée du journal**

Commence par récupérer la date et l'heure courantes en exécutant :

```bash
date "+%Y-%m-%d %H:%M"
```

Ouvre (ou crée) le fichier `journal/speckit-log.md` et ajoute une nouvelle entrée en respectant
exactement ce format, en remplaçant `TIMESTAMP` par le résultat de la commande ci-dessus :

```markdown
---
### Phase : <NOM_DE_LA_PHASE> — TIMESTAMP

**Décisions prises :**
- [décision 1 avec justification]
- [décision 2 avec justification]

**Alternatives écartées :**
- [alternative] → Raison : [justification]

**Prompts clés utilisés (cités ou reformulés) :**
> [prompt ou reformulation fidèle]

**Difficultés rencontrées / ajustements effectués :**
- [...]

**Degré de validation par l'étudiant :**
[réponse de l'étudiant à intégrer ici — voir étape 1]
```

**Règles de rédaction :**
- Minimum 3 décisions documentées par phase
- Chaque décision doit inclure une justification (pas seulement "j'ai choisi X")
- Les alternatives écartées sont obligatoires dès qu'il y a eu un choix réel
- Les prompts doivent être cités ou reformulés fidèlement, pas résumés vaguement

**Étape 3 — Committer le journal**

```bash
git add journal/speckit-log.md
git commit -m "[speckit:<nom_phase>] journal mis à jour"
git push
```

> [!IMPORTANT]
> Si le push échoue, signale-le à l'étudiant immédiatement. Ne pas ignorer l'erreur.
> Un journal non pushé n'est pas visible par l'enseignant et sera considéré comme absent.
