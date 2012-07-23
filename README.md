haproxy-cluster
===============

> "Can we survive a rolling restart, 2 at a time?"
>
> "Will restarting myserver01 take the site down?"
>
> "How many concurrent connections right now across all load balancers?"

While there are already a handfull of HA Proxy abstraction layers on RubyGems, I think we needed one more. I wanted to be able to answer questions like those above and more, quickly, accurately, and easily.

`HAProxyInstance` provides an ORM for [HA Proxy](http://haproxy.1wt.edu)'s status page.

`HAProxyCluster` provides a simple MapReduce-like framework on top of `HAProxyInsance`.

`haproxy_cluster` provides a shell scripting interface for `HAProxyCluster`. Exit codes are meaningful and intended to be useful from Nagios.

Do you deploy new code using a sequential restart of application servers? Using this common pattern carelessly can result in too many servers being down at the same time, and cutomers seeing errors. `haproxy_cluster` can prevent this by ensuring that every load balancer agrees that the application is up at each stage in the deployment. In the example below, we will deploy a new WAR to three Tomcat instances which are fronted by two HA Proxy instances. HA Proxy has been configured with `option httpchk /check`, a path which only returns an affirmative status code when the application is ready to serve requests.

```bash
#!bin/bash
set -o errexit
servers="server01.example.com server02.example.com server03.example.com"
load_balancers="lb01.example.com lb02.example.com"

for server in $servers ; do
    haproxy_cluster --timeout=300 --eval "wait_until(true){ myapp.rolling_restartable? }" $load_balancers
    scp myapp.war $server:/opt/tomcat/webapps
done
```

The code block passed to `--eval` will not return until every load balancer reports that at least 80% of the backend servers defined for "myapp" are ready to serve requests. If this takes more than 5 minutes (300 seconds), the whole deployment is halted.

Non-Features
------------

* Doesn't try to modify configuration files. Use [haproxy-tools](https://github.com/subakva/haproxy-tools), [rhaproxy](https://github.com/jjuliano/rhaproxy), [haproxy_join](https://github.com/joewilliams/haproxy_join), or better yet, [Chef](http://www.opscode.com/chef) for that.
* Doesn't talk to sockets, yet. Use [haproxy-ruby](https://github.com/inkel/haproxy-ruby) for now if you need this.

ProTip
------

HA Proxy's awesome creator Willy Tarrreau loves [big text files](http://haproxy.1wt.eu/download/1.5/doc/configuration.txt) and [big, flat web pages](http://haproxy.1wt.eu/). If smaller, hyperlinked documents are more your style, you should know about the two alternative documentation sources:

* http://code.google.com/p/haproxy-docs/
* http://cbonte.github.com/haproxy-dconv/configuration-1.5.html

