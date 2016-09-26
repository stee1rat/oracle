alter session set nls_date_format = 'DD.MM.YYYY HH24:MI:SS';
select local_tran_id , FAIL_TIME from dba_2pc_pending;

begin
 for i in (select local_tran_id, FAIL_TIME from dba_2pc_pending) loop
  execute immediate 'rollback force ''' || i.local_tran_id || '''';
  dbms_transaction.purge_lost_db_entry(i.local_tran_id);
  commit;
 end loop;
 end;
/
