-- Getting soft

SET SEARCH_PATH TO markus;
DROP TABLE IF EXISTS q2;

-- You must not change this table definition.
CREATE TABLE q2 (
	ta_name varchar(100),
	average_mark_all_assignments real,
	mark_change_first_last real
);



-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- sum weighted out_of
CREATE VIEW Denom as
    select assignment_id, sum(weighted_outof) as denominator
    from (select rubric_id, assignment_id, cast(out_of as real) * weight as weighted_outof
    from RubricItem) Weightedoutof
    group by assignment_id;

-- sum weighted grade from result.mark
CREATE VIEW Num as
    select group_id, assignment_id, sum(weighted_grade) as numerator
    from (select group_id, Grade.rubric_id, assignment_id, cast(grade as real) * weight as weighted_grade
    from Grade, RubricItem
    where Grade.rubric_id = RubricItem.rubric_id) Weightedgrade
    group by group_id, assignment_id;

-- Calculte the grade in percentage
CREATE VIEW Gradepercentage as
    select Num.group_id as group_id, Num.assignment_id as assignment_id, 100 * numerator/denominator as grade
    from Num, Denom
    where Denom.assignment_id = Num.assignment_id;

-- Link assignment id, group_id with grade
CREATE VIEW Assignment_grade as
    select Assignment.assignment_id as assignment_id, group_id, grade
    from Assignment, Gradepercentage
    where Assignment.assignment_id = Gradepercentage.assignment_id;

-- Rename username for grader
CREATE VIEW TA as 
    select group_id, username as ta 
    from grader;

-- Count the number of student in each group of each assignment
CREATE VIEW Countstudent as 
    select ta, assignment_id, group_id, count(username) as studentnumber, sum(grade) as totalgrade
    from Assignment_grade NATURAL JOIN Membership NATURAL JOIN TA
    group by ta, assignment_id, group_id;
    --having count(group_id) >= 10;

-- Average across individual students for each assignment
CREATE VIEW Avgstudent as 
    select ta, assignment_id, (sum(totalgrade)/sum(studentnumber)) as average_mark_per_a
    from Countstudent
    group by ta, assignment_id;

-- Average across individual students across assignment for each ta
CREATE VIEW postavg as 
    select ta, (sum(totalgrade)/sum(studentnumber)) as average_mark_all_assignments
    from Countstudent
    group by ta;

-- Link due_date with ta, assignment_id, average_mark per assignment
CREATE VIEW Shouldhave as 
    select ta, assignment_id, average_mark_per_a, due_date
    from Avgstudent NATURAL JOIN Assignment;

-- not Softer
CREATE VIEW Notsofter as
    select a.ta as ta
    from Shouldhave a, Shouldhave b
    where a.ta = b.ta and (a.due_date > b.due_date and a.average_mark_per_a < b.average_mark_per_a);

-- ta who is getting softer
CREATE VIEW Softer as
    (select ta
    from Shouldhave)
    EXCEPT 
    (select ta from Notsofter);

-- concatenating ta's firstname and last name
CREATE VIEW TAname as 
    select ta, (firstname || ' ' || surname) as ta_name
    from Softer, MarkusUser
    where ta = username;

-- Find assignment that ta didn't grade at first
CREATE VIEW Notfirst as
    select b.ta as ta, b.assignment_id, b.average_mark_per_a as average_mark_per_a
    from Shouldhave a, Shouldhave b
    where a.ta = b.ta and a.due_date < b.due_date;

-- Find the first assignment that ta graded
CREATE VIEW First as
    select ta, assignment_id, average_mark_per_a as markfirst
    from ((select ta, assignment_id, average_mark_per_a
        from Shouldhave)
        EXCEPT
        (select * 
        from Notfirst)) firstly;

-- Find assignment that ta didn't grade at last
CREATE VIEW Notlast as
    select b.ta as ta, b.assignment_id, b.average_mark_per_a as average_mark_per_a
    from Shouldhave a, Shouldhave b
    where a.ta = b.ta and a.due_date > b.due_date;

-- Find the last assignment that ta graded
CREATE VIEW Last as
    select ta, assignment_id, average_mark_per_a as marklast
    from ((select ta, assignment_id, average_mark_per_a
        from Shouldhave)
        EXCEPT
        (select * 
        from Notlast)) lastly;

-- Find the mark changes between first and last assignment a TA graded
CREATE VIEW Change as 
    select First.ta, coalesce((marklast - markfirst), 0) as mark_change_first_last
    from First, Last
    where First.ta = Last.ta;

-- Find the total number of assignment
CREATE VIEW Assignnumber as 
    select count(distinct assignment_id) as anum
    from Assignment;

-- Find TAs have graded on every assignment
CREATE VIEW Gradeevery as 
    select ta
    from Countstudent
    group by ta 
    having count(assignment_id) > (select anum from Assignnumber);

-- Find TAs They have completed grading for at least 10 groups on each assignment.
CREATE VIEW Atleastten as 
    select ta
    from Countstudent
    group by ta
    having count(group_id) >= 10;

-- Combine everything
CREATE VIEW Finally as 
    select ta_name, average_mark_all_assignments, mark_change_first_last
    from Softer NATURAL JOIN TAname NATURAL JOIN postavg NATURAL JOIN Change 
         NATURAL JOIN Gradeevery NATURAL JOIN Atleastten;



-- Final answer.
INSERT INTO q2 (select * from Finally);
	-- put a final query here so that its results will go into the table.
