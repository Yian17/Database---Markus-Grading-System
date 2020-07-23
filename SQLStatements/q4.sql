-- Grader report

SET SEARCH_PATH TO markus;
DROP TABLE IF EXISTS q4;

-- You must not change this table definition.
CREATE TABLE q4 (
    assignment_id integer,
    username varchar(25), 
    num_marked integer, 
    num_not_marked integer,
    min_mark real,
    max_mark real
);


-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.

-- assignment that has one or more graders
CREATE VIEW SeveralGrader as
    select assignment_id
    from Grader, AssignmentGroup
    where Grader.group_id = AssignmentGroup.group_id
    group by assignment_id
    having count(distinct username) >= 1;

-- number of group a ta has graded for an assignment
CREATE VIEW Numbermarked as
    select assignment_id, coalesce(count(AssignmentGroup.group_id), 0) as num_marked
    from AssignmentGroup, Grader, Result
    where AssignmentGroup.group_id = Grader.group_id and Grader.group_id = Result.group_id 
          and (AssignmentGroup.assignment_id in (select (assignment_id) from SeveralGrader))
    group by assignment_id, username;

-- number of group that a ta should mark
CREATE VIEW Shouldmark as
    select assignment_id, coalesce(count(AssignmentGroup.group_id), 0) as num
    from AssignmentGroup, Grader
    where AssignmentGroup.group_id = Grader.group_id and (AssignmentGroup.assignment_id in (select (assignment_id) from SeveralGrader))
    group by assignment_id, username;

-- number of group that a ta not marked
CREATE VIEW Notmarked as
    select Shouldmark.assignment_id, (num - num_marked) as num_not_marked
    from Shouldmark, Numbermarked
    where Shouldmark.assignment_id = Numbermarked.assignment_id;

-- Total Mark for an assignment
CREATE VIEW TotalOutOf as
    select sum(out_of) as total, assignment_id
    from RubricItem
    group by assignment_id;

-- Find the grade for each assignment
CREATE VIEW AssignmentGrade as
    select TotalOutOf.assignment_id, 100 *(Result.mark/TotalOutOf.total) as grade
    from TotalOutOf, Result, AssignmentGroup
    where TotalOutOf.assignment_id = AssignmentGroup.assignment_id and Result.group_id = AssignmentGroup.group_id;

-- Mingrade without null
CREATE VIEW Mingrade as
    select AssignmentGrade.assignment_id, min(grade) as min_mark
    from AssignmentGrade NATURAL LEFT JOIN Grader NATURAL LEFT JOIN AssignmentGroup
    where AssignmentGrade.assignment_id = AssignmentGroup.assignment_id and Grader.group_id = AssignmentGroup.group_id
    group by AssignmentGrade.assignment_id, username;

-- Mingrade without null
CREATE VIEW Maxgrade as
    select AssignmentGrade.assignment_id, max(grade) as max_mark
    from AssignmentGrade NATURAL LEFT JOIN Grader NATURAL LEFT JOIN AssignmentGroup
    group by AssignmentGrade.assignment_id, username;

-- Combine all views
CREATE VIEW Final as
    select distinct AssignmentGroup.assignment_id as assignment_id, Grader.username as username, 
           num_marked, coalesce(num_not_marked, 0) as num_not_marked,
           Mingrade.min_mark, Maxgrade.max_mark
    From AssignmentGroup NATURAL LEFT JOIN Grader NATURAL LEFT JOIN Numbermarked NATURAL LEFT JOIN Notmarked NATURAL LEFT JOIN Maxgrade NATURAL LEFT JOIN Mingrade
    where AssignmentGroup.assignment_id in (select * from SeveralGrader);

-- Final answer.
INSERT INTO q4 (select * from Final);
    -- put a final query here so that its results will go into the table.