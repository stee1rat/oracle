alter session set nls_date_format = 'DD.MM.YYYY HH24:MI:SS';

select sql_id, 
       plan_hash_value, 
       child_number,       
       executions, 
       round(elapsed_time/decode(executions,0,1,executions)/1e6,5) avg_time, 
       round(disk_reads/decode(executions,0,1,executions),2) avg_disk_reads, 
       round(buffer_gets/decode(executions,0,1,executions),2) avg_buffer_gets,
       last_active_time
  from v$sql 
 where sql_id = '3njba9fjtzfa9';
 
select * from table(dbms_xplan.display_cursor('3gsxwd71msx65',0));
select * from table(dbms_xplan.display_awr('3gsxwd71msx65',1323758824));
