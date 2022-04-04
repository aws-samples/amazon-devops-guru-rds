#! /bin/env python3

import mysql.connector
import string
import random
import os
import sys
import threading

from datetime import datetime
from time import time, sleep


num_workers, max_seconds, batch_size, table_size = (
    int(sys.argv[1]), int(sys.argv[2]),
    int(sys.argv[3]), int(sys.argv[4])
)


def update_batch(session):
    conn = mysql.connector.connect(
        user=os.environ["DBUSER"],
        password=os.environ["DBPASSWORD"],
        host=os.environ["HOST"],
        database=os.environ["DB"],
        use_pure=False
    )
    cursor = conn.cursor()

    batch_sql = "select * from test1 where id=%(id)s"

    start_time = time()
    while True:
        if time() - start_time > max_seconds:
            break

        try:
            p_id = random.randint(0, table_size) - batch_size
            for i in range(batch_size):
                cursor.execute(batch_sql, {"id": p_id + i})
                _ = cursor.fetchall()
        except Exception as e:
            print(f"Session: {session} failed at: {i}: {e}")
            sleep(1)

    cursor.close()
    conn.close()


threads = []

print(
    f"BEGIN: Starting {num_workers} thread for {max_seconds} seconds. Batch size: {batch_size}")
for i in range(num_workers):
    x = threading.Thread(target=update_batch, args=(i,))
    threads.append(x)
    x.start()

print(f"WAITING for {num_workers} threads to complete")
[_.join() for _ in threads]
print(f"END")

print("The script is successfully completed.")
