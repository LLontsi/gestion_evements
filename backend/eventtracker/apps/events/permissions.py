from rest_framework import permissions

class IsEventOwner(permissions.BasePermission):
    """Permission personnalisée pour autoriser uniquement les propriétaires d'événements à les modifier"""
    
    def has_object_permission(self, request, view, obj):
        # Les permissions en lecture sont autorisées pour toute demande
        if request.method in permissions.SAFE_METHODS:
            return True
            
        # Les autorisations d'écriture ne sont autorisées qu'au propriétaire de l'événement
        return obj.created_by == request.user