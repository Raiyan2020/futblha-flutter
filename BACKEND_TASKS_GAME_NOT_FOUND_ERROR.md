# Backend Task: "No query results for model [App\Models\Game] 189" on Game Details

## Summary

On **Game Details**, the app showed this raw error in a red message:

> No query results for model [App\Models\Game] 189

There are two problems:

1. **The game cannot be found.** The game id `189` came from the backend itself: the app opened Game Details from a game returned by a list endpoint. Then a `/games/189/...` request answered that the game does not exist. A list endpoint and the game endpoints disagree about the same game.
2. **The error message is not usable.** It is Laravel's default `ModelNotFoundException` text. It is always in English (it ignores `Accept-Language: ar`) and it shows the internal model name `App\Models\Game` to the user.

## What the app sends (checked on the mobile side)

- The game id is never typed or built by the app. It is the `id` of the game object returned by the list endpoint (Upcoming Games, Diwaniya games, Active Games…), passed unchanged to Game Details.
- When Game Details opens, and when the user acts on it, the app calls these endpoints with that same id:

| Action | Request |
|---|---|
| Open Game Details | `GET /games/{id}`, `GET /games/{id}/members` |
| Change position (تغيير المركز) | `POST /games/{id}/change-position` with `position`, `slot_index` |
| Join / leave | `POST /games/{id}/join`, `POST /games/{id}/leave` |
| Book playground | `GET /games/{id}/booking-available` |

- Every request sends `Authorization: Bearer …` and `Accept-Language` (`ar` or `en`, the app's language). Other errors, such as validation errors, already come back translated, so the header works.
- The app shows the `msg` field of the error response exactly as received.

## Tasks

| # | Task | Endpoint | Done? |
|---|---|---|---|
| T1 | Find why game **189** is not found. Check whether it was deleted or soft-deleted, or whether a query scope (status, type, user, Diwaniya) hides it from the `/games/{id}` routes while list endpoints still return it | `/games/{id}/*` | ☐ |
| T2 | Make list endpoints and game endpoints agree. A game returned in any list (`/games-upcoming`, `/diwaniyas/{id}/games`, `/active-games`, `/games-invitation`) must be readable by `GET /games/{id}` for the same user. If a deleted game should not be shown, remove it from the lists as well | lists + `/games/{id}` | ☐ |
| T3 | Handle `ModelNotFoundException` / `NotFoundHttpException` in the exception handler. Return **404** with a translated `msg` and never the model class name | all API routes | ☐ |
| T4 | Use a per-model message when possible, for example `msg` = «المباراة غير موجودة» / "Game not found" for games | all API routes | ☐ |

Example of the expected response for T3/T4:

```json
// GET /games/189 with Accept-Language: ar
{ "status": false, "msg": "المباراة غير موجودة" }

// GET /games/189 with Accept-Language: en
{ "status": false, "msg": "Game not found" }
```

## Test we will run

1. Call `GET /games/999999` (an id that does not exist), once with `Accept-Language: ar` and once with `Accept-Language: en`.
   - **Expected:** 404, with a `msg` in the requested language that does not mention `App\Models`.
2. In the app (Arabic), open a game from **Upcoming Games**, then tap **تغيير المركز** and pick a free slot.
   - **Expected:** the position changes and the success message appears.
3. Delete or cancel a game from the backend while it is open on a phone, then tap **تغيير المركز** on that phone.
   - **Expected:** a translated "game not found" message, and the game no longer appears in the lists after refresh.
4. Open game **189** again for the user who saw the error.
   - **Expected:** either it opens normally, or it no longer appears in any list.

## Please reply with

- Why game 189 was not found (deleted, scope, or something else), and which request returned the error.
- The status of each row in the table.
- One real response of `GET /games/999999` in Arabic and in English after the fix.
