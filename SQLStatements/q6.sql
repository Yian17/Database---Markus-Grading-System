-- Steady work

SET SEARCH_PATH TO markus;
DROP TABLE IF EXISTS q6;

-- You must not change this table definition.
CREATE TABLE q6 (
  group_id integer,
  first_file varchar(25),
  first_time timestamp,
  first_submitter varchar(25),
  last_file varchar(25),
  last_time timestamp, 
  last_submitter varchar(25),
  elapsed_time interval
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.

-- Find A1
CREATE VIEW assign1 as
    select assignment_id
    from Assignment
    where description = 'A1';

-- Find groups did A1
CREATE VIEW group_a1 as
    select group_id, assignment_id
    from AssignmentGroup NATURAL JOIN assign1;

-- Find group_a1 submitted files
CREATE VIEW group_a1_submitted as
    select group_a1.group_id as group_id, file_name, assignment_id, username, submission_date
    from group_a1, Submissions
    where group_a1.group_id = Submissions.group_id;

-- Find those files who are not last
CREATE VIEW not_last_files as
    select g2.group_id as group_id, g2.file_name as file_name, g2.assignment_id as assignment_id,
           g2.username as username, g2.submission_date as submission_date
    from group_a1_submitted g1, group_a1_submitted g2
    where (g1.group_id = g2.group_id) and (g1.submission_date > g2.submission_date);

--- Find the last files
CREATE VIEW last_files as
    (select * from group_a1_submitted) 
     EXCEPT   
    (select * from not_last_files);

-- Find those files who are not first
CREATE VIEW not_first_files as
    select g2.group_id as group_id, g2.file_name as file_name, g2.assignment_id as assignment_id,
           g2.username as username, g2.submission_date as submission_date
    from group_a1_submitted g1, group_a1_submitted g2
    where (g1.group_id = g2.group_id) and (g1.submission_date < g2.submission_date);

-- Find the first files
CREATE VIEW first_files as
    (select * from group_a1_submitted) 
     EXCEPT 
    (select * from not_first_files);

-- Final
CREATE VIEW Final as
    select f1.group_id as group_id, f1.file_name as first_file, f1.submission_date as first_time,
           f1.username as first_submitter,
           f2.file_name as last_file, f2.submission_date as last_time,
           f2.username as last_submitter,
           (f2.submission_date - f1.submission_date) as elapsed_time
    from first_files f1, last_files f2
    where f1.group_id = f2.group_id;

-- Final answer.
INSERT INTO q6 (select * from Final);
  -- put a final query here so that its results will go into the table.