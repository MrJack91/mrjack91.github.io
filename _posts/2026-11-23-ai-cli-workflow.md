---
layout: post
# title: "Some articles are just so short that we have to make the footer stick"
categories: ai, cli, workflow, git, worktree, linux
# meta: "Springfield"
# modified_date: 2016-05-27
published: true
excerpt_separator: <!--end_excerpt-->
---

Möglicher Workflow um mit CLI LLM's und Git zu arbeiten.


<!--end_excerpt-->

**Grundregel:** Jeder Branch darf nur in **einem** Worktree gleichzeitig ausgecheckt sein. Alle Worktrees teilen sich dieselbe `.git`-Datenbank und dieselben Remote-Referenzen (`origin/*`).

---

## 1. Worktree erstellen & entwickeln

```bash
# Fetch latest remote references
git fetch origin

# Create a linked worktree with a new feature branch based on origin/main
git worktree add -b feature/my-feature ../repo-my-feature origin/main
cd ../repo-my-feature

# Commit and publish the feature branch
git add .
git commit -m "Implement feature"
git push -u origin feature/my-feature
```

---

## 2. Feature-Branch aktuell halten

Je nach Team-Situation unterscheidet sich das Vorgehen vor der Integration:

| Situation | Strategie im Feature-Worktree | Remote-Update |
| :--- | :--- | :--- |
| **Niemand hat etwas geändert** | Nichts nötig | `git push` |
| **Neue Commits auf `main`** (du bist allein auf dem Feature-Branch) | `git rebase origin/main` | `git push --force-with-lease` |
| **Mehrere Entwickler auf demselben Feature-Branch** | `git merge origin/main` | `git push` |

### Fall A: Allein auf dem Feature-Branch (Rebase)
```bash
# Fetch updated origin/main without checking out main
git fetch origin

# Replay local feature commits on top of the latest origin/main
git rebase origin/main

# Safely overwrite the remote feature branch after rewriting history
git push --force-with-lease
```
*(Hinweis: Nach einem Rebase **niemals** `git pull` ausführen, da sonst der alte Pre-Rebase-Commit wieder hineingemergt wird.)*

### Fall B: Gemeinsamer Feature-Branch (Merge)
```bash
# Integrate teammates' commits on the feature branch first
git fetch origin
git pull --rebase

# Merge updated main without rewriting shared commit history
git merge origin/main
git push
```

---

## 3. Änderungen vor dem Merge prüfen

```bash
# List commits on the feature branch not yet in main
git log main..feature/my-feature

# Show exact code diff that the feature introduces into main
git diff main...feature/my-feature
```

---

## 4. Sauber in `main` integrieren

### Variante A: Über Pull Request / Merge Request (Team-Standard)
* **Rebase and Merge / Fast-Forward:** Übernimmt lineare Einzel-Commits (aus Fall A).
* **Squash and Merge:** Fasst alle Feature-Commits zu einem einzigen Commit auf `main` zusammen.
* **Merge Commit:** Erhält die vollständige Historie bei geteilten Feature-Branches (aus Fall B).

### Variante B: Lokal über den Haupt-Worktree
```bash
# Switch back to the primary worktree where main is checked out
cd /pfad/zum/haupt-repo

# Update local main strictly via fast-forward
git pull --ff-only origin main

# Integrate the feature branch
git merge feature/my-feature

# Push updated main to remote
git push origin main
```

---

## 5. Worktree und Branches aufräumen

```bash
# Remove the linked worktree directory
git worktree remove ../repo-my-feature

# Delete the local feature branch (-D if integrated via Squash and Merge)
git branch -d feature/my-feature

# Delete the remote branch if not auto-deleted by the Git platform
git push origin --delete feature/my-feature
```