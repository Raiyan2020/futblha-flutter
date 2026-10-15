# Backend Task: Friends (add / accept / reject) and inviting friends to a match

## Summary

The app needs two connected features:

1. **Friends.** On a player's card in a match (`PlayerInfoBottomSheet`), a user can tap **إضافة صديق** to send a friend request. The other user gets a notification and can **قبول** (accept) or **رفض** (reject). The card shows the real state: not friends / request sent / request received / friends.
2. **Invite friends to a match.** On the match page (صفحة التشكيلة), a **دعوة الأصدقاء** option lists the user's friends. The user picks some and invites them to the match.

**The app has no API for either feature.** There is no friendship endpoint, no friends list, and no way to invite a single player to a match. `/games-invitation` is only for Diwaniya-vs-Diwaniya challenges. We won't build the screens until the API exists, so we don't ship a fake flow.

The endpoints and fields below are a **proposal**. Use them, or send us yours and we'll match them.

## What the app has today

- **Player card:** opened by tapping a player on the match pitch. It shows the photo, name and position from `GET /games/{id}/members`. Each player has `id`, `name`, `image`, `position`, `position_text`, `slot_index`, `team_index`, `team`. **No friendship data.**
- **The current user's id** is known (stored at login), so the app can hide "إضافة صديق" on the user's own card.
- **Push notifications:** the app reads `type` and `notification_id` from the push `data`. The in-app list has `type`, `title`, `body`, `data` (JSON string), `is_read`. Only `type = "game_invitation"` opens a screen today.
- **Joining a match:** `POST /games/{id}/join` with `position`, `slot_index` (and `my_diwanya_team` for my_diwanya games).

## Questions to answer

| # | Question |
|---|---|
| Q1 | Can any user send a friend request to any other user, or only to players they share a match or Diwaniya with? |
| Q2 | Is friendship mutual (request + accept), as assumed here? Can a user remove a friend or cancel a sent request? |
| Q3 | If A sends a request to B while B already sent one to A, should the backend make them friends right away? |
| Q4 | Who can invite friends to a match: only the creator, or any member? For which match types (`public`, `my_diwanya`, `private`)? |
| Q5 | Does a match invitation reserve a place for the friend, or does the friend still join normally (picks a free position through `/join`) and may find the match full? |
| Q6 | Can an invited friend decline? Do invitations expire (e.g. when the match is full, cancelled, finished or started)? |
| Q7 | For `my_diwanya` games, can you invite a friend who isn't a member of your Diwaniya? For `private` games, only members of the two Diwaniyas? |

## Proposed API

### Friends

| # | Method + endpoint | Request | Success | Errors |
|---|---|---|---|---|
| F1 | `GET /games/{id}/members` (existing) | — | Add to **each player**: `friendship_status`: `self` \| `none` \| `request_sent` \| `request_received` \| `friends`, and `friend_request_id` when there is a pending request. One call gives the card everything it needs | — |
| F2 | `POST /friend-requests` | `user_id` | `201 { "data": { "id": 15, "status": "request_sent" } }`. If the other user already sent a request (Q3): `200 { "status": "friends" }` | `422` user_id missing or is yourself · `404` user not found · `409` already sent / already friends (with the current `friendship_status`) |
| F3 | `POST /friend-requests/{id}/accept` | — | `200 { "data": { "status": "friends" } }` | `403` you aren't the receiver · `404` · `409` already accepted / rejected / cancelled |
| F4 | `POST /friend-requests/{id}/reject` | — | `200 { "data": { "status": "none" } }` | `403` · `404` · `409` already handled |
| F5 | `GET /friend-requests?type=received` | — | Pending requests: `[{ id, user: { id, name, image }, created_at }]` | — |
| F6 | `GET /friends` (paginated) | `page` | `[{ id, name, image, position, position_text }]` | — |
| F7 | `DELETE /friend-requests/{id}` (cancel) and `DELETE /friends/{user_id}` (remove), if Q2 says yes | — | `200` | `403`, `404` |

Every `msg` must be translated (`Accept-Language`).

### Inviting friends to a match

| # | Method + endpoint | Request | Success | Errors |
|---|---|---|---|---|
| M1 | `GET /games/{id}/invitable-friends` | — | The user's friends, each with `invite_status`: `can_invite` \| `already_member` \| `already_invited` \| `not_eligible`, plus a translated `reason` when not invitable (e.g. "not a member of the Diwaniya") | `403` user can't invite to this match (Q4) · `422` match full / cancelled / finished / started |
| M2 | `POST /games/{id}/invite-friends` | `user_ids[]` | `200` with a result **per user**: `[{ user_id, status: "invited" \| "already_member" \| "already_invited" \| "not_eligible", msg }]`. One invitation per user per match, even if called twice | `403` · `422` match full / closed · `422` a user_id isn't your friend |
| M3 | `POST /game-player-invitations/{id}/decline` (if Q6 says yes) | — | `200` | `403`, `404`, `409` already handled |

Joining stays on the existing `POST /games/{id}/join`, with the same capacity and position checks.

### Notifications

| # | Type | Sent to | Push `data` and in-app `data` JSON |
|---|---|---|---|
| N1 | `friend_request` | Receiver | `friend_request_id`, `user_id`, `user_name` |
| N2 | `friend_request_accepted` | Sender | `user_id` |
| N3 | `game_player_invitation` | Invited friend | `game_id`, `invitation_id`, `inviter_name` |

The app will show **قبول / رفض** on `friend_request` items, calling F3 / F4. Tapping `game_player_invitation` opens the match page, where the friend can join.

## Tasks

| # | Task | Priority | Done? |
|---|---|---|---|
| T1 | Answer Q1–Q7 | High | ☐ |
| T2 | F1–F4 with the validation and error codes above, safe against double taps and two devices: one pending request per pair, using a unique index on the user pair | **Critical** | ☐ |
| T3 | F5, F6 (and F7 if needed) | High | ☐ |
| T4 | N1, N2 notifications. Accepting or rejecting an old request returns `409`, not a second friendship | High | ☐ |
| T5 | M1, M2 with permission (Q4), eligibility (Q7), capacity and match-state checks. One invitation per user per match | High | ☐ |
| T6 | N3 notification, and M3 / expiry if Q6 says yes | Medium | ☐ |

## What the app will build once this exists

- **Player card:** the add-friend icon in the card's top corner. It's hidden on the user's own card. It shows a loading state and blocks double taps, then "request sent", "accept / reject", or "friends", all from F1–F4.
- **Notifications:** `friend_request` items with **قبول / رفض**, which refresh the request after the action.
- **Match page:** a **دعوة الأصدقاء** option that opens a friends picker (M1). Friends who can't be invited are disabled with the reason. The picker sends M2 and shows the result for each friend.
- **Tapping `game_player_invitation`** opens the match page.

## Test we will run

1. A opens B's card in a match and taps **إضافة صديق**.
   - **Expected:** `201`, and the card shows "request sent". A second tap or a second device gets `409`.
2. B gets the notification.
   - Accept: both cards show "friends".
   - Reject instead: A's card shows "add friend" again.
3. B accepts an old request that A already cancelled.
   - **Expected:** `409`.
4. A opens their own card.
   - **Expected:** `friendship_status = self`, so there is no add-friend icon.
5. A invites B and C to a public match where C is already a member.
   - **Expected:** B = `invited`, C = `already_member`. Inviting B again gives `already_invited`.
6. Invite to a full or finished match.
   - **Expected:** `422`.
7. A non-allowed member invites (if Q4 says creator only).
   - **Expected:** `403`.

## Please reply with

- Your answers to Q1–Q7.
- The status of each row in the table.
- The final endpoints and field names.
- One real response each for F1, M1 and M2.
