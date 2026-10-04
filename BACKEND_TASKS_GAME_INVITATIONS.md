# Backend Tasks: Private Game Invitations (Invited Diwaniya)

## Feature summary

When a Diwaniya creates a **private** game against another Diwaniya, the invited Diwaniya must be notified as follows:

1. **Every member** of the invited Diwaniya receives a **push notification** on their phone and an **in-app notification** in the Notifications screen: *"There is a challenge between you and {Diwaniya name}"*.
2. The app shows a **red badge** on the notifications bell and on the **Games Invitations** menu item.
3. Tapping the push notification, or the notification inside the app, opens **Games Invitations**, under the Receiving Games tab.
4. **Only admins** of the invited Diwaniya can accept or reject the invitation. Other members can view it only.
5. The Games Invitations badge clears **only after the invitation is accepted or rejected**.

## Compatibility rules (apply to every task below)

- **Do not rename, remove or change the type of any existing field or endpoint.** Older app versions must keep working without changes.
- Every change below either **adds a new field** or **adds a new endpoint**. Older apps ignore fields they don't know.
- Keep the response envelope used today: `{ "data": ..., "pagination": ... }`, with errors returned as `msg` / `message`.
- Keep `is_read` as a number (`0` / `1`), the same as today.
- Localize `title` and `body` using the `Accept-Language` header (`en` / `ar`), which the app already sends.

---

## Task 1: Notify every member of the invited Diwaniya

**Trigger:** a game is created with `type = "private"` and an opponent Diwaniya (the existing `POST /games`).

**Action:** create one notification row for **each member** of the opponent Diwaniya, not only its admin or creator.

Use the **existing** notification fields only. No new columns are needed on the notification item:

| Field (existing) | Value |
|---|---|
| `type` | `"game_invitation"` |
| `title` | e.g. EN `"New challenge!"` / AR `"تحدي جديد!"` |
| `body` | EN `"There is a challenge between you and {creator_diwaniya_name}"` / AR `"هناك تحدي بينكم وبين ديوانية {creator_diwaniya_name}"` |
| `data` | JSON **string** (the app already treats `data` as a JSON string): `{"game_id": 123, "creator_diwanya_id": 10, "opponent_diwanya_id": 20}` |
| `is_read` | `0` |

Example item in `GET /notifications` (same shape as today):

```json
{
  "id": 501,
  "user_id": 77,
  "order_id": null,
  "type": "game_invitation",
  "title": "New challenge!",
  "body": "There is a challenge between you and Al-Nasr Diwaniya",
  "data": "{\"game_id\":123,\"creator_diwanya_id\":10,\"opponent_diwanya_id\":20}",
  "is_read": 0,
  "created_at": "2026-10-04 18:30"
}
```

This notification must appear in the user's in-app list (`GET /notifications`). It must also be sent as a **push notification**, as described in Task 6.

---

## Task 2: Show the invitation to all members in `GET /games-invitation`

Existing endpoint, existing response shape: `receiving_games` and `sending_games`.

- `receiving_games` must include the pending private game for **every member** of the invited Diwaniya, not only admins.
- Inside each game, the existing `opponent_diwanya` object must include its **existing** `user_permission.is_admin` for the current user. The app uses this to decide whether to show the Accept/Reject buttons. No new key is needed:

```json
"opponent_diwanya": {
  "id": 20,
  "name": "...",
  "image": "...",
  "user_permission": { "is_admin": true, "is_member": true, "can_join": false, "can_leave": true }
}
```

---

## Task 3: Allow only admins to accept or reject

Existing endpoints:
- `POST /games/{id}/accept`
- `POST /games/{id}/reject`

Change: if the current user is **not an admin** of the opponent Diwaniya, return **403** with the usual error body. The app shows `msg` or `message` to the user:

```json
{ "msg": "Only the Diwaniya admin can accept or reject this challenge" }
```

Successful responses stay the same as today.

---

## Task 4: Unread and badge counts (new endpoint)

`GET /notifications/unread-count`

```json
{
  "data": {
    "unread_count": 3,
    "pending_invitations_count": 1
  }
}
```

- `unread_count` is the number of the current user's notifications with `is_read = 0`, across all types. It drives the red badge on the bell.
- `pending_invitations_count` is the number of games in the user's `receiving_games` that are still waiting for an accept or reject. It drives the red badge on **Games Invitations**, and it must **only decrease when the invitation is accepted or rejected**. Opening or reading the notification does not change it.

---

## Task 5: Mark notifications as read (new endpoints)

| Endpoint | Purpose |
|---|---|
| `POST /notifications/{id}/read` | Mark one notification as read. The app calls this when the user taps a notification. |
| `POST /notifications/read-all` | Mark all of the current user's notifications as read. |

Response: the usual success envelope, e.g. `{ "msg": "success" }`.

**Recommended:** after accept or reject (Task 3), mark the related `game_invitation` notifications as read for **all** members of the invited Diwaniya, so their bell badges clear too.

---

## Task 6: Push notification (FCM) to every invited member

When the Task 1 notification is created, also send an FCM push to **each member** of the opponent Diwaniya. Tapping the push must open the **Games Invitations** screen in the app.

**Device tokens:** the app already sends the device token as `fcm_token` on login (`POST /auth/login`) and register. Send to the token(s) stored for each member.

**Payload:** use the keys the app already reads from pushes: top-level `type`, `title` and `body`. Add only `game_id`. All FCM `data` values must be **strings**.

```json
{
  "token": "<member fcm_token>",
  "notification": {
    "title": "New challenge!",
    "body": "There is a challenge between you and Al-Nasr Diwaniya"
  },
  "data": {
    "type": "game_invitation",
    "title": "New challenge!",
    "body": "There is a challenge between you and Al-Nasr Diwaniya",
    "game_id": "123",
    "notification_id": "501",
    "click_action": "FLUTTER_NOTIFICATION_CLICK"
  },
  "android": { "priority": "high" },
  "apns": { "payload": { "aps": { "sound": "default" } } }
}
```

- `notification` makes iOS and Android display the push when the app is in the background or closed.
- `data.type = "game_invitation"` tells the app to open Games Invitations on tap.
- `data.notification_id` is the `id` of the matching in-app notification row from Task 1. The app uses it to mark that row as read when the push is tapped.
- Localize the text using each member's saved language, the same language used for the Task 1 row.
- Other push types are unchanged. Older app versions show the push as before and ignore the new keys.

---

## Summary checklist

- [ ] T1: On private game creation, create a `game_invitation` notification (existing fields) for every member of the opponent Diwaniya.
- [ ] T1: Localize `title` and `body` from `Accept-Language`, and put `game_id` in `data`.
- [ ] T2: `GET /games-invitation` returns the receiving game for all members, with `opponent_diwanya.user_permission.is_admin`.
- [ ] T3: `POST /games/{id}/accept` and `/reject` return 403 for non-admins.
- [ ] T4: New `GET /notifications/unread-count` returning `unread_count` and `pending_invitations_count`.
- [ ] T5: New `POST /notifications/{id}/read` and `POST /notifications/read-all`.
- [ ] T6: Send an FCM push to every member's `fcm_token`, with `data.type = "game_invitation"`, `game_id` and `notification_id` (all strings).
- [ ] Provide the mobile team with the Firebase config files `google-services.json` (Android) and `GoogleService-Info.plist` (iOS). Both are missing from the app repo.
- [ ] Check that existing responses are unchanged apart from the new additive fields.
