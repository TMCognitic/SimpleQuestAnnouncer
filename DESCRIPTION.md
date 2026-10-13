# SimpleQuestAnnouncer

## Description

SimpleQuestAnnouncer is a lightweight World of Warcraft addon that automatically announces your quest progress to your group.

Whenever a quest objective changes (for example `Wolves slain: 3/8`), the addon posts a short message in your party or raid chat, so your teammates always know where you stand without you having to type anything. When every objective of a quest is done, it also announces `Objectives completed`.

### Features

- Automatic announcements of quest objective progress.
- Announcement when all the objectives of a quest are completed.
- Sends to **Raid** chat when you are in a raid, **Party** chat when you are in a party.
- Local notifications when a quest is accepted or removed.
- No announcement of the objectives that already existed when you log in, only new progress is reported.
- Updates are batched, so a burst of quest log events produces no spam.
- Simple on/off switch, saved between sessions.
- No dependency, no configuration window.

### Message format

```
[Quest Title] Objective text
[Quest Title] Objectives completed
```

Example:

```
[Wolves of the Forest] Wolf Pelt: 5/10
[Wolves of the Forest] Objectives completed
```

## Usage

The addon works out of the box: join a group, progress in your quests, and the announcements are sent automatically.

### Slash commands

| Command       | Effect                                    |
|---------------|-------------------------------------------|
| `/sqa on`     | Enable announcements                      |
| `/sqa off`    | Disable announcements                     |
| `/sqa status` | Show whether announcements are enabled    |
| `/sqa`        | Show the list of available commands       |

The enabled/disabled state is stored in the `SimpleQuestAnnouncerDB` saved variable and persists across sessions. Announcements are enabled by default.

### Behavior details

| Situation        | Where the announcement goes                                      |
|------------------|------------------------------------------------------------------|
| In a raid        | `RAID` chat                                                      |
| In a party       | `PARTY` chat                                                     |
| Solo             | Displayed only in your own chat frame                            |

Notes:

- The first scan after login or a loading screen only records the current state of your quest log; it does not announce anything.
- If you disable the addon with `/sqa off`, nothing is sent to your group.

## License

Released under the MIT License. See the [LICENSE](LICENSE) file.
