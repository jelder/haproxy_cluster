haproxy-cluster
===============

> "Can we survive a rolling restart?"
>
> "How many transactions per second am I seeing?"
>
> "What's my session backlog?"

While there are already a handfull of [HA Proxy](http://haproxy.1wt.edu) abstraction layers on RubyGems, I wanted to be able to answer questions like those above and more, quickly, accurately, and easily. So here's one more for the pile.

`HAProxyCluster::Member` provides an ORM for HA Proxy's status page.

`HAProxyCluster` provides a simple map/reduce-inspired framework on top of `HAProxyCluster::Member`.

`haproxy_cluster` provides a shell scripting interface for `HAProxyCluster`. Exit codes are meaningful and intended to be useful from Nagios.

Do you deploy new code using a sequential restart of application servers? Using this common pattern carelessly can result in too many servers being down at the same time, and cutomers seeing errors. `haproxy_cluster` can prevent this by ensuring that every load balancer agrees that the application is up at each stage in the deployment. In the example below, we will deploy a new WAR to three Tomcat instances which are fronted by two HA Proxy instances. HA Proxy has been configured with `option httpchk /check`, a path which only returns an affirmative status code when the application is ready to serve requests.

```bash
#!bin/bash
set -o errexit
servers="server1.example.com server2.example.com server3.example.com"
load_balancers="https://lb1.example.com:8888 http://lb2.example.com:8888"

for server in $servers ; do
    haproxy_cluster --timeout=300 --eval "wait_until(true){ myapp.rolling_restartable? }" $load_balancers
    scp myapp.war $server:/opt/tomcat/webapps
done
```

The code block passed to `--eval` will not return until every load balancer reports that at least 80% of the backend servers defined for "myapp" are ready to serve requests. If this takes more than 5 minutes (300 seconds), the whole deployment is halted.

Maybe you'd like to know how many transactions per second your whole cluster is processing.

```bash
haproxy_cluster --eval 'poll{ puts members.map{|m|m.myapp.rate}.inject(:+) }' $load_balancers
```

Installation
------------

`gem install haproxy-cluster`

Requires Ruby 1.9.2 and depends on RestClient.

Non-Features
------------

* Doesn't try to modify configuration files. Use [haproxy-tools](https://github.com/subakva/haproxy-tools), [rhaproxy](https://github.com/jjuliano/rhaproxy), [haproxy_join](https://github.com/joewilliams/haproxy_join), or better yet, [Chef](http://www.opscode.com/chef) for that.
* Doesn't talk to sockets, yet. Use [haproxy-ruby](https://github.com/inkel/haproxy-ruby) for now if you need this. I intend to add support for this using `Net::SSH` and `socat(1)` but for now HTTP is enough for my needs.

ProTip
------

HA Proxy's awesome creator Willy Tarrreau loves [big text files](http://haproxy.1wt.eu/download/1.5/doc/configuration.txt) and [big, flat web pages](http://haproxy.1wt.eu/). If smaller, hyperlinked documents are more your style, you should know about the two alternative documentation sources:

* http://code.google.com/p/haproxy-docs/
* http://cbonte.github.com/haproxy-dconv/configuration-1.5.html

