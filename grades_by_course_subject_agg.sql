SELECT passed.institution as "Факультет", passed.fullname as "Тест", REGEXP_REPLACE(REGEXP_REPLACE(passed.name, '[\s]+', ' '), '[\t]+', ' ') as "Дисциплина", 
	ROUND(passed.count*100.0/enrol.count,2) as "Участие в %", enrol.count as "Всего запланировано", passed.count as "Участвовали в тестах", absent.count as "Не явились",
	--pct as "Успеваемость в %" ,
	ROUND((passed.g5 + passed.g4 + passed.g3)*100.0/passed.count,2) as "Успеваемость в % (сумма 5+4+3)" ,
	ROUND(passed.g5*100.0/passed.count,2) as "% получив. 5",  
	ROUND(passed.g4*100.0/passed.count,2) as "% получив. 4",
	ROUND(passed.g3*100.0/passed.count,2) as "% получив. 3", 
	ROUND(passed.g2*100.0/passed.count,2) as "% получив. 2", 
	passed.g5 as "Получили 5", passed.g4 as "Получили 4", passed.g3 as "Получили 3", passed.g2 as "Получили 2"
FROM (SELECT u.institution, c.fullname, c.id as courseid, q.name, q.id as quizid, 
	--ROUND(AVG(gg.finalgrade*100/gg.rawgrademax),2) as pct,
	COUNT(u.id) as count,
	COUNT(gi.id) filter (where gg.finalgrade*100.0/gg.rawgrademax >= 85 ) as g5, 
	COUNT(gi.id) filter (where gg.finalgrade*100.0/gg.rawgrademax >= 70 AND gg.finalgrade*100.0/gg.rawgrademax < 85) as g4,
	COUNT(gi.id) filter (where gg.finalgrade*100.0/gg.rawgrademax >= 55 AND gg.finalgrade*100.0/gg.rawgrademax < 70) as g3,
	COUNT(gi.id) filter (where gg.finalgrade*100.0/gg.rawgrademax < 55 OR gg.finalgrade is null) as g2
	FROM mdl_course c 
		LEFT JOIN mdl_quiz q ON q.course = c.id
		LEFT JOIN mdl_enrol e ON e.courseid = c.id
		LEFT JOIN mdl_user_enrolments ue ON e.id = ue.enrolid
		LEFT JOIN mdl_user u ON ue.userid = u.id
		LEFT OUTER JOIN mdl_grade_grades gg ON u.id = gg.userid 
		LEFT OUTER JOIN mdl_grade_items gi ON gi.id = gg.itemid 
	WHERE (gi.itemname is null OR gi.itemname = q.name) 
		AND (gg.aggregationstatus = 'used' 
			OR gg.aggregationstatus = 'novalue'  
			OR gg.aggregationstatus is null)
	GROUP BY u.institution, c.fullname, c.id, q.name, q.id, gi.itemname
) as passed
  JOIN (SELECT q.id as quizid, 
	COUNT(u.id) as count
	FROM mdl_course c 
		LEFT JOIN mdl_quiz q ON q.course = c.id
		LEFT JOIN mdl_enrol e ON e.courseid = c.id
		LEFT JOIN mdl_user_enrolments ue ON e.id = ue.enrolid
		LEFT JOIN mdl_user u ON ue.userid = u.id
		LEFT OUTER JOIN mdl_grade_grades gg ON u.id = gg.userid 
		LEFT OUTER JOIN mdl_grade_items gi ON gi.id = gg.itemid 
	WHERE (gi.itemname is null OR gi.itemname = q.name) 
		AND (gg.aggregationstatus = 'used' 
			OR gg.aggregationstatus = 'novalue'  
			OR gg.aggregationstatus is null)
	GROUP BY q.id, gi.itemname
) as absent ON passed.quizid = absent.quizid
JOIN (SELECT q.id as quizid, 
	COUNT(u.id) as count
	FROM mdl_course c 
		LEFT JOIN mdl_quiz q ON q.course = c.id
		LEFT JOIN mdl_enrol e ON e.courseid = c.id
		LEFT JOIN mdl_user_enrolments ue ON e.id = ue.enrolid
		LEFT JOIN mdl_user u ON ue.userid = u.id
	GROUP BY q.id
) as enrol ON passed.quizid = enrol.quizid AND enrol.count = passed.count + absent.count
WHERE passed.name is not null AND (passed.g5 + passed.g4 + passed.g3 + passed.g2) > 0.0 AND passed.institution <>'' --AND passed.courseid = 118 
ORDER BY passed.institution, passed.fullname, passed.name ASC
