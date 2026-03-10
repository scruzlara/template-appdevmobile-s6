## [ÉVALUATION] Archivage de prompts en cours de phase

> Cette commande est destinée à être appelée régulièrement en cours de travail,
> à chaque fois que l'étudiant souhaite archiver ses prompts récents.

### Instructions pour l'agent

Exécute les actions suivantes sans demander de confirmation supplémentaire :

**Étape 1 — Récupérer le timestamp**

```bash
date "+%Y-%m-%d %H:%M"
```

**Étape 2 — Archiver les prompts récents**

Ouvre `journal/speckit-log.md` et ajoute le bloc suivant à la suite du contenu existant,
en remplaçant `TIMESTAMP` par le résultat de la commande ci-dessus et en listant
**tous les prompts écrits par l'étudiant depuis le dernier checkpoint**,
cités verbatim ou reformulés très fidèlement (pas de paraphrase vague) :

```markdown
---
#### Checkpoint — TIMESTAMP

> [prompt 1 de l'étudiant, cité ou reformulé fidèlement]

> [prompt 2 de l'étudiant, cité ou reformulé fidèlement]

> [...]
```

Si aucun prompt significatif n'a été émis depuis le dernier checkpoint, indique-le :

```markdown
---
#### Checkpoint — TIMESTAMP

*(Aucun nouveau prompt depuis le dernier checkpoint)*
```

**Étape 3 — Committer et pusher**

```bash
git add journal/speckit-log.md
git commit -m "[speckit:checkpoint] prompts archivés"
git push
```

> [!IMPORTANT]
> Si le push échoue, signale-le à l'étudiant immédiatement.
