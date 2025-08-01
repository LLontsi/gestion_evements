from rest_framework import viewsets, permissions, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from .models import EventType, Event, Reminder
from .serializers import EventTypeSerializer, EventSerializer, EventDetailSerializer, ReminderSerializer
from .permissions import IsEventOwner

class EventTypeViewSet(viewsets.ReadOnlyModelViewSet):
    """Vue pour les types d'événements"""
    queryset = EventType.objects.all()
    serializer_class = EventTypeSerializer
    permission_classes = [permissions.IsAuthenticated]
    
class EventViewSet(viewsets.ModelViewSet):
    """Vue pour les événements"""
    serializer_class = EventSerializer
    permission_classes = [permissions.IsAuthenticated, IsEventOwner]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['event_type', 'start_date', 'is_private']
    search_fields = ['title', 'description', 'location']
    ordering_fields = ['start_date', 'created_at']
    ordering = ['-start_date']
    
    def get_queryset(self):
        """Retourne les événements de l'utilisateur connecté"""
        return Event.objects.filter(created_by=self.request.user)
    
    def perform_create(self, serializer):
        """Associe l'utilisateur connecté à l'événement lors de la création"""
        serializer.save(created_by=self.request.user)
        
    def get_serializer_class(self):
        """Utilise le sérialiseur détaillé pour les actions retrieve"""
        if self.action == 'retrieve':
            return EventDetailSerializer
        return self.serializer_class
    
    @action(detail=False, methods=['get'])
    def upcoming(self, request):
        """Endpoint pour récupérer les événements à venir"""
        from django.utils import timezone
        events = self.get_queryset().filter(start_date__gte=timezone.now())
        serializer = self.get_serializer(events, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def by_month(self, request):
        """Endpoint pour récupérer les événements d'un mois spécifique"""
        year = int(request.query_params.get('year', timezone.now().year))
        month = int(request.query_params.get('month', timezone.now().month))
        
        from django.db.models import Q
        from datetime import datetime
        
        start_date = datetime(year, month, 1)
        if month == 12:
            end_date = datetime(year + 1, 1, 1)
        else:
            end_date = datetime(year, month + 1, 1)
        
        events = self.get_queryset().filter(
            Q(start_date__gte=start_date, start_date__lt=end_date) |
            Q(end_date__gte=start_date, end_date__lt=end_date)
        )
        
        serializer = self.get_serializer(events, many=True)
        return Response(serializer.data)

class ReminderViewSet(viewsets.ModelViewSet):
    """Vue pour les rappels"""
    serializer_class = ReminderSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        """Retourne les rappels des événements de l'utilisateur connecté"""
        return Reminder.objects.filter(event__created_by=self.request.user)
    
    def perform_create(self, serializer):
        """Vérifie que l'événement appartient à l'utilisateur connecté"""
        event_id = self.request.data.get('event')
        event = Event.objects.get(id=event_id)
        
        if event.created_by != self.request.user:
            from rest_framework.exceptions import PermissionDenied
            raise PermissionDenied("Vous n'êtes pas autorisé à ajouter un rappel à cet événement.")
            
        serializer.save()