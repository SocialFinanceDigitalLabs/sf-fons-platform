
----====> NOTE: Empty Database Deployment -
----====> NOTE: Template for a Web App DB - Dev Environment - but can be used for any DB 

----=========> Checks Start 

----====> Check whether the database and application role already exist.

SELECT datname
FROM pg_database
WHERE datname = 'db_filesystem_dev';

SELECT rolname
FROM pg_roles
WHERE rolname = 'db_filesystem_app_dev';

----=========> Checks End 

----=========> Script Start 

# Connect to the PostgreSQL RDS instance as admin.

psql \
  "host=postgres.cluster-c5wedn8epwoc.eu-west-2.rds.amazonaws.com port=3306 dbname=postgres user=postgres sslmode=require" \
  -W

----====> Create a restricted login role for the application.

CREATE ROLE db_filesystem_app_dev
    WITH LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION;

----====> Set the application role password.

\password db_filesystem_app_dev


----====> Temporarily grant role membership to create the database with the application role as owner.

GRANT db_filesystem_app_dev TO postgres;

CREATE DATABASE db_filesystem_dev
    OWNER db_filesystem_app_dev
    TEMPLATE template0;

REVOKE db_filesystem_app_dev FROM postgres;

----====> Verify database ownership and removal of temporary role membership.

SELECT d.datname, r.rolname AS owner
FROM pg_database d
JOIN pg_roles r ON r.oid = d.datdba
WHERE d.datname = 'db_filesystem_dev';

SELECT pg_has_role('postgres', 'db_filesystem_app_dev', 'MEMBER');

----====> Connect to the application database as admin.

\connect db_filesystem_dev postgres

----====> Restrict public schema creation and grant application-specific permissions.

BEGIN;

REVOKE CREATE ON SCHEMA public FROM PUBLIC;
GRANT USAGE, CREATE ON SCHEMA public TO db_filesystem_app_dev;

COMMIT;

----====> Reconnect to the database using the application role.

\connect db_filesystem_dev db_filesystem_app_dev

----====> Verify application identity, database context and schema permissions.

SELECT
    current_user,
    current_database(),
    has_schema_privilege(current_user, 'public', 'CREATE') AS can_create;

\dn+ public

----=========> Script End 

----=========> Table Structure Start 

#
# To populate database table structure, initialise Django tables locally from the application repo.
# - Configure the DEV database connection and application environment variables.
# - Ensure RDS is reachable (VPN, SSH/SSM tunnel or permitted network access) if not already 
#
# - Be mindful of database context 
#
# - Execute the following:
# poetry run python manage.py migrate
#
# - Verify using:
# poetry run python manage.py showmigrations
#
# Expected to creates Django tables and needed structure 
# 

----=========> Table Structure End 
