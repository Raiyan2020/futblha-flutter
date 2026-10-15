# Backend Task: Make playground booking conflict-safe

## Summary

The app has been updated to show only bookable times, to ignore slow or stale availability responses, to block double taps, and to go back and reload the times when a booking is rejected. These are **UX only**. The app cannot stop two users from booking the same time. Only the backend can.

The backend code is not in the app repository, so **none of the rules below have been verified**. Please confirm each one, fix what is missing, and reply with the table filled in.

## Endpoints that reserve a playground

Every one of these must apply the **same** availability check.

| # | Endpoint | Who uses it | Sends |
|---|---|---|---|
| E1 | `POST /bookings` (multipart) | Book Playground → Confirm | `playground_id`, `booking_date` (`yyyy-MM-dd`), `periods[i][start_time]`, `periods[i][end_time]`, `payment_method`, `use_wallet`, `code` |
| E2 | `POST /games` (multipart) | Create Game (all types) | `playground_id`, `booking_date`, `periods[i][start_time]`, `periods[i][end_time]`, `type` (`my_diwanya` / `private` / `public`), `players`, `position`, `slot_index`, `opponent_diwaniya_id` |
| E3 | `POST /games/{id}/update-booking` | Game → choose another playground | `playground_id`, `booking_date`, `periods[…]`, `payment_method`, `use_wallet`, `code` |
| E4 | `POST /games/{id}/confirm-booking` | Game → confirm & pay | `payment_method`, `use_wallet`, `code` |
| E5 | Admin panel / manual blocks | Admins | — |

Endpoints that only **read** availability:

| # | Endpoint | Returns |
|---|---|---|
| R1 | `GET /playgrounds/{id}?date=yyyy-MM-dd` | `data.available_slots[] = { start_at, end_at, available }` |
| R2 | `POST /games/{id}/booking-available` | `data.available` |

`POST /games/{id}/join` must **not** create a playground reservation. It only adds a player to an existing game.

## Questions to answer

| # | Question |
|---|---|
| Q1 | Do `my_diwanya`, `private` and `public` games each create an **exclusive** reservation of the playground for their periods? (The app assumes yes.) |
| Q2 | Which booking statuses hold a slot? Please list every status (for example pending / awaiting payment / confirmed / cancelled / expired / failed / completed) and whether it blocks the slot. |
| Q3 | When a booking is created with an online payment (`paymentUrl`), how long is the slot held before it is released if the user doesn't pay? Is there a job that expires it? |
| Q4 | What timezone are `booking_date`, `start_at` and `end_at` in? (We assume Asia/Kuwait.) |
| Q5 | What is the exact format of `start_at` / `end_at`: `17:00`, `17:00:00` or `5:00 PM`? Does it change with `Accept-Language: ar`? |
| Q6 | Can a slot cross midnight (for example `23:00 - 00:00`)? If yes, which `booking_date` does it belong to? |
| Q7 | Are there per-playground settings for buffers between bookings, minimum notice, or breaks? |

## Tasks

| # | Task | Endpoint | Priority | Done? |
|---|---|---|---|---|
| T1 | Answer Q1–Q7 | — | High | ☐ |
| T2 | Reject a booking that overlaps any **active** reservation on the same playground, using interval overlap `existing.start < new.end AND new.start < existing.end` (not "same start time"). Adjacent periods (`17:00-18:00` and `18:00-19:00`) are allowed. Apply it across **all** sources: bookings, every game type, admin bookings and manual blocks | E1, E2, E3, E4, E5 | **Critical** | ☐ |
| T3 | Make the check concurrency-safe. Two requests for the same playground and overlapping time must not both succeed. Do the check and the insert in **one DB transaction**, locking the playground row (`SELECT … FOR UPDATE`) or using an exclusion / unique constraint on (playground, date, period). A plain "read, then insert" is not enough | E1, E2, E3, E4 | **Critical** | ☐ |
| T4 | Return **HTTP 409** with a translated `msg` when the time is taken. The app reads the 409, shows `msg`, and goes back to reload the times. Example: `409 {"status": false, "msg": "هذا الوقت محجوز، الرجاء اختيار وقت آخر"}` | E1, E2, E3, E4 | High | ☐ |
| T5 | Reject the overlap **between periods in the same request** (for example `17:00-18:00` and `17:30-18:30` in one booking) with `422` | E1, E2, E3 | High | ☐ |
| T6 | Validate every period: valid `HH:mm`, end after start (or the agreed midnight rule), within the playground's working hours for that day, not on a closed day, not in a break or admin block. Missing or malformed values → `422` with a translated `msg` | E1, E2, E3 | High | ☐ |
| T7 | Reject periods that have already started (same-day bookings), using **server time** in the playground's timezone, not the phone's time → `422` | E1, E2, E3, E4 | High | ☐ |
| T8 | `confirm-booking` must re-check availability (another user may have booked since the game was created) and return `409` if taken | E4 | High | ☐ |
| T9 | Unpaid online bookings: hold the slot only for the agreed time (Q3), then expire it and release the slot. Failed / cancelled / expired bookings must release the slot. A payment callback that arrives after expiry must not confirm a booking whose slot was taken by someone else | E1, payment callback | High | ☐ |
| T10 | `available_slots` must use exactly the same rules as T2, T6, T7 and T9, so a slot shown as `available: true` can actually be booked. Past slots on today's date should be `available: false` | R1 | Medium | ☐ |
| T11 | `booking-available` must use the same rules as T2 | R2 | Medium | ☐ |
| T12 | Idempotency: a retried or double-sent `POST /bookings` (same user, playground, date, periods within a few seconds) must not create two bookings. The app now blocks double taps, but a network retry can still repeat a request | E1, E2 | Medium | ☐ |
| T13 | If availability is cached, invalidate it when a booking is created, cancelled, expired or rescheduled | R1, R2 | Medium | ☐ |

## Test we will run

Setup: playground **P**, open 16:00–24:00, hourly slots. Two test users, **U1** and **U2**.

1. U1 books P 17:00–18:00.
   - **Expected:** success. `GET /playgrounds/P?date=…` shows 17:00–18:00 as `available: false`.
2. U2 books P 17:00–18:00 (same time).
   - **Expected:** `409` with a translated `msg`.
3. U2 books 17:30–18:30, 16:00–19:00 and 17:15–17:45.
   - **Expected:** `409` for each.
4. U2 books 18:00–19:00 (adjacent).
   - **Expected:** success.
5. U2 creates a `public` game, and then a `private` game, on P 17:00–18:00.
   - **Expected:** `409` for both.
6. U1 and U2 send `POST /bookings` for P 20:00–21:00 **at the same moment** (for example two `curl` commands run in parallel, repeated 20 times).
   - **Expected:** exactly one success each time, the other gets `409`.
7. U1 books 21:00–22:00 with an online payment and doesn't pay.
   - **Expected:** the slot is held, then released after the hold time (Q3).
8. Book a period that already started today, a period outside working hours, and a malformed time (`25:00`).
   - **Expected:** `422` for each.
9. Book `17:00-18:00` and `17:30-18:30` in one request.
   - **Expected:** `422`.

## Please reply with

- Your answers to Q1–Q7.
- The status of each row in the table.
- Real responses for steps 2, 6 and 8.
