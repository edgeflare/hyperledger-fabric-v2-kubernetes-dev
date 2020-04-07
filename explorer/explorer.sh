kubectl -n org1 exec -i $(kubectl -n org1 get pod -l app=explorerdb -o name) -c explorer-db -- ./createdb.sh
