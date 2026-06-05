### Objective

A developer was trying to configure the Redis server to accept connections from outside localhost. They modified the `redis.conf` file, but something went wrong and now the `redis-server` service is crashing on startup.

Your task is to:
1. Figure out why the Redis daemon is failing.
2. Fix the configuration file so it binds correctly.
3. Successfully restart the `redis-server` service.

### Useful Commands
- `systemctl status redis-server`
- `journalctl -u redis-server.service`
- `redis-server /etc/redis/redis.conf`
