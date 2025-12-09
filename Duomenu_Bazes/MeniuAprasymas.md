## Meniu punktų paaiškinimas

## 1.	ShowAllStudents	    
Rodo visus studentus su pagrindine info ir grupės numeriu (JOIN su Grupe)

## 2.	SearchStudent	    
Ieško studento pagal vardą arba pavardę (LIKE, parametrizuota užklausa)

## 3.	ShowStudentDetails	
Rodo studento info su dalykais, dėstytojais ir egzaminų rezultatais (JOIN kelioms lentelėms)

## 4.	RegisterNewStudent	
Įveda naują studentą į DB, parodo galimas studijų programas ir grupes, saugoma domeninė logika

## 5.	TransferStudentToGroup	
Perkelia studentą į kitą grupę; naudojama transakcija keliems SQL sakiniams

## 6.	RemoveStudent	
Pašalina studentą iš sistemos (DELETE kelioms lentelėms, transakcija)

## 7.	ShowStudentAverages	
Rodo studentų egzaminų vidurkius (VIEW)

## 8.	ShowProblematicStudents
Rodo probleminius studentus (VIEW)

## 9.	AddExamGrade
Įveda egzamino pažymį studentui; rodo galimus dalykus ir egzaminų datas

## 10.	ShowProgramStatistics	
Rodo studijų programų statistiką (materialized view)

## 11.	ShowTeacherWorkload 
Rodo dėstytojų darbo krūvį (materialized view)

## 0	-	Išeiti iš programos