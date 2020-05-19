#!/bin/sh

# Pull environment for this install
. "`cd \`dirname $0\` && /bin/pwd`/../lib/env.sh"

# Make sure the user running this script is the owner and/or su to that user
check_user "$@"
ES=$?
if [ "$ES" -ne 0 ]; then
    exit $ES
fi

# Keep track of where script was invoked
ORIGINAL_DIR=$(pwd)

# Make sure CWD is set to runner run dir
cd $RUNNER_BASE_DIR

# Identify the script name
SCRIPT=`basename $0`

node_up_check

TARGET_NODE=$RIAK_NODENAME_PREFIX@$1.$FRAMEWORK_HOST

echo "Attempting to join $RIAK_NODENAME to $TARGET_NODE"

$ERTS_PATH/erl -noshell $NAME_PARAM node_connect$NAME_HOST -setcookie $COOKIE -pa $RUNNER_LIB_DIR/basho-patches -eval "net_kernel:connect('$TARGET_NODE')" -s init stop || true
/usr/local/riak/bin/riak-admin cluster join $TARGET_NODE || true
/usr/local/riak/bin/riak-admin cluster plan || true
/usr/local/riak/bin/riak-admin cluster commit || true