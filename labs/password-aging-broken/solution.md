### The Issue

The user account `ops-user` has been locked out because of two password aging and account expiration issues:
1. **Account Expiration**: The account has been configured with an expiration date set in the past (`2026-06-01`), preventing any SSH logins.
2. **Password Expiration**: The last password change date was set to epoch `0` (indicating the password has never been changed), which systemd/PAM treats as immediately expired and prevents normal login unless changed.

### Step-by-Step Fix

1. **Diagnose password aging settings**:
   Run the `chage` command to list the password aging information for `ops-user`:
   ```bash
   sudo chage -l ops-user
   ```
   You will notice that:
   - `Account expires` is set to a past date (`Jun 01, 2026`).
   - `Last password change` is set to `password must be changed`.

2. **Remove the account expiration date**:
   Use the `-E` flag with `-1` to set the account expiration to "never":
   ```bash
   sudo chage -E -1 ops-user
   ```

3. **Reset the password age to today**:
   Use the `-d` flag with today's date (or `today`) to update the last password change date so that it is no longer considered expired:
   ```bash
   sudo chage -d today ops-user
   ```

4. **Verify the changes**:
   Check the password aging properties again:
   ```bash
   sudo chage -l ops-user
   ```
   Confirm that `Account expires` is set to `never`, and `Last password change` displays today's date.
