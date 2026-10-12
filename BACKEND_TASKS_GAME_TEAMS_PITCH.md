# Backend Task: Make game teams (`my_team` / `opposing_team`) clear and correct on the pitch

## Summary

During testing, a player tapped **Change position** (تغيير المركز) on Game Details and could pick slots in the half the tester thought was the **opponent's** half. In the app, the half you can pick is always the half of the team the backend puts you in. So either the backend placed the player in the wrong team, or the rule for which team appears where needs to change.

The app does **not** decide which team a player is in. The backend decides it when the player joins, and returns it in `GET /games/{id}/members`. We need you to confirm the team rules below and fix any wrong team assignment.

## How the app works today

1. **Members.** `GET /games/{id}/members` returns either:
   - `my_team` and `opposing_team` (relative to the logged-in user), or
   - `team_1` and `team_2` (absolute teams), used when `my_team` is missing.
2. **Pitch layout.** The app draws `my_team` (or `team_1`) on the **top** half and `opposing_team` (or `team_2`) on the **bottom** half. Each player is drawn in the half of the list they come from. The app ignores each player's `team_index` for this.
3. **Change position.** The app looks for the logged-in user's id in the two lists. Only the empty slots in **that user's half** can be tapped. The request is:
   ```
   POST /games/{id}/change-position
   position=<goal_keeper|defender|center|attacker>
   slot_index=<0-based slot in the team>
   ```
   No team is sent. The backend keeps the player in their current team.
4. **Join.**
   ```
   POST /games/{id}/join
   position=<…>
   slot_index=<…>
   my_diwanya_team=<team_1|team_2>   // only for type = my_diwanya
   ```
   For `private` and `public` games no team is sent, so the backend picks the team.

## Questions to answer

| # | Question |
|---|---|
| Q1 | For `private` and `public` games, how do you choose the team on join? Creator's Diwaniya members → `team_1`, opponent Diwaniya members → `team_2`? What about a public-game player who is in neither Diwaniya? |
| Q2 | Does `GET /games/{id}/members` always return `my_team` / `opposing_team` for a player in the game? When do you return `team_1` / `team_2` instead (non-members, guests, `my_diwanya` games)? |
| Q3 | For a user who has **not** joined yet, what is `my_team`: empty, missing, or the team they would join? |
| Q4 | In `my_diwanya` games, is `my_diwanya_team=team_1` always the creator side, and which list (`my_team` / `team_1`) is it returned in? |

## Tasks

| # | Task | Endpoint | Done? |
|---|---|---|---|
| T1 | Answer Q1–Q4 above | — | ☐ |
| T2 | On join, put each player in the team of **their own Diwaniya** (creator Diwaniya → creator team, opponent Diwaniya → opponent team). A player must never land in the other Diwaniya's team | `POST /games/{id}/join` | ☐ |
| T3 | On change position, keep the player in their current team and reject a `slot_index` that is already taken in that team (with a translated `msg`) | `POST /games/{id}/change-position` | ☐ |
| T4 | Return the same shape for every member: `my_team` = the logged-in user's team (including the user), `opposing_team` = the other team. Each player keeps `slot_index` and `position` | `GET /games/{id}/members` | ☐ |
| T5 | Add `team` (`team_1` / `team_2`) to every player in `my_team` and `opposing_team`, so we can show which Diwaniya each half belongs to | `GET /games/{id}/members` | ☐ |
| T6 | Check existing games for players stored in the wrong team (a Diwaniya member stored in the other Diwaniya's team) and fix them | database | ☐ |

## Optional: if the business rule should change

If the product wants a different rule, for example "the creator's Diwaniya is always on top and the opponent is always at the bottom for every viewer", tell us. In that case, please return `team_1` / `team_2` for everyone (plus a flag for the user's own team), and we will update the app to match. The app will keep following `my_team` on top until we agree on that.

## Test we will run

Setup: Diwaniya **A** (creator) and Diwaniya **B** (opponent), a **private** game A vs B with 4 vs 4.

1. A member of **A** joins a slot.
   - **Expected:** they appear in `my_team` for themselves, and in `opposing_team` for B members.
2. A member of **B** joins a slot.
   - **Expected:** they appear in `my_team` for themselves (top half on their phone), never with A's players.
3. Each of them taps **Change position** and picks a free slot.
   - **Expected:** they move within their own team. The other team does not change.
4. One of them picks a slot that was just taken by a teammate.
   - **Expected:** an error with a translated `msg`.
5. Repeat steps 1–3 with a **public** game and a **my_diwanya** game (choosing `team_1` and `team_2`).

## Please reply with

- Your answers to Q1–Q4.
- The status of each row in the table.
- One real `GET /games/{id}/members` response for a member of A and one for a member of B, for the same game.
