# Guide de configuration — Enseignant

> Ce fichier est destiné à l'enseignant. Il peut être supprimé du template avant
> de le publier, ou conservé en le renommant (il ne sera pas visible des étudiants
> s'il est exclu via `.gitignore` ou placé dans une branche séparée).

---

## 1. Création de l'organisation GitHub

1. Créer une organisation GitHub dédiée (ex. `iut-appdevmobile-2026`)
2. Inviter les co-enseignants avec le rôle **Owner**
3. Les étudiants n'ont PAS accès à l'organisation directement — GitHub Classroom gère cela

---

## 2. Configuration du dépôt template

1. Créer un dépôt **privé** dans l'organisation (ex. `template-appdevmobile-s6`)
2. Y pousser le contenu de ce répertoire :
   ```bash
   git init
   git add .
   git commit -m "init: template évaluation AppDevMobile S6"
   git remote add origin https://github.com/<org>/template-appdevmobile-s6.git
   git push -u origin main
   ```
3. Dans les paramètres du dépôt → cocher **"Template repository"**

---

## 3. Configuration de GitHub Classroom

1. Aller sur https://classroom.github.com
2. Créer une **nouvelle classroom** liée à l'organisation
3. Créer un **assignment** :
   - Type : **Individual**
   - Starter code : sélectionner `template-appdevmobile-s6`
   - Visibility : **Private**
   - Admin access : cocher **"Grant students admin access"** → NON (laisser décoché)
   - Deadline : selon le calendrier pédagogique

---

## 4. Protection de la branche principale (anti-manipulation)

Dans chaque dépôt étudiant (ou via les paramètres de l'organisation) :

**Settings → Branches → Add branch protection rule** sur `main` :
- [x] **Require a pull request before merging** → NON (trop contraignant pour les étudiants)
- [x] **Do not allow bypassing the above settings**
- [x] **Allow force pushes** → **DÉCOCHER** (c'est la protection clé)
- [x] **Allow deletions** → **DÉCOCHER**

> Cette configuration peut être automatisée via l'API GitHub ou via un GitHub Action
> dans le template (voir section 6).

---

## 5. Accès enseignant aux dépôts

GitHub Classroom donne automatiquement un accès **admin** à l'enseignant sur tous les
dépôts créés. Pour visualiser les journaux :

- **Vue d'ensemble** : GitHub Classroom → Assignment → liste des étudiants avec statut
- **Journal individuel** : `https://github.com/<org>/<depot-etudiant>/blob/main/journal/speckit-log.md`
- **Historique Git du journal** : `https://github.com/<org>/<depot-etudiant>/commits/main/journal/speckit-log.md`

---

## 6. GitHub Action recommandée (protection automatique)

Ajouter ce fichier dans le template pour protéger automatiquement la branche `main`
lors de la création de chaque dépôt étudiant :

**Fichier : `.github/workflows/protect-branch.yml`**

```yaml
name: Protect main branch
on:
  push:
    branches: [main]
    paths-ignore: ['**']  # Ne s'exécute qu'à la création

jobs:
  protect:
    runs-on: ubuntu-latest
    if: github.event.created == true
    steps:
      - name: Enable branch protection
        uses: actions/github-script@v7
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          script: |
            await github.rest.repos.updateBranchProtection({
              owner: context.repo.owner,
              repo: context.repo.repo,
              branch: 'main',
              required_status_checks: null,
              enforce_admins: false,
              required_pull_request_reviews: null,
              restrictions: null,
              allow_force_pushes: false,
              allow_deletions: false,
            });
            console.log('Branch protection enabled on main');
```

> Note : ce workflow nécessite que le token ait les droits `administration: write`.
> Dans GitHub Classroom, activer **"Grant workflows GITHUB_TOKEN read and write permissions"**
> dans les paramètres de l'organisation → Actions.

---

## 7. Grille d'évaluation de la démarche IA

| Critère | Insuffisant (0-4) | Satisfaisant (5-7) | Excellent (8-10) |
|---|---|---|---|
| **Régularité du journal** | Tout en fin de projet ou phases manquantes | Une entrée par phase principale | Entrées par phase + itérations d'implémentation |
| **Qualité des justifications** | Absentes ou "j'ai choisi X" sans raison | Raisons présentes | Alternatives documentées, trade-offs argumentés |
| **Pertinence des prompts** | Prompts génériques non cités | Prompts adaptés au contexte | Prompts itératifs, reformulations documentées |
| **Cohérence journal / code** | Incohérences majeures | Globalement cohérent | Traçabilité complète décision → implémentation |
| **Défense orale** | Ne reconnaît pas ses choix | Explique ses choix | Remet en question, argumente avec recul |

---

## 8. Préparation de l'oral de soutenance

Pour chaque étudiant, avant l'oral :

1. Lire `journal/speckit-log.md` dans son intégralité
2. Consulter le git log du journal : `git log --follow -p journal/speckit-log.md`
3. Repérer :
   - Les entrées vagues ou répétitives (signal de faible engagement)
   - Les entrées ajoutées en masse le même jour (signal de fabrication a posteriori)
   - Les décisions incohérentes avec le code produit
4. Préparer 3-5 questions ciblées par étudiant basées sur son journal

**Questions types :**
- "Tu as écrit que tu as écarté [alternative X], explique-moi pourquoi concrètement."
- "Ce prompt que tu as cité en phase Plan — qu'est-ce qui t'a amené à le formuler ainsi ?"
- "Entre ta phase Specify et ton implémentation finale, qu'est-ce qui a changé et pourquoi ?"
- "Tu as validé sans modification la sortie de l'agent sur cette tâche. Qu'aurais-tu fait différemment ?"
