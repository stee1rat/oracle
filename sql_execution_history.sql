-- sql execution history

col begin_interval_time format a30

select sql_id, snap_id, plan_hash_value, sql_profile, executions_total,
       trunc(decode(executions_total, 0, 0, rows_processed_total/executions_total)) rows_avg,
       trunc(decode(executions_total, 0, 0, fetches_total/executions_total)) fetches_avg,
       trunc(decode(executions_total, 0, 0, disk_reads_total/executions_total)) disk_reads_avg,
       trunc(decode(executions_total, 0, 0, buffer_gets_total/executions_total)) buffer_gets_avg,
       trunc(decode(executions_total, 0, 0, cpu_time_total/executions_total)) cpu_time_avg,
       trunc(decode(executions_total, 0, 0, elapsed_time_total/executions_total)) elapsed_time_avg,
       trunc(decode(executions_total, 0, 0, iowait_total/executions_total)) iowait_time_avg,
       trunc(decode(executions_total, 0, 0, clwait_total/executions_total)) clwait_time_avg,
       trunc(decode(executions_total, 0, 0, apwait_total/executions_total)) apwait_time_avg,
       trunc(decode(executions_total, 0, 0, ccwait_total/executions_total)) ccwait_time_avg,
       trunc(decode(executions_total, 0, 0, plsexec_time_total/executions_total)) plsexec_time_avg,
       trunc(decode(executions_total, 0, 0, javexec_time_total/executions_total)) javexec_time_avg
from dba_hist_sqlstat
where sql_id = '9g5qqpk7zhjd2'
order by sql_id, snap_id;
