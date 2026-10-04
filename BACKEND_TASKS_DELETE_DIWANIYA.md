# Backend Issue: Admin cannot delete their own Diwaniya

## Summary

When the **admin** of a Diwaniya taps **Delete Diwaniya** in the app's Diwaniya settings, the request fails with `422`. The error message is about deleting a *member*:

```
POST https://futblha.com/api/diwaniyas/29/delete
Authorization: Bearer <admin token>
Accept-Language: ar
Body: {}

422 Unprocessable Content
{
  "status": false,
  "msg": "You cannot delete an admin member from the diwaniya"
}
```

The user is the admin of Diwaniya `29`. The expected result is that the whole Diwaniya is deleted.

<details>
<summary>Full app log (token redacted)</summary>

```
╔╣ Request ║ POST
║  https://futblha.com/api/diwaniyas/29/delete
╚══════════════════════════════════════════════
╔ Headers
╟ Accept: application/json
╟ Content-Type: application/json
╟ Authorization: Bearer <redacted>
╟ Accept-Language: ar
╟ contentType: application/json
╟ responseType: ResponseType.json
╟ followRedirects: true
╚══════════════════════════════════════════════
║ {}

╔╣ DioError ║ Status: 422 Unprocessable Content ║ Time: 292 ms
║  https://futblha.com/api/diwaniyas/29/delete
╚══════════════════════════════════════════════
╔ DioExceptionType.badResponse
║    {
║         "status": false,
║         "msg": "You cannot delete an admin member from the diwaniya"
║    }
```

</details>

## Root cause

The API has **no endpoint for deleting a Diwaniya**. The only endpoint under `/delete` is the one that **removes a member**:

| Postman name | Request |
|---|---|
| delete diwaniya member | `POST /diwaniyas/{id}/delete?user_id={userId}` |

The app is currently using this member-removal endpoint for both actions:

| App action | Request sent today |
|---|---|
| Remove member (admin removes a user) | `POST /diwaniyas/{id}/delete`, body `{ "user_id": "5" }` (works) |
| **Delete Diwaniya** | `POST /diwaniyas/{id}/delete`, **no `user_id`** (fails) |

Because no `user_id` is sent, the backend appears to treat the request as "remove the current user". The current user is the admin, so the request is refused with *"You cannot delete an admin member"*.

## Requested change

### Task 1: Add a "Delete Diwaniya" endpoint

Add a **new** endpoint. Do not change the existing member-removal endpoint, because older app versions use it to remove members.

Suggested request (any path works; tell us which one you choose):

```
POST /diwaniyas/{id}/destroy
```

or the REST equivalent `DELETE /diwaniyas/{id}`.

**Authorization**
- Only the Diwaniya **admin** (or creator) may delete it.
- Any other user receives `403` with a localized `msg`.

**Success response** (same envelope as other endpoints):

```json
{
  "status": true,
  "data": "تم حذف الديوانية بنجاح"
}
```

`data` is a localized message string chosen by the `Accept-Language` header (`en` / `ar`). The app shows it as-is.

**Error responses**
- `403`: the user is not an admin of this Diwaniya.
- `404`: the Diwaniya does not exist.
- `422`: the Diwaniya cannot be deleted right now. Return the reason in `msg`, for example when it has a confirmed upcoming game.

### Task 2: Make the member-removal endpoint validate `user_id`

On `POST /diwaniyas/{id}/delete`, if `user_id` is missing, return a clear validation error (for example *"user_id is required"*). Do not silently fall back to the current user. This stops the confusing *"cannot delete an admin member"* message.

## Questions for the backend team

Please confirm what happens to related data when a Diwaniya is deleted:

1. **Upcoming and confirmed games, and playground bookings:** are they cancelled? Are payments refunded to the wallet?
2. **Members:** are they notified (push and in-app notification)?
3. **Chat messages and game history:** are they removed or kept?
4. **Deletion blocking:** should deletion be refused while the Diwaniya has an active or confirmed game (the `422` case above)?

## App side (after the backend change)

Once the endpoint exists, the app will change `deleteDiwaniya` in `lib/data/datasources/diwaniya_remote_datasource/diwaniya_remote_datasource_impl.dart` to call the new path. Member removal stays on `/diwaniyas/{id}/delete`.
