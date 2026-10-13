# Backend Task: Let players choose their team when joining a public game

## Summary

**New business rule (confirmed by the client):** in a **public** game, **any player** can choose which team to join, `team_1` (host) or `team_2` (opponent). This includes members of the creator's Diwaniya.

Today the backend decides the team itself: creator-Diwaniya members go to host, everyone else goes to opponent (`GameService::determineUserTeam()`, your answer to Q1 in `BACKEND_TASKS_GAME_TEAMS_PITCH.md`). The app now lets every player tap a slot in either half of the pitch in a public game and sends the chosen team. The backend needs to accept and respect it.

The client's rules:
- **Public game:** you can join team A or team B.
- **Private game:** you cannot choose. You play with your own Diwaniya.
- **My Diwaniya game:** you can choose any team.

## Rules per game type

| Game type | Player | Team |
|---|---|---|
| `public` | Anyone (creator's Diwaniya, another Diwaniya, or no Diwaniya) | **Their choice:** `team_1` or `team_2` (new) |
| `private` | Accepted member of the creator / opponent Diwaniya | Fixed by Diwaniya, no change |
| `my_diwanya` | Any member | Their choice, already supported, no change |

## What the app sends

The same field the app already sends for `my_diwanya` games, now also for `public` games:

```
POST /games/{id}/join
position=<goal_keeper|defender|center|attacker>
slot_index=<0-based slot in the team>
my_diwanya_team=<team_1|team_2>
```

- `team_1` = the host (creator) team, `team_2` = the opponent team. This is the same as `team_1` / `team_2` in `GET /games/{id}/players`, which the app shows on the pitch before the user joins (`team_1` on the top half).

If you prefer a clearer field name for public games (for example `team`), tell us and we will send that instead.

## Tasks

| # | Task | Endpoint | Done? |
|---|---|---|---|
| T1 | In a `public` game, for **every** player, use `my_diwanya_team` from the request to choose `host` (`team_1`) or `opponent` (`team_2`) | `POST /games/{id}/join` | ☐ |
| T2 | If `my_diwanya_team` is missing, keep today's behaviour (creator-Diwaniya member → `host`, anyone else → `opponent`) so older app versions still work | `POST /games/{id}/join` | ☐ |
| T3 | In `private` games, keep ignoring the requested team: the player always joins their own Diwaniya's team | `POST /games/{id}/join` | ☐ |
| T4 | Reject joining a team that is already full (`players_target / 2`) with **422** and a translated `msg`, for example «هذا الفريق مكتمل» / "This team is full" | `POST /games/{id}/join` | ☐ |
| T5 | Keep the "slot already taken" check (from the previous task) per chosen team | `POST /games/{id}/join` | ☐ |
| T6 | After joining, `GET /games/{id}/members` returns the chosen team as `my_team` for that player | `GET /games/{id}/members` | ☐ |
| T7 | Change position keeps the player in the team they chose (no team switch through change-position) | `POST /games/{id}/change-position` | ☐ |

## Test we will run

Setup: a **public** game created by Diwaniya **A**, 4 vs 4.

1. User **X** (member of Diwaniya B) opens the game and taps a free slot in the **top** half (host).
   - **Expected:** X joins `team_1`. On X's phone, X's team (the host team) is on the top half.
2. User **Y** (no Diwaniya) taps a free slot in the **bottom** half (opponent).
   - **Expected:** Y joins `team_2`.
3. A member of **A** taps a free slot in the **bottom** half (opponent).
   - **Expected:** they join `team_2`.
4. Fill the host team, then user **Z** tries to join the host team.
   - **Expected:** 422 "This team is full" in the app's language.
5. X uses **Change position** to another free slot.
   - **Expected:** X stays in `team_1`.
6. In a **private** game, a member of the opponent Diwaniya sends `my_diwanya_team=team_1`.
   - **Expected:** they still join their own Diwaniya's team (`team_2`).

## Release note

The app change and this backend change must go out **together**. If the app is released first, a player who taps the host half will still be placed in the opponent team.

## Please reply with

- The status of each row in the table.
- Whether you keep the field name `my_diwanya_team` or want a new one.
- One real `POST /games/{id}/join` response for a public game with `my_diwanya_team=team_1` from a non-creator user.
