## Backup Councourse Database

#### Dump the db

1. try to connect to db
```
/var/vcap/jobs/postgres/packages/postgres-9.6.6/bin/psql -U concourse atc
```
2. Dump the db
```
/var/vcap/jobs/postgres/packages/postgres-9.6.6/bin/pg_dump -U concourse atc > dbexport.pgsql
```

3. Copy to your local machine

    If the dump file is larger then 1 GB, then compress before download to your machine.
```
bosh -e sl -d concourse scp db:/var/vcap/jobs/postgres/dbexport.pgsql ~/Developer/workspace/cloudfoundry/bits-service-private-config
```

#### Restore concourse db

1. make a zip of the db_dump

2. copy the zip into the db instance
```
bosh -e sl -d concourse scp ~/Developer/workspace/cloudfoundry/bits-service-private-config/dbexport.pgsql db:/tmp/dbexport.pgsql.zip
```
3. Stop the db client access `bosh -e concourse -d concourse stop web`
4. login into the db instance via bosh ssh

5. connect to the db
```
/var/vcap/jobs/postgres/packages/postgres-9.6.6/bin/psql -U vcap
```
6. close active connections
```
SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE pg_stat_activity.datname = 'atc' AND pid <> pg_backend_pid();
```

7. delete db
```
/var/vcap/jobs/postgres/packages/postgres-9.6.6/bin/dropdb -U vcap atc
```
8. create db
```
/var/vcap/jobs/postgres/packages/postgres-9.6.6/bin/createdb -U vcap atc
```

9. unzip the db dump
```
unzip /tmp/dbexport_zip.pgsql.zip
```
10. Restore the db with the import of the dump
```
/var/vcap/jobs/postgres/packages/postgres-9.6.6/bin/psql -U concourse atc < dbexport_zip.pgsql
```

