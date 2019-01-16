#!/bin/bash

. oraenv 

echo "Initializing Arena"
sqlplus / as sysdba << EOF
  alter system set processes=300 scope=spfile;
  alter system set sessions=600 scope=spfile;
  alter system set db_recovery_file_dest_size=4096G scope=both;

  create pluggable database ARENA admin user axsys identified by GGHt7
  file_name_convert=('/opt/oracle/oradata/XE/pdbseed','/opt/oracle/oradata/XE/ARENA');
  alter pluggable database ARENA open read write;
  alter pluggable database all save state;
  alter session set container=ARENA
  create tablespace data datafile '/opt/oracle/oradata/XE/ARENA/data01.dbf' size 1024M autoextend on next 512m maxsize 9216M extent management local;
  create tablespace image datafile '/opt/oracle/oradata/XE/ARENA/image01.dbf' size 1024M autoextend on next 512m maxsize 9216M extent management local;
  create tablespace indx datafile '/opt/oracle/oradata/XE/ARENA/indx01.dbf' size 1024M autoextend on next 512m maxsize 6194M extent management local;
  CREATE DIRECTORY dp_dir AS '/opt/oracle/oradata/dp';
  GRANT ALL ON DIRECTORY dp_dir TO PUBLIC;
  exec dbms_service.CREATE_SERVICE('arena-central','arena-central');
  exec dbms_service.start_service('arena-central');
  alter system register;
  alter pluggable database save state;
  exec dbms_service.CREATE_SERVICE('arena-local','arena-local');
  exec dbms_service.start_service('arena-local');
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