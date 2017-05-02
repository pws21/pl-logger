# pl-logger

Damn simple logger for PL/SQL

```
begin
  -- First of all you should init logger with some handler and logging level
  logger.init(OutputLogHandler(logger.LEVEL_INFO));
  
  -- Now all calls except debug will be handled by this handler
  logger.debug('DEBUG Message');
  logger.info('INFO Message');
  logger.warn('WARNING Message');
  logger.err('ERROR Message');
  logger.crit('CRITICAL Message');
end;
/
```

And you'll see this in Output:

```
22:44:38.290 - [INFO] INFO Message
22:44:38.290 - [WARN] WARNING Message
22:44:38.290 - [ERR] ERROR Message
22:44:38.290 - [CRIT] CRITICAL Message
```