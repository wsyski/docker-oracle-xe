#!/bin/bash

. oraenv 

echo "Initializing Arena"
sqlplus / as sysdba << EOF
  alter system set processes=300 scope=spfile;
  alter system set sessions=600 scope=spfile;
  alter pluggable database XEPDB1 close;
  drop pluggable database XEPDB1 including datafiles;

  create pluggable database ARENA admin user axsys identified by GGHt7
  file_name_convert=('/opt/oracle/oradata/XE/pdbseed','/opt/oracle/oradata/XE/ARENA');
  alter pluggable database ARENA open read write;
  alter pluggable database all save state;
  alter session set container=ARENA;
  grant dba to axsys with admin option;
  grant create any job to axsys with admin option;
  GRANT aq_administrator_role TO axsys with admin option;
  GRANT aq_user_role TO axsys with admin option;
  GRANT EXECUTE ON dbms_aqadm TO axsys with grant option;
  GRANT EXECUTE ON dbms_aq TO axsys with grant option;
  grant execute on utl_smtp to axsys with grant option;
  grant execute on utl_http to axsys with grant option;
  grant execute on utl_file to axsys with grant option;
  GRANT EXECUTE ON dbms_aqin TO axsys with grant option;
  create tablespace data datafile '/opt/oracle/oradata/XE/ARENA/data01.dbf' size 1024M autoextend on next 512m maxsize 16384m extent management local;
  CREATE DIRECTORY arenaDatadir AS '/opt/oracle/arena';
  GRANT ALL ON DIRECTORY arenaDatadir TO PUBLIC;
  exec dbms_service.CREATE_SERVICE('arena-central','arena-central');
  exec dbms_service.start_service('arena-central');
  alter system register;
  alter pluggable database save state;
  exec dbms_service.CREATE_SERVICE('arena-local','arena-local');
  exec dbms_service.start_service('arena-local');
  alter system register;
  alter pluggable database save state;
  exec dbms_service.CREATE_SERVICE('ehub','ehub');
  exec dbms_service.start_service('ehub');
  alter system register;
  alter pluggable database save state;

  ALTER PROFILE DEFAULT LIMIT FAILED_LOGIN_ATTEMPTS UNLIMITED PASSWORD_LIFE_TIME UNLIMITED;
  create role arena_user;
  GRANT connect TO arena_user;
  GRANT resource TO arena_user;
  GRANT CREATE SESSION TO arena_user;
  grant execute on  dbms_aq to arena_user;
  grant create view to arena_user;
  grant create job to arena_user;
  grant create trigger to arena_user;
  grant create table to arena_user;
  grant execute on sys.dbms_aq to arena_user;
  grant execute on sys.utl_smtp to arena_user;
  grant execute on sys.utl_file to arena_user;
  grant execute on sys.dbms_aq to arena_user;
  grant execute on sys.utl_smtp to arena_user;
  grant execute on sys.utl_file to arena_user;
  create role arena_dba identified by aarenaa;
  grant dba to arena_dba;
EOF