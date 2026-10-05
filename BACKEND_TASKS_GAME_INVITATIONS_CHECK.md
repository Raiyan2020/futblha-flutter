# Backend Task: Confirm the private-game invitation feature is complete

## Summary

The app side of the private-game invitation feature is finished:
- every member of the invited Diwaniya sees a **red** invitation notification;
- the **Games Invitations** menu item shows a red badge;
- tapping the notification opens Games Invitations;
- only the Diwaniya admin sees Accept / Reject.

All of this depends on the backend tasks T1 to T6 we sent earlier (`BACKEND_TASKS_GAME_INVITATIONS.md`). That checklist is still unticked on our side. **Please confirm each item below as done, or tell us what is still missing**, so we can run the end-to-end test and release.

## Checklist: please mark each one

| # | Task | Endpoint / place | Done? |
|---|---|---|---|
| T1 | When a **private** game is created, create a `game_invitation` notification for **every member** of the opponent Diwaniya (not only the admin) | `POST /games` | ☐ |
| T1 | `title` / `body` localized by `Accept-Language`. AR body: «هناك تحدي بينكم وبين ديوانية {اسم الديوانية}». `data` contains `game_id` | `GET /notifications` | ☐ |
| T2 | `receiving_games` returns the pending private game to **every member** of the invited Diwaniya, with `opponent_diwanya.user_permission.is_admin` filled for the current user | `GET /games-invitation` | ☐ |
| T3 | Accept and reject return **403** with a `msg` for non-admin members | `POST /games/{id}/accept`, `POST /games/{id}/reject` | ☐ |
| T4 | New endpoint returning `unread_count` and `pending_invitations_count` | `GET /notifications/unread-count` | ☐ |
| T4 | `pending_invitations_count` goes down **only** when the invitation is accepted or rejected. Reading the notification does **not** change it | same | ☐ |
| T5 | Mark one notification as read / mark all as read | `POST /notifications/{id}/read`, `POST /notifications/read-all` | ☐ |
| T5 | (Recommended) After accept or reject, mark that invitation's notifications as read for **all** members, so every member's bell clears | accept / reject | ☐ |
| T6 | FCM push to **every** member's `fcm_token`, with `data.type = "game_invitation"`, `data.game_id` and `data.notification_id`. All `data` values must be **strings** | Firebase | ☐ |

## Test we will run once you confirm

Setup: Diwaniya **A** (one admin), Diwaniya **B** (one admin + one regular member). The app is open on B's two phones, one in Arabic and one in English.

1. A's admin creates a **private** game against B.
   - **Expected:** both B members receive a **push**. Each push is in that phone's language.
   - **Expected:** both B members see a red notification in the list, saying there is a challenge with Diwaniya A.
   - **Expected:** both see badge **1** on the bell and on Games Invitations.
2. Both B members tap the notification.
   - **Expected:** it opens Games Invitations and the game is listed.
   - **Expected:** the bell count goes down, and the Games Invitations badge **stays at 1**.
3. The B **regular member** calls accept (for example from Postman).
   - **Expected:** `403` with a localized `msg`.
4. The B **admin** accepts.
   - **Expected:** the Games Invitations badge becomes **0** for both B members.
   - **Expected (if T5 recommendation done):** the invitation notification is marked read for both.
5. Repeat with **reject** on a new game.
   - **Expected:** same badge result as step 4.

## Please reply with

- The status of each row in the table (done / not done / changed).
- Anything you implemented differently from the original task: endpoint paths, field names, or the push payload.
- One **real example** of each of these, so we can compare with what the app reads:
  - the `GET /notifications/unread-count` response;
  - a `game_invitation` item from `GET /notifications`;
  - the FCM push `data` payload.
