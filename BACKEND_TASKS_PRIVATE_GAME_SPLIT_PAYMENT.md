# Backend Task: Private game (challenge) — each team pays 50%

## Summary

New business rule for **private games** (`type=private`, a challenge between two Diwaniyas):

1. Team A creates the challenge and invites Team B. Nothing is paid at this point.
2. Team B accepts.
3. The playground price is split **equally**: each team pays its own 50% through the existing payment gateway, at different times if they want.
4. The game (and the playground booking) is confirmed **only after both teams have paid**. The backend decides this, not the app.

Private games don't show the "طريقة الدفع" choice when they are created (that choice is only for `public` and `my_diwanya`). The app sends no payment field for private games.

**Nothing in the current API supports the split.** The app can't show each team's amount, track each team's payment, or know when both have paid. We need the backend to add this. The backend code is not in the app repository, so nothing here is verified.

## How the app works today

| Step | Endpoint | What the app sends / reads |
|---|---|---|
| Create challenge | `POST /games` | `type=private`, `opponent_diwaniya_id`, `playground_id`, `booking_date`, `periods[…]`, `players`, `position`, `slot_index`. No payment field |
| See invitations | `GET` games invitations | `receiving_games[]`, `sending_games[]`. Status from `game_status`: `pending`, `accepting_players` / `*waiting*`, `accepted` / `confirmed`, `rejected` |
| Accept / reject | `POST /games/{id}/accept`, `POST /games/{id}/reject` | Nothing sent. Response `data` = message string. Only admins of the invited Diwaniya see the buttons (`opponent_diwanya.user_permission.is_admin`) |
| Pay | `POST /games/{id}/booking-available` then `POST /games/{id}/confirm-booking` | `payment_method`, `use_wallet`, `code`. Shown only when `game_status = players_completed`, `booking.payment_method = null` and `user_permission.can_book = true` |
| Amount shown | — | **Calculated in the app**: playground hourly price × number of periods, minus voucher and wallet. So today **one user is charged 100%** of the price |

Booking fields the app reads today: `total`, `grand_total`, `hourly_rate`, `total_hours`, `voucher_discount`, `wallet_discount`, `payment_method`, `payment_url`. There is **no booking status, no per-team amount and no per-team payment status**.

## Questions to answer

| # | Question |
|---|---|
| Q1 | When can each team pay: right after Team B accepts, or only after `players_completed`? |
| Q2 | Who may pay for a team: only the Diwaniya admin, or any member of that team? Can the same user pay for both teams? (Should be no.) |
| Q3 | How do you split an amount that doesn't divide evenly in KWD (3 decimals), e.g. `40.005`? Who pays the extra fils? |
| Q4 | Are vouchers and wallet discounts per team (applied only to that team's share)? |
| Q5 | Is the playground slot held from creation, from acceptance, or only after the first payment? For how long? |
| Q6 | What happens if one team pays and the other doesn't before the deadline: cancel the game and refund the paid team? |
| Q7 | What happens to payments if the challenge is cancelled or rejected, or the playground becomes unavailable before both teams pay? |
| Q8 | Can a team accept the same challenge twice, or accept after rejecting? (Should return an error.) |

## Tasks

The field names below are a **proposal**. Use them, or tell us your names and we'll match them.

| # | Task | Endpoint | Priority | Done? |
|---|---|---|---|---|
| T1 | Answer Q1–Q8 | — | High | ☐ |
| T2 | Return each team's share and payment status in the game response, for example `booking.team_payments: [{ "team": "team_1", "diwaniya_id": …, "amount": "20.000", "status": "unpaid" \| "pending" \| "paid" \| "failed" \| "refunded", "paid_at": … }, { "team": "team_2", … }]`. Amounts are calculated by the backend (Q3) | `GET /games/{id}`, invitations, game lists | **Critical** | ☐ |
| T3 | Charge only the paying team's share: `confirm-booking` for a private game creates a payment for **the current user's team** amount only (after its voucher / wallet, Q4) and returns that `payment_url` | `POST /games/{id}/confirm-booking` | **Critical** | ☐ |
| T4 | Mark the game and booking **confirmed only when both teams are `paid`**, set from the verified gateway callbacks (never from the app's redirect). Until then, return a status the app can show, e.g. `awaiting_payment` with `team_payments` showing who is missing | callback, `GET /games/{id}` | **Critical** | ☐ |
| T5 | Payment authorization: only an allowed member of a team (Q2) can pay that team's share. Return `user_permission.can_pay_team_share: true` for them and `403` with a translated `msg` for anyone else, including someone trying to pay for the other team | `POST /games/{id}/confirm-booking`, `GET /games/{id}` | High | ☐ |
| T6 | Idempotency: paying again while that team's payment is pending returns the same `payment_url`. After the team has paid, return `409` "already paid". A repeated or out-of-order callback must not double-mark or double-charge | `confirm-booking`, callback | High | ☐ |
| T7 | Both teams paying at the same moment must confirm the game exactly once, using a transaction / row lock on the game booking | callback | High | ☐ |
| T8 | Re-check playground availability before each team's payment and before final confirmation. Return `409` if the time was taken (same rules as `BACKEND_TASKS_PLAYGROUND_BOOKING_CONFLICTS.md` T2, T3) | `confirm-booking`, callback | High | ☐ |
| T9 | Deadline and refunds (Q5, Q6, Q7): if the game can't be confirmed (other team didn't pay, cancelled, playground taken), cancel it, refund the team that paid, and set its status to `refunded` | scheduled job, cancel | High | ☐ |
| T10 | Accept and reject must be one-time: accepting twice, or accepting after rejecting, returns `409` with a translated `msg` | `POST /games/{id}/accept`, `/reject` | Medium | ☐ |
| T11 | `POST /games` with `type=private` must **not** require any payment field, and must reject `payment_timing` (see `BACKEND_TASKS_GAME_PAYMENT_TIMING.md`) | `POST /games` | Medium | ☐ |
| T12 | Notify both teams when a team pays, when the game is confirmed, and when it's cancelled or refunded, with `game_id` in the push and notification `data` | push + notifications | Medium | ☐ |

## What the app will do once T2–T5 are ready

- **Payment screen:** show the amount from the backend (the team's share), not the app's own calculation.
- **Game page:** show both teams with their amount and status, e.g. "ديوانية أ: تم الدفع ✓" / "ديوانية ب: بانتظار الدفع".
- **Pay button:** only for users the backend allows (`can_pay_team_share`), and only while their team is unpaid.
- **"Confirmed":** shown only when the backend says the game is confirmed.

None of this is built yet, because we won't guess the field names.

## Test we will run

Setup: Diwaniya **A** challenges Diwaniya **B**. Playground price 40 KWD.

1. B accepts.
   - **Expected:** both teams show `amount: 20.000`, `status: unpaid`. The game isn't confirmed.
2. A pays.
   - **Expected:** A = `paid`, B = `unpaid`, game = `awaiting_payment`.
3. B pays.
   - **Expected:** both `paid`, and the game and booking are confirmed.
4. Repeat with B paying first.
   - **Expected:** same result.
5. A's payment fails.
   - **Expected:** A = `failed` or `unpaid`, A can pay again, and the game isn't confirmed.
6. A member of B tries to pay A's share.
   - **Expected:** `403`.
7. A taps pay twice quickly.
   - **Expected:** one payment only.
8. A and B pay at the same moment.
   - **Expected:** the game is confirmed once.
9. A pays, B never pays.
   - **Expected:** after the deadline, the game is cancelled and A is refunded.
10. B accepts twice.
    - **Expected:** the second call returns `409`.

## Please reply with

- Your answers to Q1–Q8.
- The status of each row in the table.
- The final field names for T2, T4 and T5.
- One real `GET /games/{id}` response at each of steps 1, 2 and 3.
