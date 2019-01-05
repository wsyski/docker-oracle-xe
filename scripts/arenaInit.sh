#!/bin/bash

. oraenv 

echo "Initializing Arena"
sqlplus / as sysdba << EOF
  create pluggable database ARENA admin user axsys identified by GGHt7
  file_name_convert=('/opt/oracle/oradata/XE/pdbseed','/opt/oracle/oradata/XE/ARENA');
  alter pluggable database ARENA open read write;
  alter pluggable database all save state;
  CREATE DIRECTORY dp_dir AS '/opt/oracle/oradata/dp';
  GRANT ALL ON DIRECTORY dp_dir TO PUBLIC;
EOF