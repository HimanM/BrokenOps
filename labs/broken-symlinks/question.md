### Scenario
A junior administrator recently attempted to migrate the backend application data to a new directory structure (`/opt/app/new_location/`). However, the migration was messy, and now the main application script (`/opt/app/bin/run.sh`) fails to start.

The application relies on specific file paths:
- A configuration file at `/opt/app/config/current_config`
- A database file at `/opt/app/data/current_db`

It appears some symbolic links (soft links) were broken, and hard links were left pointing to outdated or incorrect data during the move.

### Objective
Diagnose the broken links in `/opt/app/config/` and identify the outdated data in `/opt/app/data/`. Re-create the links so they point to the correct files in `/opt/app/new_location/`. 
- `current_config` should be a soft link to `app_config`.
- `current_db` should be a hard link to `app_db`.

### Useful Commands
- `/opt/app/bin/run.sh`
- `ls -l /opt/app/config/`
- `ls -l /opt/app/data/`
- `find /opt/app -xtype l`
- `ln -s`
- `ln`
