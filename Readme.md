[![wercker status](https://app.wercker.com/status/6fae9d612ce512dbdfff1146042d65fc/m "wercker status")](https://app.wercker.com/project/bykey/6fae9d612ce512dbdfff1146042d65fc)

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
# after 1 minute delay since the last fail, maybe client will try again
client.ping
=> 'PONG'
```

Does not have significant performance overhead. The following is a benchmark of 1000 redis calls to `set`
![Image of benchmark](https://raw.githubusercontent.com/renra/ruby-maybe_client/master/maybe_client_benchmark_1000.png)
