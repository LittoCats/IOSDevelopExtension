# 1900-2100区间内的公历、农历互转
# charset  UTF-8
# Auth 程巍巍
# 公历转农历：calendar.solar2lunar 1987,11,01

# 农历1900-2100的润大小信息表
LunarInfo = [
	0x04bd8,0x04ae0,0x0a570,0x054d5,0x0d260,0x0d950,0x16554,0x056a0,0x09ad0,0x055d2,
	0x04ae0,0x0a5b6,0x0a4d0,0x0d250,0x1d255,0x0b540,0x0d6a0,0x0ada2,0x095b0,0x14977,
	0x04970,0x0a4b0,0x0b4b5,0x06a50,0x06d40,0x1ab54,0x02b60,0x09570,0x052f2,0x04970,
	0x06566,0x0d4a0,0x0ea50,0x06e95,0x05ad0,0x02b60,0x186e3,0x092e0,0x1c8d7,0x0c950,
	0x0d4a0,0x1d8a6,0x0b550,0x056a0,0x1a5b4,0x025d0,0x092d0,0x0d2b2,0x0a950,0x0b557,
	0x06ca0,0x0b550,0x15355,0x04da0,0x0a5b0,0x14573,0x052b0,0x0a9a8,0x0e950,0x06aa0,
	0x0aea6,0x0ab50,0x04b60,0x0aae4,0x0a570,0x05260,0x0f263,0x0d950,0x05b57,0x056a0,
	0x096d0,0x04dd5,0x04ad0,0x0a4d0,0x0d4d4,0x0d250,0x0d558,0x0b540,0x0b6a0,0x195a6,
	0x095b0,0x049b0,0x0a974,0x0a4b0,0x0b27a,0x06a50,0x06d40,0x0af46,0x0ab60,0x09570,
	0x04af5,0x04970,0x064b0,0x074a3,0x0ea50,0x06b58,0x055c0,0x0ab60,0x096d5,0x092e0,
	0x0c960,0x0d954,0x0d4a0,0x0da50,0x07552,0x056a0,0x0abb7,0x025d0,0x092d0,0x0cab5,
	0x0a950,0x0b4a0,0x0baa4,0x0ad50,0x055d9,0x04ba0,0x0a5b0,0x15176,0x052b0,0x0a930,
	0x07954,0x06aa0,0x0ad50,0x05b52,0x04b60,0x0a6e6,0x0a4e0,0x0d260,0x0ea65,0x0d530,
	0x05aa0,0x076a3,0x096d0,0x04bd7,0x04ad0,0x0a4d0,0x1d0b6,0x0d250,0x0d520,0x0dd45,
	0x0b5a0,0x056d0,0x055b2,0x049b0,0x0a577,0x0a4b0,0x0aa50,0x1b255,0x06d20,0x0ada0,
	0x14b63,0x09370,0x049f8,0x04970,0x064b0,0x168a6,0x0ea50,0x06b20,0x1a6c4,0x0aae0,
	0x0a2e0,0x0d2e3,0x0c960,0x0d557,0x0d4a0,0x0da50,0x05d55,0x056a0,0x0a6d0,0x055d4,
	0x052d0,0x0a9b8,0x0a950,0x0b4a0,0x0b6a6,0x0ad50,0x055a0,0x0aba4,0x0a5b0,0x052b0,
	0x0b273,0x06930,0x07337,0x06aa0,0x0ad50,0x14b55,0x04b60,0x0a570,0x054e4,0x0d160,
	0x0e968,0x0d520,0x0daa0,0x16aa6,0x056d0,0x04ae0,0x0a9d4,0x0a2d0,0x0d150,0x0f252,
	0x0d520
]

# 公历每个月份的天数普通表
SolarMonth = [31,28,31,30,31,30,31,31,30,31,30,31]

# 天干地支之天干速查表
Gan = ['甲','乙','丙','丁','戊','己','庚','辛','壬','癸']

# 天干地支之地支速查表
Zhi = ['子','丑','寅','卯','辰','巳','午','未','申','酉','戌','亥']

# 天干地支之地支速查表<=>生肖
Animals = ['鼠','牛','虎','兔','龙','蛇','马','羊','猴','鸡','狗','猪']
	
# 24节气速查表
SolarTerm = ['小寒','大寒','立春','雨水','惊蛰','春分','清明','谷雨','立夏','小满','芒种','夏至','小暑','大暑','立秋','处暑','白露','秋分','寒露','霜降','立冬','小雪','大雪','冬至']

# 十二星座速查表
AstronomyInfo = [
	{1223:'摩羯座'}
	{121:'水瓶座'}
	{220:'双鱼座'}
	{321:'牡羊座'}
	{421:'金牛座'}
	{522:'双子座'}
	{622:'巨蟹座'}
	{724:'狮子座'}
	{824:'处女座'}
	{924:'天秤座'}
	{1024:'天蝎座'}
	{1123:'射手座'}
	{1223:'摩羯座'}
]

# 1900-2100各年的24节气日期速查表
sTermInfo = [	
	'9778397bd097c36b0b6fc9274c91aa','97b6b97bd19801ec9210c965cc920e','97bcf97c3598082c95f8c965cc920f',
	'97bd0b06bdb0722c965ce1cfcc920f','b027097bd097c36b0b6fc9274c91aa','97b6b97bd19801ec9210c965cc920e',
	'97bcf97c359801ec95f8c965cc920f','97bd0b06bdb0722c965ce1cfcc920f','b027097bd097c36b0b6fc9274c91aa',
	'97b6b97bd19801ec9210c965cc920e','97bcf97c359801ec95f8c965cc920f','97bd0b06bdb0722c965ce1cfcc920f',
	'b027097bd097c36b0b6fc9274c91aa','9778397bd19801ec9210c965cc920e','97b6b97bd19801ec95f8c965cc920f',
	'97bd09801d98082c95f8e1cfcc920f','97bd097bd097c36b0b6fc9210c8dc2','9778397bd197c36c9210c9274c91aa',
	'97b6b97bd19801ec95f8c965cc920e','97bd09801d98082c95f8e1cfcc920f','97bd097bd097c36b0b6fc9210c8dc2',
	'9778397bd097c36c9210c9274c91aa','97b6b97bd19801ec95f8c965cc920e','97bcf97c3598082c95f8e1cfcc920f',
	'97bd097bd097c36b0b6fc9210c8dc2','9778397bd097c36c9210c9274c91aa','97b6b97bd19801ec9210c965cc920e',
	'97bcf97c3598082c95f8c965cc920f','97bd097bd097c35b0b6fc920fb0722','9778397bd097c36b0b6fc9274c91aa',
	'97b6b97bd19801ec9210c965cc920e','97bcf97c3598082c95f8c965cc920f','97bd097bd097c35b0b6fc920fb0722',
	'9778397bd097c36b0b6fc9274c91aa','97b6b97bd19801ec9210c965cc920e','97bcf97c359801ec95f8c965cc920f',
	'97bd097bd097c35b0b6fc920fb0722','9778397bd097c36b0b6fc9274c91aa','97b6b97bd19801ec9210c965cc920e',
	'97bcf97c359801ec95f8c965cc920f','97bd097bd097c35b0b6fc920fb0722','9778397bd097c36b0b6fc9274c91aa',
	'97b6b97bd19801ec9210c965cc920e','97bcf97c359801ec95f8c965cc920f','97bd097bd07f595b0b6fc920fb0722',
	'9778397bd097c36b0b6fc9210c8dc2','9778397bd19801ec9210c9274c920e','97b6b97bd19801ec95f8c965cc920f',
	'97bd07f5307f595b0b0bc920fb0722','7f0e397bd097c36b0b6fc9210c8dc2','9778397bd097c36c9210c9274c920e',
	'97b6b97bd19801ec95f8c965cc920f','97bd07f5307f595b0b0bc920fb0722','7f0e397bd097c36b0b6fc9210c8dc2',
	'9778397bd097c36c9210c9274c91aa','97b6b97bd19801ec9210c965cc920e','97bd07f1487f595b0b0bc920fb0722',
	'7f0e397bd097c36b0b6fc9210c8dc2','9778397bd097c36b0b6fc9274c91aa','97b6b97bd19801ec9210c965cc920e',
	'97bcf7f1487f595b0b0bb0b6fb0722','7f0e397bd097c35b0b6fc920fb0722','9778397bd097c36b0b6fc9274c91aa',
	'97b6b97bd19801ec9210c965cc920e','97bcf7f1487f595b0b0bb0b6fb0722','7f0e397bd097c35b0b6fc920fb0722',
	'9778397bd097c36b0b6fc9274c91aa','97b6b97bd19801ec9210c965cc920e','97bcf7f1487f531b0b0bb0b6fb0722',
	'7f0e397bd097c35b0b6fc920fb0722','9778397bd097c36b0b6fc9274c91aa','97b6b97bd19801ec9210c965cc920e',
	'97bcf7f1487f531b0b0bb0b6fb0722','7f0e397bd07f595b0b6fc920fb0722','9778397bd097c36b0b6fc9274c91aa',
	'97b6b97bd19801ec9210c9274c920e','97bcf7f0e47f531b0b0bb0b6fb0722','7f0e397bd07f595b0b0bc920fb0722',
	'9778397bd097c36b0b6fc9210c91aa','97b6b97bd197c36c9210c9274c920e','97bcf7f0e47f531b0b0bb0b6fb0722',
	'7f0e397bd07f595b0b0bc920fb0722','9778397bd097c36b0b6fc9210c8dc2','9778397bd097c36c9210c9274c920e',
	'97b6b7f0e47f531b0723b0b6fb0722','7f0e37f5307f595b0b0bc920fb0722','7f0e397bd097c36b0b6fc9210c8dc2',
	'9778397bd097c36b0b70c9274c91aa','97b6b7f0e47f531b0723b0b6fb0721','7f0e37f1487f595b0b0bb0b6fb0722',
	'7f0e397bd097c35b0b6fc9210c8dc2','9778397bd097c36b0b6fc9274c91aa','97b6b7f0e47f531b0723b0b6fb0721',
	'7f0e27f1487f595b0b0bb0b6fb0722','7f0e397bd097c35b0b6fc920fb0722','9778397bd097c36b0b6fc9274c91aa',
	'97b6b7f0e47f531b0723b0b6fb0721','7f0e27f1487f531b0b0bb0b6fb0722','7f0e397bd097c35b0b6fc920fb0722',
	'9778397bd097c36b0b6fc9274c91aa','97b6b7f0e47f531b0723b0b6fb0721','7f0e27f1487f531b0b0bb0b6fb0722',
	'7f0e397bd097c35b0b6fc920fb0722','9778397bd097c36b0b6fc9274c91aa','97b6b7f0e47f531b0723b0b6fb0721',
	'7f0e27f1487f531b0b0bb0b6fb0722','7f0e397bd07f595b0b0bc920fb0722','9778397bd097c36b0b6fc9274c91aa',
	'97b6b7f0e47f531b0723b0787b0721','7f0e27f0e47f531b0b0bb0b6fb0722','7f0e397bd07f595b0b0bc920fb0722',
	'9778397bd097c36b0b6fc9210c91aa','97b6b7f0e47f149b0723b0787b0721','7f0e27f0e47f531b0723b0b6fb0722',
	'7f0e397bd07f595b0b0bc920fb0722','9778397bd097c36b0b6fc9210c8dc2','977837f0e37f149b0723b0787b0721',
	'7f07e7f0e47f531b0723b0b6fb0722','7f0e37f5307f595b0b0bc920fb0722','7f0e397bd097c35b0b6fc9210c8dc2',
	'977837f0e37f14998082b0787b0721','7f07e7f0e47f531b0723b0b6fb0721','7f0e37f1487f595b0b0bb0b6fb0722',
	'7f0e397bd097c35b0b6fc9210c8dc2','977837f0e37f14998082b0787b06bd','7f07e7f0e47f531b0723b0b6fb0721',
	'7f0e27f1487f531b0b0bb0b6fb0722','7f0e397bd097c35b0b6fc920fb0722','977837f0e37f14998082b0787b06bd',
	'7f07e7f0e47f531b0723b0b6fb0721','7f0e27f1487f531b0b0bb0b6fb0722','7f0e397bd097c35b0b6fc920fb0722',
	'977837f0e37f14998082b0787b06bd','7f07e7f0e47f531b0723b0b6fb0721','7f0e27f1487f531b0b0bb0b6fb0722',
	'7f0e397bd07f595b0b0bc920fb0722','977837f0e37f14998082b0787b06bd','7f07e7f0e47f531b0723b0b6fb0721',
	'7f0e27f1487f531b0b0bb0b6fb0722','7f0e397bd07f595b0b0bc920fb0722','977837f0e37f14998082b0787b06bd',
	'7f07e7f0e47f149b0723b0787b0721','7f0e27f0e47f531b0b0bb0b6fb0722','7f0e397bd07f595b0b0bc920fb0722',
	'977837f0e37f14998082b0723b06bd','7f07e7f0e37f149b0723b0787b0721','7f0e27f0e47f531b0723b0b6fb0722',
	'7f0e397bd07f595b0b0bc920fb0722','977837f0e37f14898082b0723b02d5','7ec967f0e37f14998082b0787b0721',
	'7f07e7f0e47f531b0723b0b6fb0722','7f0e37f1487f595b0b0bb0b6fb0722','7f0e37f0e37f14898082b0723b02d5',
	'7ec967f0e37f14998082b0787b0721','7f07e7f0e47f531b0723b0b6fb0722','7f0e37f1487f531b0b0bb0b6fb0722',
	'7f0e37f0e37f14898082b0723b02d5','7ec967f0e37f14998082b0787b06bd','7f07e7f0e47f531b0723b0b6fb0721',
	'7f0e37f1487f531b0b0bb0b6fb0722','7f0e37f0e37f14898082b072297c35','7ec967f0e37f14998082b0787b06bd',
	'7f07e7f0e47f531b0723b0b6fb0721','7f0e27f1487f531b0b0bb0b6fb0722','7f0e37f0e37f14898082b072297c35',
	'7ec967f0e37f14998082b0787b06bd','7f07e7f0e47f531b0723b0b6fb0721','7f0e27f1487f531b0b0bb0b6fb0722',
	'7f0e37f0e366aa89801eb072297c35','7ec967f0e37f14998082b0787b06bd','7f07e7f0e47f149b0723b0787b0721',
	'7f0e27f1487f531b0b0bb0b6fb0722','7f0e37f0e366aa89801eb072297c35','7ec967f0e37f14998082b0723b06bd',
	'7f07e7f0e47f149b0723b0787b0721','7f0e27f0e47f531b0723b0b6fb0722','7f0e37f0e366aa89801eb072297c35',
	'7ec967f0e37f14998082b0723b06bd','7f07e7f0e37f14998083b0787b0721','7f0e27f0e47f531b0723b0b6fb0722',
	'7f0e37f0e366aa89801eb072297c35','7ec967f0e37f14898082b0723b02d5','7f07e7f0e37f14998082b0787b0721',
	'7f07e7f0e47f531b0723b0b6fb0722','7f0e36665b66aa89801e9808297c35','665f67f0e37f14898082b0723b02d5',
	'7ec967f0e37f14998082b0787b0721','7f07e7f0e47f531b0723b0b6fb0722','7f0e36665b66a449801e9808297c35',
	'665f67f0e37f14898082b0723b02d5','7ec967f0e37f14998082b0787b06bd','7f07e7f0e47f531b0723b0b6fb0721',
	'7f0e36665b66a449801e9808297c35','665f67f0e37f14898082b072297c35','7ec967f0e37f14998082b0787b06bd',
	'7f07e7f0e47f531b0723b0b6fb0721','7f0e26665b66a449801e9808297c35','665f67f0e37f1489801eb072297c35',
	'7ec967f0e37f14998082b0787b06bd','7f07e7f0e47f531b0723b0b6fb0721','7f0e27f1487f531b0b0bb0b6fb0722'
]
	
# 数字转中文速查表	
nStr1 = ['〇','一','二','三','四','五','六','七','八','九','十']
	
# 日期转农历称呼速查表
nStr2 = ['初','十','廿','卅']

# 月份转农历称呼速查表
nStr3 = ['正','二','三','四','五','六','七','八','九','十','冬','腊']

	
# 返回农历y年闰月是哪个月；若y年没有闰月 则返回0
# param lunar Year
# return Number (0-12)
leapMonth = (y)-> LunarInfo[y-1900] & 0xf


# 返回农历y年闰月的天数 若该年没有闰月则返回0
# param lunar Year
# return Number (0、29、30)
leapMonthDays = (y)-> 
	if leapMonth y 
		return if LunarInfo[y-1900] & 0x10000 then 30 else 29
	0

# 返回农历y年一整年的总天数
# param lunar Year
# return Number
lunarYearDays = (y)->
	sum = 348;
	i = 0x8000
	while i > 0x8
		sum += 1 if (LunarInfo[y-1900] & i) 
		i >>= 1
	sum + leapMonthDays y
	
	
# 返回农历y年m月（非闰月）的总天数，计算m为闰月时的天数请使用leapMonthDays方法
# param lunar Year
# return Number (-1、29、30)
lunarMonthDays = (y,m)->
	return -1 if m > 12 or m < 1 #月份参数从1至12，参数错误返回-1
	return if LunarInfo[y-1900] & (0x10000>>m) then 30 else 29
	
	
# 返回公历(!)y年m月的天数
# param solar Year
# return Number (-1、28、29、30、31)
solarDays = (y,m)->
	return -1 if m>12 or m<1 #若参数错误 返回-1
	ms = m-1;
	return SolarMonth[ms] if ms isnt 1 
	return if (y%4 is 0) && (y%100 isnt 0) or (y%400 is 0) then 29 else 28   #2月份的闰平规律测算后确认返回28或29
	

# 传入offset偏移量返回干支
# param offset 相对甲子的偏移量
# return 中文
toGanZhi = (offset)-> Gan[offset%10] + Zhi[offset%12]
	

# 公历(!)y年获得该年第n个节气的公历日期
# param y公历年(1900-2100)；n二十四节气中的第几个节气(1~24)；从n=1(小寒)算起 
# return day Number
getSolarTerm = (y,n)->
	return -1 if y < 1900 or y > 2100 or n < 1 or n > 24
	n -= 1
	_table = sTermInfo[y-1900]
	_info = parseInt '0x'+_table.substr parseInt(n/4)*5,5
		.toString()
	parseInt _info.substr [0,1,3,4][n%4], [1,2][n%4%2]
	
# 传入农历数字年份返回汉语通俗表示法
# param lunar year
# return Cn string
# 若参数错误 返回 ""
toChinaYear = (y)->
	yStr = ''+y
	ret = ''
	ret += nStr1[parseInt yStr.substr i, 1] for i in [0...yStr.length]
	ret + '年'


# 传入农历数字月份返回汉语通俗表示法
# param lunar month
# return Cn string
# 若参数错误 返回 ""
toChinaMonth = (m)-> return if m>12 or m<1 then '' else nStr3[m-1] + '月'

# 传入农历日期数字返回汉字表示法
# param lunar day
# return Cn string
# return Cn string
# eg: cnDay = toChinaDay 21 #cnMonth='廿一'
toChinaDay = (d)-> nStr2[Math.floor(d/10)]+nStr1[d%10]	


# 年份转生肖[!仅能大致转换] => 精确划分生肖分界线是“立春”
# param y year
# return Cn string
getAnimal = (y)-> Animals[(y - 4) % 12]


# 根据生日计算十二星座
# param solar month 1 ~ 12
# param solar day
# return Cn string
getAstronomy = (m,d)->
	for key, value of AstronomyInfo[m]
		return value if m*100+d >= key
	return value for key, value of AstronomyInfo[m-1]
		

	
# 传入公历年月日获得详细的公历、农历object信息 <=>JSON
# param y  solar year
# param m solar month
# param d  solar day
# return JSON object
# 参数区间1900.1.31~2100.12.31
solar2lunar = (y,m,d)->
	return -1 if y < 1900 or y > 2100 	 #年份限定、上限
	return -1 if y is 1900 and m is 1 and d < 31 #下限
	objDate = new Date y,parseInt(m - 1),d
	leap = 0
	temp = 0
	# 修正ymd参数
	y = objDate.getFullYear()
	m = objDate.getMonth()+1
	d = objDate.getDate()
	offset = (Date.UTC(y,m - 1,d) - Date.UTC(1900,0,31))/86400000

	for i in [1900...2100]
		break	if offset <= 0
		temp = lunarYearDays i
		offset -= temp
	
	if offset<0 then offset += temp; i--
	
	# 是否今天
	isTodayObj = new Date()
	isToday = isTodayObj.getFullYear()==y && isTodayObj.getMonth()+1==m && isTodayObj.getDate()==d

	# 星期几
	nWeek = objDate.getDay()
	cWeek = nStr1[nWeek]
	nWeek = 7 if nWeek is 0 #数字表示周几顺应天朝周一开始的惯例

	# 农历年
	year = i
	
	# 闰哪个月
	leap = leapMonth i
	isLeap = false;

	# 效验闰月
	for i in [1...12]
		break if offset <= 0
		# 闰月
		if leap>0 && i==(leap+1) && isLeap==false
			--i;
			isLeap = true; temp = leapMonthDays year #计算农历闰月天数
		else
			temp = lunarMonthDays year, i #计算农历普通月天数
		# 解除闰月
		isLeap = false if isLeap is true && i is leap+1
		offset -= temp;

	if(offset==0 && leap>0 && i==leap+1)
		if isLeap then isLeap = false else isLeap = true; --i;
		
	if offset < 0 then offset += temp; --i

	# 农历月
	month 	= i
	# 农历日
	day = offset + 1

	# 天干地支处理
	sm = m-1
	term3	=	getSolarTerm year,3 #该农历年立春日期
	gzY = toGanZhi year-4 	#普通按年份计算，下方尚需按立春节气来修正
	
	# 依据立春日进行修正gzY
	gzY = if sm<2 and d<term3 then toGanZhi year-5 else toGanZhi year-4
	
	# 月柱 1900年1月小寒以前为 丙子月(60进制12)
	firstNode = getSolarTerm y,m*2-1 	#返回当月「节」为几日开始
	secondNode = getSolarTerm y,m*2 	#返回当月「节」为几日开始

	# 依据12节气修正干支月
	gzM = if d<firstNode then toGanZhi (y-1900)*12+m+11 else toGanZhi (y-1900)*12+m+12

	# 传入的日期的节气与否
	isSolarTerm = false
	solarTerm = ''
	if firstNode is d
		isSolarTerm 	= true
		solarTerm = SolarTerm[m*2-2]
	if secondNode is d
		isSolarTerm = true
		solarTerm = SolarTerm[m*2-1]

	# 日柱 当月一日与 1900/1/1 相差天数
	dayCyclical = Date.UTC(y,sm,1,0,0,0,0)/86400000+25567+10
	gzD = toGanZhi dayCyclical+d-1
	
	return {
		'SolarYear':y
		'SolarMonth':m
		'SolarDay':d
		'Week':nWeek
		'LunarYear':year
		'LunarMonth':month
		'LunarDay':day
		'LunarYearCN': toChinaYear year
		'LunarMonthCN':(if isLeap then '闰' else '')+toChinaMonth month
		'LunarDayCN':toChinaDay day
		'GZYear':gzY
		'GZMonth':gzM
		'GZDay':gzD
		'AnimalCN':getAnimal year
		'AstronomyCN': getAstronomy m, d
		'SolarTermCN':solarTerm
		'WeekNameCN':'星期'+cWeek
		'isSolarTerm':isSolarTerm
		'isToday':isToday
		'isLeapMonth':isLeap
	}
		

# 传入公历年月日以及传入的月份是否闰月获得详细的公历、农历object信息 <=>JSON
# param y  lunar year
# param m lunar month
# param d  lunar day
# param isLeapMonth  lunar month is leap or not.
# return JSON object
# 参数区间1900.1.31~2100.12.1
lunar2solar = (y,m,d,isLeapMonth)->
	leapOffset = 0;
	leap_month = leapMonth y
	return -1 if isLeapMonth and leap_month isnt m #传参要求计算该闰月公历 但该年得出的闰月与传参的月份并不同
	return -1 if (y is 2100 and m is 12 and d > 1) or (y is 1900 and m is 1 and d < 31) #超出了最大极限值

	day = lunarMonthDays y,m
	return -1 if y < 1900 or y > 2100 or d > day #参数合法性效验
	
	# 计算农历的时间差
	offset = 0
	offset += lunarYearDays i for i in [1900...y]

	leap = 0
	isAdd= false
	for i in [1...m]
		leap = leapMonth y

		if !isAdd and (leap <= i and leap > 0) 
			offset += leapMonthDays y
			isAdd = true

		offset += lunarMonthDays y, i

	# 转换闰月农历 需补充该年闰月的前一个月的时差
	offset += day if isLeapMonth

	# 1900年农历正月一日的公历时间为1900年1月30日0时0分0秒(该时间也是本农历的最开始起始点)
	stmap = Date.UTC 1900,1,30,0,0,0
	calObj = new Date (offset+d-31)*86400000+stmap
	
	solar2lunar calObj.getUTCFullYear(),calObj.getUTCMonth()+1,calObj.getUTCDate()

@SuperCalendar = {
	lunar2solar: lunar2solar
	solar2lunar: solar2lunar
	leapMonth: leapMonth
	leapMonthDays: leapMonthDays
	lunarYearDays: lunarYearDays
	lunarMonthDays: lunarMonthDays
	solarDays: solarDays
	getSolarTerm: getSolarTerm
	getAnimal: getAnimal
	getAstronomy: getAstronomy
}

console.log  @SuperCalendar.lunar2solar 2015,2,1
# console.log lunarYearDays 2015
# lunar2solar 2015,1,27