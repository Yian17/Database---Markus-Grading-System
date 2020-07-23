## Overview
This project work with a database that could support the online tool MarkUs. MarkUs is “an
open-source tool which recreates the ease and flexibility of grading assignments with pen on paper, within a web
application. It also allows students and instructors to form groups, and collaborate on assignments.” (reference:
http://markusproject.org/).

## Functionality(SQLStatements)
1. For each assignment, report the average grade, the number of grades between 80 and 100 percent inclusive,
the number of grades between 60 and 79 percent inclusive, the number of grades between 50 and 59 percent
inclusive, and the number of grades below 50 percent. Where there were no grades in a given range, report 0.
2. Find graders who meet all of these criteria:
- They have graded (that is, they have been assigned to at least one group) on every assignment.
- They have completed grading (that is, there is a grade recorded in the Result table) for at least 10 groups
on each assignment.
- The average grade they have given has gone up consistently from assignment to assignment over time
(based on the assignment due date).
3. Find assignments where the average grade of those who worked alone is greater than the average grade earned
by groups. For each, report the assignment ID and description, the number of students declared to be working
alone and their average grade, the number of students (not groups) declared to be working in groups and the
average grade across those groups (not students), and finally, the average number of students involved in each
group, (include in this calculation those who worked solo).
4. For each assignment that has any graders declared, and each grader of that assignment, report the number
of groups they have already completed grading (that is, there is a grade recorded in the Result table), the
number they have been assigned but have not yet graded, and the minimum and maximum grade they have
given.
5. Find assignments where the number of groups assigned to each grader has a range greater than 10. For
instance, if grader 1 was assigned 45 groups, grader 2 was assigned 58, and grader 3 was assigned 47, the
range was 13 and this assignment should be reported. For each grader of these assignments, report the
assignment, the grader, and the number of groups they are assigned to grade.
6. For each group on assignment A1 (the assignment whose description is ‘A1’), report the group ID, the name
of the first file submitted by anyone in the group, when it was submitted, and the username of the group
member who submitted it, the name of the last file submitted, when it was submitted, and the username of
the group member who submitted it, and the time between submission of the first and last file.
It is possible that a group submitted only 1 file. In that case the first file and the last file submitted are the
same. It is also possible that two files could be submitted at the same time. In that case, report a row for
every first-last combination for the group.
7. Report the username of all graders who have been assigned at least one group (the group could be solo or
larger) for every assignment and have been assigned to grade every student (whether in a solo or larger group)
on at least one assignment.
8. Find students who never worked solo on an assignment that allows groups, and who submitted at least one
file for every assignment (indicating that they did contribute to the group). Report their username, their
average grade on the assignments that allowed groups, and their average grade on the assignments that did
not allow groups.
9. Report pairs of students who each did group work whenever the assignment permitted it, and
always worked together (possibly with other students in a larger group).
10. Compute the grade out of 100 for each group on assignment A1, the di↵erence between their grade and the
average A1 grade across groups (negative if they are below average; positive if they are above average), and
either “above”, “at”, or “below” to indicate whether they are above, at or below this average.

# JDBC(EmbeddedSQL)
- Implemented Java Database Connectivity tools to run SQL queries and manipulate database records
- All in EmbeddedSQL.java
