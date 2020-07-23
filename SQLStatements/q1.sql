-- Distributions

SET SEARCH_PATH TO markus;
DROP TABLE IF EXISTS q1;

-- You must not change this table definition.
CREATE TABLE q1 (
    assignment_id integer,
    average_mark_percent real, 
    num_80_100 integer, 
    num_60_79 integer, 
    num_50_59 integer, 
    num_0_49 integer
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.

-- Find percentage grade of each group
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
CREATE VIEW assign_grade as
    select Assignment.assignment_id as assignment_id, group_id, grade
    from Assignment, Gradepercentage
    where Assignment.assignment_id = Gradepercentage.assignment_id;

-- Find average for each assignment
CREATE VIEW Average as
    select assignment_id, avg(cast(grade as real)) as average_mark_percent
    from assign_grade
    group by assignment_id;

-- Find the number of grades between 80 and 100 percent inclusive for each assignment
CREATE VIEW Eightyplus as
    select DISTINCT assignment_id, count(grade) as num_80_100
    from assign_grade
    where 80 <= grade and 100 >= grade
    group by assignment_id;

-- The number of grades between 60 and 79 percent inclusive for each assignment
CREATE VIEW SixtyToEighty as
    select distinct assignment_id, count(grade) as num_60_79
    from assign_grade
    where 60 <= grade and 80 > grade
    group by assignment_id;

-- The number of grades between 50 and 59 percent inclusive
CREATE VIEW FiftyToSixty as
    select DISTINCT assignment_id, count(grade) as num_50_59
    from assign_grade
    where 50 <= grade and 60 > grade
    group by assignment_id;

-- Find The number of grades below 50 percent
CREATE VIEW BelowFifty as
    select DISTINCT assignment_id, count(grade) as num_0_49
    from assign_grade
    where 0 <= grade and 50 > grade
    group by assignment_id;

-- The final view combine every view 
CREATE VIEW Final as
    select DISTINCT Average.assignment_id as assignment_id, 
           average_mark_percent, 
           coalesce(num_80_100, 0) as num_80_100, 
           coalesce(num_60_79, 0) as num_60_79, 
           coalesce(num_50_59, 0) as num_50_59, 
           coalesce(num_0_49, 0) as num_0_49
    from Average NATURAL FULL JOIN Eightyplus NATURAL FULL JOIN SixtyToEighty
         NATURAL FULL JOIN FiftyToSixty NATURAL FULL JOIN BelowFifty;

-- Final answer.
INSERT INTO q1 (select * from Final);
    -- put a final query here so that its results will go into the table.