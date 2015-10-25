#!/bin/bash

echo "Starting Redis"
/usr/local/bin/redis-server /etc/redis/redis.config

echo "Starting Openvas..."

cd /usr/local/sbin

echo "Starting gsad"
# http://wiki.openvas.org/index.php/Edit_the_SSL_ciphers_used_by_GSAD
./gsad --gnutls-priorities="SECURE128:-AES-128-CBC:-CAMELLIA-128-CBC:-VERS-SSL3.0:-VERS-TLS1.0"
echo "Starting Openvassd"
./openvassd
echo "Rebuilding openvasmd"
n=1
until [ $n -eq 4 ]
do
         timeout 15m openvasmd --rebuild -v;
        if [ $? -eq 0 ]; then
                 break;
         fi
         echo "Rebuild failed, attempt: $n"
         n=$[$n+1]
         echo "Cleaning up:"
         rm -rf /usr/local/var/lib/openvas/mgr/tasks.db
done

echo "Starting Openvasmd"
./openvasmd

echo "Checking setup"

until [ $n -eq 50 ]
do
         timeout 10s /openvas/openvas-check-setup --v8 --server;
        if [ $? -eq 0 ]; then
                 break;
         fi
         echo "Re-running openvas-check-setup, attempt: $n"
         n=$[$n+1]
done

echo "Starting Arachni Web UI"

/opt/arachni/bin/arachni_web -o 0.0.0.0 &

echo "Done."

echo "Starting infinite loop..."

echo "Press [CTRL+C] to stop.."

while true
do
	sleep 1
done
