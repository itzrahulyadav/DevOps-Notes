# Create an RDS instance in AWS

Docs: [RDS](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ConnectToInstance.html)


1. Create an RDS with public access to false
2. Select engine to be postgresql
3. Select free tier
4. Give name to your RDS `Dev-DB`
5. Select credentials to be self managed.
6. Choose strong passwords `DBUser#123`
7. For Connectivity choose `Connect to an EC2 Compute resource`
8. Keep the other values as is
9. Create a new VPC security group
10. Database authentication should be `Password authentication`
11. Disable performance insights
12. Connect to your postgresql rds

13. Install the command line client [AWS Docs](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/mysql-install-cli.html)

14. Install the pqsl client

```

sudo dnf install postgresql15 postgresql15-server -y
sudo -u postgres /usr/bin/initdb --pgdata=/var/lib/pgsql/data


```

```
psql \
   --host=<DB instance endpoint> \
   --port=<port> \
   --username=<master username> \
   --password \
   --dbname=postgres <default db>

It will prompt for password

// psql example
psql --host=mypostgresql.c6c8mwvfdgv0.us-west-2.rds.amazonaws.com --port=5432 --username=awsuser --password --dbname=mypgdb 

// sql
mysql -h <endpoint> -P 3306 -u <username> -p

```
14. Create a mysql database

```sql

CREATE DATABASE mydatabase; // for postgres
create database mydatabase; // for sql

show databases; //for sql
SELECT datname FROM pg_database; //for psql or \c
````

13. use the database

```sql
USE mydatabase; // sqql
\c mydatabase; // postgresql

```

14. Create a table named users

```sql

CREATE TABLE users (id INT AUTO_INCREMENT PRIMARY KEY,name VARCHAR(255) NOT NULL,email VARCHAR(255) UNIQUE NOT NULL); // sql


// for postgresql

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL
);

describe users //sql
\dt //psql

```

15. Insert data into users table

```sql

INSERT INTO users (name, email) VALUES
('John Doe', 'john.doe@example.com'),
('Jane Smith', 'jane.smith@example.com'),
('Alice Johnson', 'alice.johnson@example.com'),
('Bob Brown', 'bob.brown@example.com'),
('Charlie Davis', 'charlie.davis@example.com');

```

16. Run a query to check the entries

```sql

select * from users

```


17. exit

```

\q

```

