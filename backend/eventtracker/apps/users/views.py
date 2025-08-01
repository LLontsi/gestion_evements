from django.shortcuts import render

# Create your views here.
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.authtoken.models import Token
from rest_framework.authtoken.views import ObtainAuthToken
from django.contrib.auth import get_user_model
from .models import UserPreference
from .serializers import UserSerializer, UserPreferenceSerializer, RegisterSerializer

User = get_user_model()

class RegisterView(generics.CreateAPIView):
    """Vue pour l'inscription des utilisateurs"""
    queryset = User.objects.all()
    serializer_class = RegisterSerializer
    permission_classes = [permissions.AllowAny]

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        
        # Créer les préférences utilisateur par défaut
        UserPreference.objects.create(user=user)
        
        # Créer un token pour l'utilisateur
        token, created = Token.objects.get_or_create(user=user)
        
        return Response({
            'user': UserSerializer(user, context=self.get_serializer_context()).data,
            'token': token.key
        }, status=status.HTTP_201_CREATED)


class CustomAuthToken(ObtainAuthToken):
    def post(self, request, *args, **kwargs):
        # Obtenez l'email et le mot de passe de la requête
        email = request.data.get('email')
        password = request.data.get('password')
        
        if not email or not password:
            return Response(
                {'error': 'L\'email et le mot de passe sont requis'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Recherchez l'utilisateur par email
        User = get_user_model()
        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return Response(
                {'error': 'Aucun utilisateur trouvé avec cet email'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Vérifiez le mot de passe
        if not user.check_password(password):
            return Response(
                {'error': 'Mot de passe incorrect'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Créez ou récupérez un token
        token, created = Token.objects.get_or_create(user=user)
        
        # Renvoyez le token et les données utilisateur
        return Response({
            'token': token.key,
            'user': UserSerializer(user).data
        })
        
class UserProfileView(generics.RetrieveUpdateAPIView):
    """Vue pour récupérer et mettre à jour le profil utilisateur"""
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_object(self):
        return self.request.user

class UserPreferenceView(generics.RetrieveUpdateAPIView):
    """Vue pour récupérer et mettre à jour les préférences utilisateur"""
    serializer_class = UserPreferenceSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_object(self):
        return UserPreference.objects.get(user=self.request.user)