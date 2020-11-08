# Portfolio_ML

머신러닝 프로젝트 포트폴리오 정리

------

## #1. Project - 소비 트렌드 분석

- Background

통폐합지점 이탈에 영향을 주는 변수들을 찾고, 영업 성과 관리를 위해 변수 특성이 비슷한 지점들을 클러스터링

- Summary

  (1). Data Collection
  \- 은행 데이터 마트(지점데이터 + 고객데이터) + 외부데이터(금융결제원)

  (2). Data Preprocessing
  \- EDA (지점데이터 + 고객데이터 + 외부데이터)
  \- Reduction (특성이 다른 지점 데이터 제거, missing value 포함한 고객데이터 제거)

  (3). Model & Algorithms
  \- xgboost regression(지점 데이터) --> RMSE 작을 때 feature importance
  \- xgboost classifier(고객 데이터) --> F1 높을 때 feature importance
  \- Aggregation(고객데이터 --> 지점데이터) --> Clustering(Hierarchical, K-means, Gaussian mixture)

  (4). Report
  \- 이탈에 영향을 주는 변수 목록 작성 - 변수 특성이 비슷한 지점끼리 클러스터링한 결과 표 작성

  (5). Review
  \- 피드백 : 클러스터링보다 나은 방법이 있지 않았을까
  \- Futher Research : 바뀌는 금융환경 ---> 모델링 반복 필요
   : 통폐합이 영향을 준 고객만을 대상으로 분석 모델을 구축해야 한다

*보러가기: [은행이탈률 클러스터링](https://github.com/hbkimhbkim/Portfolio_ML/blob/master/bankchurn/)*    

------

## 