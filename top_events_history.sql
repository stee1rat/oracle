select sample_time, event, count(session_id) from dba_hist_active_sess_history 
 where sample_time > to_date('10.06.2015 09:00', 'DD.MM.YYYY HH24:MI')
   and sample_time < to_date('10.06.2015 18:00', 'DD.MM.YYYY HH24:MI')
   and event is not null
   and dbid = 3647405474
 group by sample_time, event
having count(session_id) > 3
 order by sample_time asc;