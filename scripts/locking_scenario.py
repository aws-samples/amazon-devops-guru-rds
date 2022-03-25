#! /bin/env python3

import mysql.connector
import string
import random
import os
import sys
import threading
import multiprocessing

from datetime import datetime
from time import time, sleep

session, max_seconds, delay_seconds = int(
    sys.argv[1]), int(sys.argv[2]), int(sys.argv[3])


def create_lock(timer):
    conn = mysql.connector.connect(
        user=os.environ["DBUSER"],
        password=os.environ["DBPASSWORD"],
        host=os.environ["HOST"],
        database=os.environ["DB"],
        use_pure=False
    )
    cursor = conn.cursor()

    sql = "update test1 set timer=%(timer)s where id=-1"

    cursor.execute("set innodb_lock_wait_timeout=%(timeout)s",
                   {"timeout": max_seconds+50})
    cursor.execute(sql, {"timer": datetime.now()})

    cursor.close()
    conn.close()


print(f"BEGIN: {session}")
i, threads, start_time = 0, [], time()
while True:
    if time() - start_time > max_seconds:
        break

    try:
        print(f"Session: {session}: starting thread: {i}")
        x = threading.Thread(target=create_lock, args=(datetime.now(),))
        threads.append(x)
        x.start()
        sleep(delay_seconds)
        i += 1

    except Exception as e:
        print(f"Session: {session} failed at: {i}: {e}")
        sleep(1)

print(f"END: {session}")
[_.join() for _ in threads]
