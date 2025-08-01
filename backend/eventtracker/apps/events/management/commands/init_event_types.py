from django.core.management.base import BaseCommand
from apps.events.models import EventType

class Command(BaseCommand):
    help = 'Initialise les types d\'événements dans la base de données'

    def handle(self, *args, **kwargs):
        # Définir les types d'événements par défaut
        event_types = [
            {'name': 'Anniversaire', 'icon': 'cake', 'color': '#FF4081'},
            {'name': 'Mariage', 'icon': 'favorite', 'color': '#AB47BC'},
            {'name': 'Fête', 'icon': 'celebration', 'color': '#26A69A'},
            {'name': 'Réunion', 'icon': 'people', 'color': '#42A5F5'},
            {'name': 'Conférence', 'icon': 'mic', 'color': '#5C6BC0'},
            {'name': 'Voyage', 'icon': 'flight', 'color': '#66BB6A'},
            {'name': 'Dîner', 'icon': 'restaurant', 'color': '#FFA726'},
            {'name': 'Sport', 'icon': 'directions_run', 'color': '#EF5350'},
            {'name': 'Deuil', 'icon': 'format_color_reset', 'color': '#78909C'},
        ]
        
        # Créer les types d'événements s'ils n'existent pas déjà
        for event_type in event_types:
            EventType.objects.get_or_create(
                name=event_type['name'],
                defaults={
                    'icon': event_type['icon'],
                    'color': event_type['color']
                }
            )
            
        self.stdout.write(
            self.style.SUCCESS(f'Types d\'événements initialisés avec succès ({len(event_types)} types)')
        )