### Scenario
A developer has reported that their Redis instance running on the database server works perfectly while running, but loses all recent data whenever the server or the Redis service restarts. 

You need to investigate why Redis is failing to persist data to disk and fix the configuration/environment so that data remains durable across restarts.

### Objective
Ensure that the Redis database successfully persists data to disk, and that keys written to the database survive a service restart.

### Useful Commands
- `systemctl status redis-server`
- `redis-cli ping`
- `redis-cli info persistence`
- `redis-cli save`
- `tail -n 50 /var/log/redis/redis-server.log`
