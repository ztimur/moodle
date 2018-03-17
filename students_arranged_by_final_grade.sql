SELECT u.institution, u.department,u.lastname,u.firstname,u.email,gg.finalgrade, gg.rawgrademax, gg.finalgrade*100/gg.rawgrademax as pct
	FROM mdl_grade_grades gg JOIN mdl_grade_items gi ON gi.id=gg.itemid JOIN mdl_user u ON u.id=gg.userid 
	WHERE gi.itemtype='course' AND u.institution != ''
	ORDER BY gg.finalgrade desc;