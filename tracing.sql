-- single process query
alter session set tracefile_identifier = 'TEST1_PARALLEL';
alter session set timed_statistics = true;
alter session set statistics_level = all;
alter session set max_dump_file_size = unlimited;
alter session set events '10046 trace name context forever, level 12';

-- parallel query specific
alter session set "_px_trace" = low , messaging;

-- disable
alter session set events '10046 trace name context off';
alter session set "_px_trace" = none;

trcsess output=TEST1-parallel.trc module="sqlplus@DB-prod-01 (TNS V1-V3)" ahd*TEST1_PARALLEL.trc
tkprof TEST1-parallel.trc TEST1-parallel.out sort=exeela sys=no

-- tracing the decision to use buffer cache or direct read
-- https://blogs.oracle.com/smartscan-deep-dive/when-bloggers-get-it-wrong-part-2
alter session set events '10358 trace name context forever, level 2';
alter session set events 'trace [NSMTIO] disk highest'; 
