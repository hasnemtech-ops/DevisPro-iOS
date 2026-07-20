# Devis Pro — version iPhone (iOS)

Application de devis autonome (hors-ligne), packagée en app iOS native avec WKWebView.

⚠️ **Ce projet ne peut être compilé que sur un Mac équipé de Xcode.** Je n'ai pas pu le tester moi-même (pas de Mac/Xcode disponible dans mon environnement) — si une erreur de compilation apparaît à l'ouverture, envoyez-moi le message exact et je corrige.

## Prérequis

- Un **Mac** avec **Xcode** installé (gratuit sur le Mac App Store)
- Un identifiant Apple (gratuit) pour signer l'app et l'installer sur votre iPhone en test
- Un compte **Apple Developer payant (99$/an)** uniquement si vous voulez la publier sur l'App Store — pas nécessaire pour l'installer sur votre propre iPhone en développement

## Étape 1 — Générer le projet Xcode

Ce dossier contient les fichiers sources (Swift, HTML, icônes) mais pas le fichier `.xcodeproj` lui-même — on le génère avec l'outil **XcodeGen**, plus fiable qu'un fichier de projet écrit à la main.

Dans le Terminal du Mac :

```
brew install xcodegen
cd DevisPro-iOS
xcodegen generate
open DevisPro.xcodeproj
```

## Étape 2 — Configurer la signature

Dans Xcode, une fois le projet ouvert :
1. Cliquez sur le projet **DevisPro** dans la barre latérale, puis sur la cible **DevisPro**
2. Onglet **Signing & Capabilities**
3. Cochez **Automatically manage signing**
4. Choisissez votre **Team** (votre identifiant Apple gratuit apparaît ici — sinon, ajoutez-le via Xcode > Settings > Accounts)

## Étape 3 — Lancer sur votre iPhone

1. Branchez votre iPhone en USB (ou connectez-le au même réseau Wi-Fi)
2. Sélectionnez votre iPhone dans la liste des appareils en haut de Xcode (à côté du bouton ▶️)
3. Cliquez sur **▶️ Run**
4. Sur l'iPhone, la première fois : **Réglages > Général > VPN et gestion d'appareil** → faites confiance à votre identifiant développeur

Avec un compte Apple gratuit, l'app doit être réinstallée tous les 7 jours (limite Apple). Avec un compte payant (99$/an), elle reste installée durablement et peut être distribuée plus largement (TestFlight, App Store).

## Ce que contient le projet

- **WKWebView** chargeant `www/electricien-devis.html` (même application que les versions web/Android/Desktop)
- **localStorage** natif → vos devis restent sauvegardés sur l'iPhone
- **Pont d'impression natif** : le bouton "Aperçu / Imprimer PDF" ouvre la feuille d'impression iOS (AirPrint, enregistrer en PDF, partager)
- **Sélecteur de photo natif** pour l'import du logo (pellicule photo)
- Les liens externes (bouton **WhatsApp**) s'ouvrent dans Safari / l'app WhatsApp, jamais dans la WebView
- **Aucune permission réseau** requise — tout fonctionne hors-ligne. Seule la photothèque est demandée (pour le logo)

## Licence

Le système de licence (identifiant client + clé d'activation, valable 365 jours glissants, multi-écrans) est strictement identique aux autres versions : même secret `LICENSE_SECRET` dans `www/electricien-devis.html`, même `generateur-cles.html` pour produire les clés.

## Solution alternative sans XcodeGen

Si vous préférez ne pas installer XcodeGen : ouvrez Xcode, créez un nouveau projet **App** (iOS, Swift, UIKit/Storyboard : "Storyboard" peut être laissé sur "None" si proposé), nommez-le `DevisPro`, puis remplacez/ajoutez manuellement dans le projet créé les fichiers `AppDelegate.swift`, `SceneDelegate.swift`, `ViewController.swift`, `Info.plist`, le dossier `www/` et `Assets.xcassets/AppIcon.appiconset/` fournis ici (glissez-les dans le navigateur de projet Xcode, en cochant "Copy items if needed").
