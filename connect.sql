@vars.sql

set lines 140 pages 999

col username for a10
col instance_name for a14
col db_name for a10
col sid for a10
col spid for a10

prompt connect &&test_user/*****@&&test_vip:1521/&&test_service..&&test_domain
connect &&test_user/&&test_user_pwd@&&test_vip:1521/&&test_service..&&test_domain

@ses-status.sql
