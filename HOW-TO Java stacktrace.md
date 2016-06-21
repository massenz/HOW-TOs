# HOW-TO get a Java stacktrace

Use the following:

```bash
$ jps -mv
47314  -Dfile.encoding=UTF-8 -XX:+UseConcMarkSweepGC
    -XX:SoftRefLRUPolicyMSPerMB=50 -ea 
    -Dsun.io.useCanonCaches=false 
    -Djava.net.preferIPv4Stack=true -XX:+HeapDu ....
    
$ jstack -l 47314

... stack trace dump follows
```
 