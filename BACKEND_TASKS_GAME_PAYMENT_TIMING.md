# Backend Task: Game payment timing — "الفوري" vs "بعد اكتمال العدد"

## Summary

When creating a **public** or **my Diwaniya** (`my_diwanya`) game, the creator now chooses a payment method (طريقة الدفع):

- **الفوري (Immediate):** the app creates the game, then opens the existing game payment screen right away. That screen calls `POST /games/{id}/confirm-booking` and opens `payment_url`.
- **بعد اكتمال العدد (After players complete):** the app creates the game and does nothing else. This is today's flow: once `game_status = players_completed`, the game page shows the payment button (now **استكمال عملية الحجز**). Tapping it calls `POST /games/{id}/booking-available`, then `confirm-booking`.

The app only uses endpoints that already exist. It never shows a booking as paid or confirmed by itself. However, several things the feature needs are **not supported or not visible** in the current API. They are listed below. The backend code is not in the app repository, so nothing here is verified.

## How the app works today

1. `POST /games` (multipart): `playground_id`, `booking_date`, `periods[i][start_time]`, `periods[i][end_time]`, `type` (`public` / `private` / `my_diwanya`), `players`, `position`, `slot_index`, `opponent_diwaniya_id`. **No payment field.**
2. Game page payment button is shown when `game_status == "players_completed"` **and** `booking.payment_method == null` **and** `user_permission.can_book == true`.
3. `POST /games/{id}/booking-available` → `data.available`. If false, the app asks the user to choose another playground (`POST /games/{id}/update-booking`).
4. `POST /games/{id}/confirm-booking`: `payment_method`, `use_wallet`, `code` → the app opens `booking.payment_url` in a web view and waits for a URL containing `/success`.
5. Push notifications: the app only opens a screen for `type = "game_invitation"`. Any other type just marks the notification as read.

## Questions to answer

| # | Question |
|---|---|
| Q1 | Does `POST /games` hold the playground slot for an **unpaid** game? If yes, for how long, and what happens when it expires? |
| Q2 | Can `POST /games/{id}/confirm-booking` be called **before** the game is full? The "Immediate" option depends on this. |
| Q3 | Which user is allowed to pay (`can_book`): the creator only, or also others? |
| Q4 | Do you already send a notification when a game reaches `players_completed`? What is its `type` and payload? |
| Q5 | What are all possible values of `game_status`, and is there a booking / payment status anywhere in the game response? |
| Q6 | If a player leaves after `players_completed`, does `game_status` go back? What if the booking was already paid? |
| Q7 | What happens to the booking and the money when a game is cancelled before payment, and after payment? |

## Tasks

| # | Task | Endpoint | Priority | Done? |
|---|---|---|---|---|
| T1 | Answer Q1–Q7 | — | High | ☐ |
| T2 | Accept and store the creator's choice: `payment_timing` = `immediate` \| `after_players_complete`. Required for `type=public` and `type=my_diwanya`; rejected for `type=private` (private games keep the current flow). Invalid value → `422` with a translated `msg`. Return it in the game response as `payment_timing` | `POST /games`, `GET /games/{id}` | **Critical** | ☐ |
| T3 | When `payment_timing=immediate`, allow `confirm-booking` right after creation (before the game is full) for the creator, and return `can_book: true` for them until the booking is paid | `POST /games/{id}/confirm-booking`, `GET /games/{id}` | **Critical** | ☐ |
| T4 | Add a booking status to the game response, for example `booking.status` = `unpaid` \| `pending_payment` \| `paid` \| `failed` \| `expired` \| `cancelled`, set **only** from the verified gateway callback. The app needs this to show "paid / not paid" and to hide the pay button once paid | `GET /games/{id}`, game lists | **Critical** | ☐ |
| T5 | When a game with `payment_timing=after_players_complete` reaches `players_completed`, send a push and an in-app notification to the user who must pay, with `type: "game_payment_required"` (or tell us your type) and `game_id` in the push `data` and in the notification `data` JSON. Send it once per completion | push + `GET /notifications` | High | ☐ |
| T6 | `confirm-booking` must re-check playground availability (another user may have booked the time since the game was created) and return `409` with a translated `msg` if it is taken. Use the same overlap and locking rules as `BACKEND_TASKS_PLAYGROUND_BOOKING_CONFLICTS.md` (T2, T3, T8) | `POST /games/{id}/confirm-booking` | High | ☐ |
| T7 | Idempotent payment: calling `confirm-booking` again while a payment is pending must return the **same** `payment_url`, not create a second payment. After the booking is paid, return `409` "already paid". The gateway callback must be idempotent too | `POST /games/{id}/confirm-booking`, callback | High | ☐ |
| T8 | Only the allowed payer (Q3) can call `confirm-booking`. Others get `403` with a translated `msg` | `POST /games/{id}/confirm-booking` | High | ☐ |
| T9 | Release the slot and set `booking.status=failed` / `expired` when the payment fails, is cancelled, or the hold expires. A late successful callback must not confirm a slot that someone else has taken since (refund instead) | callback, scheduled job | High | ☐ |
| T10 | Define what happens when players leave after `players_completed` (Q6), and after cancellation (Q7), and return the result in `game_status` / `booking.status` | `POST /games/{id}/leave`, cancel | Medium | ☐ |
| T11 | Payment failure URL (see `BACKEND_TASKS_PAYMENT_FAILED.md`, T4) so the app can show "payment failed, try again" instead of staying on the gateway error page | callback | Medium | ☐ |

When T2, T4 and T5 are done, the app will:

- send `payment_timing`;
- show the paid / unpaid state from `booking.status`;
- open the game page from the payment notification.

**These parts are not built in the app yet.** We won't build them before the fields exist.

## Test we will run

1. Create a public game, and a my Diwaniya game, with **الفوري** and pay with a valid card.
   - **Expected:** `booking.status=paid`, and the payment button doesn't show again.
2. Create a public game with **الفوري** and close the payment page without paying.
   - **Expected:** the game exists with `booking.status=unpaid` or `pending_payment`, and the creator can pay again from the game page.
3. Create a public game, and a my Diwaniya game, with **بعد اكتمال العدد** and fill all player slots.
   - **Expected:** the payer receives one `game_payment_required` notification with `game_id`. Tapping it opens the game. Paying works.
4. In test 3, book the same playground and time from another account before paying.
   - **Expected:** `booking-available` is false, or `confirm-booking` returns `409`.
5. Tap pay twice quickly.
   - **Expected:** one payment only (same `payment_url`).
6. Another member (not the payer) calls `confirm-booking`.
   - **Expected:** `403`.

## Please reply with

- Your answers to Q1–Q7.
- The status of each row in the table.
- One real `GET /games/{id}` response for an unpaid game and one for a paid game.
