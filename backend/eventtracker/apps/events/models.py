from django.db import models
from apps.users.models import User

class EventType(models.Model):
    name = models.CharField(max_length=100)
    icon = models.CharField(max_length=50, blank=True)
    color = models.CharField(max_length=7, default="#6200EE")  # Format hexadécimal
    
    def __str__(self):
        return self.name

class Event(models.Model):
    title = models.CharField(max_length=255)
    event_type = models.ForeignKey(EventType, on_delete=models.CASCADE)
    description = models.TextField(blank=True)
    location = models.CharField(max_length=255, blank=True)
    start_date = models.DateTimeField()
    end_date = models.DateTimeField(null=True, blank=True)
    created_by = models.ForeignKey(User, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    is_private = models.BooleanField(default=False)
    
    def __str__(self):
        return self.title
        
class Reminder(models.Model):
    event = models.ForeignKey(Event, on_delete=models.CASCADE, related_name='reminders')
    reminder_date = models.DateTimeField()
    message = models.CharField(max_length=255, blank=True)
    sent = models.BooleanField(default=False)
    
    def __str__(self):
        return f"Rappel pour {self.event.title}"