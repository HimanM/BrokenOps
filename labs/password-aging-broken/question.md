### Scenario
A developer, `ops-user`, has been locked out of the server and cannot log in via SSH despite using the correct password. The operations team suspect that password aging and account expiration policies might be responsible for the lockout.

You need to investigate the account aging settings on the server and resolve the lockout so `ops-user` can log in normally.

### Objective
Investigate and correct `ops-user`'s account settings so that:
1. The account is no longer expired.
2. The user is not forced to immediately change their password upon their next login (i.e. the password is not considered expired).
3. The password aging policy is relaxed so the user can authenticate cleanly.

### Useful Commands
- `chage`
- `passwd`
- `getent`
