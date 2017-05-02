create or replace package body logger is

  type t_ctx is table of varchar2(4000) index by varchar2(256);
  g_ctx t_ctx;
  g_max_log_level number := 0;
  
  function is_enabled(p_lvl in number := LEVEL_CRIT) return boolean
  is
  begin
    return p_lvl <= g_max_log_level;
  end;

  function  get_level_name(p_level in binary_integer) return varchar2
  is
  begin
    case p_level
      when LEVEL_DEBUG then return 'DEBUG';
      when LEVEL_INFO  then return 'INFO';
      when LEVEL_WARN  then return 'WARN';
      when LEVEL_ERR   then return 'ERR';
      when LEVEL_CRIT  then return 'CRIT';
      else return null;
    end case;
  end;

  procedure clear_handlers is
  begin
    g_handlers.delete;
    g_max_log_level := 0;
  end;

  procedure add_handler(p_handler in BaseLogHandler) is
  begin
    g_handlers(g_handlers.count + 1) := p_handler;
    if p_handler.lvl > g_max_log_level then
      g_max_log_level := p_handler.lvl;
    end if;
  end;
  
  procedure remove_handler is
  begin
    if g_handlers.last is not null then
      g_handlers.delete(g_handlers.last);
    end if;
  end;

  procedure init(p_handler in BaseLogHandler) is
  begin
    clear_handlers;
    add_handler(p_handler);
  end;

  procedure clear_ctx is
  begin
    g_ctx.delete;
  end;

  procedure set_ctx(p_key in varchar2, p_value in varchar2) is
  begin
    g_ctx(upper(p_key)) := p_value;
  end;

  function format_str(p_fmt_str in varchar2) return varchar2
  is
    l_key varchar2(256);
    l_ret varchar2(32767);
  begin
    l_key := g_ctx.first();
    l_ret := p_fmt_str;
    loop
     exit when l_key is null;
     l_ret := replace(l_ret, '%'||upper(l_key)||'%', g_ctx(l_key));
     l_key := g_ctx.next(l_key);
    end loop;

    return l_ret;
  end;

  function get_ctx(p_key in varchar2) return varchar2 is
  begin
    return g_ctx(upper(p_key));
  end;

  procedure write_log(p_msg in varchar2, p_lvl in number)
  is
    i number;
  begin
    if not is_enabled(p_lvl) then
      -- No suitable handlers
      return;
    end if;
    
    clear_ctx;
    set_ctx('MSG', substr(p_msg, 1, 4000));
    set_ctx('LVL', get_level_name(p_lvl));
    set_ctx('DATE', to_char(current_timestamp, 'dd.mm.yyyy'));
    set_ctx('TIME', to_char(current_timestamp, 'hh24:mi:SSxFF3'));

    i := g_handlers.first;
    loop
      exit when i is null;
      if g_handlers(i).lvl >= p_lvl then
        g_handlers(i).write(p_msg, p_lvl);
      end if;
      i := g_handlers.next(i);
    end loop;
  end;

  procedure debug(p_msg in varchar2) is
  begin
    write_log(p_msg, LEVEL_DEBUG);
  end;

  procedure info(p_msg in varchar2) is
  begin
    write_log(p_msg, LEVEL_INFO);
  end;

  procedure warn(p_msg in varchar2) is
  begin
    write_log(p_msg, LEVEL_WARN);
  end;

  procedure err(p_msg in varchar2) is
  begin
    write_log(p_msg, LEVEL_ERR);
  end;

  procedure crit(p_msg in varchar2) is
  begin
    write_log(p_msg, LEVEL_CRIT);
  end;

end logger;
/