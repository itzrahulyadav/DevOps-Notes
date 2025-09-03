### Create a google spanner instance

```
 gcloud spanner instances create [INSTANCE-ID] \
    --config=[INSTANCE-CONFIG] \
    --description="[INSTANCE-NAME]" \
    --nodes=[NODE-COUNT]

```

### List the instance which was created

```
gcloud spanner instances list

```

### Create the database in the spanner using cli

```
gcloud spanner databases create banking-db-2 --instance=banking-instance-2
```

### Modify the number of nodes

```
gcloud spanner instances update banking-instance-2 --nodes=1
```


### Deleting the instance

```
gcloud spanner instances delete banking-instance-2

```



### Insert data with ddl
- Run the following command using cloudshell

```
gcloud spanner databases execute-sql banking-db --instance=banking-instance \
 --sql="INSERT INTO Customer (CustomerId, Name, Location) VALUES ('bdaaaa97-1b4b-4e58-b4ad-84030de92235', 'Richard Nelson', 'Ada Ohio')"

```

