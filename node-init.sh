#!/bin/bash

mkdir -p /mnt/mesos/sandbox/riak/data
rm -rf /var/lib/riak
cd /var/lib
ln -fs /mnt/mesos/sandbox/riak/data riak

mkdir -p /mnt/mesos/sandbox/riak/config-data
rm -rf /usr/local/riak/data
cd /usr/local/riak
ln -fs /mnt/mesos/sandbox/riak/config-data data

mkdir -p /mnt/mesos/sandbox/riak/var-log
rm -rf /var/log/riak
cd /var/log
ln -fs /mnt/mesos/sandbox/riak/var-log riak

mkdir -p /mnt/mesos/sandbox/riak/etc
mkdir -p /usr/local/riak/etc.bak/
cp -R /usr/local/riak/etc/* /usr/local/riak/etc.bak/
cp -R /usr/local/riak/etc.bak/* /mnt/mesos/sandbox/riak/etc/
rm -rf /usr/local/riak/etc
cd /usr/local/riak
ln -fs /mnt/mesos/sandbox/riak/etc etc

mkdir -p /mnt/mesos/sandbox/riak/erl-log
rm -rf /usr/local/riak/log
cd /usr/local/riak
ln -fs /mnt/mesos/sandbox/riak/erl-log log

cp /var/service/riak/run /var/service/riak/run.bak
rm -f /var/service/riak/run
cat >> /var/service/riak/run <<EOL
#!/bin/sh
exec /usr/local/riak/bin/riak start
EOL
chmod 755 /var/service/riak/run

rm -f /var/service/riak/finish
cat >> /var/service/riak/finish <<EOL
#!/bin/bash
while true; do 
  /usr/local/riak/bin/riak ping
  if [[ "\$?" -ne 1 ]]; then 
    break
  fi
  sleep 5
done
exec /usr/bin/tail -F /usr/local/riak/log/*
EOL
chmod 755 /var/service/riak/finish