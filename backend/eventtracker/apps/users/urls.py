from django.urls import path
from rest_framework.authtoken.views import obtain_auth_token
from . import views

urlpatterns = [
    path('register/', views.RegisterView.as_view(), name='register'),
    path('login/', views.CustomAuthToken.as_view(), name='login'),
    path('profile/', views.UserProfileView.as_view(), name='profile'),
    path('preferences/', views.UserPreferenceView.as_view(), name='preferences'),
    path('token-auth/', views.CustomAuthToken.as_view(), name='token_auth'),
]