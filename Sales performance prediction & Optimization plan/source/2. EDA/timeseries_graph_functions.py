import pandas as pd
import numpy as np 
import os 

import seaborn as sns
import matplotlib as mpl
import matplotlib.pyplot as plt
import matplotlib.font_manager as fm
from matplotlib import rc


# In[2]:


pd.set_option('display.float_format', '{:.2f}'.format)   # 과학적 표기법 사용 안함
mpl.rcParams['axes.unicode_minus'] = False               # 마이너스 표기 오류 방지 


# In[3]:

# 한글 폰트 깨짐 방지 
font_name = fm.FontProperties(fname="C:/Windows/Fonts/malgun.ttf").get_name()   
rc('font', family=font_name)


# In[4]:


def sales_by_month(data):
    sales_per_month = pd.DataFrame(data, columns=("월", "취급액"))
    sales_per_month_group = sales_per_month.groupby("월")

    sales_per_month_group_SUM = sales_per_month_group.sum()
    sales_per_month_group_MEAN = sales_per_month_group.mean()

    sales_per_month_group_SUM.plot()
    plt.title("월별 취급액 합계")
    plt.xticks(np.arange(1, 13, 1))

    sales_per_month_group_MEAN.plot()
    plt.title("월별 취급액 평균")
    plt.xticks(np.arange(1, 13, 1))


# In[5]:


def sales_by_time(data):
    sales_by_hhmm = pd.DataFrame(data, columns=("시간", "취급액"))
    sales_by_hhmm_group = sales_by_hhmm.groupby("시간")

    sales_by_time_SUM = sales_by_hhmm_group.sum()
    sales_by_time_MEAN = sales_by_hhmm_group.mean()


    sales_by_time_SUM.plot(figsize=(15, 5))
    # 시간 표기 조정
    plt.xticks(["00:00", "01:00", "02:00", "03:00", "04:00", "05:00", "06:00", "07:00", "08:00", "09:00", "10:00",
                "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00",
                "22:00", "23:00", "23:59"], fontsize=9)
    plt.title("시간대 별 취급액 총합")
    plt.show()
    #     plt.savefig('../../assets/images/markdown_img/180801_plt_xticks.svg')

    sales_by_time_MEAN.plot(figsize=(15, 5))
    # 시간 표기 조정
    plt.xticks(["00:00", "01:00", "02:00", "03:00", "04:00", "05:00", "06:00", "07:00", "08:00", "09:00", "10:00",
                "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00",
                "22:00", "23:00", "23:59"], fontsize=9)
    plt.title("시간대 별 취급액 평균")
    plt.show()


# In[6]:


def sales_by_yoill(data):
    sales_by_yoill_var = pd.DataFrame(data, columns = ("요일", "취급액"))
    sales_by_yoill_group = sales_by_yoill_var.groupby("요일")
    
    sales_by_yoill_SUM = sales_by_yoill_group.sum()
    sales_by_yoill_MEAN = sales_by_yoill_group.mean()

    # 요일 순서 조정
    yoill_sum_sort = pd.DataFrame(sales_by_yoill_SUM, ("월요일", "화요일", "수요일", "목요일" , "금요일", "토요일", "일요일"))
    yoill_mean_sort = pd.DataFrame(sales_by_yoill_MEAN, ("월요일", "화요일", "수요일", "목요일" , "금요일", "토요일", "일요일"))

    yoill_sum_sort.plot()
    plt.title("요일 별 취급액 총합")
    
    yoill_mean_sort.plot()
    plt.title("요일 별 취급액 평균")


# In[7]:



def sales_by_season(data):
    sales_season = pd.DataFrame(data, columns=['취급액', '계절'])
    group_season = sales_season.groupby(['계절'])

    season_sum = group_season.sum()
    season_mean = group_season.mean()

    season_sum_sort = pd.DataFrame(season_sum, ("봄", "여름", "가을", "겨울"))
    season_mean_sort = pd.DataFrame(season_mean, ("봄", "여름", "가을", "겨울"))

    print(season_sum_sort.plot.bar())
    print(plt.title("계절 별 취급액 총합"))

    print(season_mean_sort.plot.bar())
    print(plt.title("계절 별 취급액 평균"))


# In[8]:


def soldout_by_season(data):
    soldout_by_season = pd.DataFrame(data, columns =['매진여부','계절'])
    group_soldout = soldout_by_season.groupby(['계절'])
    print(group_soldout.sum())


# In[9]:


def unitprice_by_season(data):
    uprice_by_season = pd.DaㄴtaFrame(data, columns=['판매단가', '계절'])
    uprice_group_season = uprice_by_season.groupby("계절")

    sum_group = uprice_group_season.sum()
    mean_group = uprice_group_season.mean()

    # 계절 순서 조정
    sum_group_sort = pd.DataFrame(sum_group, ("봄", "여름", "가을", "겨울"))
    mean_group_sort = pd.DataFrame(mean_group, ("봄", "여름", "가을", "겨울"))

    print(sum_group_sort.plot.bar())
    print(plt.title("계절별 판매단가 총액"))

    print(mean_group_sort.plot.bar())
    print(plt.title("계절별 판매단가 평균"))


# In[10]:



def quantity_by_season(data):
    quantity_season = pd.DataFrame(data, columns=["계절", "최소판매수량"])
    quantity_season_group = quantity_season.groupby("계절")

    quantity_group_sum = quantity_season_group.sum()  # 데이터프레임
    quantity_group_mean = quantity_season_group.mean()

    df_quantity_groupSUM = pd.DataFrame(quantity_group_sum, ("봄", "여름", "가을", "겨울"))
    df_quantity_groupMEAN = pd.DataFrame(quantity_group_mean, ("봄", "여름", "가을", "겨울"))

    df_quantity_groupSUM.plot.bar()
    plt.title("계절별 최소판매수량 합계")

    df_quantity_groupMEAN.plot.bar()
    plt.title("계절별 최소판매수량 평균")


# In[11]:




def sales_by_Q(data):
    sales_Q = pd.DataFrame(data, columns=("분기", "취급액"))
    sales_by_Q_group = sales_Q.groupby("분기")

    Q_group_sum = sales_by_Q_group.sum()
    Q_group_mean = sales_by_Q_group.mean()

    Q_group_sum.plot.bar()
    plt.title("분기별 취급액 총합")
    Q_group_mean.plot.bar()
    plt.title("분기별 취급액 평균")


# In[12]:



def unitprice_by_Q(data):
    unitprice_Q =  pd.DataFrame(data, columns = ['판매단가','분기'])
    unitprice_by_Q_season = unitprice_Q.groupby("분기")
    unitprice_by_Q_MEAN= unitprice_by_Q_season.mean()

    unitprice_by_Q_MEAN.plot.bar()
    plt.title("분기별 판매 단가 평균")


# In[13]:


def quantity_by_Q(data):
    quantity_Q = pd.DataFrame(data, columns=["분기", "최소판매수량"])
    quantity_Q_group = quantity_Q.groupby("분기")

    quantity_Q_group_sum = quantity_Q_group.sum()  # 데이터프레임
    quantity_Q_group_mean = quantity_Q_group.mean()

    quantity_Q_group_sum.plot.bar()
    plt.title("분기별 최소판매수량 합계")
    quantity_Q_group_mean.plot.bar()
    plt.title("분기별 최소판매수량 평균")


def sales_by_time_sicheong(data, product):
    sales_by_hhmm = pd.DataFrame(data, columns=("시간", "시청률"))
    sales_by_hhmm_group = sales_by_hhmm.groupby("시간")

    sales_by_time_SUM = sales_by_hhmm_group.sum()
    sales_by_time_MEAN = sales_by_hhmm_group.mean()

    sales_by_time_SUM.plot(figsize=(15, 5))
    # 시간 표기 조정

    plt.xticks(["00:00", "01:00", "02:00", "03:00", "04:00", "05:00", "06:00", "07:00", "08:00", "09:00", "10:00",
                "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00",
                "22:00", "23:00", "23:59"], fontsize=9)
    plt.title(product + " - 시간대 별 시청률 총합")

    ## 그래프 저장용 위치 ##
    #plt.savefig('C:\\programming\\bigcontest_2020\\champion_league\\eda\\공유용 PPT\\images\{}.png'.format(product + " - 시간대 별 시청률 총합"))


    plt.show()


    sales_by_time_MEAN.plot(figsize=(15, 5))
    # 시간 표기 조정
    plt.xticks(["00:00", "01:00", "02:00", "03:00", "04:00", "05:00", "06:00", "07:00", "08:00", "09:00", "10:00",
                "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00",
                "22:00", "23:00", "23:59"], fontsize=9)
    plt.title(product + " - 시간대 별 시청률 평균")

    ## 그래프 저장용 위치 ##
    # plt.savefig('C:\\programming\\bigcontest_2020\\champion_league\\eda\\공유용 PPT\\images\{}.png'.format(product + " - 시간대 별 시청률 평균"))
    plt.show()

#
# def importance_by_season(data):
#     sales_season = pd.DataFrame(data, columns=['취급액', '계절'])
#     group_season = sales_season.groupby(['계절'])

################################################ 더블 그래프 #################################


def sicheong_sales_by_time(data, product):
    # data = focus_data

    sales_by_hhmm = pd.DataFrame(data, columns=("시간", "취급액", "시청률"))
    sales_by_hhmm_group = sales_by_hhmm.groupby("시간")

    sales_by_time_SUM = sales_by_hhmm_group.sum()
    sales_by_time_MEAN = sales_by_hhmm_group.mean()

    ## SUM ##

    plt.rcParams["figure.figsize"] = (15, 5)
    ax = sales_by_time_SUM.plot(y="취급액", legend=False, color="r")
    ax2 = ax.twinx()
    sales_by_time_SUM.plot(y="시청률", ax=ax2, legend=False)
    ax.figure.legend()
    plt.xticks(["00:00", "01:00", "02:00", "03:00", "04:00", "05:00", "06:00", "07:00", "08:00", "09:00", "10:00",
                "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00",
                "22:00", "23:00", "23:59"], fontsize=9)
    plt.title(product + " - 시간대 별 시청률 & 취급액 총합")

    ## 그래프 저장용 위치 ##
    plt.savefig('C:\\programming\\bigcontest_2020\\champion_league\\eda\\공유용 PPT\\images\{}.png'.format(product + " - 시간대 별 시청률 & 취급액 총합"))

    plt.show()

    ## MEAN ##

    plt.rcParams["figure.figsize"] = (15, 5)
    ax = sales_by_time_MEAN.plot(y="취급액", legend=False, color="r")
    ax2 = ax.twinx()
    sales_by_time_MEAN.plot(y="시청률", ax=ax2, legend=False)
    ax.figure.legend()
    plt.xticks(["00:00", "01:00", "02:00", "03:00", "04:00", "05:00", "06:00", "07:00", "08:00", "09:00", "10:00",
                "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00",
                "22:00", "23:00", "23:59"], fontsize=9)
    plt.title(product + " - 시간대 별 시청률 & 취급액 평균")
    ## 그래프 저장용 위치 ##
    plt.savefig('C:\\programming\\bigcontest_2020\\champion_league\\eda\\공유용 PPT\\images\{}.png'.format(product + " - 시간대 별 시청률 & 취급액 평균"))

    plt.show()



def sicheong_sales_by_month(data, product):
    # data = focus_data

    sales_by_month = pd.DataFrame(data, columns=("월", "취급액", "시청률"))
    sales_by_month_group = sales_by_month.groupby("월")

    sales_by_month_SUM = sales_by_month_group.sum()
    sales_by_month_MEAN = sales_by_month_group.mean()

    ## SUM ################

    plt.rcParams["figure.figsize"] = (15, 5)
    ax = sales_by_month_SUM.plot(y="취급액", legend=False, color="r")
    ax2 = ax.twinx()
    sales_by_month_SUM.plot(y="시청률", ax=ax2, legend=False)
    plt.xticks(np.arange(1, 13, 1))
    ax.figure.legend()
    plt.title(product + " - 월별 시청률 & 취급액 총합")

    ## 그래프 저장용 위치 ##
    plt.savefig('C:\\programming\\bigcontest_2020\\champion_league\\eda\\공유용 PPT\\images\{}.png'.format(product + " - 월별 시청률 & 취급액 총합"))

    plt.show()

    ## MEAN ################

    plt.rcParams["figure.figsize"] = (15, 5)
    ax = sales_by_month_MEAN.plot(y="취급액", legend=False, color="r")
    ax2 = ax.twinx()
    sales_by_month_MEAN.plot(y="시청률", ax=ax2, legend=False)
    plt.xticks(np.arange(1, 13, 1))
    ax.figure.legend()
    plt.title(product + " - 월별 시청률 & 취급액 평균")

    ## 그래프 저장용 위치 ##
    plt.savefig('C:\\programming\\bigcontest_2020\\champion_league\\eda\\공유용 PPT\\images\{}.png'.format(
        product + " - 월별 시청률 & 취급액 평균"))

    plt.show()

def sicheong_sales_by_yoill(data, product):
    # data = focus_data
    sales_by_yoill_var = pd.DataFrame(data, columns=("요일", "취급액", "시청률"))
    sales_by_yoill_group = sales_by_yoill_var.groupby("요일")

    sales_by_yoill_SUM = sales_by_yoill_group.sum()
    sales_by_yoill_MEAN = sales_by_yoill_group.mean()

    # 요일 순서 조정
    yoill_sum_sort = pd.DataFrame(sales_by_yoill_SUM, ("월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일"))
    yoill_mean_sort = pd.DataFrame(sales_by_yoill_MEAN, ("월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일"))

    ## SUM ################

    plt.rcParams["figure.figsize"] = (15, 5)
    ax = yoill_sum_sort.plot(y="취급액", legend=False, color="r")
    ax2 = ax.twinx()
    yoill_sum_sort.plot(y="시청률", ax=ax2, legend=False)
    ax.figure.legend()
    plt.title(product + " - 요일별 별 시청률 & 취급액 총합")

    ## 그래프 저장용 위치 ##
    plt.savefig('C:\\programming\\bigcontest_2020\\champion_league\\eda\\공유용 PPT\\images\{}.png'.format(product + " - 요일별 시청률 & 취급액 총합"))

    plt.show()

    ## MEAN ################
    plt.rcParams["figure.figsize"] = (15, 5)
    ax = yoill_mean_sort.plot(y="취급액", legend=False, color="r")
    ax2 = ax.twinx()
    yoill_mean_sort.plot(y="시청률", ax=ax2, legend=False)
    ax.figure.legend()
    plt.title(product + " - 요일별 별 시청률 & 취급액 평균")

    ## 그래프 저장용 위치 ##
    plt.savefig('C:\\programming\\bigcontest_2020\\champion_league\\eda\\공유용 PPT\\images\{}.png'.format(
        product + " - 요일별 시청률 & 취급액 평균"))

    plt.show()

def sicheong_sales_by_season(data, product):

    sales_season = pd.DataFrame(data, columns=['계절','취급액','시청률'])
    group_season = sales_season.groupby(['계절'])

    season_sum = group_season.sum()
    season_mean = group_season.mean()

    season_sum_sort = pd.DataFrame(season_sum, ("봄", "여름", "가을", "겨울"))
    season_mean_sort = pd.DataFrame(season_mean, ("봄", "여름", "가을", "겨울"))

    ## SUM ################

    plt.rcParams["figure.figsize"] = (15, 5)
    ax = season_sum_sort.plot(y="취급액", legend=False, color="r")
    ax2 = ax.twinx()
    season_sum_sort.plot(y="시청률", ax=ax2, legend=False)
    ax.figure.legend()
    plt.title(product + " - 계절별 시청률 & 취급액 총합")

    ## 그래프 저장용 위치 ##
    plt.savefig('C:\\programming\\bigcontest_2020\\champion_league\\eda\\공유용 PPT\\images\{}.png'.format(
        product + " - 계절별 시청률 & 취급액 총합"))

    plt.show()

    ## MEAN ################
    plt.rcParams["figure.figsize"] = (15, 5)
    ax = season_mean_sort.plot(y="취급액", legend=False, color="r")
    ax2 = ax.twinx()
    season_mean_sort.plot(y="시청률", ax=ax2, legend=False)
    ax.figure.legend()
    plt.title(product + " - 계절별 별 시청률 & 취급액 평균")

    ## 그래프 저장용 위치 ##
    plt.savefig('C:\\programming\\bigcontest_2020\\champion_league\\eda\\공유용 PPT\\images\{}.png'.format(
        product + " - 계절별 시청률 & 취급액 평균"))

    plt.show()



def sicheong_sales_by_Q(data, product):
    sales_Q = pd.DataFrame(data, columns=("분기", "취급액", "시청률"))
    sales_by_Q_group = sales_Q.groupby("분기")

    Q_group_sum = sales_by_Q_group.sum()
    Q_group_mean = sales_by_Q_group.mean()

    ## SUM ################

    plt.rcParams["figure.figsize"] = (15, 5)
    ax = Q_group_sum.plot(y="취급액", legend=False, color="r")
    ax2 = ax.twinx()
    Q_group_sum.plot(y="시청률", ax=ax2, legend=False)
    ax.figure.legend()
    plt.title(product + " - 분기별 시청률 & 취급액 총합")

    ## 그래프 저장용 위치 ##
    plt.savefig('C:\\programming\\bigcontest_2020\\champion_league\\eda\\공유용 PPT\\images\{}.png'.format(
        product + " - 분기별 시청률 & 취급액 총합"))

    plt.show()

    ## MEAN ################
    plt.rcParams["figure.figsize"] = (15, 5)
    ax = Q_group_mean.plot(y="취급액", legend=False, color="r")
    ax2 = ax.twinx()
    Q_group_mean.plot(y="시청률", ax=ax2, legend=False)
    ax.figure.legend()
    plt.title(product + " - 분기별 별 시청률 & 취급액 평균")

    ## 그래프 저장용 위치 ##
    plt.savefig('C:\\programming\\bigcontest_2020\\champion_league\\eda\\공유용 PPT\\images\{}.png'.format(
        product + " - 분기별 시청률 & 취급액 평균"))

    plt.show()
