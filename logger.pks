create or replace package logger is

  -- Author  : PWS
  -- Created : 02.11.2016 20:07:23
  -- Purpose : Logging

  type t_handlers is table of BaseLogHandler index by binary_integer;
  g_handlers t_handlers;

  -- Logging levels 
  LEVEL_DEBUG constant binary_integer := 5;
  LEVEL_INFO  constant binary_integer := 4;
  LEVEL_WARN  constant binary_integer := 3;
  LEVEL_ERR   constant binary_integer := 2;
  LEVEL_CRIT  constant binary_integer := 1;

  -- Default output format
  DFLT_OUTPUT_FORMAT constant varchar2(64) := '%TIME% - [%LVL%] %MSG%';

  /**
   * Format logging string and substitute values from context
   */
  function format_str(p_fmt_str in varchar2) return varchar2;

  /**
   * Numeric level to character
   */
  function  get_level_name(p_level in binary_integer) return varchar2;
  
  /**
   * Check there are any handlers with such logging level
   */
  function is_enabled(p_lvl in number := LEVEL_CRIT) return boolean;

  /**
   * Set value in context
   */
  procedure set_ctx(p_key in varchar2, p_value in varchar2);
  
  /**
   * Get value from context
   */
  function get_ctx(p_key in varchar2) return varchar2;

  /**
   * Remove all handlers
   */
  procedure clear_handlers;
  
  /**
   * Add handler
   */
  procedure add_handler(p_handler in BaseLogHandler);
  
  /**
   * Remove last handler
   */
  procedure remove_handler;

  /**
   * Init logger with handlers
   */
  procedure init(p_handler in BaseLogHandler);

  /**
   * Log DEBUG message
   */ 
  procedure debug(p_msg in varchar2);
  
  /**
   * Log INFO message
   */
  procedure info(p_msg in varchar2);
  
  /**
   * Log WARNING message
   */
  procedure warn(p_msg in varchar2);
  
  /**
   * Log ERROR message
   */
  procedure err(p_msg in varchar2);
  
  /**
   * Log CRITICAL message
   */
  procedure crit(p_msg in varchar2);

end logger;
/