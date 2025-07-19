from django.urls import path
from . import views
urlpatterns = [
    path('', views.contact_list, name='contact_list'),
    path('add/', views.contact_create, name='contact_create'),
    path('edit/<int:pk>/', views.contact_edit, name='contact_edit'),
    path('delete/<int:pk>/', views.contact_delete, name='contact_delete'),
]
