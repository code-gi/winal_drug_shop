"""
Script to force populate farm activities into the PostgreSQL database.
"""

import os
from app import create_app, db
from app.models.farm_activity import FarmActivity
from datetime import datetime

# Force production environment
os.environ['FLASK_ENV'] = 'production' 
app = create_app('production')

def force_populate_farm_activities():
    with app.app_context():
        print(f"Connected to database: {db.engine.url}")
        
        # Clear existing farm activities
        print("Clearing existing farm activities...")
        FarmActivity.query.delete()
        db.session.commit()
        print("Existing farm activities cleared.")
        
        # Create farm activities
        print("Creating farm activities...")
        farm_activities = [
            {
                "name": "Farm Consultation Visit",
                "description": "Professional consultation visit to assess farm health and provide recommendations",
                "image_path": "assets/images/FARM VISITS.jpeg",
                "price": 150.00,
                "duration": 120  # 2 hours
            },
            {
                "name": "Animal Health Workshop",
                "description": "Educational workshop covering animal health, nutrition, and disease prevention",
                "image_path": "assets/images/SEMINARS.jpeg",
                "price": 75.00,
                "duration": 180  # 3 hours
            },
            {
                "name": "Vaccination Service",
                "description": "Comprehensive vaccination service for farm animals",
                "image_path": "assets/images/IMMUNITY.jpeg",
                "price": 200.00,
                "duration": 240  # 4 hours
            },
            {
                "name": "Nutrition Planning",
                "description": "Custom nutrition planning and feed management consultation",
                "image_path": "assets/images/DIET.jpeg",
                "price": 100.00,
                "duration": 90  # 1.5 hours
            },
            {
                "name": "Emergency Farm Visit",
                "description": "24/7 emergency veterinary services for urgent farm issues",
                "image_path": "assets/images/CONSTRUCTION.jpeg",
                "price": 250.00,
                "duration": 120  # 2 hours
            }
        ]

        for activity_data in farm_activities:
            activity = FarmActivity(**activity_data)
            db.session.add(activity)
        
        db.session.commit()
        print(f"Successfully added {len(farm_activities)} farm activities.")
        
        # Verify the count
        count = FarmActivity.query.count()
        print(f"Total farm activities in database: {count}")

if __name__ == "__main__":
    force_populate_farm_activities()
