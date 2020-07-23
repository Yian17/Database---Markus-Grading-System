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
• They have graded (that is, they have been assigned to at least one group) on every assignment.
• They have completed grading (that is, there is a grade recorded in the Result table) for at least 10 groups
on each assignment.
• The average grade they have given has gone up consistently from assignment to assignment over time
(based on the assignment due date).
