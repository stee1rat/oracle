select bytes/1024/1024/1024 from dba_segments where segment_name = 'PC_HISTORY_WORK'; 
select sum(bytes/1024/1024/1024) from dba_segments where segment_name = 'PC_HISTORY_WORK'; 
select * from dba_ind_columns where table_name = 'ENT_INDEX_SBERBANKREPORTSDATA' order by index_name, column_position;
select * from dba_ind_columns where index_name = 'PC_HISTORY_WORK_PZTM_OBJ_HSTTP';
select * from dba_tab_columns where table_name = 'PC_HISTORY_WORK';