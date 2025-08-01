from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from rest_framework.authtoken import views as token_views

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/auth/', include('rest_framework.urls')),
    path('api/token-auth/', token_views.obtain_auth_token),
    
    # Apps URLs
    path('api/events/', include('apps.events.urls')),
    path('api/gifts/', include('apps.gifts.urls')),
    path('api/guests/', include('apps.guests.urls')),
    path('api/planning/', include('apps.planning.urls')),
    path('api/photos/', include('apps.photos.urls')),
    path('api/messaging/', include('apps.messaging.urls')),
    path('api/users/', include('apps.users.urls')),
]

# Servir les médias en développement
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)