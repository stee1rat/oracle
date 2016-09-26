select * from dba_sql_profiles order by created;

select object_name, object_alias, t.* 
  from v$sql_plan t 
  where sql_id in ('3njba9fjtzfa9')
    and object_name in ('ENT_INDEX_SBERBANKREPORTSDATA', 'DATA_HISTORY_REPORT_DATA');

select extractvalue(value(h),'.')
  from v$sql_plan p,
       table(xmlsequence(extract(xmltype(p.other_xml),'*/outline_data/hint'))) h
 where p.sql_id = '3njba9fjtzfa9'
 and p.child_number = 1
   and p.other_xml is not null;
   
declare
  text clob;
begin
  select sql_fulltext into text from v$sql where sql_id = '40vhq1m88bb31' and child_number = 0;
  dbms_sqltune.import_sql_profile(sql_text => text,
                                  profile => sqlprof_attr('USE_HASH("Work"@"SEL$1" "PC0"@"SEL$1"'),
                                  name => 'profile_40vhq1m88bb31');
end;  

begin
  dbms_sqltune.drop_sql_profile('SYS_SQLPROF_014840710c4f0001');
end;