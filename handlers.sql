drop type DbLogHandler;
drop type OutputLogHandler;
drop type BaseLogHandler;


create or replace type BaseLogHandler as object (
/** 
 * Base Handler
 * Write all messages to output without formatting and cut each to 255 characters
 */
  lvl number(2),
  with_ctx number,
  
  constructor function BaseLogHandler(self in out nocopy BaseLogHandler, p_lvl in number := 0) return self as result,
  
  member procedure write(self in out nocopy BaseLogHandler, p_msg in varchar2, p_lvl in number),
  member procedure setLevel(self in out nocopy BaseLogHandler, p_lvl in number)
  
) not final;
/
create or replace type body BaseLogHandler as 

  constructor function BaseLogHandler(self in out nocopy BaseLogHandler, p_lvl in number := 0) return self as result
  is
  begin
    self.lvl := p_lvl;  
    return;
  end;

  member procedure write(self in out nocopy BaseLogHandler, p_msg in varchar2, p_lvl in number)
  is 
  begin
    dbms_output.put_line(substr(p_msg, 1, 255));
  end;
  
  member procedure setLevel(self in out nocopy BaseLogHandler, p_lvl in number)
  is
  begin
    self.lvl := p_lvl;
  end;
end;
/

create or replace type DbLogHandler UNDER BaseLogHandler (
/** 
 * Db Handler
 * Write all messages to table without formatting and cut each to 2000 characters
 */
  constructor function DbLogHandler(self in out nocopy DbLogHandler, p_lvl in number := 0) return self as result,
  
  OVERRIDING member procedure write(self in out nocopy DbLogHandler, p_msg in varchar2, p_lvl in number)
) NOT FINAL;
/

create or replace type body DbLogHandler  as

  constructor function DbLogHandler(self in out nocopy DbLogHandler, p_lvl in number := 0) return self as result
  is
  begin
    self.lvl := p_lvl;  
    return;
  end;

  OVERRIDING member procedure write(self in out nocopy DbLogHandler, p_msg in varchar2, p_lvl in number)
  is
    pragma autonomous_transaction;
  begin
    insert into logger_log(cdate, lvl, msg, usr, sid) values (current_timestamp, self.lvl, substr(p_msg, 1, 2000), user, dbms_session.unique_session_id);
    commit;
  exception when others then 
    raise;
  end;
  
end;
/

create or replace type OutputLogHandler UNDER BaseLogHandler (
/** 
 * Output Handler
 * Write all messages to output with formatting 
 */
  fmt_str varchar2(256),

  constructor function OutputLogHandler(self in out nocopy OutputLogHandler, p_lvl in number := 0, p_fmt_str in varchar2 := null) return self as result,
  
  OVERRIDING member procedure write(self in out nocopy OutputLogHandler, p_msg in varchar2, p_lvl in number)
) NOT FINAL;
/

create or replace type body OutputLogHandler  as

  constructor function OutputLogHandler(self in out nocopy OutputLogHandler, p_lvl in number := 0, p_fmt_str in varchar2 := null) return self as result
  is
  begin
    self.lvl := p_lvl;
    if p_fmt_str is not null then
      self.fmt_str := p_fmt_str;
    else
      self.fmt_str := logger.DFLT_OUTPUT_FORMAT;
    end if;
    return;
  end;

  OVERRIDING member procedure write(self in out nocopy OutputLogHandler, p_msg in varchar2, p_lvl in number)
  is
    l_buff number := 255;
    l_cnt number := 1;
    l_start number := 1;
  begin
    dbms_output.put_line(logger.format_str(replace(self.fmt_str, '%MSG%', substr(p_msg, l_start, l_buff))));
    loop
      l_start := l_start + l_buff;
      if substr(p_msg, l_start, 1) is not null then
        dbms_output.put_line(substr(p_msg, l_start, l_buff));
      else
        exit;
      end if;
      l_cnt := l_cnt + 1;
    end loop;
  exception when others then
    if sqlcode = -20000 then
      null;
    else
      raise;
    end if;
  end;

end;
/
