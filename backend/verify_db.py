"""
Script to verify the database contents.
"""

import os
from app import create_app, db
from app.models.medication import Medication, Category, MedicationImage
from app.models.farm_activity import FarmActivity
from app.models.user import User

# Force production environment
os.environ['FLASK_ENV'] = 'production'
app = create_app('production')

def verify_db():
    with app.app_context():
        print(f"Connected to database: {db.engine.url}")
        
        # Check all tables
        print("\n=== DATABASE COUNTS ===")
        print(f"Users: {User.query.count()}")
        print(f"Categories: {Category.query.count()}")
        print(f"Medications: {Medication.query.count()}")
        print(f"Medication Images: {MedicationImage.query.count()}")
        print(f"Farm Activities: {FarmActivity.query.count()}")
        
        # Print some sample data
        print("\n=== SAMPLE DATA ===")
        print("\nCategories:")
        for category in Category.query.limit(5).all():
            print(f"  - {category.id}: {category.name} ({category.medication_type})")
        
        print("\nMedications:")
        for med in Medication.query.limit(5).all():
            print(f"  - {med.id}: {med.name} (Price: {med.price}, Type: {med.medication_type})")
        
        print("\nFarm Activities:")
        for activity in FarmActivity.query.limit(5).all():
            print(f"  - {activity.id}: {activity.name} (Price: {activity.price})")

if __name__ == "__main__":
    verify_db()
