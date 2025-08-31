
set lines 132 pages 999

col username for a10
col instance_name for a14
col db_name for a10
col sid for 9999
col spid for a10
col failover_method for a15
col failover_type for a13
col failed_over for a11
col drain_status for a13

select
  sys_context('userenv', 'current_user') username,
  sys_context('userenv', 'db_name') db_name,
  sys_context('userenv', 'instance_name') instance_name,
  to_number(sys_context('userenv', 'sid')) sid,
  (select spid from v$process
   where addr =
     (select paddr from v$session where sid = sys_context('userenv', 'sid'))
  ) spid,
  failover_method,
  failover_type,
  failed_over,
  sys_context('userenv', 'drain_status') drain_status
from
  v$session
where
   sid = sys_context('userenv', 'sid');


