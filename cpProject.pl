:- use_module(library(clpfd)).

schedule(Hours, Probation, Obligatory, CreditHours, CourseSchedules, History, Prerequisites, Semester, Condense, Ans) :-
	Hours2 #=  Hours + Probation * 3,
	DaysOff #>= 1,
	length(CreditHours, NumberOfCourses),
	NumberOfSetOfCourses #= 2 ^ (NumberOfCourses + 1),
	TakenCourses in 0 .. NumberOfSetOfCourses,
	TakenCourses /\ 1 #= 0,
	putObligatoryInTakenCourses(TakenCourses, Obligatory),
	constraintPrerequisites(TakenCourses, 1, Prerequisites, History),
	computeCreditHours(TakenCourses, 1, CreditHours, TakenCreditHours),
	TakenCreditHours #=< Hours2,
	labeling([max(TakenCreditHours)], [TakenCourses]),
	getTakenList(TakenCourses, 1, NumberOfCourses, TakenList),
	Ans = [Ans1, Ans2, Ans3, Ans4, Ans5,
			Ans6, Ans7, Ans8, Ans9, Ans10,
			Ans11, Ans12, Ans13, Ans14, Ans15,
			Ans16, Ans17, Ans18, Ans19, Ans20,
			Ans21, Ans22, Ans23, Ans24, Ans25,
			Ans26, Ans27, Ans28, Ans29, Ans30],
	UpperBound #= NumberOfCourses * 1000,
	Ans ins 0 .. UpperBound,
	NumberOfSlots #= TakenCreditHours div 2,
	FreeSlots #= 30 - NumberOfSlots,
	countEl(0, Ans, FreeSlots),
	makeSchedule(TakenList, CourseSchedules, Ans, Preferable),
	Ans1 + Ans2 + Ans3 + Ans4 + Ans5 #= Off1,
	Ans6 + Ans7 + Ans8 + Ans9 + Ans10 #= Off2,
	Ans11 + Ans12 + Ans13 + Ans14 + Ans15 #= Off3,
	Ans16 + Ans17 + Ans18 + Ans19 + Ans20 #= Off4,
	Ans21 + Ans22 + Ans23 + Ans24 + Ans25 #= Off5,
	Ans26 + Ans27 + Ans28 + Ans29 + Ans30 #= Off6,
	Off1 #= 0 #<==> (M1 #= 1),
	Off2 #= 0 #<==> (M2 #= 1),
	Off3 #= 0 #<==> (M3 #= 1),
	Off4 #= 0 #<==> (M4 #= 1),
	Off5 #= 0 #<==> (M5 #= 1),
	Off6 #= 0 #<==> (M6 #= 1),
	Off1 #\= 0 #<==> (M1 #= 0),
	Off2 #\= 0 #<==> (M2 #= 0),
	Off3 #\= 0 #<==> (M3 #= 0),
	Off4 #\= 0 #<==> (M4 #= 0),
	Off5 #\= 0 #<==> (M5 #= 0),
	Off6 #\= 0 #<==> (M6 #= 0),
	DaysOff #= M1 + M2 + M3 + M4 + M5,
	DaysOff #< 6,
	Gaps in 0 .. 30,
	[Gaps1, Gaps2, Gaps3, Gaps4, Gaps5, Gaps6] ins 0 .. 5,
	computeGaps(Ans1, Ans2, Ans3, Ans4, Ans5, Gaps1),
	computeGaps(Ans6, Ans7, Ans8, Ans9, Ans10, Gaps2),
	computeGaps(Ans11, Ans12, Ans13, Ans14, Ans15, Gaps3),
	computeGaps(Ans16, Ans17, Ans18, Ans19, Ans20, Gaps4),
	computeGaps(Ans21, Ans22, Ans23, Ans24, Ans25, Gaps5),
	computeGaps(Ans26, Ans27, Ans28, Ans29, Ans30, Gaps6),
	Gaps #= Gaps1 + Gaps2 + Gaps3 + Gaps4 + Gaps5 + Gaps5 + Gaps6,
	sameSemester(Semester, Ans, Same),
	makeLabeling(Condense, Preferable, DaysOff, Same, Gaps, [Gaps1, Gaps2, Gaps3, Gaps4, Gaps5, Gaps6|Ans]).

makeLabeling(1, Preferable, DaysOff, Same, Gaps, Ans) :-
	labeling([max(Preferable), min(DaysOff), max(Same), min(Gaps)], Ans).

makeLabeling(0, Preferable, _, Same, Gaps, Ans) :-
	labeling([max(Preferable), max(Same), min(Gaps)], Ans).

putObligatoryInTakenCourses(_, []).

putObligatoryInTakenCourses(TakenCourses, [H|T]) :-
	X #= 2 ^ H,
	TakenCourses /\ X #\= 0,
	putObligatoryInTakenCourses(TakenCourses, T).

computeCreditHours(_, Idx, CreditHours, TakenCreditHours) :-
	X #= 2 ^ Idx,
	length(CreditHours, L),
	Y #= 2 ^ (L + 1),
	X #>= Y,
	TakenCreditHours #= 0.

computeCreditHours(TakenCourses, Idx, CreditHours, TakenCreditHours) :-
	X #= 2 ^ Idx,
	length(CreditHours, L),
	Y #= 2 ^ (L + 1),
	X #< Y,
	Idx1 #= Idx + 1,
	computeCreditHours(TakenCourses, Idx1, CreditHours, TakenCreditHours1),
	element(Idx, CreditHours, CurrentCH),
	Temp #= TakenCourses /\ X,
	Temp #= X #<==> (TakenCreditHours #= TakenCreditHours1 + CurrentCH),
	Temp #= 0 #<==> (TakenCreditHours #= TakenCreditHours1).

constraintPrerequisitesHelper([], _, 1).

constraintPrerequisitesHelper([H|_], History, Ans) :-
	nth1(H, History, Grade),
	Grade = fa,
	Ans #= 0.

constraintPrerequisitesHelper([H|T], History, Ans) :-
	nth1(H, History, Grade),
	Grade \= ff,
	constraintPrerequisitesHelper(T, History, Ans).

constraintPrerequisites(_, Idx, Prerequisites, _) :-
	X #= 2 ^ Idx,
	length(Prerequisites, L),
	Y #= 2 ^ (L + 1),
	X #>= Y.

constraintPrerequisites(TakenCourses, Idx, Prerequisites, History) :-
	X #= 2 ^ Idx,
	length(Prerequisites, L),
	Y #= 2 ^ (L + 1),
	X #< Y,
	nth1(Idx, Prerequisites, CurrentPrerequisites),
	constraintPrerequisitesHelper(CurrentPrerequisites, History, Ans),
	Temp #= TakenCourses /\ X,
	Temp #= X #==> (Ans #= 1),
	Ans #= 0 #==> (Temp #= 0).

getTakenList(_, Idx, NumberOfCourses, []) :-
	Idx #> NumberOfCourses.

getTakenList(TakenCourses, Idx, NumberOfCourses, [Idx|Ans]):-
	Idx #=< NumberOfCourses,
	X #= 2 ^ Idx,
	Temp #= TakenCourses /\ X,
	Temp #\= 0,
	Idx1 #= Idx + 1,
	getTakenList(TakenCourses, Idx1, NumberOfCourses, Ans).

getTakenList(TakenCourses, Idx, NumberOfCourses, Ans):-
	Idx #=< NumberOfCourses,
	X #= 2 ^ Idx,
	Temp #= TakenCourses /\ X,
	Temp #= 0,
	Idx1 #= Idx + 1,
	getTakenList(TakenCourses, Idx1, NumberOfCourses, Ans).

countEl(_, [], 0).

countEl(X, [Y|L], N):-
    X #=Y #<==> B,
    N #= M+B,
    countEl(X, L, M).

makeSchedule([], _, _, 0).

makeSchedule([CourseID|TakenList], CourseSchedules, Ans, Preferable) :-
	nth1(CourseID, CourseSchedules, CurrentCourseSchedule),
	length(CurrentCourseSchedule, Slots),
	Slots = 1,
	nth1(1, CurrentCourseSchedule, Lectures),
	element(LectureGroup, Lectures, LectureTime),
	LectureId #= (CourseID * 10) * 10 + LectureGroup,
	element(LectureTime, Ans, LectureId),
	makeSchedule(TakenList, CourseSchedules, Ans, Preferable).

makeSchedule([CourseID|TakenList], CourseSchedules, Ans, Preferable) :-
	nth1(CourseID, CourseSchedules, CurrentCourseSchedule),
	length(CurrentCourseSchedule, Slots),
	Slots = 2,
	nth1(1, CurrentCourseSchedule, Lectures),
	nth1(2, CurrentCourseSchedule, Tutorials),
	element(LectureGroup, Lectures, LectureTime),
	LectureId #= (CourseID * 10) * 10 + LectureGroup,
	element(LectureTime, Ans, LectureId),
	element(TutorialGroup, Tutorials, TutorialTime),
	TutorialId #= (CourseID * 10 + 1) * 10 + TutorialGroup,
	element(TutorialTime, Ans, TutorialId),
	LectureTime #< TutorialTime,
	makeSchedule(TakenList, CourseSchedules, Ans, Preferable).

makeSchedule([CourseID|TakenList], CourseSchedules, Ans, Preferable) :-
	nth1(CourseID, CourseSchedules, CurrentCourseSchedule),
	length(CurrentCourseSchedule, Slots),
	Slots = 3,
	nth1(1, CurrentCourseSchedule, Lectures),
	nth1(2, CurrentCourseSchedule, Tutorials),
	nth1(3, CurrentCourseSchedule, Labs),
	element(LectureGroup, Lectures, LectureTime),
	LectureId #= (CourseID * 10) * 10 + LectureGroup,
	element(LectureTime, Ans, LectureId),
	element(TutorialGroup, Tutorials, TutorialTime),
	TutorialId #= (CourseID * 10 + 1) * 10 + TutorialGroup,
	element(TutorialTime, Ans, TutorialId),
	LectureTime #< TutorialTime,
	element(LabGroup, Labs, LabTime),
	LabId #= (CourseID * 10 + 2) * 10 + LabGroup,
	element(LabTime, Ans, LabId),
	TutorialTime #< LabTime,
	makeSchedule(TakenList, CourseSchedules, Ans, Preferable2),
	LabGroup #= TutorialGroup #<==> (Preferable #= Preferable2 + 1),
	LabGroup #\= TutorialGroup #<==> (Preferable #= Preferable2).

computeGaps(Ans1, Ans2, Ans3, Ans4, Ans5, Gaps) :-
	[M2, M3, M4] ins 0 .. 1,
	Gaps in 0 .. 3,
	(Ans1 #= 0 #\/ (Ans3 #= 0 #/\ Ans4 #= 0 #/\ Ans5 #= 0)) #<==> (M2 #= 0),
	((Ans1 #= 0 #/\ Ans2 #= 0) #\/ (Ans4 #= 0 #/\ Ans5 #= 0)) #<==> (M3 #= 0),
	((Ans1 #= 0 #/\ Ans2 #= 0 #/\ Ans3 #= 0) #\/ Ans5 #= 0) #<==> (M3 #= 0),
	(Ans1 #\= 0 #/\ (Ans3 #\= 0 #\/ Ans4 #\= 0 #\/ Ans5 #\= 0)) #<==> (M2 #= 1),
	((Ans1 #\= 0 #\/ Ans2 #\= 0) #/\ (Ans4 #\= 0 #\/ Ans5 #\= 0)) #<==> (M3 #= 1),
	((Ans1 #\= 0 #\/ Ans2 #\= 0 #\/ Ans3 #\= 0) #/\ Ans5 #\= 0) #<==> (M3 #= 1),
	Gaps #= M2 + M3 + M4.

sameSemester(_, [], 0).

sameSemester(Semester, [H|T], Same) :-
	H2 #= H div 10,
	Course #= H2 div 10,
	var(Course),
	element(Course, Semester, CurrentSemester),
	sameSemesterHelper(CurrentSemester, Semester, H, T, Same3),
	sameSemester(Semester, T, Same2),
	Same #= Same2 + Same3.

sameSemester(Semester, [H|T], Same) :-

	H2 #= H div 10,
	Course #= H2 div 10,
	nonvar(Course), Course #\= 0,
	element(Course, Semester, CurrentSemester),
	sameSemesterHelper(CurrentSemester, Semester, H, T, Same3),
	sameSemester(Semester, T, Same2),
	Same #= Same2 + Same3.

sameSemester(Semester, [H|T], Same) :-
	H2 #= H div 10,
	Course #= H2 div 10,
	nonvar(Course), Course #= 0,
	sameSemester(Semester, T, Same).

sameSemesterHelper(_, _, _, [], 0).

sameSemesterHelper(CurrentSemester, Semesters, Slot, [H|T], Same) :-
	Same2 in 0 .. 1,
	Group #= H mod 10,
	H2 #= H div 10,
	Type #= H2 mod 10,
	Group2 #= Slot mod 10,
	Slot2 #= Slot div 10,
	Type2 #= Slot2 mod 10,
	Course2 #= H2 div 10,
	var(Course2),
	element(Course2, Semesters, CurrentSemester2),
	(Type #\= 0 #\/ Type2 #\= 0 #\/ (Type #= 0 #/\ Type2 #= 0 #/\ Group #\= Group2) #\/ CurrentSemester #\= CurrentSemester2) #<==> (Same2 #= 0),
	(Type #= 0 #/\ Type2 #= 0 #/\ CurrentSemester #= CurrentSemester2 #/\ Group #= Group2) #<==> (Same2 #= 1),
	sameSemesterHelper(CurrentSemester, Semesters, Slot, T, Same1),
	Same #= Same1 + Same2.

sameSemesterHelper(CurrentSemester, Semesters, Slot, [H|T], Same) :-
	Same2 in 0 .. 1,
	Group #= H mod 10,
	H2 #= H div 10,
	Type #= H2 mod 10,
	Group2 #= Slot mod 10,
	Slot2 #= Slot div 10,
	Type2 #= Slot2 mod 10,
	Course2 #= H2 div 10,
	nonvar(Course2), Course2 #\= 0,
	element(Course2, Semesters, CurrentSemester2),
	(Type #\= 0 #\/ Type2 #\= 0 #\/ (Type #= 0 #/\ Type2 #= 0 #/\ Group #\= Group2) #\/ CurrentSemester #\= CurrentSemester2) #<==> (Same2 #= 0),
	(Type #= 0 #/\ Type2 #= 0 #/\ CurrentSemester #= CurrentSemester2 #/\ Group #= Group2) #<==> (Same2 #= 1),
	sameSemesterHelper(CurrentSemester, Semesters, Slot, T, Same1),
	Same #= Same1 + Same2.

sameSemesterHelper(CurrentSemester, Semesters, Slot, [H|T], Same) :-
	H2 #= H div 10,
	Course2 #= H2 div 10,
	nonvar(Course2), Course2 #= 0,
	sameSemesterHelper(CurrentSemester, Semesters, Slot, T, Same).