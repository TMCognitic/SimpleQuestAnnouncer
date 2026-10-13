# SimpleQuestAnnouncer

Addon World of Warcraft léger qui annonce automatiquement la progression de vos quêtes à votre groupe.

Dès qu'un objectif de quête évolue (par exemple `Loups tués : 3/8`), l'addon envoie un court message dans le chat de groupe ou de raid. Vos coéquipiers savent où vous en êtes sans que vous ayez à écrire quoi que ce soit.

## Fonctionnalités

- Annonce automatique de la progression des objectifs de quête.
- Annonce lorsque tous les objectifs d'une quête sont terminés.
- Envoi sur le canal **Raid** en raid, **Groupe** en groupe.
- Notification locale lors de l'acceptation ou de l'abandon d'une quête.
- Aucune annonce des objectifs déjà présents à la connexion : seules les nouvelles avancées sont signalées.
- Les mises à jour sont regroupées pour éviter le spam lors des rafales d'événements du journal de quêtes.
- Activation/désactivation simple, conservée entre les sessions.
- Aucune dépendance, aucune fenêtre de configuration.

## Format des messages

```
[Titre de la quête] Texte de l'objectif
[Titre de la quête] Objectives completed
```

Exemple :

```
[Wolves of the Forest] Wolf Pelt: 5/10
[Wolves of the Forest] Objectives completed
```

## Installation

1. Téléchargez ou clonez ce dépôt.
2. Copiez le dossier `SimpleQuestAnnouncer` (contenant `SimpleQuestAnnouncer.toc` et `SimpleQuestAnnouncer.lua`) dans le répertoire des addons :
   `World of Warcraft/_<version>_/Interface/AddOns/`
3. Relancez le jeu, ou tapez `/reload` s'il est déjà lancé.
4. Vérifiez que l'addon est activé dans la liste des addons de l'écran de sélection du personnage.

Le message `SimpleQuestAnnouncer loaded` apparaît dans le chat à la connexion.

## Utilisation

L'addon fonctionne tout de suite : rejoignez un groupe, avancez dans vos quêtes, les annonces partent automatiquement.

### Commandes

| Commande      | Effet                                          |
|---------------|------------------------------------------------|
| `/sqa on`     | Active les annonces                            |
| `/sqa off`    | Désactive les annonces                         |
| `/sqa status` | Affiche l'état actuel (activé / désactivé)     |
| `/sqa`        | Affiche la liste des commandes                 |

L'état est enregistré dans la variable sauvegardée `SimpleQuestAnnouncerDB` et persiste entre les sessions. Les annonces sont activées par défaut.

### Canal de sortie

| Situation | Destination                                                         |
|-----------|---------------------------------------------------------------------|
| En raid   | Canal `RAID`                                                        |
| En groupe | Canal `PARTY`                                                       |
| En solo   | Affichage local uniquement dans votre chat (pratique pour tester)   |

> En solo, rien n'est envoyé sur `SAY` ou `YELL` : le jeu bloque ces canaux lorsqu'ils ne sont pas déclenchés par un clic du joueur.

## Structure du projet

| Fichier                      | Rôle                                                    |
|------------------------------|---------------------------------------------------------|
| `SimpleQuestAnnouncer.toc`   | Métadonnées de l'addon et variables sauvegardées        |
| `SimpleQuestAnnouncer.lua`   | Code de l'addon                                         |
| `DESCRIPTION.md`             | Description et mode d'emploi (anglais)                  |
| `Icone_SQA.png`              | Icône de l'addon                                        |
| `LICENSE`                    | Licence MIT                                             |

## Fonctionnement technique

- Les événements `QUEST_LOG_UPDATE` et `PLAYER_ENTERING_WORLD` déclenchent un scan différé (0,2 s) du journal de quêtes.
- Chaque scan compare les textes d'objectifs de chaque quête avec ceux mémorisés lors du scan précédent, et annonce ceux qui ont changé.
- `QUEST_ACCEPTED` et `QUEST_REMOVED` affichent une notification locale et mettent le cache à jour.

## Licence

Distribué sous licence MIT. Voir le fichier [LICENSE](LICENSE).

## Auteur

TMCognitic
