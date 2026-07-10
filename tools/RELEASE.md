# Publier une release du patch IVèS

À faire depuis un clone avec le remote `origin` (fork) et `gh` authentifié.

```sh
# 0. Mettre à jour master depuis l'upstream (ohmybash/oh-my-bash)
git fetch upstream
git checkout master
git merge --ff-only upstream/master
git push origin master

# 1. Rebaser la branche sur le master à jour
git fetch origin
git checkout feat/install_local_without_git
git rebase origin/master
# ... résoudre les éventuels conflits, puis `git rebase --continue` ...

# 2. Générer le patch dans dist/omb-ives.patch
bash tools/generate_patch.sh

# 3. Créer la release avec le patch en asset
#    (la commande exacte, avec le bon commit, est affichée par le script ci-dessus)
COMMIT=$(git rev-parse --short "$(git merge-base origin/master HEAD)")
gh release create "omb-ives-$COMMIT" \
  --title "omb-ives-$COMMIT" \
  --generate-notes \
  "dist/omb-ives.patch"
```

Récupération et application du dernier patch (script de déploiement, sans git) :

```sh
curl -fsSL -o omb-ives.patch \
  https://github.com/bastien-martin/oh-my-bash/releases/latest/download/omb-ives.patch
# depuis la racine du répertoire oh-my-bash extrait :
patch -p1 < omb-ives.patch
```
