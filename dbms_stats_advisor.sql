/* 

New Oracle 12c feature - Optimizer Statistics Advisor
Usage exmaple:
http://www.oracle.com/technetwork/database/bi-datawarehousing/twp-bp-for-stats-gather-12c-1967354.pdf

Analyzes information in the data dictionary, assesses the quality of statistics and discovers how statistics are being gathered. It will report on
poor and missing statistics and generate recommendations to resolve these problems.

*/

DECLARE
 tname VARCHAR2(32767) := 'demo'; -- task name
BEGIN
 tname := dbms_stats.create_advisor_task(tname);
END;
/

DECLARE
 tname VARCHAR2(32767) := 'demo'; -- task name
 ename VARCHAR2(32767) := NULL; -- execute name
BEGIN
 ename := dbms_stats.execute_advisor_task(tname);
END;
/

SELECT dbms_stats.report_advisor_task('demo') AS report FROM dual;