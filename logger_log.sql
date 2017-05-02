-- Table for log messages
create table logger_log(
  cdate timestamp with time zone,
  lvl number(2),
  msg varchar2(1000),
  usr varchar2(32),
  sid varchar2(32)
);
create index ak1_logger_log on logger_log(cdate);