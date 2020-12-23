"""Agrifood_prj URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/3.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from agrifoodApp.views import *
# from musicApp.views import KakaoToDjangoLogin


urlpatterns = [
    path('admin/', admin.site.urls),
    path('', index, name='index'),
    path('index/', index2, name='index'),
    path('garlic/', garlic, name='garlic'),
    path('onion/', onion, name='onion'),
    path('radish/', radish, name='radish'),
    path('cabbage/', cabbage, name='cabbage'),
    path('map/', map, name='map'),

    # path('',include('agrifoodApp'))
]
