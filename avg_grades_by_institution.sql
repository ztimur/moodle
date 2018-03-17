SELECT u.institution, AVG(gg.finalgrade) AS avg_final_grade, AVG(gg.finalgrade*100/gg.rawgrademax) as pct
	FROM mdl_grade_grades gg JOIN mdl_grade_items gi ON gi.id=gg.itemid JOIN mdl_user u ON u.id=gg.userid 
	WHERE gi.itemtype='course'
	GROUP BY u.institution
	ORDER by pct DESC
	
