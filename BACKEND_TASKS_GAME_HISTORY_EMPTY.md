# Backend Task: `GET /game-history` returns no games

## Summary

**My Games History** in the app is always empty. `GET /game-history` returns `items: []` and `total: 0`, but the same user has past games that other endpoints return.

The app sends the request correctly (bearer token, `Accept-Language`, `page`). It shows whatever `items` contains, so nothing will appear in the app until this endpoint returns the user's games.

## Evidence

Same user (id **85**, "alaa magdy"), same session, same token.

**1. `GET /game-history?page=1` → empty**

```json
{
  "status": true,
  "data": {
    "items": [],
    "paginate": { "total": 0, "count": 0, "per_page": 10, "current_page": 1, "total_pages": 1 },
    "extra": null
  }
}
```

**2. `GET /diwaniyas/33/games?page=1` → 10 past games for the same user**

The user created all 10 games and is in the `players` list of each (`"id": 85`). All of them are in the past:

| Game id | type | game_status | booking_date | result |
|---|---|---|---|---|
| 173 | private | overdue | 8 Oct 2026 | null |
| 174 | private | overdue | 9 Oct 2026 | null |
| 175 | my_diwanya | overdue | 8 Oct 2026 | null |
| 176 | my_diwanya | overdue | 5 Oct 2026 | null |
| 178 | my_diwanya | overdue | 5 Oct 2026 | null |
| 179 | public | overdue | 5 Oct 2026 | null |
| 180 | public | overdue | 5 Oct 2026 | null |
| 181 | public | overdue | 5 Oct 2026 | null |
| 184 | my_diwanya | overdue | 6 Oct 2026 | null |
| 185 | private | overdue | 6 Oct 2026 | null |

## Likely cause

`/game-history` probably only returns games that were finished with a result (for example `game_status = finished` or `result IS NOT NULL`). All of this user's past games are `overdue` with `result: null`, so the query matches nothing. Please check the query's filters on status, result, and how the user is linked to the game (creator, player, or Diwaniya member).

## Tasks

| # | Task | Endpoint | Done? |
|---|---|---|---|
| T1 | Find why the games above are not returned for user 85 | `GET /game-history` | ☐ |
| T2 | Return every past game the user **played in or created**, whatever its type (`private`, `public`, `my_diwanya`), including `overdue` games with no result | `GET /game-history` | ☐ |
| T3 | Order by booking date, newest first, and keep the current pagination format (`items`, `paginate`) | `GET /game-history` | ☐ |
| T4 | Keep the same item shape as `/diwaniyas/{id}/games` (`booking.booking_date`, `booking.periods`, `creator_diwanya`, `opponent_diwanya`, `result`, `game_status_text`) | `GET /game-history` | ☐ |

If `overdue` games are left out on purpose, please tell us which statuses count as "history" so we can show the right empty-state text in the app.

## Test we will run

1. Log in as user 85 and open **My Games History**.
   - **Expected:** games 173 to 185 are listed, newest booking date first.
2. Switch the app language between Arabic and English.
   - **Expected:** `game_status_text`, `booking_date` and playground names follow `Accept-Language`.
3. Log in as a user who has never played.
   - **Expected:** `items: []` with `total: 0` (the app shows its empty state).

## Please reply with

- What the query was filtering on, and what you changed.
- One real response of `GET /game-history?page=1` for user 85 after the fix.
