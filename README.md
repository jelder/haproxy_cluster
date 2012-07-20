
HAProxyInstance and HAProxyCluster
==================================

> "Can we survive a rolling restart, 3 at a time?"
>
> "Will restarting myserver01 take the site down?"

`HAProxyInstance` provides an almost ActiveRecord-like interface to [HA Proxy](http://haproxy.1wt.edu)'s status page.

`HAProxyCluster` provides a simple MapReduce-like framwork on top of `HAProxyInsance`.

`check_haproxy` provides a Nagios- and shell-scripting-friendly interface for `HAProxyCluster`.

While there are already a handfull of HA Proxy abstraction layers on RubyGems, I think we needed one more. I wanted to be able to answer questions like those above and more, quickly, accurately, and easily.

Do you need to do rolling restarts of your application servers? This may be a good starting point.

```bash
#!/bin/bash
tomcats=$(knife search node "roles:tomcat AND chef_environment:production" -i | egrep -v 'items found')
haproxies=$(knife search node "roles:haproxy AND chef_environment:production" -i | egrep -v 'items found')

for tomcat in $tomcats ; do
    check_haproxy --eval "wait_for ; tomcat.servers.map{|s|s.ok?} ; end" $haproxies
    scp myapp.war $tomcat:/opt/tomcat/webapps
done
```

Non-Features
------------

* Doesn't try to modify configuration files. Use [haproxy-tools](https://github.com/subakva/haproxy-tools), [rhaproxy](https://github.com/jjuliano/rhaproxy), [haproxy_join](https://github.com/joewilliams/haproxy_join), or better yet, [Chef](http://www.opscode.com/chef) for that.
* Doesn't talk to sockets, yet. Use [haproxy-ruby](https://github.com/inkel/haproxy-ruby) for now if you need this.

ProTip
------

HA Proxy's awesome creator Willy Tarrreau loves [big text files](http://haproxy.1wt.eu/download/1.5/doc/configuration.txt) and [big, flat web pages](http://haproxy.1wt.eu/). If smaller, hyperlinked documents are more your style, you should know about the two alternative documentation sources:

* http://code.google.com/p/haproxy-docs/
* http://cbonte.github.com/haproxy-dconv/configuration-1.5.html

