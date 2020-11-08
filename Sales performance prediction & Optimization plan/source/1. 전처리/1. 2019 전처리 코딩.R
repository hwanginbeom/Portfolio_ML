
{
  if(!require(readxl)){install.packages("readxl"); library(readxl)}
  if(!require(dplyr)){install.packages("dplyr"); library(dplyr)}
  if(!require(ggplot2)){install.packages("ggplot2"); library(ggplot2)}
  if(!require(stringr)){install.packages("stringr"); library(stringr)}
  if(!require(tm)){install.packages("tm"); library(tm)}
  if(!require(lubridate)){install.packages("lubridate"); library(lubridate)}
  if(!require(rcompanion)){install.packages("rcompanion"); library(rcompanion)}
  if(!require(MASS)){install.packages("MASS"); library(MASS)}
  if(!require(reshape2)){install.packages("reshape2"); library(reshape2)}
} 


# 원본 train
rawdata <- read_xlsx('C:\\Users\\lan41\\Desktop\\최종 연습 제출\\NS홈쇼핑_원데이터.xlsx',skip=1)
train_rawdata <- rawdata[c(1:35154),]
test_rawdata <- rawdata[c(35155:38309),]
str(train_rawdata) #(38309,8)
str(test_rawdata) #(3155,8)


#### train과 test셋 합치기
rawdata <- as.data.frame(rbind(train_rawdata, test_rawdata)); str(rawdata)
d1 <- rawdata


#### train과 test셋 합쳐서 전처리

#### 원데이터 탐색으로 인한 변수 탐색 및 생성 

# 1. 노출(분)

# 노출(분) 결측치 16784개
table(is.na(d1$'노출(분)'))
# 노출(분) 결측치 처리
for (i in 2:nrow(d1)) {
  if (is.na(d1$`노출(분)`[i])) {
    d1$`노출(분)`[i] = d1$`노출(분)`[i-1]
  }
}
d1$`노출(분)` <- round(d1$`노출(분)`,3)


# 2. 방송일시

# 월, 일, 요일 변수 생성
d1$월 <- month(d1$방송일시)
d1$일 <- day(d1$방송일시)
d1$요일 <- weekdays(d1$방송일시)

# 상/하반기, 분기, 365일별, 53주차 단위 변수 생성
d1$반기 <- semester(d1$방송일시)
d1$분기 <- quarters(d1$방송일시)
d1$`365일` <- yday(d1$방송일시)
d1$`53주차` <- week(d1$방송일시)


# 날짜시간, 시간, 계절, 일주일을 168시간 변수 생성
방송일시_split <- strsplit(as.character(d1$방송일시),' ')
for (i in 1:nrow(d1)) {
  
  d1$시간[i] <- 방송일시_split[[i]][2]
  d1$시간hour[i] <- substr(d1$시간[i],1,2) 
  d1$날짜[i] <- str_replace_all(방송일시_split[[i]][1],'-','')
  d1$날짜시간[i] = str_c(d1$날짜[i],d1$시간hour[i])
  
  if (d1$월[i]==3 | d1$월[i]==4 | d1$월[i]==5) {
    d1$계절[i] <- '봄'
  } else if (d1$월[i]==6 | d1$월[i]==7 | d1$월[i]==8) {
    d1$계절[i] <- '여름'
  } else if (d1$월[i]==9 | d1$월[i]==10 | d1$월[i]==11) {
    d1$계절[i] <- '가을'
  } else {
    d1$계절[i] <- '겨울'
  }
  
  if (d1$요일[i]=='월요일') {
    d1$`168시간`[i] <- (0*24)+as.integer(d1$시간hour[i])+1
  } else if (d1$요일[i]=='화요일') {
    d1$`168시간`[i] <- (1*24)+as.integer(d1$시간hour[i])+1
  } else if(d1$요일[i]=='수요일') {
    d1$`168시간`[i] <- (2*24)+as.integer(d1$시간hour[i])+1
  } else if(d1$요일[i]=='목요일') {
    d1$`168시간`[i] <- (3*24)+as.integer(d1$시간hour[i])+1
  } else if(d1$요일[i]=='금요일') {
    d1$`168시간`[i] <- (4*24)+as.integer(d1$시간hour[i])+1
  } else if(d1$요일[i]=='토요일') {
    d1$`168시간`[i] <- (5*24)+as.integer(d1$시간hour[i])+1
  } else {
    d1$`168시간`[i] <- (6*24)+as.integer(d1$시간hour[i])+1
  }
  
}


# 휴일 변수 생성
species1 <- c('0101','0301','0505','0512','0606','0815','1003','1009','1225')
species2 <- c('1231','0228','0504','0511','0605','0814','1002','1008','1224')
for (i in 1:nrow(d1)) {
  if (d1$요일[i]=='토요일' | d1$요일[i] == '일요일' | substr(d1$날짜시간[i],5,8) %in% species1) {
    d1$휴일[i] <- 2
  } else if (d1$요일[i]=='금요일' | substr(d1$날짜시간[i],5,8) %in% species2) {
    d1$휴일[i] <- 1
  } else {
    d1$휴일[i] <- 0
  }
}


# 방송시간 변수 전처리, 매진 변수 생성
d2 <- d1
for (i in 1:nrow(d2)) {
  d2$방송시간[i] = round(difftime(d2$방송일시[i+1],d2$방송일시[i]),3)
}
for (i in (nrow(d2)-1):1) {
  if (d2$방송시간[i]==0) {
    d2$방송시간[i] = d2$방송시간[i+1]
  }
}
table(d2$방송시간) #15type

# 방송시간 이상치 처리
# 1) 방송시간 1:30:00~02:10:00 노출을 따르게한다
d2[d2$시간 == '01:30:00',]$방송시간 <- d2[d2$시간 == '01:30:00',]$'노출(분)'
d2[d2$시간 == '01:40:00',]$방송시간 <- d2[d2$시간 == '01:40:00',]$'노출(분)'
d2[d2$시간 == '01:50:00',]$방송시간 <- d2[d2$시간 == '01:50:00',]$'노출(분)'
d2[d2$시간 == '02:00:00',]$방송시간 <- d2[d2$시간 == '02:00:00',]$'노출(분)'
d2[d2$시간 == '02:10:00',]$방송시간 <- d2[d2$시간 == '02:10:00',]$'노출(분)'
# 2) 방송시간 1 => 60
index2 <- d2[d2$방송시간==1,] %>% na.omit() %>% rownames(); index2 <- as.integer(index2)
d2[index2,]$방송시간<- 20
# 3) 방송시간 1.333 => 20
index3 <- d2[d2$방송시간==1.333,] %>% na.omit() %>% rownames(); index3 <- as.integer(index3)
d2[index3,]$방송시간<- 20
# 4) 방송시간 40,50 이면서 토요일 노출을 따르게한다
d2[d2$방송시간==40 & d2$요일=='토요일',]$방송시간 <- d2[d2$방송시간==40 & d2$요일=='토요일',]$'노출(분)'
d2[d2$방송시간==50 & d2$요일=='토요일',]$방송시간 <- d2[d2$방송시간==50 & d2$요일=='토요일',]$'노출(분)'

# 매진변수 생성 (방송시간>노출)
table(d2[d2$방송시간 > d2$'노출(분)',]$방송시간)
d2$매진여부 <- ifelse(d2$방송시간 > d2$'노출(분)', 1, 0)

# 방송끝나는시간변수 생성
d2$방송끝나는시간 <- d2$방송일시 + dminutes(d2$방송시간)



# 3. 마더코드 + 상품명

d3 <- d2
d3$마더코드 <- as.character(d3$마더코드)

# 그룹코드 뽑아낼 그룹 dataframe 생성
gdf <- data.frame()
for (i in 1:nrow(train_rawdata)) {
  if (!(d3$상품명[i] %in% gdf$상품명) | !(d3$마더코드[i] %in% gdf$마더코드)) {
    gdf <- rbind(gdf, d3[i,c('상품명','마더코드')])
  }
}
for (i in 1:nrow(d3)) {
  if (d3$상품명[i] %in% gdf$상품명) {
    d3$그룹코드[i] <- row.names(gdf[d3$상품명[i]==gdf$상품명,])
  } else if (d3$마더코드[i] %in% gdf$마더코드) {
    d3$그룹코드[i] <- row.names(gdf[d3$마더코드[i]==gdf$마더코드,])
  }
}


# 한달 단위 같은 그룹코드 빈도 변수 생성
d3_c1 <- merge(d3 %>% count(월),
               d3 %>% group_by(월,그룹코드) %>% summarise(한달_상품= n()),
               by='월', all.y=TRUE)
d3_c2 <- d3_c1 %>% group_by(월,그룹코드) %>% summarise(한달_상품빈도 = 한달_상품/n)
d3 <- merge(d3, d3_c2, by=c('월','그룹코드'), all.x=TRUE)

d4 <- d3 %>% arrange(`방송일시`)
d4$시간hour <- as.integer(d4$시간hour)


# 4. 상품명

# 상품명 브랜드 변수 생성
d4$브랜드 <- str_extract(d4$상품명,
                      paste(c(
                        #가구
                        '삼익가구','한샘','보루네오','이누스바스','장수','이조농방','벨라홈','레스토닉','유캐슬',
                        #가전
                        '딤채','LG','대우전자','삼성','캐리어',
                        #건강기능
                        '광동','뉴트리원','닥터','종근당','블랙모어스','안국','경남제약','네페르티티','티젠','한삼인','베지밀','제주농장','이롬','이경제',
                        #생활용품
                        '한솔','일월','월시스','중외신약','보국','센티멘탈','스윙','LG생활건강','엔웰스','세렌셉템버','벨라홈','굿프렌드','바로톡',
                        '김병만의 정글피싱','까사마루','노비타','노송가구','대웅모닝컴','도루코','모리츠','자미코코','타이거','니봇','밀레','숀리','메디쉴드',
                        '메디컬드림','밸런스파워','브람스','선일','코지마','바두기','바로바로','발렌티노루','뚜러킹','블루콤','사운드룩','센스톰','수련',
                        '스위스밀리터리','스칸디나비아','스팀큐','스피드랙','씨엔지코리아','엑사이더','올바로','이지스','센스하우스','히팅맘','캐치온','코이모',
                        '코튼데이','퀸메이드','크린조이','킹스스파','테팔','트라이','파로마','페르소나','한일','신일','에브리밍','아룬싸왓','에레키반','에브리빙','프리모',
                        #속옷
                        '크로커다일','헤드','푸마','라쉬반','오모떼','LSX','댄스킨','란체티','레이프릴','로베르타','루시헨느','리복','몬테밀라노','발레리',
                        '벨레즈온','남영비비안','헤스떼벨','뷰티플렉스','실크트리','실크플러스','아키','에버라스트','오가닉뷰티','오렐리안','저스트마이사이즈',
                        '카파','컬럼비아','코몽트','쿠미투니카','히트융','자연감성',
                        #의류
                        'EXR','K-SWISS','디즈니','유리진','페플럼제이','헤스티지','USPA','마리노블','CERINI by PAT','NNF','그렉노먼','대동모피','더블유베일',
                        '도네이','디베이지','라라쎄','레드캠프','로이몬스터','르까프','릴리젼','마담팰리스','마르엘라로사티','뱅뱅','보코','스텔라테일러',
                        '스튜디오럭스','아리스토우','아문센','아주아','어반시크릿','에르나벨','엔셀라두스','이동수골프','임페리얼','젠트웰','코몽트','코펜하겐럭스',
                        '타운젠트','팜스프링스','헤비추얼','디키즈','알렉스하운드','크리스티나앤코','테이트','오렐리안','마모트',
                        #이미용
                        '엘렌실라','보닌','AHC','TS샴푸','네오젠','뉴웨이','달바','더블모','라라츄','마리끌레르','메디앤서','미바','바바코코','블링썸',
                        '비버리힐스폴로클럽','스칼프솔루션','스포메틱스','시크릿 라메종','시크릿뮤즈','실크테라피','아미니','아이앤아이','에이온에이',
                        '에이유플러스','엘로엘','자올','참존','컨시크','코튼플러스','파시노',
                        #잡화
                        '안드레아바나','DIOR','RYN','가이거','루이띠에','생쥴랑','플로쥬','기라로쉬','로베르타 디 까메리노','엘리자베스아덴','AAA','AAD','갈란테',
                        '골드파일','구찌','도스문도스','레노마','레코바','마스케라','마이클코어스','메디아글램','메이듀','바치','버버리','삭루츠','세인트스코트',
                        '스프리스','시스마르스','썸덱스','아가타','아르테사노','알비에로 마르티니','에버라스트 제니스','에트로','에펨','오델로','월드컵','제옥스',
                        '칼리베이직','코치','트레스패스','프라다','엘르',
                        #주방
                        '쿠쿠','쿠첸','라니 퍼니쿡','올리고','세라맥스','글라스락','am마카롱','오슬로','구스터','노와','클레린','뉴욕맘','델첸','두꺼비','락앤락',
                        '램프쿡','로벤탈','린나이','모즈','PN풍년','도깨비','리큅','마이베비','매직쉐프','센스락','홈쿠','비앙코','스위스밀리터리','실리만','쓰임',
                        '아이넥스','아이오','에버홈','에지리','에코라믹','에코바이런','오스터','드럼쿡','쿠진','클란츠','키친플라워','파뷔에','테팔','프로피쿡',
                        '하우홈','휴롬','세균싹','셀렉프로','멀티핸즈','실바트','안타고','에델코첸','옥샘쿡','이지엔','해피콜','키친아트','벨라홈','한샘','한일',
                        '송도순','베스트','PN','믹서를 품은 텀블러',
                        #침구
                        '한샘','리앤','보몽드','안지','한빛','효재',
                        #농수축
                        #1) 유명 농수축 브랜드
                        '농협','바다원','본죽','수협','슬로푸드','영광군수협','삼립','청정수산',
                        '피시원','하림','바다먹자','소들녘','천연담아','현대어찬',
                        #2) 사람이름 들어간 브랜드
                        '팽현숙','전철우','강레오','김선영','김정문','김정배','깐깐송도순','김규흔','이봉원',
                        '오세득','유귀열','이경제','이만기','이보은','이정섭','임성근','천수봉','최인선'),
                        collapse='|'))
d4[grep('클라쎄', d4$상품명), ]$브랜드 <- '대우전자'
d4[grep('모나코사놀', d4$상품명), ]$브랜드 <- '뉴트리원'
d4[grep('BBC', d4$상품명), ]$브랜드 <- '남영비비안'
d4[grep('생줄랑', d4$상품명), ]$브랜드 <- '생쥴랑'
d4$브랜드 <- ifelse(is.na(d4$브랜드), d4$마더코드, d4$브랜드)


# 상품명 결제1/결제2_일시불/결제2_무이자 변수 생성
d4$결제수단 <- ''
d4[grep('(무)|무)|무이자' , d4$상품명), ]$결제수단 <- '결제2_무이자'
d4[grep('(일)|일)|일시불' , d4$상품명), ]$결제수단 <- '결제2_일시불'
d4[d4$결제수단=='',]$결제수단 <- '결제1'


# 상품명 sale단어 노출 여부 변수 생성
d4$sale단어 <- ''
d4[grep('초특가|파격가|%|최저가?|가격인하|삼성카드' , d4$상품명), ]$sale단어 <- 1
d4[d4$sale단어=='',]$sale단어 <- 0


# 5. 취급액 + 프라임 변수

d <- d4[ ,c('상품군','취급액','시간hour','요일','168시간')]
product_group = c('가구','가전','건강기능','농수축','생활용품','속옷','의류','이미용','잡화','주방','침구')


#### 프라임 비율 넣은 테이블 생성

# 1) 상품군 & 요일 테이블
df_yoill <- matrix(0, nrow=11, ncol=7)
colnames(df_yoill) = c("월요일","화요일","수요일","목요일","금요일","토요일","일요일")
rownames(df_yoill) = product_group
df_yoill <- as.data.frame(df_yoill)

# 3) 상품군 & 24시간 테이블
df_hour24 <- matrix(0, nrow=11, ncol=24)
colnames(df_hour24) = c(0:23)
rownames(df_hour24) = product_group
df_hour24 <- as.data.frame(df_hour24)

# 4) 상품군 & 168시간 테이블
df_hour168 <- matrix(0, nrow=11, ncol=168)
colnames(df_hour168) = c(1:168)
rownames(df_hour168) = product_group
df_hour168 <- as.data.frame(df_hour168)


#### 프라임 비율 DF 생성

# 1) 요일별 프라임 비율 DF 생성함수

yoill_ratio_function <- function() {
  
  for (i in c(1:NROW(product_group))) {
    
    d1_yoill <- d %>% filter(상품군==product_group[i]) %>% group_by(요일) %>% 
      summarise(sales_mean = mean(취급액, na.rm = TRUE))
    sum_of_sales_mean <-  sum(d1_yoill$sales_mean)
    d1_yoill$요일프라임비율 <- (d1_yoill$sales_mean/sum_of_sales_mean)
    
    # 요일 정렬
    d1_yoill$요일 <- factor(d1_yoill$요일, levels=c("월요일","화요일","수요일","목요일","금요일","토요일","일요일"), ordered=TRUE)
    d1_yoill <- arrange(d1_yoill, 요일)
    
    # 비율만 뽑아서 레코드로 저장
    ratio_record <- d1_yoill$요일프라임비율
    df_yoill[i,] <- ratio_record
    
  }
  return(df_yoill)
}
table_yoill <- yoill_ratio_function()

# 3) 24시간별 프라임 비율 DF 생성함수

hour24_ratio_function <- function() {
  
  for (i in c(1:NROW(product_group))) {
    
    d1_hour24 <- d %>% filter(상품군==product_group[i]) %>% group_by(시간hour) %>%
      summarise(sales_mean = mean(취급액, na.rm = TRUE))
    
    # 24시간 중 안팔았던 달이 있는 애들을 대비해 새로운 템플릿 생성
    df_compare_hour24 <- data.frame(c(0:23))
    colnames(df_compare_hour24) <-  c("시간hour")
    # left outer join 
    merged_hour24<- merge(df_compare_hour24, d1_hour24, by='시간hour',  all.x  = TRUE)   
    # 결측치를 0으로 처리 
    merged_hour24$sales_mean[is.na(merged_hour24$sales_mean)] <- 0
    
    sum_of_sales_mean <-  sum(d1_hour24$sales_mean, na.rm=TRUE)
    merged_hour24$`24시간프라임비율` <- (merged_hour24$sales_mean/sum_of_sales_mean)
    
    # 비율만 뽑아서 레코드로 저장
    ratio_record <- merged_hour24$`24시간프라임비율`
    df_hour24[i,] <- ratio_record
    
  } 
  return(df_hour24)
}
table_hour24 <- hour24_ratio_function()

# 4) 168시간별 프라임 비율 DF 생성함수

hour168_ratio_function <- function() {
  
  for (i in c(1:NROW(product_group))) {
    
    d1_hour168 <- d %>% filter(상품군==product_group[i]) %>% group_by(`168시간`) %>%
      summarise(sales_mean = mean(취급액, na.rm = TRUE))
    
    #168시간 중 안팔았던 달이 있는 애들을 대비해 새로운 템플릿 생성
    df_compare_hour168 <- data.frame(c(1:168))
    colnames(df_compare_hour168) <-  c("168시간")
    #left outer join 
    merged_hour168 <- merge(df_compare_hour168, d1_hour168, by='168시간',  all.x  = TRUE)   
    #결측치를 0으로 처리 
    merged_hour168$sales_mean[is.na(merged_hour168$sales_mean)] <- 0
    
    sum_of_sales_mean <-  sum(d1_hour168$sales_mean, na.rm=TRUE)
    merged_hour168$`168시간프라임비율` <- (merged_hour168$sales_mean/sum_of_sales_mean)
    
    #비율만 뽑아서 레코드로 저장
    ratio_record <- merged_hour168$`168시간프라임비율`
    df_hour168[i,] <- ratio_record
    
  } 
  return(df_hour168)
}
table_hour168 <- hour168_ratio_function()


for (i in (1:NROW(d4))) {
  
  focus_product <- d4$상품군[i]
  focus_yoill <- d4$요일[i]
  focus_hour24 <- d4$시간hour[i]
  focus_hour168 <- d4$'168시간'[i]
  
  d4$요일프라임비율[i] <- table_yoill[focus_product, focus_yoill]
  d4$'24시간프라임비율'[i] <- table_hour24[focus_product, focus_hour24+1]
  d4$'168시간프라임비율'[i] <- table_hour168[focus_product, focus_hour168]
  
}
str(d4)


# 6. 재원오빠

d5 <- d4 %>% arrange(`방송일시`)
temp_train_data <- d5[d5$`날짜시간` < '2019120105',]

fac <- levels(factor(temp_train_data$`상품군`))
fac <- fac[-which(fac == '무형')]

product_list <- list()
for(f in fac){
  product_list[[f]] <- temp_train_data %>% filter(`상품군` == f)
}

data <- d5[d5$`상품군` != '무형', ]

ggplot(data = data,
       aes(x = `상품군`,
           y = `취급액`,
           fill = `상품군`)) +
  geom_boxplot(outlier.colour = 'red', outlier.size = 0.5, outlier.shape = 8)



# 1. 그룹코드 별로 '대박횟수' / '전체횟수' / '대박확률' 구하기
#   >>> 중복된 그룹코드를 제거한 후 그룹코드별로 가지는 '대박횟수' / '전체횟수' / '대박확률'을 데이터프레임으로 만들고
#       본데이터에 그룹코드를 기준으로 join합니다.

# (1) 상품군 별로 이상치인 상품만이 포함된 데이터프레임
outlier_product_list <- list()
for(f in fac){
  df <- product_list[[f]]
  name_fac <- levels(factor(df$`그룹코드`))
  a <- boxplot(df$`취급액`)
  outlier_product_list[[f]] <- df[df$`취급액` > a$stats[5,],]
}

# (2) 그룹코드 별로 '대박횟수' 칼럼 생성
out_cnt_byname <- list()
for(f in fac){
  df <- outlier_product_list[[f]]
  out_cnt_byname[[f]] <- df %>% group_by(`그룹코드`) %>% summarise(`그룹코드별대박횟수` = n())
}

# (3) 그룹코드 별로 '전체횟수' 칼럼 생성
all_name_cnt <- list()
for(f in fac){
  df <- temp_train_data %>% filter(`상품군` == f)
  all_name_cnt[[f]] <- df %>% group_by(`그룹코드`) %>% summarise(`그룹코드별전체횟수` = n())
}

# (4) '대박횟수' / '전체횟수' 칼럼을 포함하는 데이터프레임 생성
cnt_df_list <- list()
for(f in fac){
  temp_df <- left_join(all_name_cnt[[f]], out_cnt_byname[[f]])
  temp_df[is.na(temp_df$그룹코드별대박횟수), ]$그룹코드별대박횟수 <- 0
  cnt_df_list[[f]] <- temp_df
}

# (5) 그룹코드를 기준으로 '대박횟수' 칼럼 / '전체횟수' 칼럼 합치기
#     '대박확률' 칼럼 만들기
product_hitprob_df <- cnt_df_list[[1]]
for(i in 2:11){
  product_hitprob_df <- rbind(product_hitprob_df, cnt_df_list[[i]])
}
product_hitprob_df$`대박확률` <- (product_hitprob_df$`그룹코드별대박횟수` / product_hitprob_df$`그룹코드별전체횟수`)
product_hitprob_df


# (6) 대박확률에 근거한 등급 : 대박확률 누적 평균그래프

product_hitprob_df <- product_hitprob_df %>% arrange(desc(`대박확률`))

set.seed(123456789)
cum_mean_list <- list()
for(i in 1:10){
  prob <- c()
  for(j in 1:500){
    prob <- c(prob, product_hitprob_df[sample(1:nrow(product_hitprob_df), 1, replace = TRUE),]$`대박확률`)
  }
  cum_mean_list[[i]] <- cummean(prob)
}


cum_mean_df <- data.frame(cum_mean_list[[1]])
for(i in 2:10){
  cum_mean_df <- cbind(cum_mean_df, cum_mean_list[[i]])
}
cum_mean_df <- cbind(cum_mean_df, c(1:500))
colnames(cum_mean_df) <- c('p1', 'p2', 'p3', 'p4', 'p5', 'p6', 'p7', 'p8', 'p9', 'p10', 'x')

ggplot(data = cum_mean_df,
       aes(x = x)) +
  geom_line(aes(y = p1), col = 1) +
  geom_line(aes(y = p2), col = 2) +
  geom_line(aes(y = p3), col = 3) +
  geom_line(aes(y = p3), col = 4) +
  geom_line(aes(y = p5), col = 5) +
  geom_line(aes(y = p6), col = 6) +
  geom_line(aes(y = p7), col = 7) +
  geom_line(aes(y = p8), col = 8) +
  geom_line(aes(y = p9), col = 9) +
  geom_line(aes(y = p10), col = 10) +
  scale_y_continuous(limit = c(0, 0.3)) +
  xlab('방송노출횟수') +
  ylab('대박확률 누적평균')
# 위 그래프 결과 방송노출횟수(`전체횟수`) 200일때 수렴이 시작
# 그러므로 200에서 등급 부여 방법을 다르게 적용한다
# `전체횟수`가 200이상이면 대박확률 순서에 따라 A/B/C/D/E 등급 부여
# `전채횟수`가 200미만이면 대박확률 순서에 따라 B/C/D 등급 부여


# (7) 표본수 200을 기준으로 `대박확률등급` 나누기
# 전체횟수가 200이상 : 표본이 많이 대박확률을 신뢰할 수 있는경우
up200_df <- product_hitprob_df[product_hitprob_df$`그룹코드별전체횟수` >= 200, ] 
up200_df$`대박확률등급` <- ''

hit_prob_fac <- unique(up200_df$`대박확률`)
standard <- quantile(hit_prob_fac, probs = c(0.2, 0.4, 0.6, 0.8))

up200_df$`대박확률등급` <- 'E'
up200_df[up200_df$`대박확률` >= standard[[1]], ]$`대박확률등급` <- 'D'
up200_df[up200_df$`대박확률` >= standard[[2]], ]$`대박확률등급` <- 'C'
up200_df[up200_df$`대박확률` >= standard[[3]], ]$`대박확률등급` <- 'B'
up200_df[up200_df$`대박확률` >= standard[[4]], ]$`대박확률등급` <- 'A'

# 전체횟수가 200미만 : 표본이 적어 상대적으로 대박확률을 믿을 수 없는 경우
down200_df <- product_hitprob_df[product_hitprob_df$`그룹코드별전체횟수` < 200, ]
down200_df$`대박확률등급` <- ''

hit_prob_fac <- unique(down200_df$`대박확률`)
standard <- quantile(hit_prob_fac, probs = c(0.33, 0.66))

down200_df$`대박확률등급` <- 'D'
down200_df[down200_df$`대박확률` >= standard[[1]], ]$`대박확률등급` <- 'C'
down200_df[down200_df$`대박확률` >= standard[[2]], ]$`대박확률등급` <- 'B'

all200_df <- rbind(up200_df, down200_df)
all200_df <- unique(all200_df)


# 대박확률등급이 있는 데이터프레임과 train 데이터프레임을 join
d6 <- left_join(d5, all200_df)


# 7. 주기를 고려한 파생변수 : 월/분기/168시간/24시간 

# 월
d6$`월_COS` <- cos(( 2*pi*as.numeric(d6$`월`) ) / 12)
d6$`월_SIN` <- sin(( 2*pi*as.numeric(d6$`월`) ) / 12)

# 분기
d6$`분기_COS` <- cos(( 2*pi*as.numeric(substr(d6$`분기`, 2, 2)) ) / 4)
d6$`분기_SIN` <- sin(( 2*pi*as.numeric(substr(d6$`분기`, 2, 2)) ) / 4)

# 168시간 : 일주일
d6$`168시간_COS` <- cos(( 2*pi*as.numeric(d6$`168시간`) ) / 168)
d6$`168시간_SIN` <- sin(( 2*pi*as.numeric(d6$`168시간`) ) / 168)

# 24시간 : 하루
d6$`24시간_COS` <- cos(( 2*pi*as.numeric(d6$`시간hour`) ) / 24)
d6$`24시간_SIN` <- sin(( 2*pi*as.numeric(d6$`시간hour`) ) / 24)

# 53주차
d6$`53주차_COS` <- cos(( 2*pi*as.numeric(d6$`53주차`) ) / 12)
d6$`53주차_SIN` <- sin(( 2*pi*as.numeric(d6$`53주차`) ) / 12)

str(d6)


# 8. 중분류
middlecategory <- as.data.frame(read_xlsx('C:\\Users\\lan41\\Desktop\\최종 연습 제출\\중분류 데이터 및 트리.xlsx'))

중분류_split <- strsplit(middlecategory$중분류,'-')
for (i in 1:nrow(middlecategory)) {
  middlecategory$중분류_split[i] <- 중분류_split[[i]][2]
}
middle <- middlecategory %>% dplyr::select(상품명,중분류_split) %>% unique()

d4 <- left_join(d6, middle)
str(d4)


#### 외부데이터 탐색으로 인한 변수 정리 

# 1. 기상청 데이터

# 기상청 2019
weather <- read.csv('C:\\Users\\lan41\\Desktop\\최종 연습 제출\\2019기상청.csv')
colnames(weather) <- c('지점','지점명','일시','기온','강수량','풍속','습도','적설','전운량')
colSums(is.na(weather)); colSums(weather==0,na.rm=TRUE);

# 기상청 강수량과 적설 0은 0.02로 결측치는 0으로 처리
weather[!is.na(weather$강수량) & weather$강수량==0,]$강수량  <- 0.02
weather[is.na(weather$강수량),]$강수량 <- 0
weather[!is.na(weather$적설) & weather$적설==0,]$적설  <- 0.02
weather[is.na(weather$적설),]$적설 <- 0
weather$일시 <- as.POSIXct(weather$일시)

w1 <- weather %>% group_by(일시) %>% dplyr::summarise(기온 = mean(기온, na.rm=TRUE),
                                                      강수량 = mean(강수량, na.rm=TRUE),
                                                      풍속 = mean(풍속, na.rm=TRUE),
                                                      습도 = mean(습도, na.rm=TRUE),
                                                      적설 = mean(적설, na.rm=TRUE),
                                                      전운량 = mean(전운량, na.rm=TRUE))
w1$비눈여부 <- as.factor(ifelse(w1$강수량==0 & w1$적설==0, 0, 1))
w1$비눈여부_평균이상 <- as.factor(ifelse(w1$강수량>mean(w1$강수량) | w1$적설>mean(w1$적설), 1, 0))
colSums(is.na(w1)); w1[is.na(w1$전운량),]$전운량 <- 0

d5 <- merge(d4, w1, by.x='방송일시', by.y='일시', all.x=TRUE)
for (i in 2:nrow(d5)) {
  if (is.na(d5[i,c('기온','강수량','풍속','습도','적설','전운량','비눈여부','비눈여부_평균이상')])) {
    d5[i,c('기온','강수량','풍속','습도','적설','전운량','비눈여부','비눈여부_평균이상')] <- d5[(i-1),c('기온','강수량','풍속','습도','적설','전운량','비눈여부','비눈여부_평균이상')]
  }
}


# 2. 미세먼지 데이터

# 미세먼지 2019
dust1 <- read.csv('C:\\Users\\lan41\\Desktop\\최종 연습 제출\\2019미세먼지.csv')
dust1$일자 <- as.character(as.integer(dust1$일자)-1)

a1 <- d5[,c('날짜시간','시간')]
a2 <- merge(a1, dust1, by.x='날짜시간', by.y='일자', all.x=TRUE)
d5$미세먼지 <- a2$미세먼지
d5$초미세먼지 <- a2$초미세먼지



#### train과 test셋 분리

d6 <- d5
train <- d6[c(1:nrow(train_rawdata)),]; str(train); #(35154,56)
test <- d6[c((nrow(train_rawdata)+1):nrow(d6)),]; str(test); #(3155,56)


#### train 전처리

# train 상품군이 "무형" 인 경우 767개
table(train$상품군 == "무형")
# 취급액 train 결측치 767개
sum(is.na(train$취급액))
# 취급액 50000 이상치 1907개
table(train$취급액 == 50000)

train1 = train[!is.na(train$취급액) & train$취급액!=50000, ]
str(train1) #(32480,56)


# 취급액 분포
boxplot(train1$취급액)
#install.packages('rcompanion')
library(rcompanion)
# 취급액의 분포가 왼쪽으로 치우쳐져 있다
plotNormalHistogram(train1$취급액)

# 정규 변환 - boxcox
#install.packages('MASS')
library(MASS)
Box = boxcox(lm(train1$취급액 ~ 1))
Cox = data.frame(Box$x, Box$y)          
Cox2 = Cox[with(Cox, order(-Cox$Box.y)),] 
lambda = Cox2[1, 'Box.x'] #lambda = 0.22
y2 = (train1$취급액 ^ lambda - 1)/lambda
plotNormalHistogram(y2)
qqnorm(y2); qqline(y2)

# 취급액 boxcox로 변환한 변수 생성
train1['취급액boxcox'] <- y2
summary(train1['취급액boxcox'])


#### train 변수 추가

# 시청률 데이터
rating <- read.csv('C:\\Users\\lan41\\Desktop\\최종 연습 제출\\2019시청률.csv')
colnames(rating) <- c('방송일시','시청률평균','시청률중앙값','시청률최고값','0.016평균값')
rating$방송일시 <- as.POSIXct(rating$방송일시)

train1 <- left_join(train1, rating)
str(train1)
colSums(is.na(train1))


#### test 전처리

tail(test)
# test 상품군이 "무형" 인 경우
test1 <- test[test$상품군 != "무형",]
test1$취급액boxcox <- (test1$취급액 ^ lambda - 1)/lambda
colSums(is.na(test1))


write.csv(train1, file='train.csv')
write.csv(test1, file='test.csv')

