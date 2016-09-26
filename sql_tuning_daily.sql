col object_name format a40
col owner format a8
select * from (
select o.owner, 
       o.object_name, 
       o.object_type, 
       s.bytes/1024/1024/1024,
       count(*)*8192/1024/1024/1024 
  from x$bh b, 
       dba_objects o,
       dba_segments s
 where o.object_id = b.obj 
       and s.segment_name = o.object_name
       and s.owner = o.owner
 group by o.owner, 
       o.object_name, 
       o.object_type,
       s.bytes/1024/1024/1024
  order by 5 desc) where rownum < 10;
 
with
p AS (
SELECT plan_hash_value
  FROM gv$sql_plan
 WHERE sql_id = TRIM('79dgttru12z7u')
   AND other_xml IS NOT NULL
 UNION
SELECT plan_hash_value
  FROM dba_hist_sql_plan
 WHERE sql_id = TRIM('79dgttru12z7u')
   AND other_xml IS NOT NULL ),
m AS (
SELECT plan_hash_value,
       SUM(elapsed_time)/SUM(executions) avg_et_secs
  FROM gv$sql
 WHERE sql_id = TRIM('79dgttru12z7u')
   AND executions > 0
 GROUP BY
       plan_hash_value ),
a AS (
SELECT plan_hash_value,
       SUM(elapsed_time_total)/SUM(executions_total) avg_et_secs
  FROM dba_hist_sqlstat
 WHERE sql_id = TRIM('79dgttru12z7u')
   AND executions_total > 0
 GROUP BY
       plan_hash_value )
SELECT p.plan_hash_value,
       ROUND(NVL(m.avg_et_secs, a.avg_et_secs)/1e6, 3) avg_et_secs
  FROM p, m, a
 WHERE p.plan_hash_value = m.plan_hash_value(+)
   AND p.plan_hash_value = a.plan_hash_value(+)
 order by
       avg_et_secs nulls last;
       
       
-- 1bvqfbtm2j3zq
select * from v$session where sql_id = '1bvqfbtm2j3zq';
select * from v$sql_plan where sql_id = '1g6fq3cycfwxm';

select sql_id, plan_hash_value, sql_text from v$sql where sql_id in ('8d0yk8ts7ws4k');

select sql_id, plan_hash_value,
       round((sum(elapsed_time_total)/sum(executions_total))/1e6, 3) avg_et_secs
  from dba_hist_sqlstat
 where sql_id in ('8d0yk8ts7ws4k')
   and executions_total > 0
 group by
       sql_id, plan_hash_value;
       
       
select * from v$sql where sql_id = '9qwrbymxwzf94';
select * from table(dbms_xplan.display_cursor('9qwrbymxwzf94'));

select plan_hash_value, executions from dba_hist_sqlstat where sql_id = '1bvqfbtm2j3zq' order by snap_id desc;

select plan_hash_value, executions, round(elapsed_time/executions/1e6, 3) from v$sql where sql_id = '9qwrbymxwzf94';

select * from table(dbms_xplan.display_cursor('5tqhkasqx1uag','0',''));
select * from table(dbms_xplan.display_awr('5tqhkasqx1uag','3875536485'));

select s.begin_interval_time, h.plan_hash_value, round(h.elapsed_time_delta/1e6, 3) 
from   dba_hist_sqlstat h,  dba_hist_snapshot s 
where  sql_id = '8d0yk8ts7ws4k' 
  and  s.snap_id = h.snap_id
order  by 
       s.begin_interval_time desc;
       
select s.begin_interval_time, h.plan_hash_value, round((h.elapsed_time_total/h.executions_total)/1e6, 3) 
from   dba_hist_sqlstat h,  dba_hist_snapshot s 
where  sql_id = '12tnn6m3h75s5' 
  and  s.snap_id = h.snap_id
order  by 
       s.begin_interval_time desc;

select * from dba_hist_snapshot ;
select * from v$sql where sql_id like '%1bvqf%';


select plan_hash_value, to_char(timestamp, 'DD.MM.YYYY HH24:MI:SS') from dba_hist_sql_plan where sql_id = '8d0yk8ts7ws4k' order by timestamp desc;

select plan_hash_value, to_char(timestamp, 'DD.MM.YYYY HH24:MI:SS') from v$sql_plan where sql_id = '12tnn6m3h75s5' order by timestamp desc;
select * from v$sql where sql_id = '12tnn6m3h75s5';

select * from dba_views where view_name like '%PLAN%';
select * from dba_tables where table_name like 'S_OPTY_POSTN';


begin
  dbms_stats.set_table_stats (
   ownname => 'SIEBEL', 
   tabname => 'S_OPTY_POSTN',
   numrows => 879893,
   no_invalidate => false);
   
end;

select sample_time, event, count(session_id) from dba_hist_active_sess_history 
where sample_time > to_date('14.05.2012 19:10', 'DD.MM.YYYY HH24:MI')
and sample_time < to_date('14.05.2012 19:18', 'DD.MM.YYYY HH24:MI')
and event is not null
group by sample_time, event
having count(session_id) > 3
order by sample_time asc;


select extractvalue(value(h),'.')
  from v$sql_plan p,
       table(xmlsequence(extract(xmltype(p.other_xml),'*/outline_data/hint'))) h
 where p.sql_id = '3z90tmhmv7cvj'
   and p.other_xml is not null;

select 'q''[' || extractvalue(value(h),'.') || ']'','
  from v$sql_plan p,
       table(xmlsequence(extract(xmltype(p.other_xml),'*/outline_data/hint'))) h
 where p.sql_id = '3z90tmhmv7cvj'
 --and p.child_number = 1
   and p.other_xml is not null;

select object_name, object_alias, t.* 
  from v$sql_plan t 
  where sql_id in ('76hvzchjs1yv6');

declare
  text clob;
begin
  select sql_fulltext into text from v$sql where sql_id = 'g9qzcgsy18vjh';
  dbms_sqltune.import_sql_profile(sql_text => text,
                                  profile => sqlprof_attr('OPTIMIZER_FEATURES_ENABLE(''10.2.0.4'')'),
                                  name => 'import_profile_g9qzcgsy18vjh');
end;  

DECLARE
sql_txt CLOB;
h       SYS.SQLPROF_ATTR;
BEGIN
h := SYS.SQLPROF_ATTR(
q'[BEGIN_OUTLINE_DATA]',
q'[IGNORE_OPTIM_EMBEDDED_HINTS]',
q'[OPTIMIZER_FEATURES_ENABLE('11.2.0.2')]',
q'[DB_VERSION('11.2.0.2')]',
q'[ALL_ROWS]',
q'[OUTLINE_LEAF(@"SEL$58A6D7F6")]',
q'[MERGE(@"SEL$1")]',
q'[OUTLINE(@"SEL$2")]',
q'[OUTLINE(@"SEL$1")]',
q'[INDEX_RS_ASC(@"SEL$58A6D7F6" "Work"@"SEL$1" ("ENT_INDEX_SBERBANKREPORTSDATA"."SYS_CLASSGROUP" "ENT_INDEX_SBERBANKREPORTSDATA"."PROC_PROCESSDEF" "ENT_INDEX
_SBERBANKREPORTSDATA"."APP_ISSUEDATETIME"))]',
q'[INDEX_RS_ASC(@"SEL$58A6D7F6" "PC0"@"SEL$1" ("DATA_HISTORY_REPORT_DATA"."PXOBJCLASS" "DATA_HISTORY_REPORT_DATA"."PXTIMECREATED"))]',
q'[LEADING(@"SEL$58A6D7F6" "Work"@"SEL$1" "PC0"@"SEL$1")]',
q'[USE_HASH(@"SEL$58A6D7F6" "PC0"@"SEL$1")]',
q'[END_OUTLINE_DATA]');

select sql_fulltext into sql_txt from v$sql where sql_id = '8dm29twm9ysc3' and child_number = 0;
DBMS_SQLTUNE.IMPORT_SQL_PROFILE (
sql_text    => sql_txt,
profile     => h,
name        => 'coe_8dm29twm9ysc3_HASHJOIN',
description => 'coe 8dm29twm9ysc3 HASHJOIN ',
category    => 'DEFAULT',
validate    => TRUE,
replace     => TRUE,
force_match => TRUE /* TRUE:FORCE (match even when different literals in SQL). FALSE:EXACT (similar to CURSOR_SHARING) */ );
END;

select c.child_address,
       child_number,       
       extractvalue(value(x),'//reason') reason,
       extractvalue(value(x),'//bind_position') bind_position,
       extractvalue(value(x),'//original_oacflg') original_oacflg,
       extractvalue(value(x),'//original_oacdty') original_oacdty,
       extractvalue(value(x),'//new_oacdty') new_oacdty
  from v$sql_shared_cursor c ,
       table(xmlsequence(extract(xmltype('<doc>'||c.reason||'</doc>'),'//ChildNode'))) x
 where sql_id = '9k26umgptg7x8'
 order by child_number, child_address;



