### The Issue

The timer unit is installed with the wrong `[Install]` target, so it does not get pulled in by the normal timer target on boot. Because of that, the scheduled backup never starts after reboot.

### Step-by-Step Fix

1. **Correct the timer installation target**:
   ```bash
   sudo sed -i 's/WantedBy=graphical.target/WantedBy=timers.target/' /etc/systemd/system/nightly-backup.timer
   ```
2. **Reload systemd so it sees the updated unit**:
   ```bash
   sudo systemctl daemon-reload
   ```
3. **Enable and start the timer**:
   ```bash
   sudo systemctl enable --now nightly-backup.timer
   ```
4. **Confirm the backup job ran**:
   ```bash
   cat /var/log/nightly-backup.log
   ```
