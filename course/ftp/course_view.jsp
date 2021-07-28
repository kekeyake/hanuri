<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

String site_path = m.rs("site"); 
String gubun_id = m.rs("g_id"); //기본키
String ctype = m.rs("ctype", "COURSE");
if("".equals(gubun_id)) { m.jsError("기본키는 지정해야 합니다."); return; }

String today = m.time("yyyyMMdd");
String now = m.time("yyyyMMddHHmmss");
int eplcnt = m.ri("eplcnt", 6);

String on_step_id = "";

//객체
UserDao user = new UserDao();
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
OrderDao order = new OrderDao();
OrderItemDao oi = new OrderItemDao();
CouponDao coupon = new CouponDao();
PointDao point = new PointDao();
LicenseDao license = new LicenseDao();
CourseUserLicenseDao cul = new CourseUserLicenseDao();
LicenseUserDao licenseUser = new LicenseUserDao();

BizMsgDao biz = new BizMsgDao();
biz.setDB(new DB("jdbc/bizppurio"));
SmsDao sms = new SmsDao();

boolean read_complete_block = false; //독지사 수료자인지
boolean issimhwa = false;
boolean isonsimhwa = false;
boolean islecturepay = false;
boolean isbosu = false;
boolean isbosu_lecturepay = false;
boolean isbosu3 = false; //3차보수교육 과정인경우
boolean isbosu3_16times = false; //보수교육 3차대상자(16시간이상자)인 경우
boolean iswhistory = false;
boolean isonehistory = false;
boolean isoneliter = false;
boolean isdonghwa = false;
boolean ismindmap = false;
boolean isedunetuser = false;
boolean isself = false;
boolean isnocenterdc = false;
boolean istoron2 = false;
boolean is2teamcourse = false;
boolean ishanuriteacher = false;
boolean ishanteachercourse = false;  
boolean is2team50course = false;
boolean isselfcoaching = false;
boolean issnsmemberaddr = false;
boolean isteachercourse = false;
boolean isjehucourse = false;
boolean isnonsul90course = false;
boolean is1teameventcourse = false;
boolean isreadtoron2 = false;
boolean isnonsul = false;
boolean iskangseo = false; //강서구청여부
boolean issungdong = false; //성동구청여부
boolean current_pass_exam_block = false; //최근 독지사시험 합격자인지
boolean dc26years = false;
boolean prevstudy_block = false; //독지사 개강전인지
boolean freebook_block = false; //독지사 교재가 무료인지
boolean prevstudy_dcbook = false; //독지사 개강전 신청하여 교재를 무료로 받았는지
boolean is_reinfo = false; //동일과정 재수강자인지
boolean read_restudy_block = false; //독지사 재수강자인지
String event_info = ""; //어떤 이벤트로 유입되었는지

DataSet uinfo = user.find("id = '" + userId + "' AND status = 1");
if(!uinfo.next()) { m.jsError("회원 정보를 찾을 수 없습니다."); return; }

if((uinfo.s("join_motive").equals("40") || uinfo.s("join_motive").equals("41")) && (uinfo.s("addr").equals("") && uinfo.s("new_addr").equals(""))) issnsmemberaddr = true; //SNS가입회원의우편물주소입력여부

//정보
//course.d(out);
DataSet info = course.query(
	   " SELECT a.* "
	+ "			, (CASE WHEN EXISTS (SELECT id FROM " + cu.table + " WHERE course_id = a.id AND user_id = '" + userId + "' AND status IN (1,3,5,99)) THEN 'Y' ELSE 'N' END) is_retake "
	+ " FROM " + course.table + " a "
	+ " WHERE a.gubun = '" + gubun_id + "' AND a.class_type = 'ON' AND a.status = 1 "
	+ " ORDER BY a.main_yn DESC, a.sort "
, 1);
if(!info.next()) { m.jsError("해당 정보가 없습니다."); return; }

//today = "20210710";

int hisReadComplete = cu.getOneInt(
	"SELECT COUNT(a.id) comcnt "
	+ " FROM " + cu.table + " a"
	+ " WHERE a.status IN ('1','3','5','98','99') AND a.end_yn = 'Y' AND a.complete_yn = 'Y' AND a.course_id IN ('CRS00000049', 'CRS00000053', 'CRS00100035', 'CRS00100051','CRS00100131','CRS00100138') AND a.step_id NOT IN ('CRS000000560001','CRS000000560002','CRS000000570001','CRS001000740001','campusreadonlineread_test201001') AND a.user_id = '" + userId + "' "
);
if(hisReadComplete > 0) read_complete_block = true;

//현재접수중인 과정코드 가져오기
//step.d(out);
DataSet steplist = step.query(
	"SELECT a.offline_yn, MAX(a.id) id, MAX(a.name) name, MAX(a.zoom_yn) zoom_yn, MAX(a.request_sdate) request_sdate, MAX(a.request_edate) request_edate, MAX(a.reg_date) reg_date, MAX(b.event_yn) event_yn, MAX(b.event_info) event_info, MAX(b.event_info_detail) event_info_detail "
	+ " FROM " + step.table + " a "
	+ " 	INNER JOIN " + course.table + " b ON b.id = a.course_id AND b.gubun = '" + gubun_id + "' "
	+ " WHERE a.status = 1 AND a.package_yn = 'N' AND a.course_id != 'CRS00100138' AND '" + today + "' BETWEEN a.request_sdate AND a.request_edate "
//	+ " WHERE a.status = 1 AND a.package_yn = 'N' AND a.course_id != 'CRS00100138' "
	+ " GROUP BY offline_yn "
	+ " ORDER BY offline_yn, request_edate, id "
);
while(steplist.next()) {
	if(steplist.s("offline_yn").equals("Y")) steplist.put("gubun_type_conv", "출석");
	else if(steplist.s("zoom_yn").equals("Y")) steplist.put("gubun_type_conv", "ZOOM");
	else steplist.put("gubun_type_conv", "온라인");
	steplist.put("zoom_block", steplist.s("zoom_yn").equals("Y"));
	if(steplist.s("offline_yn").equals("N") && !steplist.s("zoom_yn").equals("Y")) on_step_id = steplist.s("id");
	steplist.put("reg_date_conv", m.getTimeString("yyyy.MM.dd", steplist.s("reg_date")));
}

//온라인 심화과정인 경우 최근 독지사시험 합격자 할인 처리(2020년까지)
if(is2teamcourse == true) {
	int pass_currentexam = cu.getOneInt(
		" SELECT COUNT(*) passcnt FROM (SELECT a.user_id, "
		+ " ( CASE WHEN a.type = '03' AND a.practical_pass_yn = 'Y' THEN 'Y' " 
		+ "   WHEN a.type = '02' AND a.written_pass_yn = 'Y' THEN 'Y' "
		+ "   WHEN a.type = '01' AND a.practical_pass_yn = 'Y' AND a.written_pass_yn = 'Y' THEN 'Y'  "
		+ "   ELSE 'N' "
		+ "   END "
		+ " ) is_final "
		+ " FROM Tb_license_exam_user a INNER JOIN Tb_user e ON a.user_id = e.id "
		+ " WHERE a.status IN (1, 0, 2, 3) AND a.exam_id IN (100025, 100026, 100027) AND a.user_id = '" + userId + "' AND a.status IN (1, 2) AND a.practical_score1 > -1 AND a.written_score1 > -1 "
		+ " ) "
		+ " WHERE is_final = 'Y' "
	);
	if(pass_currentexam > 0) current_pass_exam_block = true;
}

//on_step_id = "CRS000000490158";

//정보
/*
step.d(out);
DataSet info = step.query(
	"SELECT a.*, b.*, l.width sample_width, l.height sample_height " + (!"".equals(userId) ? ", cu.id cuid " : "")
	+ ", (CASE WHEN '" + m.time("yyyyMMdd") + "' BETWEEN a.request_sdate AND a.request_edate THEN 'Y' ELSE 'N' END) request_yn "
	+ "	, (CASE WHEN EXISTS (SELECT id FROM Tb_course_user WHERE step_id = a.id AND user_id = '" + userId + "' AND status IN (0, 4)) THEN 'Y' ELSE 'N' END) requestcomplete_yn "
	+ "	, (CASE WHEN EXISTS (SELECT id FROM Tb_course_user WHERE step_id = a.id AND user_id = '" + userId + "' AND status IN (1, 3, 5)) THEN 'Y' ELSE 'N' END) paycomplete_yn "
	+ ", c.main_course_yn, c.name course_name "
	+ " FROM " + step.table + " a "
	+ " INNER JOIN " + etc.table + " b ON a.id = b.step_id "
	+ " INNER JOIN " + course.table + " c ON a.course_id = c.id AND c.status = 1 "
	+ " LEFT JOIN TB_LESSON l ON a.sample_lesson = l.id "
	+ (!"".equals(userId) ? " LEFT JOIN " + cu.table + " cu ON a.id = cu.step_id AND cu.course_id = c.id AND cu.user_id = '" + userId + "' AND cu.status IN (0,1,3,4,5)" : "")
//	+ " WHERE a.id = '" + id + "' AND a.status = 1 AND a.type = '01' "
	+ " WHERE a.course_id = '" + id + "' AND a.status = 1 AND a.type = '01' AND '" + m.time("yyyyMMdd") + "' BETWEEN a.request_sdate AND a.request_edate "

);
if(!info.next()) { m.jsError("해당 정보가 없습니다."); return; }
*/

info.put("request_yn", "Y".equals(info.s("request_yn")) && !"Y".equals(info.s("package_yn")) ? "Y" : "N");
if("Y".equals(info.s("request_yn"))) info.put("request_yn", info.i("cuid") > 0 ? "N" : "Y");
info.put("event_block", "Y".equals(info.s("event_yn")));
info.put("event_info_block", !"".equals(info.s("event_info")));
info.put("event_detail_block", !"".equals(info.s("event_info_detail")));
info.put("main_image_url", !info.s("thumbnail_image").equals("")?"/data/thumb_img/" + info.s("thumbnail_image"):"/data/thumb_img/course_noimage.jpg");
info.put("sample_lesson_url", !info.s("sample_link").equals("")?info.s("sample_link"):"../assets/img/@view_movie.png");
info.put("sample_lesson_block", !"".equals(info.s("sample_lesson")));

info.put("requestcomplete_block", "Y".equals(info.s("requestcomplete_yn")));
info.put("paycomplete_block", "Y".equals(info.s("paycomplete_yn")));
info.put("memo_conv", m.nl2br(info.s("memo")));
info.put("insurance_block", "Y".equals(info.s("insurance_yn")));
info.put("main_course_block", "Y".equals(info.s("main_course_yn")));
info.put("main_course_online_block", "Y".equals(info.s("main_course_yn")) && "N".equals(info.s("offline_yn")));
info.put("main_course_instantly_block", "Y".equals(info.s("main_course_yn")) && "N".equals(info.s("offline_yn")) && !"CRS00100138".equals(info.s("course_id")) && !"CRS00100141".equals(info.s("course_id")) && !"CRS00100142".equals(info.s("course_id")) ); //독지사 즉시수강여부
info.put("main_course_online_not_teacher_block", "Y".equals(info.s("main_course_yn")) && "N".equals(info.s("offline_yn")) && "CRS00000049".equals(info.s("course_id")));
info.put("main_course_offline_block", "Y".equals(info.s("main_course_yn")) && "Y".equals(info.s("offline_yn")));
info.put("restudy_block", "Y".equals(info.s("restudy_yn")));

info.put("on_block", "Y".equals(info.s("on_yn")));
info.put("zoom_block", "Y".equals(info.s("zoom_yn")));
info.put("off_block", "Y".equals(info.s("off_yn")));
info.put("blen_block", "Y".equals(info.s("blen_yn")));
info.put("quick_block", "Y".equals(info.s("quick_yn")));
info.put("free_book_block", "Y".equals(info.s("free_book_yn")));
info.put("dc_01_block", "Y".equals(info.s("dc_01_yn")));
info.put("dc_02_block", "Y".equals(info.s("dc_02_yn")));
info.put("dc_03_block", "Y".equals(info.s("dc_03_yn")));
info.put("dc_04_block", "Y".equals(info.s("dc_04_yn")));
info.put("dc_05_block", "Y".equals(info.s("dc_05_yn")));
info.put("dc_06_block", "Y".equals(info.s("dc_06_yn")));
info.put("dc_07_block", "Y".equals(info.s("dc_07_yn")));
info.put("dc_08_block", "Y".equals(info.s("dc_08_yn")));
info.put("dc_09_block", "Y".equals(info.s("dc_09_yn")));
info.put("dc_10_block", "Y".equals(info.s("dc_10_yn")));
info.put("dc_11_block", "Y".equals(info.s("dc_11_yn")));
info.put("dc_12_block", "Y".equals(info.s("dc_12_yn")));
info.put("dc_13_block", "Y".equals(info.s("dc_13_yn")));
info.put("dc_14_block", "Y".equals(info.s("dc_14_yn")));

info.put("thumbnail_image_url", m.getUploadUrl(info.s("thumbnail_image")));
//info.put("study_sdate_conv", "".equals(info.s("study_sdate"))  ? "지역별 확인" : m.time("MM월 dd일 (E)", info.s("study_sdate")));
info.put("study_sdate_conv", "".equals(info.s("study_sdate"))  ? "5월 7일 (금)" : m.time("MM월 dd일 (E)", info.s("study_sdate")));
if("20991231".equals(info.s("study_edate"))) info.put("study_sdate_conv", "결제일"); //상시과정
if("CRS00100006".equals(info.s("course_id")) || "CRS00100007".equals(info.s("course_id"))) info.put("study_sdate_conv", "결제일"); //유료첨삭과정
if("CRS00100100".equals(info.s("course_id"))) info.put("study_sdate_conv", "개강예정"); //그림책
//if("CRS00000094".equals(info.s("course_id"))) info.put("study_sdate_conv", "개강예정"); //동화창작
if("CRS00100039".equals(info.s("course_id"))) info.put("study_sdate_conv", "개강예정"); //토론지도사2
if("CRS00100099".equals(info.s("course_id"))) info.put("study_sdate_conv", "개강예정"); //동화구연
info.put("toron_block","CRS001000390017".equals(info.s("id")) || "CRS00100141".equals(info.s("course_id"))); //토론지도사 서울반
//info.put("study_sdate_conv", m.time("MM월dd일", info.s("study_sdate")));
info.put("total_price_conv", info.i("total_price") > 0 ? "<strong class=\"f_red\">" + m.nf(info.i("total_price")) + "원</strong>":"-");
//if("Y".equals(info.s("main_course_yn")) && "Y".equals(info.s("offline_yn"))) info.put("total_price_conv", "<strike>500,000원</strike>&nbsp;<strong class=\"f_red\">" + m.nf(info.i("total_price")) + "원</strong>");
//if("Y".equals(info.s("main_course_yn")) && "N".equals(info.s("offline_yn"))) info.put("total_price_conv", "<strike>425,000원</strike>&nbsp;<strong class=\"f_red\">" + m.nf(info.i("total_price")) + "원</strong>");
if("CRS000000630045".equals(info.s("id"))) info.put("total_price_conv", "<strike>220,000원</strike>&nbsp;<strong class=\"f_red\">" + m.nf(info.i("total_price")) + "원</strong>");
if("CRS001001000001".equals(info.s("id"))) info.put("total_price_conv", "<strike>180,000원</strike>&nbsp;<strong class=\"f_red\">" + m.nf(info.i("total_price")) + "원</strong>");
if("CRS001000990001".equals(info.s("id"))) info.put("total_price_conv", "<strike>150,000원</strike>&nbsp;<strong class=\"f_red\">" + m.nf(info.i("total_price")) + "원</strong>");
if("CRS001001390001".equals(info.s("id"))) info.put("total_price_conv", "<strike>180,000원</strike>&nbsp;<strong class=\"f_red\">" + m.nf(info.i("total_price")) + "원</strong>");
//if("CRS000000500082".equals(info.s("id"))) info.put("total_price_conv", "<strike>240,000원</strike>&nbsp;<strong class=\"f_red\">" + m.nf(info.i("total_price")) + "원</strong>");
//if("CRS000000490141".equals(info.s("id"))) info.put("total_price_conv", "<span class=\"f_16\"><strike>380,000원</strike>&nbsp;<strong class=\"f_red\">30%할인 ▶ " + m.nf(info.i("price")) + "원</strong></span>");
//if("CRS000000490161".equals(info.s("id"))) info.put("total_price_conv", "<span class=\"f_16\"><strike>380,000원</strike>&nbsp;<strong class=\"f_red\">20%할인 ▶ " + m.nf(info.i("price")) + "원</strong></span>");
if("CRS000000530264".equals(info.s("id"))) info.put("total_price_conv", "<span class=\"f_16\"><strike>500,000원</strike>&nbsp;<strong class=\"f_red\">30%할인 ▶ " + m.nf(info.i("price")) + "원</strong></span>");
if("CRS000000490158".equals(info.s("id"))) info.put("total_price_conv", "<span class=\"f_13\"><strike>425,000원 (수강료 380,000원+교재비 45,000원)</strike><br/><strong class=\"f_red\">311,000원</strong> (수강료 30% 할인 266,000원+교재비 45,000원)</span>"); //독지사온라인 11월한정
if("CRS000000490162".equals(info.s("id"))) info.put("total_price_conv", "<span class=\"f_13\"><strike>425,000원 (수강료 380,000원+교재비 45,000원)</strike><br/><strong class=\"f_red\">349,000원</strong> (수강료 20% 할인 304,000원+교재비 45,000원)</span>"); //독지사온라인 3월한정
if("CRS001001380001".equals(info.s("id"))) info.put("total_price_conv", "<span class=\"f_13\"><strike>475,000원 (수강료 430,000원+교재비 45,000원)</strike><br/><strong class=\"f_red\">389,000원</strong> (수강료 20% 할인 344,000원+교재비 45,000원)</span>"); //독지사줌 3월한정
if("CRS000000530297".equals(info.s("id"))) info.put("total_price_conv", "<span class=\"f_13\"><strike>545,000원 (수강료 500,000원+교재비 45,000원)</strike><br/><strong class=\"f_red\">395,000원</strong> (수강료 30% 할인 350,000원+교재비 45,000원)</span>"); //독지사출석 12월한정
if("CRS000000530304".equals(info.s("id"))) info.put("total_price_conv", "<span class=\"f_13\"><strike>545,000원 (수강료 500,000원+교재비 45,000원)</strike><br/><strong class=\"f_red\">445,000원</strong> (수강료 20% 할인 400,000원+교재비 45,000원)</span>"); //독지사출석 3월한정
if("CRS00100131".equals(info.s("course_id"))) info.put("total_price_conv", "<span class=\"f_13\"><strike>425,000원 (수강료 380,000원+교재비 45,000원)</strike><br/><strong class=\"f_red\">190,000원</strong> (수강료 50% 할인+교재비 무료)</span>"); //지도교사양성반 여부
if("CRS000000500081".equals(info.s("id"))) info.put("total_price_conv", "<span class=\"f_13\"><strike>260,000원 (수강료 250,000원+교재비 10,000원)</strike><br/><strong class=\"f_red\">150,000원</strong> (수강료 140,000원+교재비 10,000원)</span>"); //논술90일과정여부
info.put("refund_price", m.nf(info.i("refund_price")));
//out.println(info.s("name"));
info.put("name_conv", info.i("step_txt") > 0 ? info.s("name") + " " + info.i("step_txt") + "기" : info.s("name"));
if("CRS000000530297".equals(info.s("id"))) info.put("name_conv", info.s("name")); //출석반 임시로 기수제거
if("CRS00100141".equals(info.s("course_id")) || "CRS00100142".equals(info.s("course_id"))) info.put("referral_course_block", true); //위탁과정

DataSet schedules = new DataSet();
//schedule.d(out);
if(gubun_id.equals("C01") || gubun_id.equals("C02")) {
		schedules = schedule.query(
			"SELECT a.*, b.name, b.sido, b.phone, b.addr, b.addr2, b.content, b.mapapi_yn, b.locationx, b.locationy, b.roughmapno, b.homepage_link, b.company_tel "
			//+ (!"".equals(userId) ? " ,(SELECT id FROM " + cu.table + " WHERE schedule_id = a.id AND step_id = a.step_id AND user_id = '" + userId + "' AND status IN (0,1,3,4,5)) cuid " : "")
			+ " ,(CASE WHEN '" + today + "' BETWEEN c.request_sdate AND c.request_edate THEN 'Y' ELSE 'N' END) is_request "
			+ " FROM " + schedule.table + " a "
			+ "		INNER JOIN " + place.table + " b ON a.place_id = b.id "
			+ "		INNER JOIN " + step.table + " c ON a.step_id = c.id AND c.status = 1 AND c.name NOT LIKE '%추가접수%' AND '" + today + "' BETWEEN c.request_sdate AND c.request_edate "
//			+ "		INNER JOIN " + step.table + " c ON a.step_id = c.id AND c.status = 1 AND c.name NOT LIKE '%추가접수%' AND '20210310' BETWEEN c.request_sdate AND c.request_edate "
			+ "    INNER JOIN " + course.table + " d ON c.course_id = d.id AND d.status = 1 "
			+ " WHERE d.gubun = '" + gubun_id + "' AND a.status = 1 "
			+ " ORDER BY (CASE WHEN b.name like '서울%' THEN 1 WHEN sido = '서울특별시' THEN 2 ELSE 3 END) ASC, a.study_sdate, b.sido, a.start_date "
		);
		info.put("name", info.s("course_name"));
	
		while(schedules.next()) {
			schedules.put("class_conv", m.getItem(schedules.s("class"), schedule.classList));
			schedules.put("day_conv", m.join("", schedules.s("day").split(",")));
			schedules.put("study_time_conv", m.time("HH:mm", "20140101" + schedules.s("study_stime") + "00") + " ~ " + m.time("HH:mm", "20140101" + schedules.s("study_etime") + "00"));
			schedules.put("start_date_conv", m.time("MM월 dd일", schedules.s("start_date")));
			schedules.put("request_yn", schedules.i("cuid") > 0 ? "N" : "Y");
			schedules.put("location", schedules.s("sido") + " " + schedules.s("name"));
			schedules.put("location_conv", m.cutString(schedules.s("name"), 20));
			schedules.put("is_request_yn", ("Y".equals(info.s("main_course_yn")) && "Y".equals(info.s("offline_yn")) && "Y".equals(schedules.s("is_request"))) ); //출석반 과정이 접수가 마감되었는지 여부
			if("Y".equals(info.s("offline_yn")) && "Y".equals(schedules.s("is_request")) && ("CRS001000990001".equals(schedules.s("step_id")) || "CRS001001000001".equals(schedules.s("step_id"))) ) schedules.put("is_request_yn", true);
			if("".equals(info.s("thumbnail_image"))) info.put("thumbnail_image", schedules.s("thumbnail_image"));
			schedules.put("kangnam_block", "CRS000000530233".equals(schedules.s("step_id")));
			schedules.put("ulsan_block", "CRS000000530242".equals(schedules.s("step_id")));
			//schedules.put("telnot_block", "CRS000000530236".equals(schedules.s("step_id")) || "CRS000000530237".equals(schedules.s("step_id")) || "CRS000000530279".equals(schedules.s("step_id"))); //전화문의가 아닌경우
			schedules.put("telnot_block", true); //전화문의가 아닌경우 현재 모든 출석반을 신청가능하게..
			schedules.put("homepage_block", !"".equals(schedules.s("homepage_link")));
			schedules.put("company_tel_block", !"".equals(schedules.s("company_tel")));
		}
}

/*
String[] title = {"=>수강료", "reg_=>교재비", "m_=>재료비"};
int size = 0;
for(int i=0; i<title.length; i++) size += info.i(title[i].split("=>")[0] + "price") > 0 ? 1 : 0;
String[] tmp = new String[size];
for(int i=0,j=0; i<title.length; i++) {
	if(info.i(title[i].split("=>")[0] + "price") > 0) {
		tmp[j] = title[i].split("=>")[1] + " " + m.nf(info.i(title[i].split("=>")[0] + "price")) + "원" ;
		j++;
	}
}
info.put("total_price_txt", size <= 1 ? "" : "(" + m.join("+", tmp) + ")");
*/

String totalPriceTxt = "";
if(info.i("reg_price") > 0) totalPriceTxt = "수강료 " + m.nf(info.i("price")) + "원+" + "교재비 " + m.nf(info.i("reg_price")) + "원";
if("CRS000000490141".equals(info.s("id")) || "CRS000000530264".equals(info.s("id"))) totalPriceTxt = "교재비 별도";
if("CRS00100131".equals(info.s("course_id")) || "CRS000000500081".equals(info.s("id"))) totalPriceTxt = "";
if("CRS000000490162".equals(info.s("id")) || "CRS000000530297".equals(info.s("id")) || "CRS000000530304".equals(info.s("id")) || "CRS001001380001".equals(info.s("id"))) totalPriceTxt = "";
if(info.i("m_price") > 0) totalPriceTxt += ("".equals(totalPriceTxt) ? "" : ", ") + "재료비 " + m.nf(info.i("m_price")) + "원 별도";
info.put("total_price_txt", "".equals(totalPriceTxt) ? "" : "(" + totalPriceTxt + ")");

info.put("memo_block", !"".equals(info.s("memo")));
String[] contents = {"content1", "content2", "content3", "content4", "content5", "content6"};
for(int i=0; i<contents.length; i++) {
	info.put(contents[i] + "_block", !"".equals(m.replace(info.s(contents[i]),"<br>","")));
}

//폼체크
f.addElement("s_keyword", null, null);
f.addElement("s_offline_yn", null, null);
f.addElement("s_sub_category_id", null, null);
f.addElement("s_main_course_yn", null, null);
f.addElement("s_package_yn", null, null);
f.addElement("s_list_num", "10", null);
f.addElement("step_id", f.get("step_id"), "hname:'방식', required:'Y'");
if("Y".equals(info.s("sale_yn"))) {
	if("Y".equals(info.s("book_buy_yn"))) f.addElement("book_buy_yn", "Y", "hname:'교재', required:'Y'");
	f.addElement("sale_type", "03", "hname:'할인방법선택', required:'Y'");
	f.addElement("discount_type", null, "hname:'할인선택'");
	f.addElement("license_file", null, "hname:'자격증명서'");
	//f.addElement("certificate_file", null, "hname:'재직증명서'");
}
if("Y".equals(info.s("family_love_yn"))) {
	f.addElement("chilename", null, "hname:'자녀이름'");
	f.addElement("juminfront", null, "hname:'주민번호앞자리'");
	f.addElement("department", null, "hname:'소속지부'");
}

//등록
if(m.isPost() && f.validate()) {

//파라미터확인용
/*
m.jsAlert("p_step_id="+f.get("step_id"));
m.jsAlert("user_id="+userId);
m.jsAlert("p_schid="+f.getInt("schid"));
m.jsAlert("p_paymethod="+f.get("paymethod"));
m.jsAlert("p_book_buy_yn="+f.get("book_buy_yn"));
m.jsAlert("p_sale_type="+f.get("sale_type"));
m.jsAlert("p_discount_type="+f.get("discount_type"));
*/

	DataSet pay_stepinfo = step.query(
		"SELECT a.*, d.type course_type, d.main_course_yn, d.name before_name, d.recommend_yn, d.info_agree_yn, d.hanpoint_yn, d.family_love_yn, d.refund_type, d.sale_yn, d.coupon_yn, d.book_buy_yn "
		+ ", etc.*"
		+ ", c.id schid, c.class, c.start_date, c.study_sdate sch_study_sdate, c.study_edate sch_study_edate"
		+ ", p.name place_name "
		+ ", (CASE WHEN EXISTS (SELECT id FROM " + cu.table + " WHERE course_id = a.course_id AND user_id = '" + userId + "' AND status IN (1,3,5,99)) THEN 'Y' ELSE 'N' END) is_retake"
		+ ", (CASE WHEN EXISTS (SELECT id FROM " + user.table + " WHERE id = '" + userId + "' AND status = '1' AND SUBSTR(birthday,3,2) IN ('69','81','93')) THEN 'Y' ELSE 'N' END) is_chicken"
		+ ", (CASE WHEN EXISTS (SELECT id FROM " + user.table + " WHERE id = '" + userId + "' AND status = '1' AND TO_NUMBER(SUBSTR(birthday,0,4)) < 2000 AND (TO_NUMBER((TO_CHAR(SYSDATE,'YYYY')))-(TO_NUMBER('19'||SUBSTR(birthday, 3, 2)))) >= 60 ) THEN 'Y' ELSE 'N' END) is_senior"
		+ ", (CASE WHEN '" + today + "' BETWEEN a.request_sdate AND a.request_edate THEN 'Y' ELSE 'N' END) is_request"
		+ " FROM " + step.table + " a "
		+ "		INNER JOIN " + course.table + " d ON d.id = a.course_id AND d.status = 1"
		+ "		INNER JOIN " + etc.table + " etc ON a.id = etc.step_id "
		+ "		LEFT JOIN " + schedule.table + " c ON c.step_id = a.id AND c.status = 1 AND c.id = " + f.getInt("schid")
		+ "		LEFT JOIN " + place.table + " p ON c.place_id = p.id AND p.status = 1 "
		+ " WHERE a.id = '" + f.get("step_id") + "' AND a.status = 1 "
	);
	if(!pay_stepinfo.next()) { m.jsError("개설된 과정정보가 없습니다."); return; }
	pay_stepinfo.put("schedule_name", pay_stepinfo.i("schid") > 0 ? " ( " + pay_stepinfo.s("place_name") + " )" : "");
	pay_stepinfo.put("name_conv", pay_stepinfo.i("step_txt") > 0 ? pay_stepinfo.s("name") + pay_stepinfo.s("schedule_name") + " " + pay_stepinfo.i("step_txt") + "기" : pay_stepinfo.s("name") + pay_stepinfo.s("schedule_name"));

	//신청기간검사
	if(!"Y".equals(pay_stepinfo.s("is_request"))) {
		m.jsAlert("신청기간이 아닙니다.");
		return;
	}

	//선행과정여부
	if(!"".equals(pay_stepinfo.s("before_course")) && !"N".equals(pay_stepinfo.s("before_course"))) {
		if(cu.findCount("status IN (1,3,5,99) AND user_id = '" + userId + "' AND course_id IN ('" + pay_stepinfo.s("before_course") + "' , 'CRS00000053', 'CRS00100051', 'CRS00100131','CRS00100138') ") <= 0) {
			m.jsAlert("[" + pay_stepinfo.s("before_name") + "]과정을 먼저 수강하셔야 합니다.\\n관리자에게 문의하세요.");
			return;
		}
	}

	int cuCnt = cu.findCount("user_id = '" + userId + "' AND step_id = '" + pay_stepinfo.s("id") + "' AND status NOT IN (-1, -4, -5)");
	//최대수강수검사
	if("Y".equals(pay_stepinfo.s("limit_people_yn"))) {
		if(cuCnt >= pay_stepinfo.i("limit_people")) {
			m.jsAlert("최대 신청인원을 초과한 과정입니다.\\n관리자에게 문의하세요.");
			return;
		}
	}

	boolean isApprove = "Y".equals(pay_stepinfo.s("apply_approve_yn"));

	//중복신청검사
	DataSet cuinfo = cu.find("user_id = '" + userId + "' AND step_id = '" + pay_stepinfo.s("id") + "'");
	if(cuinfo.next()) {
		if(cuinfo.i("status") == -1 || cuinfo.i("status") == -4) {
			cu.execute("DELETE FROM " + cu.table + " WHERE id = " + cuinfo.i("id"));
		} else {
			if(!"20991231".equals(pay_stepinfo.s("study_edate"))) {
				m.jsAlert("이미 신청된 과정입니다.");
				m.jsReplace("index.jsp", "parent");
				return;
			}
		}
	}

	//장바구니확인 - 장바구니/cnf=N
	//--이전 즉시구매를 일반으로 업데이트
	oi.execute("UPDATE " + oi.table + " SET status = 10 WHERE order_id = 'cart' AND status = 20 AND user_id = '" + userId + "'");

	Vector<String> v = new Vector<String>(); //Rollback

	//--등록/과정
	if(oi.findCount("product_id = '" + pay_stepinfo.s("id") + "' AND user_id = '" + userId + "' AND product_type = 'COURSE' AND status = 10") > 0) {
		oi.item("reg_date", now);
		oi.item("status", 10);
		if(!oi.update("order_id = 'cart' AND product_id = '" + pay_stepinfo.s("id") + "' AND user_id = '" + userId + "' AND product_type = 'COURSE' AND status = 10")) {
			m.jsAlert("수강신청 중 오류가 발생했습니다.");
			return;
		}

	} else {

		//과정
		int newId = oi.getSequence(); v.add("" + newId);
		oi.item("id", newId);
		oi.item("order_id", "cart");
		oi.item("user_id", userId);
		oi.item("product_name", pay_stepinfo.s("name_conv"));
		oi.item("product_type", ctype); //COURSE, PACKAGE
		oi.item("product_id", pay_stepinfo.s("id"));
		oi.item("schedule_id", pay_stepinfo.i("schid"));
		oi.item("quantity", 1);
		oi.item("unit_price", 0);
		oi.item("price", pay_stepinfo.i("total_price"));
		oi.item("disc_price", 0);
		oi.item("coupon_price", 0);
		oi.item("pay_price", 0);
		oi.item("reg_date", now);
		oi.item("status", 10);
		oi.item("free_yn", pay_stepinfo.i("total_price") == 0 ? "Y" : "N");
		if(!oi.insert()) { m.jsAlert("수강신청 중 오류가 발생했습니다."); return; }
	}

	//결제정보
	String oid = order.getSequence("O", 8);
	order.item("id", oid);
	order.item("order_date", today);
	order.item("user_id", userId);
	order.item("name", pay_stepinfo.s("name_conv"));
	order.item("paymethod", f.get("paymethod"));
	order.item("book_buy_yn", f.get("book_buy_yn", "Y"));

	int regPrice = pay_stepinfo.i("reg_price") - ("Y".equals(pay_stepinfo.s("main_course_yn")) && "N".equals(f.get("book_buy_yn")) ? pay_stepinfo.i("reg_price") : 0);
	order.item("sale_type", f.get("sale_type", "03"));

//파라미터확인용
/*
m.jsAlert("p_name="+pay_stepinfo.s("name_conv"));
m.jsAlert("p_payPrice="+pay_stepinfo.i("price"));
m.jsAlert("regPrice="+regPrice);
*/

	//할인금액, 실결제 금액
	int discPrice = 0;
	int payPrice = pay_stepinfo.i("price");
	if(pay_stepinfo.i("dc_price") > 0) payPrice = pay_stepinfo.i("price") - pay_stepinfo.i("dc_price");
	int couponPrice = 0;
	String discountType = "";
	int freeCouponId = 0;
	int saleCouponId = 0;
	int edupangCouponId = 0;
	String event_course = "";

	if("04".equals(f.get("sale_type")) && "Y".equals(pay_stepinfo.s("coupon_yn")) && "Y".equals(pay_stepinfo.s("sale_yn")) && !"".equals(f.get("sdc_coupon"))) {
		if(!"".equals(f.get("free_course"))) {
			DataSet temp = coupon.find("code = UPPER('" + f.get("free_course") + "') AND type = '02' AND status = 0 AND code LIKE 'J%' AND '" + m.time("yyyyMMdd") + "' BETWEEN start_date AND end_date AND (user_id = '' OR user_id IS NULL)");
			if(temp.next()) {
				if(!"".equals(temp.s("course_id")) && !temp.s("course_id").equals(pay_stepinfo.s("course_id"))) {
					m.jsAlert("유효하지 않은 무료수강권 쿠폰번호입니다."); return;
				}
				order.item("free_course", temp.s("id"));
				payPrice = 0;
				discPrice += pay_stepinfo.i("price");
				couponPrice += pay_stepinfo.i("price");

				coupon.item("user_id", userId);
				coupon.item("use_date", m.time("yyyyMMddHHmmss"));
				coupon.item("status", 1);
				if(!coupon.update("id = " + temp.s("id"))) {}
				freeCouponId = temp.i("id");

			} else {
				m.jsAlert("유효하지 않은 무료수강권 쿠폰번호입니다."); return;
			}
		}
		if(!"".equals(f.get("edupang_coupon"))) {
			DataSet temp = coupon.find("code = UPPER('" + f.get("edupang_coupon") + "') AND type = '02' AND status = 0 AND (code LIKE 'ED%' OR code LIKE 'EP%') AND '" + m.time("yyyyMMdd") + "' BETWEEN start_date AND end_date AND (user_id = '' OR user_id IS NULL)");
			if(temp.next()) {
				if(!"".equals(temp.s("course_id")) && !temp.s("course_id").equals(pay_stepinfo.s("course_id"))) {
					m.jsAlert("유효하지 않은 에듀팡수강권 쿠폰번호입니다."); return;
				}
				order.item("edupang_coupon", temp.s("code"));
				payPrice = 0;
				discPrice += pay_stepinfo.i("price");
				couponPrice += pay_stepinfo.i("price");
				regPrice = 0; //교재비 포함
				coupon.item("user_id", userId);
				coupon.item("use_date", m.time("yyyyMMddHHmmss"));
				coupon.item("status", 1);
				if(!coupon.update("id = " + temp.s("id"))) {}
				edupangCouponId = temp.i("id");

			} else {
				m.jsAlert("유효하지 않은 에듀팡수강권 쿠폰번호입니다."); return;
			}
		}
		if(!"".equals(f.get("yes24_coupon"))) {
			DataSet temp = coupon.find("code = UPPER('" + f.get("yes24_coupon") + "') AND type = '01' AND code = 'YE764958' AND '" + m.time("yyyyMMdd") + "' BETWEEN start_date AND end_date AND (user_id = '' OR user_id IS NULL)");
			if(temp.next()) {
				if(!"".equals(temp.s("course_id")) && !temp.s("course_id").equals(pay_stepinfo.s("course_id"))) {
					m.jsAlert("유효하지 않은 할인 쿠폰번호입니다."); return;
				}
				order.item("yes24_coupon", temp.s("code"));
				int yes_dc_price = temp.i("price");
				if("Y".equals(pay_stepinfo.s("offline_yn"))) yes_dc_price = 20;
				int salePrice = "01".equals(temp.s("rate_type")) ? yes_dc_price : pay_stepinfo.i("price") * yes_dc_price / 100;
				payPrice = payPrice - salePrice;
				discPrice += salePrice;
				couponPrice += salePrice;
				//coupon.item("user_id", userId);
				//coupon.item("use_date", m.time("yyyyMMddHHmmss"));
				//coupon.item("status", 1);
				//if(!coupon.update("id = " + temp.s("id"))) {}
				saleCouponId = temp.i("id");
			} else {
				m.jsAlert("유효하지 않은 할인 쿠폰번호입니다."); return ;
			}
		}
		if("04".equals(f.get("sale_type")) && isonsimhwa == true && !"".equals(f.get("lcpass_coupon")) && current_pass_exam_block == true) {
			DataSet temp = coupon.find("code = UPPER('" + f.get("lcpass_coupon") + "') AND type = '01' AND code = 'LC47203961' AND '" + m.time("yyyyMMdd") + "' BETWEEN start_date AND end_date AND (user_id = '' OR user_id IS NULL)");
			if(temp.next()) {
				if(!"".equals(temp.s("course_id")) && !temp.s("course_id").equals(pay_stepinfo.s("course_id"))) {
					m.jsAlert("유효하지 않은 할인 쿠폰번호입니다. "); return;
				}
				order.item("gshome_coupon", temp.s("code"));
				int salePrice = pay_stepinfo.i("price") * temp.i("price") / 100;
				payPrice = payPrice - salePrice;
				discPrice += salePrice;
				couponPrice += salePrice;
				saleCouponId = temp.i("id");
			} else {
				m.jsAlert("유효하지 않은 할인 쿠폰번호입니다. "); return ;
			}
		}
		if("04".equals(f.get("sale_type")) && is2team50course == true && !"".equals(f.get("sdc_coupon")) ) {
			String coupon_code_query = " AND code IN ('SD24135706','SD31902784','LC47203961','LC39406827','LC70941836') ";
			if(isnonsul == true) coupon_code_query = " AND code IN ('SD24135706','SD31902784','SD80392514','LC47203961','LC39406827','LC70941836') ";
			if(islecturepay == true) coupon_code_query = " AND code IN ('SD24135706','SD31902784','SD80392514','LC47203961','LC39406827') ";
			DataSet temp = coupon.find("code = UPPER('" + f.get("sdc50_coupon") + "') AND type = '01' " + coupon_code_query + " AND '" + m.time("yyyyMMdd") + "' BETWEEN start_date AND end_date AND (user_id = '' OR user_id IS NULL)");
			if(temp.next()) {
				if(!"".equals(temp.s("course_id")) && !temp.s("course_id").equals(pay_stepinfo.s("course_id"))) {
					m.jsAlert("유효하지 않은 할인 쿠폰번호입니다. "); return;
				}
				order.item("gshome_coupon", temp.s("code"));
				int salePrice = pay_stepinfo.i("price") * temp.i("price") / 100;
				payPrice = payPrice - salePrice;
				discPrice += salePrice;
				couponPrice += salePrice;
				saleCouponId = temp.i("id");
			} else {
				m.jsAlert("유효하지 않은 할인 쿠폰번호입니다. "); return ;
			}
		}
		if("04".equals(f.get("sale_type")) && isselfcoaching == true && uinfo.s("jumin_no").equals("hanteacher") && !"".equals(f.get("self_coupon")) ) {
			DataSet temp = coupon.find("code = UPPER('" + f.get("self_coupon") + "') AND type = '01' AND code = 'SD54807162' AND '" + m.time("yyyyMMdd") + "' BETWEEN start_date AND end_date AND (user_id = '' OR user_id IS NULL)");
			if(temp.next()) {
				if(!"".equals(temp.s("course_id")) && !temp.s("course_id").equals(pay_stepinfo.s("course_id"))) {
					m.jsAlert("유효하지 않은 할인 쿠폰번호입니다. "); return;
				}
				order.item("gshome_coupon", temp.s("code"));
				int salePrice = pay_stepinfo.i("price") * temp.i("price") / 100;
				payPrice = payPrice - salePrice;
				discPrice += salePrice;
				couponPrice += salePrice;
				saleCouponId = temp.i("id");
			} else {
				m.jsAlert("유효하지 않은 할인 쿠폰번호입니다. "); return ;
			}
		}
		if(!"".equals(f.get("bosu_coupon")) && isbosu == true) {
			//DataSet temp = coupon.find("code = UPPER('" + f.get("bosu_coupon") + "') AND type = '01' AND code LIKE 'BO%' AND '" + m.time("yyyyMMdd") + "' BETWEEN start_date AND end_date AND (user_id = '' OR user_id IS NULL)");
			DataSet temp = coupon.find("code = UPPER('" + f.get("bosu_coupon") + "') AND type = '01' AND code IN ('BO81307425') AND '" + m.time("yyyyMMdd") + "' BETWEEN start_date AND end_date AND (user_id = '' OR user_id IS NULL)");
			if(temp.next()) {
				if(!"".equals(temp.s("course_id")) && !temp.s("course_id").equals(pay_stepinfo.s("course_id"))) {
					m.jsAlert("유효하지 않은 보수교육 할인 쿠폰번호입니다. "); return;
				}
				order.item("gshome_coupon", temp.s("code"));
				int yes_dc_price = temp.i("price");
				int salePrice = 0;
				salePrice = "01".equals(temp.s("rate_type")) ? yes_dc_price : pay_stepinfo.i("price") * yes_dc_price / 100;
				//salePrice = 10000;
				payPrice = payPrice - salePrice;
				discPrice += salePrice;
				couponPrice += salePrice;
				saleCouponId = temp.i("id");
			} else {
				m.jsAlert("유효하지 않은 보수교육 할인 쿠폰번호입니다. "); return ;
			}
		}

		if( ("01".equals(f.get("sale_type")) || "05".equals(f.get("sale_type")) || "06".equals(f.get("sale_type")) || "08".equals(f.get("sale_type")) ) && "Y".equals(info.s("sale_yn")) ) {
			if("04".equals(f.get("discount_type"))) { //동일과정 재수강
	//cu.d(out);
				//실질적으로 적용가능한지 체크
				DataSet reinfo = null;
				if("Y".equals(pay_stepinfo.s("main_course_yn"))) {
					reinfo = cu.query(
						"SELECT b.* "
						+ " FROM " + cu.table + " a "
						+ " INNER JOIN " + step.table + " b ON a.step_id = b.id AND b.status IN (1, 99) "
						+ " INNER JOIN " + course.table + " c ON b.course_id = c.id AND c.status = 1 AND c.main_course_yn = 'Y' "
						+ " WHERE a.user_id = '" + userId + "' AND a.status IN (1, 3, 5, -5, 99) "
					);
				} else {
					reinfo = cu.query(
						"SELECT b.* "
						+ " FROM " + cu.table + " a "
						+ " INNER JOIN " + step.table + " b ON a.step_id = b.id AND b.status IN (1, 99) "
						+ " INNER JOIN " + course.table + " c ON b.course_id = c.id AND c.status = 1 "
						+ " WHERE a.user_id = '" + userId + "' AND a.status IN (1, 3, 5, -5, 99) AND c.id = '" + pay_stepinfo.s("course_id") + "'"
					);
				}
				
				if(reinfo.next()) {
					//독지사는 이벤트로 인해 동일과정재수강 수강료가 변경됨
					if("Y".equals(pay_stepinfo.s("main_course_yn"))) {

						//할인이벤트시 주석해제
						/*
						if("N".equals(pay_stepinfo.s("offline_yn")) && !"CRS00100051".equals(pay_stepinfo.s("course_id")) && !"CRS00100131".equals(pay_stepinfo.s("course_id")) && !"CRS00100138".equals(pay_stepinfo.s("course_id")) ) {
							payPrice = 190000;
						} else if("Y".equals(pay_stepinfo.s("offline_yn")) || "CRS00100051".equals(pay_stepinfo.s("course_id"))) {
							payPrice = 250000;
						}
						*/

						/*
						payPrice = 100000;
						event_info = "RETAKE138";
						*/

						discPrice = payPrice * m.parseInt(m.getItem("04", order.sales)) / 100;  //할인이벤트 시 주석처리
						payPrice = payPrice - discPrice;  //할인이벤트 시 주석처리
						read_restudy_block = true;

					} else {
						if("N".equals(pay_stepinfo.s("main_course_yn"))) {
							discPrice = payPrice * m.parseInt(m.getItem("04", order.sales)) / 100;
							payPrice = payPrice - discPrice;
						}
					}
					is_reinfo = true;
					
					//123기 이전에 수강하고 이후 수료 못한 경우에는 교재비를 제외처리
/*
					DataSet reinfo_etc = null;
					reinfo_etc = cu.query(
						" SELECT DISTINCT(a.user_id) user_id "
						+ " FROM " + cu.table + " a " 
						+ " 	INNER JOIN " + step.table + " b ON a.step_id = b.id AND b.status IN (1, 99) AND b.step_txt < 123 "
						+ " 	INNER JOIN " + course.table + " c ON b.course_id = c.id AND c.status = 1 AND c.main_course_yn = 'Y' " 
						+ " WHERE a.user_id = '" + userId + "' AND a.status IN (1, 3, 5, -5, 99) "
						+ " MINUS "
						+ " SELECT DISTINCT(a.user_id) user_id " 
						+ " FROM " + cu.table + " a " 
						+ " 	INNER JOIN " + step.table + " b ON a.step_id = b.id AND b.status IN (1, 99) " 
						+ " 	INNER JOIN " + course.table + " c ON b.course_id = c.id AND c.status = 1 AND c.main_course_yn = 'Y' " 
						+ " WHERE a.user_id = '" + userId + "' AND a.status IN (1, 3, 5, -5, 99) AND a.end_yn='Y' AND a.complete_yn='Y' "				
					);				
					if(reinfo_etc.next()) is_reinfo = false;
*/

					//독지사온라인과정은 이벤트로 10만원으로..11월, 12월과정만..
					if("Y".equals(pay_stepinfo.s("main_course_yn")) && "N".equals(pay_stepinfo.s("offline_yn")) ) {
						//payPrice = 100000;
					}

					//이벤트행사 독지사수강이력이 있으면 독지사130기 전과정(출석포함)은 이벤트로 15만원으로..
					/*
					if("Y".equals(pay_stepinfo.s("main_course_yn")) && "CRS000000490150".equals(pay_stepinfo.s("step_id")) && "N".equals(pay_stepinfo.s("offline_yn"))) {				
						read_restudy_block = true;
						event_info = "RETAKE134";
					}
					*/
				}
			}

			if("06".equals(f.get("discount_type"))) { //교사/사서
				File f1 = f.saveFile("license_file");
				if(null != f1) order.item("license_file", f.getFileName("license_file"));
				else {
					m.jsAlert("자격증명서 사본은 필수 사항입니다. ");
					coupon.rollbackCoupon(edupangCouponId);
					return;
				}
			}

			if("13".equals(f.get("discount_type"))) { //한우리회원학부모
				if("".equals(f.get("childname"))) {
					m.jsAlert("자녀이름은 필수 사항입니다.");
					coupon.rollbackCoupon(edupangCouponId);
					return;
				}
				if("".equals(f.get("juminfront"))) {
					m.jsAlert("주민번호앞자리는 필수 사항입니다.");
					coupon.rollbackCoupon(edupangCouponId);
					return;
				}
				if("".equals(f.get("department"))) {
					m.jsAlert("소속지부는 필수 사항입니다.");
					coupon.rollbackCoupon(edupangCouponId);
					return;
				}

				order.item("childname", f.get("childname"));
				order.item("juminfront", f.get("juminfront"));
				order.item("department", f.get("department"));
				order.item("parent_agree_yn", f.get("parent_agree_yn"));
			}

			if("31".equals(f.get("discount_type"))) { //방문상담
				if("".equals(f.get("visit_date"))) {
					m.jsAlert("방문일자는 필수 사항입니다.");
					coupon.rollbackCoupon(edupangCouponId);
					return;
				}
				order.item("visit_date", f.get("visit_date"));
			}

			if("14".equals(f.get("discount_type"))) { //단체수강 3인이상
				if("".equals(f.get("names5"))) {
					m.jsAlert("단체성함은 필수 사항입니다.");
					coupon.rollbackCoupon(edupangCouponId);
					return;
				}
				order.item("names", f.get("names5"));
			}
			if("35".equals(f.get("discount_type"))) { //단체수강 2인이상
				if("".equals(f.get("names2"))) {
					m.jsAlert("단체성함은 필수 사항입니다.");
					coupon.rollbackCoupon(edupangCouponId);
					return;
				}
				order.item("names", f.get("names2"));
			}

			if("15".equals(f.get("discount_type"))) { //단체수강 5인이상
				if("".equals(f.get("names10"))) {
					m.jsAlert("단체성함은 필수 사항입니다.");
					coupon.rollbackCoupon(edupangCouponId);
					return;
				}
				order.item("names", f.get("names10"));
			}

			if("16".equals(f.get("discount_type"))) { //대학생
				File f1 = f.saveFile("student_file");
				if(null != f1) order.item("student_file", f.getFileName("student_file"));
				else {
					m.jsAlert("재학증명서는 필수 사항입니다.");
					coupon.rollbackCoupon(edupangCouponId);
					return;
				}
			}

			if("33".equals(f.get("discount_type"))) { //학부모이벤트
				File f1 = f.saveFile("childcheck_file");
				if(null != f1) order.item("freshman_file", f.getFileName("childcheck_file"));
				else {
					m.jsAlert("확인서류는 필수 사항입니다.");
					coupon.rollbackCoupon(edupangCouponId);
					return;
				}
			}

			//영등포구민 할인
			if("17".equals(f.get("discount_type"))) {
				File f1 = f.saveFile("user_area_file");
				if(null != f1) order.item("user_area_file", f.getFileName("user_area_file"));
				else {
					m.jsAlert("등본 및 주소확인 서류는 필수 사항입니다.");
					coupon.rollbackCoupon(edupangCouponId);
					return;
				}
				event_info = "YDPAREA130";
			}

			if("23".equals(f.get("discount_type"))) { //가족사랑이벤트
				File f1 = f.saveFile("familyhelp_file");
				if(null != f1) order.item("familyhelp_file", f.getFileName("familyhelp_file"));
				else {
					m.jsAlert("증빙 서류는 필수 사항입니다.");
					coupon.rollbackCoupon(edupangCouponId);
					return;
				}
			}

			if("30".equals(f.get("discount_type")) ) { //센터장추천
					if("".equals(f.get("center_name"))) {
						m.jsAlert("센터명 필수 입력사항입니다.");
						coupon.rollbackCoupon(edupangCouponId);
						return;
					}
					order.item("center_name", f.get("center_name"));
			}

			if("11".equals(f.get("discount_type")) ) { //준교사
				if("".equals(f.get("teacher_center_name"))) {
					m.jsAlert("센터명 필수 입력사항입니다.");
					coupon.rollbackCoupon(edupangCouponId);
					return;
				}
				order.item("teacher_center_name", f.get("teacher_center_name"));
			}
			//2021 교사소개이벤트
			if("05".equals(f.get("sale_type")) && "Y".equals(pay_stepinfo.s("main_course_yn")) && !f.get("etc_recomm_edunetid").equals("") ) {
				//아디로  폰번조회
				DataSet edunet_user = et.query(" SELECT user_nm, hp_no, user_id FROM " + et.table + " WHERE user_id = '" + f.get("etc_recomm_edunetid") + "' ", 1);
				if(edunet_user.next()) {
					order.item("etc_recomm_code", edunet_user.s("user_nm"));				
					order.item("etc_recomm_phone", edunet_user.s("hp_no"));
				}
				order.item("etc_recomm_department", f.get("etc_recomm_edunetid"));
				order.item("etc_company_yn", f.get("etc_company_yn"));
			}

			//2021 지도교사 양성반
			if("08".equals(f.get("sale_type")) && "Y".equals(pay_stepinfo.s("main_course_yn")) && (!f.get("ev_etc_recomm_edunetcenter").equals("") || !f.get("ev_etc_recomm_edunetid").equals("")) ) {
				//아디로  폰번조회
				DataSet edunet_user = et.query(" SELECT user_nm, hp_no, user_id FROM " + et.table + " WHERE user_id = '" + f.get("ev_etc_recomm_edunetid") + "' ", 1);
				if(edunet_user.next()) {
					order.item("etc_recomm_code", edunet_user.s("user_nm"));				
					order.item("etc_recomm_phone", edunet_user.s("hp_no"));
				}
				order.item("etc_recomm_department", f.get("ev_etc_recomm_edunetid"));
				order.item("teacher_center_name", f.get("ev_etc_recomm_edunetcenter"));
			}
		}
	}

	//이벤트행사(원숭이띠이고 독지사과정인경우 20%할인)
/*
	if("19".equals(f.get("discount_type")) && "Y".equals(pay_stepinfo.s("main_course_yn")) && "Y".equals(pay_stepinfo.s("is_monkey")) ){
		discPrice = payPrice * 20 / 100;
		payPrice = payPrice - discPrice;		
	}
*/

	//이벤트행사(독지사과정 신청시 교재무료)
/*
	if("20".equals(f.get("discount_type")) && "Y".equals(pay_stepinfo.s("main_course_yn")) ) {
		discPrice = pay_stepinfo.i("reg_price") - ("Y".equals(pay_stepinfo.s("main_course_yn")) && "N".equals(f.get("book_buy_yn")) ? pay_stepinfo.i("reg_price") : 0);
		payPrice = payPrice - discPrice;		
	}
*/

	//이벤트행사(독지사 부산교육장인 경우 20%자동 할인)
	if("26".equals(f.get("discount_type")) && pay_stepinfo.s("step_id").equals("CRS000000530189") && pay_stepinfo.i("step_txt") == 126 && "Y".equals(pay_stepinfo.s("main_course_yn")) ) {
		if(prevstudy_block) {
			payPrice = 360000;		
			prevstudy_dcbook = true;
		} else {
			payPrice = 400000;		
		}
	}

	//이벤트행사(독지사과정 신청시 상시과정 무료수강 차후 일괄로 승인처리)
/*
	if("21".equals(f.get("discount_type")) && "Y".equals(pay_stepinfo.s("main_course_yn")) ) {
		event_course = f.get("event_course_nm");	
	}
*/

	//얼리버드 이벤트(독지사인경우 2만원 할인)
/*
	if("22".equals(f.get("discount_type")) && "Y".equals(pay_stepinfo.s("main_course_yn")) ) {
		payPrice = payPrice - 20000;		
	}
*/

	//이벤트행사(이벤트 기간내 독지사과정 신청시 교재무료)
/*
	if( "Y".equals(pay_stepinfo.s("main_course_yn")) && 20160912 <= m.parseInt(today) && 20160918 >= m.parseInt(today) ) {
		discPrice = pay_stepinfo.i("reg_price") - ("Y".equals(pay_stepinfo.s("main_course_yn")) && "N".equals(f.get("book_buy_yn")) ? pay_stepinfo.i("reg_price") : 0);
		payPrice = payPrice - discPrice;		
		discountType = "24";
	}
*/

	//심화과정 30% 할인(독지사 수료자인 경우 온라인 심화 과정 30% 할인처리)
	if("01".equals(f.get("sale_type")) && "29".equals(f.get("discount_type")) && istoron2 == false && !"Y".equals(pay_stepinfo.s("package_yn")) && !"Y".equals(pay_stepinfo.s("main_course_yn")) && !"03".equals(pay_stepinfo.s("type")) && !"05".equals(pay_stepinfo.s("type")) && read_complete_block == true) {
			discPrice = payPrice * 30 / 100;
			payPrice = payPrice - discPrice;			
	}

	//경로우대(60세이상 20%할인)
	if("12".equals(f.get("discount_type")) && "Y".equals(pay_stepinfo.s("is_senior")) ){
		discPrice = payPrice * 20 / 100;
		payPrice = payPrice - discPrice;		
	}

	//이벤트행사(독지사 교재무료인 경우)
	if(pay_stepinfo.s("main_course_yn").equals("Y") && freebook_block) regPrice = 0;

	if("Y".equals(f.get("book_buy_yn"))) {
		payPrice = payPrice + regPrice;
	}
	
	order.item("discount_type", !"".equals(discountType) ? discountType : f.get("discount_type"));

	if("02".equals(f.get("sale_type")) && "Y".equals(pay_stepinfo.s("sale_yn")) && "Y".equals(pay_stepinfo.s("recommend_yn"))) {
		if("".equals(f.get("recomm_name"))) {
			m.jsAlert("추천인이름은 필수 사항입니다."); 
			coupon.rollbackCoupon(edupangCouponId);
			return;
		}
		if("".equals(f.get("recomm_course"))) {
			m.jsAlert("추천인 수강과정정보는 필수 사항입니다.");
			coupon.rollbackCoupon(edupangCouponId);
			return;
		}
		if("".equals(f.get("recomm_step"))) {
			m.jsAlert("추천인기수는 필수 사항입니다.");
			coupon.rollbackCoupon(edupangCouponId);
			return;
		}

		order.item("recomm_name", f.get("recomm_name"));
		order.item("recomm_step", f.get("recomm_step"));
		order.item("recomm_course", f.get("recomm_course"));
		order.item("recomm_phone", f.get("recomm_phone"));
//		order.item("recomm_addr", f.get("recomm_addr"));
		//추천인 확인완료 시 20% 자동할인
		/*
		if("Y".equals(f.get("recomm_dc_yn"))) {
			discPrice = payPrice * 20 / 100;
			payPrice = payPrice - discPrice;		
		}
		*/
	}

	if(f.get("paymethod").equals("9901") && "Y".equals(pay_stepinfo.s("main_course_yn")) && "N".equals(pay_stepinfo.s("offline_yn"))) { //독지사 온라인인 경우 평생교육바우처를 선택하면 35만원 고정
		payPrice = 350000;
	}

	if(iskangseo || issungdong) { //위탁과정은 임시로 1로 설정_바로 승인 막기
		payPrice = 1;
	}

	order.item("price", payPrice);
	order.item("disc_price", discPrice);
	order.item("coupon_price", couponPrice);
	order.item("pay_price", 0);
	order.item("paymethod", f.get("paymethod"));
	order.item("pay_date", payPrice <= 0 ? m.time("yyyyMMddHHmmss") : "");
	order.item("refund_price", 0);
	order.item("refund_date", "");
	order.item("refund_note", "");
	order.item("ord_name", uinfo.s("name"));
	order.item("ord_reci", "");
	order.item("ord_zipcode", "");
	order.item("ord_address1", "");
	order.item("ord_address2", "");
	order.item("ord_email", "");
	order.item("ord_phone", "");
	order.item("ord_mobile", "");
	order.item("ord_memo", "");
	order.item("reg_date", m.time("yyyyMMddHHmmss"));
	order.item("status", "Y".equals(pay_stepinfo.s("apply_approve_yn")) && payPrice <= 0 ? 1 : 0);
	if(isbosu3 == true && isbosu3_16times == true) order.item("status", payPrice <= 0 ? 1 : 0);
	order.item("event_course", event_course);
	order.item("prevstudy_yn", prevstudy_dcbook == true ? "Y" : "");

	if(!order.insert()) {
		m.jsAlert("등록하는 중 오류가 발생했습니다.");
		return;
	}

	oi.item("order_id", oid);
	oi.item("price", payPrice);
	oi.item("disc_price", discPrice);
	oi.item("coupon_price", couponPrice);
	oi.item("pay_price", 0);
	oi.item("free_yn", payPrice <= 0 ? "Y" : "N");
	oi.item("status", payPrice <= 0 && "Y".equals(pay_stepinfo.s("apply_approve_yn")) ? 1 : 10);
	if(isbosu3 == true && isbosu3_16times == true) oi.item("status", payPrice <= 0 ? 1 : 10);

	if(!oi.update("user_id = '" + userId + "' AND product_id = '" + pay_stepinfo.s("id") + "' AND order_id = 'cart' AND status = 10")) {
		m.jsAlert("결제정보를 등록하는 중 오류가 발생했습니다.2");
		coupon.rollbackCoupon(edupangCouponId);
		return;
	}

	DataSet oinfo = oi.find("user_id = '" + userId + "' AND product_id = '" + pay_stepinfo.s("id") + "' AND order_id = '" + oid + "'");
	if(!oinfo.next()) {
		m.jsAlert("결제정보가 없습니다.1");
		coupon.rollbackCoupon(edupangCouponId);
		return;
	}

	int newId = cu.getSequence();

	cu.item("id", newId);
	cu.item("step_id", pay_stepinfo.s("id"));
	cu.item("course_id", pay_stepinfo.s("course_id"));
	cu.item("user_id", userId);
	cu.item("order_id", oid);
	cu.item("item_id", oinfo.i("id"));
	cu.item("class", (cu.findCount("step_id = '" + pay_stepinfo.s("id") + "' AND course_id = '" + pay_stepinfo.s("course_id") + "' AND status = 1") / 100) + 1);
	if(isoneliter == true) cu.item("center_name",pay_stepinfo.s("enter_center_name"));
	else cu.item("center_name", f.get("user_center_name"));
	if(payPrice > 0) {
		cu.item("start_date", f.getInt("schid") > 0 ? pay_stepinfo.s("sch_study_sdate") : pay_stepinfo.s("study_sdate"));
		cu.item("end_date", f.getInt("schid") > 0 ? pay_stepinfo.s("sch_study_edate") : pay_stepinfo.s("study_edate"));
	} else {
		if("20991231".equals(pay_stepinfo.s("study_edate"))) {
			cu.item("start_date", m.time("yyyyMMdd"));
			cu.item("end_date", m.time("yyyyMMdd", m.addDate("D", pay_stepinfo.i("lesson_day") - 1, m.strToDate(m.time("yyyyMMdd")))));
		} else {
			if("Y".equals(pay_stepinfo.s("main_course_yn")) && "Y".equals(pay_stepinfo.s("offline_yn"))) {
				cu.item("start_date", f.getInt("schid") > 0 ? pay_stepinfo.s("sch_study_sdate") : pay_stepinfo.s("study_sdate"));
			} else {
				if(pay_stepinfo.s("course_id").equals("CRS00100138") || pay_stepinfo.s("course_id").equals("CRS00100039")) {
					cu.item("start_date", pay_stepinfo.s("study_sdate"));
				} else {
					cu.item("start_date", m.time("yyyyMMdd"));
				}
			}
			cu.item("end_date", f.getInt("schid") > 0 ? pay_stepinfo.s("sch_study_edate") : pay_stepinfo.s("study_edate"));
		}
	}
	cu.item("credit", pay_stepinfo.i("credit"));
	cu.item("attend_ratio", 0);
	cu.item("progress_ratio", 0);
	cu.item("progress_score", 0);
	cu.item("exam_score", 0);
	cu.item("homework_score", 0);
	cu.item("forum_score", 0);
	cu.item("etc_score", 0);
	cu.item("total_score", 0);
	cu.item("complete_yn", "N");
	cu.item("complete_no", "");
	cu.item("end_yn", "N");
	cu.item("edate", "");
	cu.item("end_user", "");
	cu.item("conn_date", "");
	cu.item("conn_ip", "");
	cu.item("change_date", "");
	cu.item("schedule_id", f.getInt("schid"));
	cu.item("reg_date", m.time("yyyyMMddHHmmss"));
	cu.item("status", payPrice <= 0 && "Y".equals(pay_stepinfo.s("apply_approve_yn")) ? 1 : 4);
	if(isbosu3 == true && isbosu3_16times == true) cu.item("status", payPrice <= 0 ? 1 : 4);
	cu.item("agree_yn", f.get("agree_yn"));
	if(f.get("paymethod").equals("9901")) cu.item("voucher_yn", "Y");
	if(f.get("paymethod").equals("7701")) cu.item("event", "KBS_COUPON");

	if("Y".equals(pay_stepinfo.s("insurance_yn")) && !"".equals(f.get("jumin1"))) {
		cu.item("jumin_no", f.get("jumin1") + "-" + f.get("jumin2"));
		cu.item("mobile_no", f.get("in_phone1") + "-" + f.get("in_phone2") + "-" + f.get("in_phone3"));
	}
	cu.item("event", event_info);

	if(!cu.insert()) {
		m.jsAlert("수강등록중 오류가 발생했습니다.11");
		coupon.rollbackCoupon(edupangCouponId);
		oi.itemRollback(oinfo.i("id"));
		return;
	}

	//서비스 과정 등록
	if("Y".equals(pay_stepinfo.s("main_course_yn")) && payPrice <= 0 && "Y".equals(pay_stepinfo.s("apply_approve_yn"))) {

		DataSet selist = null;
		if("Y".equals(pay_stepinfo.s("offline_yn")) && iskangseo == false && issungdong == false) {
			selist = course.find("sub_course_yn = 'Y' AND status = 1 AND (sub_offline_yn IS NULL OR sub_offline_yn = 'Y') ");	
		} else {
			selist = course.find("sub_course_yn = 'Y' AND status = 1 AND (sub_offline_yn IS NULL OR sub_offline_yn = 'N') ");
		}

		while(selist.next()) {

			DataSet tmpStep = step.query(
				"SELECT a.*"
				+ ", etc.*"
				+ " FROM " + step.table + " a "
				+ " INNER JOIN " + etc.table + " etc ON a.id = etc.step_id "
				+ " WHERE a.course_id = '" + selist.s("id") + "' AND a.status = 1 "
				+ " ORDER BY a.id DESC"
			, 1);

			if(tmpStep.next()) {
				cu.item("id", cu.getSequence());
				cu.item("step_id", tmpStep.s("id"));
				cu.item("course_id", tmpStep.s("course_id"));
				cu.item("user_id", userId);
				cu.item("order_id", oid);
				cu.item("item_id", 0);
				cu.item("class", "1");
				if("20991231".equals(tmpStep.s("study_edate"))) {
					if(tmpStep.s("course_id").equals("CRS00100074")) {
						cu.item("start_date", m.time("yyyyMMdd", m.addDate("D", 1, m.strToDate(pay_stepinfo.s("study_edate")))));
						cu.item("end_date", m.time("yyyyMMdd", m.addDate("D", tmpStep.i("restudy_day"), m.strToDate(pay_stepinfo.s("study_edate")))));
					} else {
						if(!"".equals(f.get("edupang_coupon")) || !"".equals(f.get("gshome_coupon")) || !"".equals(f.get("kbs_coupon"))) {
							cu.item("start_date", pay_stepinfo.s("study_sdate"));
							cu.item("end_date", pay_stepinfo.s("study_edate"));
						} else {
							cu.item("start_date", m.time("yyyyMMdd"));
							cu.item("end_date", m.time("yyyyMMdd", m.addDate("D", tmpStep.i("lesson_day") - 1, m.strToDate(m.time("yyyyMMdd")))));
						}
					}
				} else {
					cu.item("start_date", tmpStep.s("study_sdate"));
					cu.item("end_date", tmpStep.s("study_edate"));
				}
				cu.item("credit", tmpStep.i("credit"));
				cu.item("attend_ratio", 0);
				cu.item("progress_ratio", 0);
				cu.item("progress_score", 0);
				cu.item("exam_score", 0);
				cu.item("homework_score", 0);
				cu.item("forum_score", 0);
				cu.item("etc_score", 0);
				cu.item("total_score", 0);
				cu.item("complete_yn", "N");
				cu.item("complete_no", "");
				cu.item("end_yn", "N");
				cu.item("edate", "");
				cu.item("end_user", "");
				cu.item("conn_date", "");
				cu.item("conn_ip", "");
				cu.item("change_date", "");
				cu.item("schedule_id", 0);
				cu.item("reg_date", m.time("yyyyMMddHHmmss"));
				cu.item("status", 1);
				if(!cu.insert()) { }
			}
		}

	}

	//자격증 등록
	DataSet licenses = cr.query(
		"SELECT c.id"
		+ " FROM " + cr.table + " a "
		+ " INNER JOIN " + license.table + " b ON a.module_id = b.id AND b.status = 1"
		+ " INNER JOIN " + licenseUser.table + " c ON b.id = c.license_id AND c.user_id = '" + userId + "' AND c.status = 1"
		+ " WHERE a.module = 'LICENSE' AND a.step_id = '" + pay_stepinfo.s("id") + "'"
	);
	while(licenses.next()) {
		cul.item("course_user_id", newId);
		cul.item("license_user_id", licenses.i("id"));
		if(!cul.insert()) { }
	}

	if(isbosu3 == true && isbosu3_16times == false) {
		m.jsAlert("무료보수교육 대상자가 아닙니다. 유료 보수교육 16시간 이상 수강자에 한해 자동승인처리됩니다. ");
		m.jsReplace("waiting_list.jsp?" + m.qs("id, type, ctype, schid, cnf"), "parent");
	} else if(payPrice <= 0) {
		if(isbosu3 == true && isbosu3_16times == true) {
			m.jsAlert("무료보수교육 대상자로 확인되어 수강 승인되었습니다. ");
		} else if(iskangseo == true || issungdong == true) {
			m.jsAlert("수강 신청되었습니다. ");
		} else {
			m.jsAlert("수강 승인되었습니다. ");
		}
		if("Y".equals(pay_stepinfo.s("main_course_yn")) && iskangseo == false && issungdong == false) {
			if(!"".equals(uinfo.s("mobile"))) biz.insertATReMessage("", "", "", "", uinfo.s("mobile"), "02-6276-2626", "안녕하세요, " + uinfo.s("name") + "님\r\n" + pay_stepinfo.s("name_conv") + " 결제가 완료되어 학습이 가능합니다.\r\n\r\n▶ 학습방법 : 내 강의실 > 학습하기 공지 확인 후 학습 \r\n▶ 문의 : 프로필 클릭 > 전화 · 채팅 상담", "bizp_2018091116055163425796338", "", "but_link9.json"); //알림톡대체
		}
		m.jsReplace("index.jsp?" + m.qs("id, type, ctype, schid, cnf"), "parent");
	} else {
		if("CRS00100131".equals(pay_stepinfo.s("course_id")) || "08".equals(f.get("sale_type"))) {
			m.jsAlert("수강신청이 완료되었습니다. \\n활동 서약서가 확인되면 수강료 할인 후 문자를 드립니다. ");
		} else {
			if(isjehucourse == true) {
				m.jsAlert("수강신청이 완료되었습니다. 담당자가 익일 내로 안내전화 드리도록 하겠습니다.\\n문의사항 02-6276-2614 ");
			} else {
				m.jsAlert("수강신청이 완료되었습니다. ");
			}
		}
		if(pay_stepinfo.s("id").equals("CRS000000530267")) { //영진전문대 별도 문자발송
			//sms.send(!"".equals(uinfo.s("mobile")) ? uinfo.s("mobile") : "", "02-6276-2626", "[독서지도사 영진대]\r\n해당교육장은 전화접수 하셔야합니다.^^\r\n영진대평생교육원: 053-940-5182");
		}

		//교사소개이벤트 신청시 별도 알림톡 발송
		if("05".equals(f.get("sale_type"))) {
			//if(!"".equals(uinfo.s("mobile"))) biz.insertATReMessage("", "", "", "", uinfo.s("mobile"), "02-6276-2626", uinfo.s("name") + "님 안녕하세요.\r\n\r\n독서지도사 양성과정 <교사소개이벤트>를 신청하셨습니다.\r\n\r\n추천자를 통하여 추천서를 제출하시고 혜택을 적용받으시기 바랍니다. \r\n\r\n본 채팅창에 문의 주시면 채팅상담 가능합니다.\r\n\r\n감사합니다.", "waiting_t_event_210112", "", "but_link20.json"); //알림톡대체
		}

		m.jsReplace("../mypage/order.jsp?id=" + f.get("step_id") + "&" + m.qs("id, type, ctype, schid, cnf"), "parent");
	}

	return;
}

//출력
p.setLayout(ch);
p.setBody("course.course_view");
p.setVar("p_title", "과정상세");
p.setVar("lnb_02_block", true);
p.setVar("lnb_02", "on");
p.setVar("lnb_sub_02", "on");
p.setVar("lnb_pc_sub_22", "on");
p.setVar("list_query", m.qs("id, page"));
p.setVar("query", m.qs());
p.setVar("form_script", f.getScript());
p.setVar(info);
//p.setVar("pay_stepinfo", pay_stepinfo);
p.setVar("on_stepid", on_step_id);
p.setLoop("steps", steplist);
//p.setLoop("tutors", tutors);
//p.setLoop("list", cls);
p.setLoop("schedule_list", schedules);
//p.setLoop("epilogue", epilogue);
p.setVar("returl_block", !"".equals(m.rs("returl")));
p.setVar("blended_block", info.s("course_id").equals("CRS00100051"));
p.setVar("recommend_block", "Y".equals(info.s("recommend_yn")) && !"05".equals(info.s("type")) && !"CRS00100131".equals(info.s("id"))); //추천가능한과정
p.setVar("restudy_block", "Y".equals(info.s("is_retake")) && !"05".equals(info.s("type")) && !"CRS00100131".equals(info.s("id"))); //재수강여부
p.setVar("read_complete_block", read_complete_block);
p.setVar("eplall_block", eplcnt == 100);
p.setLoop("sub_category_list", m.arr2loop(course.subcategoryList));
p.setVar("returl", m.urlencode(request.getRequestURI() + "?" + m.getQueryString()));
p.display();

%>