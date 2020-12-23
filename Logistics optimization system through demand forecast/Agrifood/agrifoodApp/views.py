from django.shortcuts import render

# Create your views here.
def index(request) :
    # context = {'ment' : '여기까지 잘되시나요?'}
    return render(request, 'index.html')


def index2(request):
    # context = {'ment' : '여기까지 잘되시나요?'}
    return render(request, 'index_2.html')




def garlic(request) :
    # context = {'ment' : '여기까지 잘되시나요?'}
    return render(request, 'garlic.html')


def cabbage(request) :
    # context = {'ment' : '여기까지 잘되시나요?'}
    return render(request, 'cabbage.html')


def radish(request) :
    # context = {'ment' : '여기까지 잘되시나요?'}
    return render(request, 'radish.html')


def onion(request) :
    # context = {'ment' : '여기까지 잘되시나요?'}
    return render(request, 'onion.html')

def map(request) :
    # context = {'ment' : '여기까지 잘되시나요?'}
    return render(request, 'map.html')