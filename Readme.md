#Maybe Client

Wrapper for connection clients that handles outages without raising errors (which wood take the application down). Ideal for making the application resilient in case of 3rd party failures (think your redis cache instance goes down)

##How to use

```
require 'redis'
client = MaybeClient.new(Redis, host: 'localhost', port: 6666)
client.ping
=> nil
```

Ouch, we forgot to start the server

```
$redis-server --port 6666
client.ping
=> 'PONG'
```
