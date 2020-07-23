-- Solo superior

SET SEARCH_PATH TO markus;
DROP TABLE IF EXISTS q3;

-- You must not change this table definition.
CREATE TABLE q3 (
	assignment_id integer,
	description varchar(100), 
	num_solo integer, 
	average_solo real,
	num_collaborators integer, 
	average_collaborators real, 
	average_students_per_submission real
);



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

-- Find the student who worked alone
CREATE VIEW Workalone as 
    select assignment_id, group_id, count(group_id) as numbers
    from AssignmentGroup NATURAL JOIN Membership
    group by assignment_id, group_id
    having count(username) = 1;

-- Find the number of student who works alone
CREATE VIEW Numworkalone as 
    select assignment_id, count(group_id) as num_solo
    from Workalone
    group by assignment_id;

-- Find the number of group for each assignment
CREATE VIEW Numgroup as 
    select assignment_id, count(group_id) as groupnumbers
    from Assignment NATURAL JOIN Membership
    group by assignment_id;

-- Find number of student for each group for each assignment where the group number is greater than 1
CREATE VIEW Student as 
    select assignment_id, group_id, count(username) as studentnumber
    from Assignment NATURAL JOIN Membership
    group by assignment_id, group_id
    having count(username) > 1;

-- Find the total number of student who groups
CREATE VIEW Whogroups as 
    select distinct assignment_id, (sum(studentnumber)) as num_collaborators
    from AssignmentGroup NATURAL JOIN Student
    group by assignment_id;

-- Find the average of students who workalone
CREATE VIEW Avgsolo as 
    select distinct assignment_id, (sum(grade)/sum(numbers)) as average_solo
    from Assignment_grade NATURAL JOIN Workalone
    group by assignment_id, group_id;

-- Find the average of students who groups
CREATE VIEW Avgcolla as 
    select assignment_id, (sum(grade)/count(group_id))  as average_collaborators
    from Assignment_grade NATURAL JOIN Student
    group by assignment_id;

-- Find the number of student in each group
CREATE VIEW Preavgstudent as 
    select assignment_id, group_id, count(username) as totalstudentnumber
    from AssignmentGroup NATURAL JOIN Membership
    group by assignment_id, group_id;

-- Find the The average number of students involved in each group
CREATE VIEW Avgstudent as 
    select assignment_id, (sum(totalstudentnumber) / count(group_id)) as average_students_per_submission
    from Preavgstudent
    group by assignment_id;

-- Combie all views
CREATE VIEW Finally as 
    select assignment_id, description, num_solo, average_solo, num_collaborators, average_collaborators, average_students_per_submission
    from Numworkalone NATURAL LEFT JOIN Whogroups NATURAL LEFT JOIN 
    Avgsolo NATURAL LEFT JOIN Avgcolla NATURAL LEFT JOIN 
    Avgstudent NATURAL LEFT JOIN Assignment;




-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.

-- Final answer.
INSERT INTO q3 (select * from Finally);
	-- put a final query here so that its results will go into the table.
