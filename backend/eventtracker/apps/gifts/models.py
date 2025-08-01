from django.db import models

# Create your models here.
from django.db import models
from apps.users.models import User
from apps.events.models import Event

class GiftList(models.Model):
    name = models.CharField(max_length=255)
    event = models.OneToOneField(Event, on_delete=models.CASCADE, related_name='gift_list')
    description = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return self.name

class Gift(models.Model):
    STATUS_CHOICES = [
        ('available', 'Disponible'),
        ('reserved', 'Réservé'),
        ('purchased', 'Acheté'),
    ]
    
    list = models.ForeignKey(GiftList, on_delete=models.CASCADE, related_name='gifts')
    name = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    price = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    url = models.URLField(blank=True)
    image = models.ImageField(upload_to='gifts/', blank=True, null=True)
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='available')
    reserved_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return self.name