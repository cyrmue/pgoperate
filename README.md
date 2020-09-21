# TVD-PgOperate Tool-set to operate PostgreSQL clusters
---

## Prerequisites

PgOperate requires PgBaseEnv.

First PgBaseEnv must be installed.


## PostgreSQL cluster management scripts developed to automate regular tasks.

| Script                  | Description                                                            |
| ----------------------- | ---------------------------------------------------------------------- |
| **create_cluster.sh**   | Creates new PostgreSQL cluster.                                        |
| **prepare_master.sh**   | Prepares PostgreSQL cluster to master role.                            |
| **create_slave.sh**     | Creates standby cluster.                                               |
| **promote.sh**          | Promotes standby to master.                                            |
| **reinstate.sh**        | Starts old master as new standby.                                      |
| **backup.sh**           | Backup PostgreSQL cluster.                                             |
| **restore.sh**          | Restore PostgreSQL cluster.                                            |
| **check.sh**            | Executes different monitoring checks.                                  |


## Libraries

| Libraries               | Description                                                            |
| ----------------------- | ---------------------------------------------------------------------- |
| **shared.lib**          | Generally used functions.                                              |
| **check.lib**           | Check function for check.sh.                                           |


## Tool specific scripts

| Libraries                | Description                                                            |
| ------------------------ | ---------------------------------------------------------------------- |
| **pgoperate**            | Wrapper around all PgOperate scripts. Central execution point.         |
| **install_pgoperate.sh** | PgOperate installation script.                                         |
| **root.sh**              | Script to execute root actions after installation.                     |
| **bundle.sh**            | Generates installation bundle for PgOperate.                           |




## General concept

Each PostgreSQL cluster installation using PgOperate scripts will have following structure.

Like postgresql itself, we create single directory, one level over `PGDATA`, which will act as the base for the cluster.

We call this directory `PGSQL_BASE`.

The directory structure of the PgOperate itself is as follows:

```
$PGOPERATE_BASE ┐
                │
                ├─── bin ┐
                │        ├── pgoperate
                │        ├── create_cluster.sh
                │        ├── prepare_master.sh
                │        ├── create_slave.sh
                │        ├── promote.sh
                │        ├── reinstate.sh
                │        ├── backup.sh
                │        ├── restore.sh
                │        ├── check.sh
                │        ├── root.sh
                │        ├── install_pgoperate.sh
                │        ├── bundle.sh       
                │        └── VERSION
                │
                ├─── etc ┐
                │        ├── parameters_mycls.conf.tpl
                │        ├── parameters_<alias>.conf        
                │        └── ...
                │
                ├─── lib ┐
                │        ├── check.lib
                │        └── shared.lib
                │
                └─── bundle ┐
                            ├── install_pgoperate.sh
                            └── pgoperate-<version>.tar
````

Each installation will have its own single parameters file. The format of the parameter filename is important, it must be `parameters_<alias>.conf`. Where `alias` is the PgBaseEnv alias of the PostgreSQL cluster. It will be used to set its environment.

Parameter file includes all parameters required for cluster creation, backup, replication and monitoring. Everything in one place. All PgOperate scripts will use this parameter file for the current alias to get required values. It is our single point of truth.

The location of the cluster base directory `PGSQL_BASE` will be defined in the clusters `parameters_<alias>.conf` file as well.

After installation, base directory structure will look like this:

```
$PGSQL_BASE ┐
            │
            ├─── scripts ┐
            │            ├── start.sh
            │            └── root.sh
            │
            ├─── etc ┐
            │        ├── postgresql.conf
            │        ├── pg_ident.conf
            │        └── pg_hba.conf
            │
            ├─── data ┐
            │         └── $PGDATA
            │
            ├─── log ┐
            │        ├── server.log
            │        ├── postgresql-<n>.log
            │        ├── ...
            │        └── tools ┐
            │                  ├── <script name>_%Y%m%d_%H%M%S.log
            │                  └── ...
            ├─── cert
            │
            ├─── backup
            │
            └─── arch 

```

### Subdirectories

#### scripts

It will contain scripts related to current cluster.

`root.sh` - Must be executed as root user after cluster creation. It will register `postgresql-<alias>` unit by systemctl daemon and finalize cluster creation.

`start.sh` - Script to start PostgreSQL with `pg_ctl` utility. Can be used for special cases, it is recommended to use `sudo systmctl` to manage PostgreSQL instance.

#### etc

All configuration files related to current cluster will be stored in this folder.

#### data

The `$PGDATA` folder of the current cluster.

#### log

Main location to all log files related to the current cluster.

`server.log` - Is the cluster main log file. Any problems during cluster startup will be logged here. After successful start logging will be handed over to logging collector.

`postgresql-<n>.log` - Logging collector output files. By default PgOperate will use day of the month in place of n.

Sub-folder `tools` will include output logs from all the PgOperate scripts. Any script executed will log its output into this directory. Log filename will include script name and timestamp. First two lines of the logfile will be the list of arguments used to execute script and the current user id.

#### cert

Is the folder to store all server side certificate files for ssl connections.

If `ENABLE_SSL` parameter was set to "on" in `parameters_<alias>.conf` file then during cluster creation, cert files will be copied to this folder.

#### backup

Is the default and recommended location for the backups. Backup script will create backups in this folder. It is recommended to link this folder to some network attached storage. Especially is case of primary/standby configuration.

#### arch

In case of archive log mode, WAL files will be archived to **backup** sub-folder. This **arch** directory must be local. It will be used as fail-over location if **backup** folder will not be available.






## About parameters_\<alias\>.conf
---

It is a single parameter file which includes variables used by all management scripts.

Some parameters will be used only during cluster creation time, some will be used regularly.

It must be located in `$PGOPERATE_HOME/etc` folder.

Permissions of the config file must be `0600`.

There is `parameters_mycls.conf.tpl` template file with description of all the available parameters.

Parameters:

| Parameter                 | Default value                            | Description                                                                  |
| ------------------------- | ---------------------------------------- | ---------------------------------------------------------------------------- |
| **TVD_PGHOME_ALIAS**      |                                          | The PgBaseEnv alias for the PostgreSQL binaries home to be used for this cluster creation.            |
| **PGSQL_BASE**            |                                          | Cluster base directory.            |
| **TOOLS_LOG_RETENTION_DAYS** | `30`                                  | Retention in days of the log files generated by the PgOperate scripts in `$PGSQL_BASE/log/tools` location.                                   |
| **PG_PORT**               |                                          | Cluster port to create the cluster. It will be also registered in PgBaseEnv.                                   |
| **PG_ENCODING**           | `UTF8`                                   | The character set of the cluster. Used only during creation.                                   |
| **PG_DATABASE**           |                                          | Database name which will be created after installation. If empty, then no database will be created                     |
| **PG_ENABLE_CHECKSUM**    | `yes`                                    | Checksums on data pages. |
| **PG_SUPERUSER**          | `postgres`                               | The name of the superuser to create during setup.                            |
| **PG_SUPERUSER_PWD**  |                                          | The password for the superuser account.                             | 
| **PCTMEM**                | `30`                                     | The percent of the host memory to use for PostgreSQL shared buffers.         |
| **ENABLE_SSL**            | `no`                                    | Will try to copy `CA_CERT`, `SERVER_CERT` and `SERVER_KEY` to the `$PGSQL_BASE/cert` directory and then enable SSL connections to cluster. If some of these certificates will not be found then `ENABLE_SSL` will be forced to "no".                                                                 |
| **CA_CERT**               |                                          | File with CA certificate. Usually called root.crt.                           |
| **SERVER_CERT**           |                                          | File with SSL server certificate. Usually called server.crt.                 |
| **SERVER_KEY**            |                                          | File with SSL server private key. Usually called server.key.                 |
| **PG_DEF_PARAMS**         | Default value is below                   | String variable which includes the init parameters separated by new line. These parameters will be set in postgresql.conf during installation. If `shared_buffers` will be set here, then it will be overridden by `PCTMEM` if defined. If `PCTMEM` is null then absolute value will be set. |
| **BACKUP_LOCATION**       | `$PGSQL_BASE/backup`                     | Directory to store backup files.                                             |
| **BACKUP_REDUNDANCY**     | `5`                                      | Backup redundancy. Count of backups to keep.                                                 |
| **BACKUP_RETENTION_DAYS**  | `7`                                      | Backup retention in days. Keeps backups required to restore so much days back.  This parameter, if set, overrides BACKUP_REDUNDANCY.                                                |
| **MASTER_HOST**           |                                          | Replication related. The name or ip address of the master cluster.           |
| **MASTER_PORT**           |                                          | Replication related. The PORT of the master cluster. If not specified then `$PGPORT` will be used.           |
| **REPLICATION_SLOT_NAME** | `slave001, slave002, slave003  | Replication related. Replication slot names to be created in master cluster. More than one replication slot separated by comma can be specified.|
| **REPLICA_USER_PASSWORD** |                                          | Replication related. Password for user REPLICA which will be created on master site. Slave will use this credential to connect to master.|


`PG_CHECK_%` parameters described in `check.sh` section.

**PG_DEF_PARAMS** default value is 
```
    "max_connections=1000
     huge_pages=off
     password_encryption=scram-sha-256
     logging_collector = on
     log_directory = '$PGSQL_BASE/log'
     log_filename = 'postgresql-%d.log'
     log_truncate_on_rotation = on
     log_rotation_age = 1d
     log_rotation_size = 0"
 ```



# Scripts


## bundle.sh
---

This script can be used to create a bundle for the installation.

Execute it after modifications in some of the scripts.

It will create bundle by default in `$PGOPERATE_BASE/bundle` folder.

If you want to create bundle in some other location, then provide target folder as first argument.



## pgoperate
---

`pgoperate` is main interface to call all the PgOperate scripts.

During installation the alias pointing to it will be created in PgBaseEnv standard config file. That is why pgoperate can be called from any location.

But to call it from inside the scripts use full path like `$PGOPERATE_BASE/bin/pgoperate`

```
pgoperate --help


Available options:

  --create-cluster         Create new PostgreSQL Cluster
  --backup                 Backup PostgreSQL CLuster
  --restore                Restore PostgreSQL Cluster
  --check                  Execute monitoring checks
  --create-slave           Create Slave PostgreSQL Cluster and configure streaming replication
  --promote                Promote Slave cluster to Master
  --reinstate              Convert old Master to Slave and start streaming replication
  --prepare-master         Prepare PostgreSQL Cluster for Master role

  For each option you can get help by adding "help" keyword after the argument, like:
    pgoperate --backup help
```


## create_cluster.sh
---

This script will create a new PostgreSQL cluster.

Arguments:
   `-a|--alias <alias_name>` -  Alias name of the cluster to be created.

Alias name of the cluster to be created must be provided.

Parameters file for this alias must exist in `$PGOPERATE_BASE/etc` before executing the script.

The `$PGSQL_BASE` directory will be created. All subdirectories will be also created.

Cluster will be registered with PgBaseEnv. 

Next steps will be performed:

* Database `$PG_DATABASE` will be created if set.
* Schema with same name `$PG_DATABASE` will be created.
* User with same name `$PG_DATABASE` and without password will be created. This user will be owner of `$PG_DATABASE` schema.
* Replication related parameters will be adjusted
* Replication user and replication slot(s) will be create
* `pg_hba.conf` file will be updated

Script must be executed as postgres user.

At the end of installation script will offer to execute `root.sh` as root user.

Switch to root and execute `root.sh`. It will create `postgresql-<alias>` unit file in /etc/systemd/system for systemctl daemon and add `01_postgres` file into `/etc/sudoers.d` to allow `postgres` user to `start/stop/status/reload` the `postgresql-<alias>` service with sudo privileges. Cluster will be started with systemctl and in-cluster actions will be executed.

Local connection without password will be possible only by postgres user and root.

Example for cluster with alias cls1:

```
# Create parameters file for cls1
cd $PGOPERATE_BASE
cp parameters_mycls.conf.tpl parameters_cls1.conf

# Modify parameter file as required
vi parameters_cls1.conf

# Then execute as postgres
pgoperate --create-cluster --alias cls1
```





## prepare_master.sh
---

Script to create replica user and configure PostgreSQL as master site.

All these commands will be executed by `create_cluster.sh`, this script can be used in some scenarios when standby fails to connect to master,
then it is good to execute this script to be sure that all replication parameters and objects are in place.

It will check `track_commit_timestamp` parameter, if it is set to 'on'. If this parameter is 'on', then script will just reload configuration.
If `track_commit_timestamp` parameter is not set, then it will be set to 'on' and cluster will be restarted!

It will set next parameters in `$PGSQL_BASE/etc/postgresql.conf`
```
wal_level             to "replica"
max_wal_senders       to "10"
max_replication_slots to "10"
```

It will check and update `$PGSQL_BASE/etc/pg_hba.conf` file to allow replica user to connect over TCP with `scram-sha-256` encrypted password over replication protocol.

It will create replication slot(s) listed in `$REPLICATION_SLOT_NAME`.

It will create `REPLICA` user with replication permission and password `$REPLICA_USER_PASSWORD`.

Execute as postgres:
```
pgoperate --prepare-master
```



## create_slave.sh
---

Script to create standby PostgreSQL cluster.

This script requires `MASTER_HOST`, `REPLICATION_SLOT_NAME` and `REPLICA_USER_PASSWORD` parameters to be set in `$PGSQL_BASE/etc/parameters_<alias>.conf` file.

Note that, if `REPLICATION_SLOT_NAME` has more than one slot, then first one will be used in master connection string in `recovery.conf` or postgresql.conf file.

Script will set parameter `hot_standby` to "on" in `postgresql.conf`.

It will also set master related parameters, as a preparation for possible master role.

`pg_basebackup` utility will be used to duplicate all data files from master site.

It will also update `recovery.conf` or `postgresql.conf` file with related parameters.

If `$PGDATA` will not be empty, then error message will displayed. `$PGDATA` must be emptied or `--force` option must be used.


Execute as postgres:
```
sudo systemctl stop postgresql-<alias>
rm -Rf $PGDATA/*
pgoperate --create-slave

- or -

pgoperate --create-slave --force

```

At the end, script will check the status of WAL receiver, if it is "Streaming" then success message will be displayed.




## promote.sh
---


Can be executed to promote standby to master.

Master status will be checked, if it is still running, then database will not be promoted.

Can be used for Failover and Switchover operations.

For Switchover:

1. Stop master site:
  `sudo systemctl stop postgresql-<alias>`
2. Execute promote.sh on standby site
  `pgoperate --promote`
3. Start old master as new standby 
  `pgoperate --reinstate`  
  

Execute as postgres:
```
pgoperate --promote
```



## reinstate.sh
---

Script to start old primary as new standby server.
   
Script will try to start as standby in next oder:

1. Start old primary as new standby
2. If it fails to sync with master, then sync with `pg_rewind`
3. If it again fails then script will recreate standby from master if `-f` option was specified

Available options:
```
    `-m <hostname>`   Master host. If not specified master host from parameters_<alias>.conf will be used.
    `-f`              Force to recreate standby from master if everything else fails.
    `-r`              Execute only `pg_rewind` to synchronize primary and standby.
    `-d`              Recreate standby from master.
```

Execute as postgres:
```
pgoperate --reinstate -f
```






## backup.sh
---

Script to backup PostgreSQL cluster on Primary or Standby site.

Please check the script header for detailed information.

Backup will be made from online running cluster, it is hot full backup.

Backup can be execute on primary or standby.

Following backup strategies possible:
 * Database backup on master site and archived WAL backup on master site
 * Database backup on standby site and archived WAL backup on standby site
 * Database backup on standby site and archive WAL backup on primary site (Recommended)

Backups can be made also in no-archivelog mode, then restore will be possible only to backup end time.

Arguments:
                     `list` -  Script will list the contents of the BACKUP_LOCATION.
              `enable_arch` -  Sets the database cluster into archive mode. Archive location will be set to PGSQL_BASE/arch.
                               No backup will taken. Cluster will be restarted!
  `backup_dir=<directory>`  -  One time backup location. Archive log location will not be switched on this destination.


With parameters `BACKUP_REDUNDANCY` and `BACKUP_RETENTION_DAYS` in parameters_<alias>.conf, you can specify backups retention logic.

`BACKUP_REDUNDANCY` - Will define the number of backups to retain.

`BACKUP_RETENTION_DAYS` - Will define the number of the days you want to retain. If you will specify 7 for example, then backup script will guarantee that backups required to restore 7 days back will not be overwritten.

If both parameters specified, then `BACKUP_RETENTION_DAYS` overrides redundancy.

To make backup, execute without any arguments.

Execute as postgres:
```
pgoperate --backup
```

Use `list` to show all backups:
```
pgoperate --backup list
```






## restore.sh
---

Script to restore PostgreSQL cluster from backup.

If any external tablespaces exists in backup then their locations will be also cleared before restore.

Script can be executed without any parameters. In this case it will restore from the latest available backup.

 Arguments:
 ```
    list                        - Script will list the contents of the `BACKUP_LOCATION`.
    backup_dir=<directory>      - One time backup location. Will be used as restore source.
    from_subdir=<subdir>        - Execute restore from specified sub-directory number. Use 'list' to check all sub directory numbers. It must be number without date part.
    until_time=<date and time>  - To execute Point in Time recovery. Specify target time. Time must be in `\"YYYY-MM-DD HH24:MI:SS\"` format.
    pause                       - Will set `recovery_target_action` to pause in `recovery.conf` or `postgresql.conf`. When Point-In-Time will be reached, recovery will pause.
    shutdown                    - Will set `recovery_target_action` to shutdown in `recovery.conf` or `postgresql.conf`. When Point In Time will be reached, database will shutdown.
    verify                      - If this argument specified, then no actual restore will be execute. Use to check which sub-folder will be used to restore.
```

 Examples:
  Restore from last (Current) backup location:
```
    pgoperate --restore
```
  Restore from subdirectory 3:
```
    pgoperate --restore from_subdir=3
```

  First verify then restore to Point in Time `"2018-10-17 11:25:00"`:
```
    pgoperate --restore until_time="2018-10-17 11:25:00" verify
    pgoperate --restore until_time="2018-10-17 11:25:00"
```

Script by default looks to `BACKUP_LOCATION` from `parameters_<alias>.conf` for backups.

To restore from some other location, use `backup_dir` argument.

You can also list all backups from non-default location:
```
pgoperate --restore list backup_dir=/tmp/pgbackup

Backup location: /tmp/pgbackup
=========================================================================
|Sub Dir|      Backup created|WALs count|Backup size(MB)|  WALs size(MB)|
=========================================================================
|      4| 2019-08-03 12:09:09|         0|              5|              1| <--- Oldest backup dir
|      5| 2019-08-03 12:09:14|         0|              5|              1| <--- Current backup dir
=========================================================================
Number backups: 2
```

You can also restore from `subdir` or by specifying `until_time`:
```
pgoperate --restore backup_dir=/tmp/pgbackup from_subdir=4
```








## check.sh
---


Check script for PostgreSQL.

It is small framework to create custom checks.

As fist step check must be defined in `parameters_<alias>.conf` file with next parameters:
```
PG_CHECK_<CHECK NAME>=<check function name>
PG_CHECK_<CHECK NAME>_THRESHOLD=
PG_CHECK_<CHECK NAME>_OCCURRENCE=
```

Then check function must be defined in `check.lib` file.

If check defined then function with the specified name will be executed from `check.lib` library.

Function must return 0 on check success and 0 on check not passed.

Number of times check was not passed will be counted by check.sh, check function do not require to implement this logic.
If `PG_CHECK_<CHECK NAME>_OCCURRENCE` is defined, then `check.sh` will alarm only after defined number of negative checks.


There are special input and output variables that can be used in check functions:

Input variables:
    `<function_name>_THRESHOLD`   - Input variable, if there was threshold defined, it will be assigned to this variable.
    `<function_name>_OCCURRENCE`  - Input variable, if there was occurrence defined, it will be assigned to this variables.
 
    `$PG_BIN_HOME`  - Points to the bin directory of the postgresql.
    `$SCRIPTDIR`    - The directory of the check script location. Can be used to create temporary invisible files for example. 
    `$PG_AVAILABLE` - Will be true if database cluster available and false if not available.

Next functions can be called from check functions:
    `exec_pg <cmd>`   - Will execute cmd in postgres and return psql return code, output will go to stdout.
    `get_fail_count` - Will get the number of times this function returned unsuccessful result. It will be assigned to `<function_name>_FAILCOUNT` variable.

Output variables:
    `<function name>_PAYLOAD`     - Output variable, assign output text to it.
    `<function name>_PAYLOADLONG` - Output variable, assign extra output text to it. \n can be used to divide text to new lines.


When function returns 0 or 1, then it is also good to return some information to the user. This information can be passed over `<function name>_PAYLOAD` variable.
If some big amount of data, extra information must be displayed, then pass it over `<function name>_PAYLOADLONG` variable.

Check `check.lib` file for check function examples.

There are already few predefined checks.


