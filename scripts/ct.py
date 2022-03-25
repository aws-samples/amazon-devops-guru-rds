#! /bin/env python3

import mysql.connector
import string
import random
import os

from datetime import datetime


conn = mysql.connector.connect(
    user=os.environ["DBUSER"],
    password=os.environ["DBPASSWORD"],
    host=os.environ["HOST"],
    database=os.environ["DB"],
    use_pure=False
)
cursor = conn.cursor()

sql = "insert into test1(id, filler, timer) values(%(id)s, %(filler)s, %(timer)s)"

for i in range(10_000_000):
    dvars = {
        "id": i,
        "filler": "".join(random.choice(string.ascii_lowercase) for _ in range(255)),
        "timer": datetime.now(),
    }
    cursor.execute(sql, dvars)
    if not (i % 10_000):
        cursor.execute("commit")
        print(f"== {i}")

cursor.execute("commit")

cursor.close()
conn.close()
