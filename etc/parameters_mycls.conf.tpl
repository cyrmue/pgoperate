
# PostgreSQL binaries home alias to be used for this cluster.
#   Example:  TVD_PGHOME_ALIAS=pgh117
TVD_PGHOME_ALIAS=

# Base directory for this installation. Absolute path.
#   Example:  PGSQL_BASE=/u00/app/pgsql/mycls
PGSQL_BASE=

# Retention of the log files generated by the PgOperate scripts in $PGSQL_BASE/log/tools location.
TOOLS_LOG_RETENTION_DAYS=30


# PostgreSQL cluster port. Must not be used by any other cluster.
#   Example:  PG_PORT=5436
PG_PORT=

# Cluster encoding.
PG_ENCODING=UTF8

# Database name to create in cluster. If empty then no database will be created.
#   Example:  PG_DATABASE=maindb
PG_DATABASE=

# To enable block checksums for the cluster or not.
PG_ENABLE_CHECKSUM=yes

# The superuser account for the cluster
PG_SUPERUSER=postgres

# The password for the superuser account.
PG_SUPERUSER_PWD=

# Percentage of the host memory to use for cluster shared buffers
PCTMEM=30

# To enable SSL for this cluster or not.
ENABLE_SSL=no

# The absolute path and filename of the CA certificate for the SSL connections. Relevant if ENABLE_SSL is "yes".
#   Example:  CA_CERT="/home/user/root.crt"
CA_CERT=

# The absolute path and filename of the server  certificate for the SSL connections. Relevant if ENABLE_SSL is "yes".
#   Example:  SERVER_CERT="/home/user/server.crt"
SERVER_CERT=

# The absolute path and filename of the server private key for the SSL connections. Relevant if ENABLE_SSL is "yes".
#   Example:  SERVER_CERT="/home/user/server.key"
SERVER_KEY=

# This parameter defines the new line separated list of the configuration parameters which must be set.
# If `shared_buffers` will be set here, then it will be overridden by `PCTMEM` if defined. If `PCTMEM` is null then absolute value will be set.
PG_DEF_PARAMS="
max_connections=1000
huge_pages=off
password_encryption=scram-sha-256
logging_collector = on
log_directory = '$PGSQL_BASE/log'
log_filename = 'postgresql-%d.log'
log_truncate_on_rotation = on
log_rotation_age = 1d
log_rotation_size = 0
"



###########################
# Backup related parameters
###########################

# Parameter to set default backup location of the cluster
BACKUP_LOCATION=$PGSQL_BASE/backup

# Backup redundancy. Defines number of backups to keep.
BACKUP_REDUNDANCY=5

# Backup retention in days. Keeps backups required to restore so much days back.
# This parameter, if set, overrides BACKUP_REDUNDANCY parameter.
BACKUP_RETENTION_DAYS=7



################################
# Replication related parameters
################################

# Master host name or IP
MASTER_HOST=

# Master port
MASTER_PORT=

# Replication slots to be created. Can be comma separated list.
REPLICATION_SLOT_NAME="slave001, slave002, slave003"

# User replica will be created for replication purposes. This parameters defines its password.
REPLICA_USER_PASSWORD=




###########################
# Checks related parameters
###########################

PG_CHECK_WAL_COUNT=check_wal_count
PG_CHECK_WAL_COUNT_THRESHOLD=20
PG_CHECK_WAL_COUNT_OCCURRENCE=2

PG_CHECK_DEAD_ROWS=check_dead_rows
PG_CHECK_DEAD_ROWS_THRESHOLD=30
PG_CHECK_DEAD_ROWS_OCCURRENCE=2

PG_CHECK_STDBY_STATUS=check_stdby_status

PG_CHECK_STDBY_AP_LAG_MIN=check_stdby_ap_lag_time
PG_CHECK_STDBY_AP_LAG_MIN_THRESHOLD=10

PG_CHECK_STDBY_TR_DELAY_MB=check_stdby_tr_delay_mb
PG_CHECK_STDBY_TR_DELAY_MB_THRESHOLD=10

PG_CHECK_STDBY_AP_DELAY_MB=check_stdby_apply_delay_mb
PG_CHECK_STDBY_AP_DELAY_MB_THRESHOLD=100

PG_CHECK_MAX_CONNECT=check_max_conn
PG_CHECK_MAX_CONNECT_THRESHOLD=90
PG_CHECK_MAX_CONNECT_OCCURRENCE=2

PG_CHECK_LOGFILES=check_logfiles
PG_CHECK_LOGFILES_THRESHOLD="ERROR|FATAL|PANIC"

PG_CHECK_FSPACE=check_sapce_usage
PG_CHECK_FSPACE_THRESHOLD=90

