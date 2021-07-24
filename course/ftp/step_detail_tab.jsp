<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

String status = m.rs("status");

//폼입력
String step_id = m.rs("step_id");
int mid = m.ri("mid");
String mode = m.rs("mode");
int pid = m.ri("pid", 0);

//객체
CourseDao course = new CourseDao();
CourseStepDao step = new CourseStepDao();
CourseStepEtcDao etc = new CourseStepEtcDao();
CourseRelationDao cr = new CourseRelationDao();
CourseLessonDao cl = new CourseLessonDao();
CourseScheduleDao schedule = new CourseScheduleDao();
LessonDao lesson = new LessonDao();
PlaceDao place = new PlaceDao();
CourseUserDao cu = new CourseUserDao();
CePostDao cePost = new CePostDao();
CeBoardDao ceBoard = new CeBoardDao();

//step_id = "CRS000000490165";
DataSet info = new DataSet();
if(!step_id.equals("")) {
	info = step.query(
		"SELECT a.*, b.*, c.hash_tags, l.width sample_width, l.height sample_height " + (!"".equals(userId) ? ", cu.id cuid " : "")
		+ ", (CASE WHEN '" + m.time("yyyyMMdd") + "' BETWEEN a.request_sdate AND a.request_edate THEN 'Y' ELSE 'N' END) request_yn "
		+ "	, (CASE WHEN EXISTS (SELECT id FROM Tb_course_user WHERE step_id = a.id AND user_id = '" + userId + "' AND status IN (0, 4)) THEN 'Y' ELSE 'N' END) requestcomplete_yn "
		+ "	, (CASE WHEN EXISTS (SELECT id FROM Tb_course_user WHERE step_id = a.id AND user_id = '" + userId + "' AND status IN (1, 3, 5)) THEN 'Y' ELSE 'N' END) paycomplete_yn "
		+ ", c.main_course_yn, c.name course_name "
		+ " FROM " + step.table + " a "
		+ " INNER JOIN " + etc.table + " b ON a.id = b.step_id "
		+ " INNER JOIN " + course.table + " c ON a.course_id = c.id AND c.status = 1 "
		+ " LEFT JOIN TB_LESSON l ON a.sample_lesson = l.id "
		+ (!"".equals(userId) ? " LEFT JOIN " + cu.table + " cu ON a.id = cu.step_id AND cu.course_id = c.id AND cu.user_id = '" + userId + "' AND cu.status IN (0,1,3,4,5)" : "")
		+ " WHERE a.id = '" + step_id + "' AND a.status = 1 AND a.type = '01' "
	);
	if(info.next()) {
		info.put("content1_block", !info.s("content1").equals(""));
		info.put("content2_block", !info.s("content2").equals(""));
		info.put("content3_block", !info.s("content3").equals(""));
		info.put("content4_block", !info.s("content4").equals(""));
		info.put("content5_block", !info.s("content5").equals(""));
		info.put("content6_block", !info.s("content6").equals(""));
	}
}

DataSet schedules = new DataSet();
DataSet tutors = new DataSet();
DataSet clist = new DataSet();
DataSet cls = new DataSet();
DataSet epilogue = new DataSet();

//cr.d(out);
tutors = cr.query(
	"SELECT b.* "
	+ " FROM " + cr.table + " a "
	+ " INNER JOIN TB_TUTOR b ON a.module_id = b.user_id "
	+ " WHERE a.module = 'MAIN_TUTOR' AND a.step_id = '" + step_id + "'"
	+ " ORDER BY CASE WHEN b.name = '정은주' THEN 1 ELSE 2 END, b.name ASC "
);

//cl.d(out);
clist = cl.query(
	"SELECT a.*, b.subject lesson_subject"
	+ " FROM " + cl.table + " a"
	+ " LEFT JOIN " + lesson.table + " b ON a.lesson_id = b.id"
	+ " WHERE a.step_id = '" + step_id + "' AND a.status = 1"
	+ " ORDER BY a.sort"
);

Hashtable<String, String> tmp2 = new Hashtable<String, String>();
int rows = 0;
String lessonSubject = "-";
String hKey = "-";
boolean isFirst = true;
while(clist.next()) {
	if("02".equals(clist.s("type"))) {
		lessonSubject = clist.s("subject");
		hKey = clist.s("id");
		isFirst = true;
		rows = 0;
	} else {
		clist.put("hkey", hKey);
		clist.put("1depth", lessonSubject);
		clist.put("is_first", isFirst);
		isFirst = false;
		cls.addRow(clist.getRow());
		rows++;
	}
	tmp2.put(hKey, rows+"");
}
cls.first();
while(cls.next()) {
	cls.put("rows", tmp2.containsKey(cls.s("hkey")) ? m.parseInt(tmp2.get(cls.s("hkey"))) : 1);
	cls.put("offline_yn_conv", cls.s("offline_yn").equals("Y")?"출석":"온라인");
	cls.put("study_date_block", !cls.s("study_day").equals(""));
	cls.put("study_date_conv", m.time("MM/dd", cls.s("study_day")));
//out.println(cls.s("study_day"));
}

//cePost.d(out);
String course_id = "d.id = '" + info.s("course_id") + "' ";
if(info.s("course_id").equals("CRS00100051")) course_id = "d.id = 'CRS00000053' ";
if(info.s("course_id").equals("CRS00100131")) course_id = "(d.id = '" + info.s("course_id") + "' OR c.name LIKE '%교사%') ";
epilogue = cePost.query(
	"SELECT a.*, c.step_txt, c.name"
	+ " FROM " + cePost.table + " a"
	+ " INNER JOIN " + ceBoard.table + " b ON a.board_id = b.id"
	+ " INNER JOIN " + step.table + " c ON a.step_id = c.id"
	+ " INNER JOIN " + course.table + " d ON c.course_id = d.id "
	+ " WHERE a.status IN (1, -99) AND " + course_id + " AND b.type = 4"
	+ " ORDER BY DECODE(c.step_txt, '', a.point, c.step_txt) DESC, a.THREAD, a.DEPTH, a.ID DESC "
, 30);

while(epilogue.next()) {
	epilogue.put("subject_conv", m.cutString(epilogue.s("subject"), 70));
	epilogue.put("new_block", m.diffDate("H", epilogue.s("reg_date"), m.time("yyyyMMddHHmmss")) <= 24);
	if(epilogue.s("writer").length() > 2) {
		epilogue.put("writer_conv", epilogue.s("writer").substring(0,1) + "○" + epilogue.s("writer").substring(2));
	} else {
		epilogue.put("writer_conv", epilogue.s("writer").substring(0,1) + "○");
	}
//	epilogue.put("reg_date_conv", m.getTimeString("yyyy.MM.dd", epilogue.s("reg_date")));
	epilogue.put("step_name_conv", (epilogue.i("point") > 0 ? epilogue.i("point") + "기 " : (epilogue.i("step_txt") > 0 ? epilogue.i("step_txt") + "기 " : "")));
}

//출력
p.setLayout("blank");
p.setBody("course.step_detail_tab");
p.setVar("form_script", f.getScript());
p.setVar("query", m.qs());
p.setVar("list_query", m.qs("id"));
p.setVar(info);
p.setLoop("tutors", tutors);
p.setLoop("list", cls);
p.setLoop("epilogue", epilogue);
p.setLoop("schedule_list", schedules);
p.setVar("step_id", step_id);
p.setVar("step_detail_block", !step_id.equals(""));
p.setLoop("clist", clist);
//p.setVar("pagebar", lm.getPaging());
//p.setVar("list_total", lm.getTotalString());
//p.setVar("total_num", m.nf(lm.getTotalNum()));

p.display(out);

%>