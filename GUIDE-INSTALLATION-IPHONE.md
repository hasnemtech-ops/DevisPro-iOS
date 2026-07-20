# Installer Devis Pro sur un vrai iPhone, sans Mac (via Sideloadly)

## Le principe

1. GitHub Actions compile un fichier `.ipa` **non signé** (workflow "Build iOS (.ipa pour iPhone réel)")
2. Vous téléchargez ce `.ipa`
3. **Sideloadly**, installé sur votre PC Windows, le signe avec votre identifiant Apple **gratuit** et l'installe directement sur l'iPhone connecté en USB

Aucun Mac n'est nécessaire à aucun moment.

## Limites du compte Apple gratuit (à connaître avant de commencer)

- L'app installée doit être **re-signée tous les 7 jours** (Apple limite ainsi les comptes gratuits) — après 7 jours, l'app cesse de s'ouvrir tant que vous n'avez pas refait l'opération (quelques minutes avec Sideloadly, pas besoin de recompiler)
- Un compte gratuit peut avoir seulement environ **3 apps actives** à la fois via ce système
- Un compte payant (99$/an) supprime ces deux limites (validité 1 an, pas de limite de nombre d'apps) — à envisager si l'app devient votre outil principal

## Étape 1 — Récupérer le fichier .ipa

1. Ajoutez le fichier `build-ios-device.yml` fourni ici dans `.github/workflows/` de votre dépôt `devispro-ios` (même méthode que pour les workflows précédents : "Add file" → "Create new file" → coller le chemin et le contenu)
2. Onglet **Actions** → attendez que "Build iOS (.ipa pour iPhone réel)" se termine (✅, environ 5-8 minutes)
3. Ouvrez le run → section **Artifacts** en bas → téléchargez **"DevisPro-iOS-unsigned-ipa"**
4. Dézippez : vous obtenez `DevisPro-unsigned.ipa`

## Étape 2 — Installer Sideloadly sur votre PC Windows

1. Allez sur **[sideloadly.io](https://sideloadly.io)** → téléchargez la version Windows
2. ⚠️ **Important** : Sideloadly a besoin d'iTunes pour communiquer avec l'iPhone. Installez la **version "iTunes pour Windows" classique depuis le site Apple** (apple.com/itunes), **pas** celle du Microsoft Store — Sideloadly ne fonctionne pas avec la version Store
3. Installez Sideloadly

## Étape 3 — Connecter l'iPhone et installer

1. Branchez l'iPhone au PC en USB
2. Sur l'iPhone, si demandé, appuyez sur **"Faire confiance à cet ordinateur"**
3. Ouvrez Sideloadly — l'iPhone doit apparaître dans la liste déroulante en haut
4. Glissez-déposez `DevisPro-unsigned.ipa` dans la fenêtre de Sideloadly
5. Dans le champ **Apple ID**, entrez l'e-mail de votre identifiant Apple **gratuit** (celui créé plus tôt sur appleid.apple.com) et son mot de passe — Sideloadly l'utilise uniquement pour signer, comme le ferait Xcode
6. Cliquez sur **Start**
7. Patientez (peut prendre plusieurs minutes la première fois)

## Étape 4 — Autoriser l'app sur l'iPhone (obligatoire, une seule fois par certificat)

Une fois l'installation terminée, l'app n'est pas encore autorisée à s'exécuter :

1. Sur l'iPhone : **Réglages → Général → VPN et gestion de l'appareil**
2. Sous "App développeur", vous verrez votre identifiant Apple → appuyez dessus
3. Appuyez sur **"Faire confiance à [votre identifiant]"** → confirmez

L'app "Devis Pro" est maintenant utilisable normalement sur l'iPhone.

## Pour la suite (dans 7 jours)

Quand l'app cesse de s'ouvrir : rebranchez l'iPhone, rouvrez Sideloadly, refaites l'étape 3 avec le même fichier `.ipa` (pas besoin de recompiler sur GitHub, sauf si vous avez modifié le code entre-temps).
