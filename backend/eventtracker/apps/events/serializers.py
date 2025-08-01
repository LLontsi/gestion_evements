from rest_framework import serializers
from .models import EventType, Event, Reminder

class EventTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = EventType
        fields = '__all__'

class ReminderSerializer(serializers.ModelSerializer):
    class Meta:
        model = Reminder
        fields = ['id', 'reminder_date', 'message', 'sent']

class EventSerializer(serializers.ModelSerializer):
    event_type_name = serializers.CharField(source='event_type.name', read_only=True)
    event_type_color = serializers.CharField(source='event_type.color', read_only=True)
    reminders = ReminderSerializer(many=True, read_only=True)
    
    class Meta:
        model = Event
        fields = ['id', 'title', 'event_type', 'event_type_name', 'event_type_color', 
                  'description', 'location', 'start_date', 'end_date', 
                  'created_by', 'created_at', 'updated_at', 'is_private', 'reminders']
        read_only_fields = ['created_by', 'created_at', 'updated_at']
        
    def create(self, validated_data):
        validated_data['created_by'] = self.context['request'].user
        return super().create(validated_data)

class EventDetailSerializer(EventSerializer):
    """Sérialiseur pour les détails complets d'un événement"""
    class Meta(EventSerializer.Meta):
        fields = EventSerializer.Meta.fields + ['guests', 'tasks', 'gift_list']