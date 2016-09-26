set serveroutput on
DECLARE
  l_output           CLOB;
  l_sql_id           VARCHAR2(13) := '300td4a3h1pz8';
  l_sql_child_number NUMBER := 0; BEGIN

  BEGIN
    l_output := NULL;
    SELECT vsql.sql_fulltext
      INTO l_output
      FROM v$sql vsql
     WHERE vsql.sql_id = l_sql_id
       AND vsql.child_number = l_sql_child_number;

    dbms_output.put_line('--SQL_ID=' || l_sql_id || ' SQL_CHILD_NUMBER=' || l_sql_child_number);
    dbms_output.put_line('--OLD');
    dbms_output.put_line(l_output || ';');
    dbms_output.new_line;

    FOR inner_loop IN (SELECT vsqlb.name,
                              CASE
                                WHEN was_captured = 'NO' THEN
                                 'NULL'
                                WHEN value_string = 'NULL' THEN
                                 'NULL'
                                WHEN datatype IN (1, 11, 23, 96) THEN
                                 '''' || value_string || ''''
                                WHEN datatype = 2 THEN
                                 value_string
                                WHEN datatype IN (12, 180) THEN
                                 'to_date(''' || value_string ||
                                 ''',''RR/MM/DD HH24:MI:SS'')'
                                ELSE
                                 'PLEASE CHECK OUT DATATYPE'
                              END value_string
                         FROM v$sql              vsql,
                              v$sql_bind_capture vsqlb
                        WHERE vsql.sql_id = l_sql_id
                          AND vsql.child_number = l_sql_child_number
                          AND vsql.sql_id = vsqlb.sql_id
                          AND vsql.hash_value = vsqlb.hash_value
                          AND vsql.child_number = vsqlb.child_number
                        ORDER BY position) LOOP

      l_output := regexp_replace(l_output,
                                 inner_loop.name,
                                 nvl(inner_loop.value_string, 'NULL'),
                                 1,
                                 1,
                                 'i');

    END LOOP;
    dbms_output.put_line('--NEW');
    dbms_output.new_line;
    dbms_output.put_line(l_output || ';');
    dbms_output.new_line;

  EXCEPTION
    WHEN no_data_found THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;
END;
