# DevOps Guru MySQL

This repository contains CloudFromation template, some scripts and guidance how to use these resources on your own for creating and exploring DevOps Guru insights.

## Get Started

- Download [here](/DevOpsGuruMySQL.yaml) CloudFormation template and use AWS CLI to create the stack

  ```sh
  aws cloudformation create-stack --stack-name DevOpsGuru-Stack \
      --template-body file://DevOpsGuruMySQL.yaml \
      --capabilities CAPABILITY_IAM
  ```

- This will create the resources that will be needed in your account including IAM roles, RDS Database for one test case and Cloud9 IDE which will create another CloudFormation Stack.
- If you are planning to run more than one use case, you can add `--parameters ParameterKey=Tests,ParameterValue=all` to the script above to create a separate database per each test scenario since using the same database for more than one test case will not crate the same results by DevOps Guru.

## Prerequisites

- CloudFormation creates Cloud9 IDE that you will use to run scripts. Go to [Cloud9](https://console.aws.amazon.com/cloud9/home) and hit Open IDE for the environment called `DevOpsGuruMySQLInstance`.
- Upload the content of the `scripts` folder in this repository to Cloud9.
- Export the secrets running `setup.sh` script using Cloud9 terminal as below. This script will install some necessary libraries as well.

  ```sh
  sh setup.sh
  source ~/.bashrc
  ```

- If you are planning to run all test cases, you may add a parameter called `all` to the script to create and export connection parameters for all databases.

  ```sh
  sh setup.sh all
  source ~/.bashrc
  ```

## Prep for Running Tests

- **NOTE: This step should be applied for each database if you want to run all test cases.**

- Create test objects by running following commands on Cloud9 terminal.

  ```sh
  # Connect to the RDS database using the helper
  source ./connect.sh

  # OPTIONAL: You can add a parameter to connect to a different database for different use case
  source ./connect.sh test 2
  source ./connect.sh test 3

  # Select database
  USE devopsgurusource;

  # Create test table
  MySQL [devopsgurusource]> CREATE TABLE test1 (id int, filler char(255), timer timestamp);

  # Exit
  MySQL [devopsgurusource]> exit;
  ```

- Run [ct.py](scripts/ct.py) script in Cloud9 as below. This script will add 10 million records to `test1` table. This may take a long time to complete.

  ```sh
  python3 ct.py
  ```

- Add indexes

  ```sh
  # Connect to the RDS database using the helper
  source ./connect.sh test 1

  # Change `test` parameter to connect to a different database for a specific test case

  # Add index
  MySQL [devopsgurusource]> CREATE UNIQUE INDEX test1_pk ON test1(id);

  # Insert locker
  MySQL [devopsgurusource]> INSERT INTO test1 VALUES (-1, 'locker', current_timestamp);
  ```

## Test 1: Locking Issues

### Scenario

Multiple sessions compete for the same (“locked”) record and have to wait for each other. In real life, this often happens when:

1. Session gets disconnected due to a (i.e. temporary network) malfunction, while still holding a critical lock. (blocking)
2. Other sessions become stuck, while waiting for the lock to release
3. The problem is often exacerbated by application connection manager that keeps spawning additional sessions (because: existing sessions do not complete the work on time), creating distinct “inclined slope” pattern that you’ll see in this scenario.

### SQL being run

```sh
UPDATE test1 SET timer=current_timestamp() WHERE id=-1;
```

### Window 1

Locks the record with id=-1, for which other sessions will compete.

```sh
MySQL [devopsgurusource]> START TRANSACTION;
MySQL [devopsgurusource]> UPDATE test1 SET timer=current_timestamp() WHERE id=-1;
-- Do NOT exit!
```

### Window 2

Start "competing” sessions

```sh
# Set environment variables
source ./connect.sh test 1
MySQL [devopsgurusource]> exit;

# Running for 1200 seconds (20 minutes)
python3 locking_scenario.py 1 1200 2
```

## Test 2: Autocommit

### Scenario

When AUTOCOMMIT setting on a database driver is turned ON (which is, often a “default”), each DML statement gets “encased” in its own transaction, requiring data changes to be synchronized to disk, which dramatically increases statement latency.

### SQL being run

```sh
for id in <sequential_range>:
    UPDATE test1 SET timer=current_timestamp() WHERE id=:id
```

### Test

```sh
# Set environment variables
source ./connect.sh test 2
MySQL [devopsgurusource]> exit;

# Run 50 concurrent sessions
# Each session updates 1000-record batches, with records ordered sequentially
# All sessions run for 1200 seconds (20 minutes)
# autocommit driver setting is: ON
python3 batch_autocommit.py 50 1200 1000 10000000
```

## Test 3: Missing Index

### Scenario

When index gets dropped on a large table, simple index lookups that used to use it switch to scanning the entire table, increasing latency and resource use dramatically.
The problem is made more pronounced if there are multiple concurrent sessions executing lookups (which is, typically, the case).

### SQL being run

```sh
SELECT * FROM test1 WHERE id=:id;
```

**Prerequisites** drop the index

```sh
# Set environment variables
source ./connect.sh test 3

# Drop the index
MySQL [devopsgurusource]> DROP INDEX test1_pk ON test1;
MySQL [devopsgurusource]> exit;
```

### Test

```sh
# Run 50 concurrent session
# Each session is running continuous index lookups (with no index)
# All sessions run for 1200 seconds (20 minutes)
python3 no_index.py 50 1200 1000 10000000
```
