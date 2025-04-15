"""Script to populate the database with sample farm activities.
Run this script after setting up the database to add initial data.
"""

from app import create_app, db
from app.models.farm_activity import FarmActivity
from datetime import datetime

app = create_app()

def populate_farm_activities():
    with app.app_context():
        # Check if data already exists
        if FarmActivity.query.count() > 0:
            print("Database already has farm activities. Skipping population.")
            return

        # Sample farm activities data
        activities = [
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

        # Add activities to database
        for activity_data in activities:
            activity = FarmActivity(
                name=activity_data["name"],
                description=activity_data["description"],
                image_path=activity_data["image_path"],
                price=activity_data["price"],
                duration=activity_data["duration"]
            )
            db.session.add(activity)

        try:
            db.session.commit()
            print("Successfully populated farm activities table.")
        except Exception as e:
            db.session.rollback()
            print(f"Error populating farm activities: {str(e)}")

if __name__ == "__main__":
    populate_farm_activities()