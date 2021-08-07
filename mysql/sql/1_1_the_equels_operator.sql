CREATE TABLE employees (
   employee_id   NUMERIC      NOT NULL,
   first_name    VARCHAR(255) NOT NULL,
   last_name     VARCHAR(255) NOT NULL,
   date_of_birth DATE                 ,
   phone_number  VARCHAR(255) NOT NULL,
   junk          CHAR(255)            ,
   CONSTRAINT employees_pk PRIMARY KEY (employee_id)
);
--
CREATE OR REPLACE VIEW generator_16
AS SELECT 0 n UNION ALL SELECT 1  UNION ALL SELECT 2  UNION ALL
   SELECT 3   UNION ALL SELECT 4  UNION ALL SELECT 5  UNION ALL
   SELECT 6   UNION ALL SELECT 7  UNION ALL SELECT 8  UNION ALL
   SELECT 9   UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL
   SELECT 12  UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL
   SELECT 15;
--
CREATE OR REPLACE VIEW generator_256
AS SELECT ( ( hi.n << 4 ) | lo.n ) AS n
     FROM generator_16 lo, generator_16 hi;
--
CREATE OR REPLACE VIEW generator_4k
AS SELECT ( ( hi.n << 8 ) | lo.n ) AS n
     FROM generator_256 lo, generator_16 hi;
--
CREATE OR REPLACE VIEW generator_64k
AS SELECT ( ( hi.n << 8 ) | lo.n ) AS n
     FROM generator_256 lo, generator_256 hi;
--
INSERT INTO employees (employee_id,  first_name,
                       last_name,    date_of_birth,
                       phone_number, junk)
SELECT gen.n +1,
       GROUP_CONCAT(CHAR((RAND() * 25)+97) SEPARATOR ''),
       GROUP_CONCAT(CHAR((RAND() * 25)+97) SEPARATOR ''),
       SUBDATE(CURDATE(), INTERVAL (RAND()*3650 + 40*365) DAY),
       FLOOR(RAND()*9000+1000),
       'junk'
  FROM generator_4k gen, generator_16 rand
 WHERE gen.n < 1000
 GROUP BY gen.n;
--
UPDATE employees
   SET first_name='MARKUS',
       last_name='WINAND'
 WHERE employee_id=123;
--
ANALYZE TABLE employees;
-- add subsidiary_id and update existing records
ALTER TABLE employees ADD subsidiary_id NUMERIC;
UPDATE      employees SET subsidiary_id = 30;
ALTER TABLE employees MODIFY subsidiary_id NUMERIC NOT NULL;
-- change the PK
ALTER TABLE employees DROP PRIMARY KEY;
ALTER TABLE employees ADD CONSTRAINT employees_pk
      PRIMARY KEY (employee_id, subsidiary_id);
-- generate more records (Very Big Company)
INSERT INTO employees (employee_id,  first_name,
                       last_name,    date_of_birth,
                       phone_number, subsidiary_id, junk)
SELECT gen.n + 1
     , GROUP_CONCAT(CHAR( RAND()*25 + 97) SEPARATOR '')
     , GROUP_CONCAT(CHAR( RAND()*25 + 97) SEPARATOR '')
     , CURDATE() - INTERVAL (RAND(0)*365*10 + 40*365) DAY
     , FLOOR(RAND()*9000 + 1000)
     , FLOOR(RAND()*(gen.n/9000)*29 + 1)
     , 'junk'
  FROM generator_64k gen, generator_16 rand
 WHERE gen.n < 9000
 GROUP BY gen.n;
--
ANALYZE TABLE employees;
