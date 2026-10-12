# Backend Task: `GET /games-upcoming` returns only one public game

## Summary

The **Upcoming Games** screen shows only **one game**, and it is a `public` game. The user's upcoming `private` and `my_diwanya` games are missing.

The app shows every item in `data` from `GET /games-upcoming`, with no filter on type or status. It only changes the order (confirmed, then pending, then cancelled). So the list on screen is exactly what the endpoint returns.

## Evidence

User id **85** ("alaa magdy"). `GET /games-upcoming` returns a `data` array with **one** item. The end of that item:

```json
{
  "players": [
    {
      "id": 85,
      "name": "alaa magdy",
      "position": "attacker",
      "team": "team_1",
      "slot_index": "7"
    }
  ],
  "players_joines": null,
  "players_target": 18,
  "user_permission": null,
  "result": null,
  "chat_enabled": true
}
```

No `private` or `my_diwanya` game is returned, even when the user created it or joined it.

## Expected behaviour

`GET /games-upcoming` returns **every game whose booking date and time is still in the future** that the current user:
- created, or
- joined as a player, or
- belongs to through a Diwaniya (creator Diwaniya or opponent Diwaniya),

whatever its **type**:

| type | Must be returned |
|---|---|
| `public` | ✅ (works today) |
| `private` | ❌ missing |
| `my_diwanya` | ❌ missing |

It must also return these **statuses**, because the app shows a colored label for each one:

| game_status | Label in the app |
|---|---|
| confirmed / accepted | green |
| pending (private game waiting for the opponent Diwaniya to accept) | orange |
| rejected / cancelled | red |

Past games (`overdue` or finished) must **not** be returned. They belong in `GET /game-history` (see `BACKEND_TASKS_GAME_HISTORY_EMPTY.md`).

## Tasks

| # | Task | Endpoint | Done? |
|---|---|---|---|
| T1 | Find which filter limits the result to public games, or to games the user joined as a player | `GET /games-upcoming` | ☐ |
| T2 | Return the user's upcoming `private` and `my_diwanya` games as well as `public` ones | `GET /games-upcoming` | ☐ |
| T3 | Include pending private games (waiting for the opponent) and rejected/cancelled ones that are still in the future | `GET /games-upcoming` | ☐ |
| T4 | Exclude past games (booking date/time before now, in Kuwait time) | `GET /games-upcoming` | ☐ |
| T5 | Order by booking date and start time, nearest first | `GET /games-upcoming` | ☐ |
| T6 | Keep the current item shape (`booking.booking_date`, `booking.periods`, `creator_diwanya`, `opponent_diwanya`, `players`, `game_status`, `game_status_text`, `chat_enabled`) | `GET /games-upcoming` | ☐ |

## Test we will run

Setup: user 85 is admin of Diwaniya **A**. Diwaniya **B** exists with its own admin. All bookings are for future dates.

1. User 85 creates one game of each type:
   - a `my_diwanya` game in A;
   - a `public` game;
   - a `private` game against B, which B has **not** accepted yet.
2. Open **Upcoming Games** as user 85.
   - **Expected:** all 3 games are listed. The private game shows **pending**.
3. B's admin accepts the private game.
   - **Expected:** it is still listed, now shown as **confirmed**.
4. Open **Upcoming Games** as a regular member of A who did not join any game.
   - **Expected:** the `my_diwanya` and `private` games of A are listed (confirm with us if you think they should be listed only for players).
5. Wait until a game's time has passed.
   - **Expected:** it disappears from `/games-upcoming` and appears in `/game-history`.

## Please reply with

- What the query was filtering on, and what you changed.
- Your answer for step 4: should Diwaniya members see games they did not join?
- One real response of `GET /games-upcoming` for user 85 after the fix, with at least one game of each type.
