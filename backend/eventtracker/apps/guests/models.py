from django.db import models

# Create your models here.
from django.db import models
from apps.users.models import User
from apps.events.models import Event

class GuestGroup(models.Model):
    name = models.CharField(max_length=100)
    event = models.ForeignKey(Event, on_delete=models.CASCADE, related_name='guest_groups')
    
    def __str__(self):
        return f"{self.name} - {self.event.title}"

class Guest(models.Model):
    RESPONSE_CHOICES = [
        ('pending', 'En attente'),
        ('accepted', 'Accepté'),
        ('declined', 'Refusé'),
    ]
    
    event = models.ForeignKey(Event, on_delete=models.CASCADE, related_name='guests')
    group = models.ForeignKey(GuestGroup, on_delete=models.SET_NULL, null=True, blank=True, related_name='guests')
    user = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True)
    name = models.CharField(max_length=255)
    email = models.EmailField(blank=True)
    phone = models.CharField(max_length=15, blank=True)
    response_status = models.CharField(max_length=10, choices=RESPONSE_CHOICES, default='pending')
    plus_ones = models.PositiveIntegerField(default=0)
    note = models.TextField(blank=True)
    invited_at = models.DateTimeField(auto_now_add=True)
    responded_at = models.DateTimeField(null=True, blank=True)
    
    def __str__(self):
        return self.name

class Invitation(models.Model):
    guest = models.ForeignKey(Guest, on_delete=models.CASCADE, related_name='invitations')
    message = models.TextField(blank=True)
    sent_at = models.DateTimeField(auto_now_add=True)
    viewed_at = models.DateTimeField(null=True, blank=True)
    unique_code = models.CharField(max_length=100, unique=True)
    
    def __str__(self):
        return f"Invitation pour {self.guest.name}"