# Backend Task: Diwaniya names must be unique

## Summary

Two Diwaniyas can currently have the same name. Users find Diwaniyas by name (search, invitations, ranking), so duplicates are confusing. Creating or renaming a Diwaniya must fail when another Diwaniya already uses that name.

The app cannot enforce this reliably on its own: its only name search (`GET /diwaniyas-overview?name=`) is a partial match, is paginated, excludes the user's own Diwaniya, and cannot prevent two users creating the same name at the same moment. The check has to live in the backend.

## Requested change

### Task 1: Validate the name on create

`POST /diwaniyas` (create Diwaniya) must reject a `name` that is already used by another Diwaniya.

**Comparison rules**
- Trim leading/trailing spaces and collapse repeated inner spaces before comparing and before saving.
- Case-insensitive for Latin letters (`Al Nasr` = `al nasr`).
- Deleted Diwaniyas do not reserve their name (if soft-deleted rows exist, exclude them).

**Error response** (the app's normal error shape; the app shows `msg` as-is):

```json
{
  "status": false,
  "msg": "اسم الديوانية مستخدم بالفعل، اختر اسماً آخر"
}
```

Status `422`. `msg` is localized by `Accept-Language` (`en`: "This Diwaniya name is already taken. Please choose another name.").

### Task 2: Validate the name on update

`POST /diwaniyas/{id}` (update Diwaniya settings) must apply the same rule when `name` is sent, **excluding the Diwaniya being updated** (saving without changing the name must still succeed).

### Task 3: Enforce it in the database

Add a unique index on the normalized name, so two simultaneous create requests cannot both succeed. If the insert hits the index, return the same `422` as Task 1, not a `500`.

## Questions for the backend team

1. **Existing duplicates:** are there Diwaniyas that already share a name? They must be resolved (renamed) before the unique index can be added. How do you want to handle them?
2. **Arabic normalization:** should variants such as `أ`/`ا`/`إ` or `ة`/`ه` count as the same name? (Suggested: no, for now. Exact match after trimming and case-folding.)

## App side

No app change is required: create and update already show the backend's `msg` in an error message. The create form will also stop accepting a name made of spaces only.
