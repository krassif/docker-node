#!/usr/bin/env bash

# Get running container's IP
HOST=`hostname --ip-address`

MODULED="./node_modules";

if [ -d "$MODULED" ]
then
    echo "INFO: $MODULED does exist. Skipping yarn install/"
else
    eval "HOST=$HOST yarn install $INSTALL_OPTS"
fi;

# if [ $# == 1 ]; then SEEDS="$1,$IP"; 
# else SEEDS="$IP"; fi

# # Setup cluster name
# if [ -z "$CASSANDRA_CLUSTERNAME" ]; then
#         echo "No cluster name specified, preserving default one"
# else
#         sed -i -e "s/^cluster_name:.*/cluster_name: $CASSANDRA_CLUSTERNAME/" $CASSANDRA_CONFIG/cassandra.yaml
# fi

# # Setup num_tokens
# if [ -z "$CASSANDRA_NUM_TOKENS" ]; then
#         echo "No num_tokens specified, preserving default one"
# else
#         sed -i -e "s/^#\s*num_tokens:.*/num_tokens: $CASSANDRA_NUM_TOKENS/" $CASSANDRA_CONFIG/cassandra.yaml
# fi


# # 0.0.0.0 Listens on all configured interfaces
# # but you must set the broadcast_rpc_address to a value other than 0.0.0.0
# sed -i -e "s/^rpc_address.*/# rpc_address: 0.0.0.0/" $CASSANDRA_CONFIG/cassandra.yaml
# sed -i -e "s/^#\s*rpc_address.*/rpc_interface: eth0/" $CASSANDRA_CONFIG/cassandra.yaml

# # Be your own seed
# sed -i -e "s/- seeds: \"127.0.0.1\"/- seeds: \"$SEEDS\"/" $CASSANDRA_CONFIG/cassandra.yaml

# # Listen on IP:port of the container
# sed -i -e "s/^listen_address.*/listen_address: $IP/" $CASSANDRA_CONFIG/cassandra.yaml

# # With virtual nodes disabled, we need to manually specify the token
# echo "JVM_OPTS=\"\$JVM_OPTS -Dcassandra.initial_token=0\"" >> $CASSANDRA_CONFIG/cassandra-env.sh

# # Pointless in one-node cluster, saves about 5 sec waiting time
# echo "JVM_OPTS=\"\$JVM_OPTS -Dcassandra.skip_wait_for_gossip_to_settle=0\"" >> $CASSANDRA_CONFIG/cassandra-env.sh

# # Most likely not needed
# echo "JVM_OPTS=\"\$JVM_OPTS -Djava.rmi.server.hostname=$IP\"" >> $CASSANDRA_CONFIG/cassandra-env.sh

# # If configured in $CASSANDRA_DC, set the cassandra datacenter.
# if [ ! -z "$CASSANDRA_DC" ]; then
#     sed -i -e "s/endpoint_snitch: SimpleSnitch/endpoint_snitch: PropertyFileSnitch/" $CASSANDRA_CONFIG/cassandra.yaml
#     echo "default=$CASSANDRA_DC:rac1" > $CASSANDRA_CONFIG/cassandra-topology.properties
# fi

# exec cassandra -f
