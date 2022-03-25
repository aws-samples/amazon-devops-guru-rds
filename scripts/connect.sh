#! /bin/bash

test="1"
HOST=""
PORT=""
DB=""
DBUSER=""
DBPASSWORD=""

if [ "$1" == "test" ]
then
    shift
    test=$1
fi

if [ "$test" == "2" ]
then
    HOST="${TEST2HOST}"
    PORT="${TEST2PORT}"
    DB="${TEST2DB}"
    DBUSER="${TEST2DBUSER}"
    DBPASSWORD="${TEST2DBPASSWORD}"
elif [ "$test" == "3" ]
then
    HOST="${TEST3HOST}"
    PORT="${TEST3PORT}"
    DB="${TEST3DB}"
    DBUSER="${TEST3DBUSER}"
    DBPASSWORD="${TEST3DBPASSWORD}"
else
    HOST="${TEST1HOST}"
    PORT="${TEST1PORT}"
    DB="${TEST1DB}"
    DBUSER="${TEST1DBUSER}"
    DBPASSWORD="${TEST1DBPASSWORD}"
fi

if [ "$HOST" == "" ] || [ "$PORT" == "" ] || [ "$DB" == "" ] || [ "$DBUSER" == "" ] || [ "$DBPASSWORD" == "" ]
then
    echo "Connection parameters are empty. Did you run setup command?"
    exit 1;
else
    echo "Updating environment variables."
    export HOST="${HOST}" 
    export PORT="${PORT}" 
    export DBUSER="${DBUSER}" 
    export DB="${DB}" 
    export DBPASSWORD="${DBPASSWORD}" 

    echo "Connecting to the database for test case #${test}"
    mysql -h${HOST} -P ${PORT} -u${DBUSER} -D ${DB} -p${DBPASSWORD}
fi
