set linesize 160
col event format a30
col sample_time format a40

select sample_time, sql_id, event, count(session_id) from v$active_session_history
 where sample_time > to_date('18.06.2015 17:00', 'DD.MM.YYYY HH24:MI')
   and sample_time < to_date('18.06.2015 20:00', 'DD.MM.YYYY HH24:MI')
 group by sample_time, event, sql_id
 order by sample_time asc
/