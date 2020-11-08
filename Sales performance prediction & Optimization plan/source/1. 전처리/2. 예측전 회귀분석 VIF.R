
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
  if(!require(randomForest)){install.packages('randomForest'); library(randomForest)}
  if(!require(forecast)){install.packages('forecast'); library(forecast)}
  if(!require(xgboost)){install.packages('xgboost'); library(xgboost)}
  if(!require(car)){install.packages('car'); library(car)}
} 



raw_train <- read.csv('C:\\Users\\lan41\\Desktop\\2020빅콘테스트\\data\\세미프로젝트용data\\train.csv')
raw_test <- read.csv('C:\\Users\\lan41\\Desktop\\2020빅콘테스트\\data\\세미프로젝트용data\\test.csv')




train <- raw_train %>% dplyr::select(노출.분., 상품군, 판매단가, 계절, 휴일, 방송시간, 매진여부, 한달_상품빈도, 브랜드,
                          결제수단, sale단어, 요일프라임비율, X24시간프라임비율, X168시간프라임비율, 그룹코드별전체횟수,
                          그룹코드별대박횟수, 대박확률, 대박확률등급, 월_COS, 월_SIN, 분기_COS, 분기_SIN,
                          X168시간_COS, X168시간_SIN, X24시간_COS, X24시간_SIN, X53주차_COS,
                          X53주차_SIN, 중분류, 기온, 강수량, 풍속, 습도, 적설, 전운량, 비눈여부,
                          비눈여부_평균이상, 미세먼지, 초미세먼지, 취급액boxcox)

# 1.
a <- lm(취급액boxcox ~., data = train)
summary(a)
alias(a)$Complete
attributes(alias()$Complete)$dimnames[[1]]


# 2.
b <- lm(취급액boxcox ~. - 브랜드, data = train)
vif(b)

# 3.
c <- lm(취급액boxcox ~. - 브랜드 - 계절, data = train)
vif(c) # 노출.분. vs 방송시간

cor(train$취급액boxcox, train$노출.분.)
cor(train$취급액boxcox, train$방송시간)   # > 노출.분.이 더욱 상관계수 높음 : `방송시간` 제외

# 4. 
d <- lm(취급액boxcox ~. - 브랜드 - 계절 - 방송시간, data = train)
vif(d) # 기온 vs 월_SIN

cor(train$취급액boxcox, train$기온)
cor(train$취급액boxcox, train$월_SIN)   # > 기온 더욱 상관계수 높음 : `월_SIN` 제외


# 5.
e <- lm(취급액boxcox ~. - 브랜드 - 계절 - 방송시간 -월_SIN, data = train)
vif(e)


# 6.
f <- lm(취급액boxcox ~. - 브랜드 - 계절 - 방송시간 -월_SIN -대박확률등급, data = train)
vif(f)

# 7
g <- lm(취급액boxcox ~. - 브랜드 - 계절 - 방송시간 -월_SIN -상품군 - 대박확률등급, data = train)
vif(g)



