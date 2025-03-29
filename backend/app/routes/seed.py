from flask import Blueprint, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.models.medication import Category, Medication, MedicationImage
from app.models.user import User
from app import db

seed_bp = Blueprint('seed', __name__)

@seed_bp.route('/init', methods=['POST'])
@jwt_required()
def seed_initial_data():
    """Seed the database with initial categories and medications (admin only)"""
    # Verify the user is an admin
    user_id = get_jwt_identity()
    user = User.query.get(user_id)
    
    if not user or not user.is_admin:
        return jsonify({'message': 'Admin access required'}), 403
    
    try:
        # Create human medication categories
        human_categories = [
            {'name': 'Antibiotics', 'description': 'Medications that kill or inhibit the growth of bacteria'},
            {'name': 'Painkillers', 'description': 'Medications that relieve pain'},
            {'name': 'Antiviral', 'description': 'Medications used to treat viral infections'},
            {'name': 'Antihistamines', 'description': 'Medications that oppose the action of histamine'},
            {'name': 'Vitamins & Supplements', 'description': 'Nutritional supplements and vitamins'}
        ]
        
        # Create animal medication categories
        animal_categories = [
            {'name': 'Dewormers', 'description': 'Medications that rid animals of worms and internal parasites'},
            {'name': 'Antibiotics', 'description': 'Antibiotics specifically formulated for animals'},
            {'name': 'Flea & Tick Control', 'description': 'Products to control external parasites'},
            {'name': 'Supplements', 'description': 'Nutritional supplements for animals'},
            {'name': 'Vaccines', 'description': 'Preventative vaccines for animals'}
        ]
        
        # Add human categories
        for cat_data in human_categories:
            category = Category(
                name=cat_data['name'],
                description=cat_data['description'],
                medication_type='human'
            )
            db.session.add(category)
        
        # Add animal categories
        for cat_data in animal_categories:
            category = Category(
                name=cat_data['name'],
                description=cat_data['description'],
                medication_type='animal'
            )
            db.session.add(category)
        
        db.session.commit()
        
        # Get created categories
        human_cats = Category.query.filter_by(medication_type='human').all()
        animal_cats = Category.query.filter_by(medication_type='animal').all()
        
        # Sample human medications
        human_meds = [
            {
                'name': 'Amoxicillin 500mg',
                'description': 'Antibiotic used to treat bacterial infections',
                'price': 15.99,
                'stock_quantity': 100,
                'requires_prescription': True,
                'category': human_cats[0],  # Antibiotics
                'dosage_instructions': 'Take one capsule three times daily with food',
                'side_effects': 'Diarrhea, nausea, vomiting, rash',
                'image_url': '/static/images/amoxicillin.jpg'
            },
            {
                'name': 'Paracetamol 500mg',
                'description': 'Pain reliever and fever reducer',
                'price': 5.99,
                'stock_quantity': 200,
                'requires_prescription': False,
                'category': human_cats[1],  # Painkillers
                'dosage_instructions': 'Take 1-2 tablets every 4-6 hours as needed',
                'side_effects': 'Nausea, stomach pain, loss of appetite',
                'image_url': '/static/images/panadol.jpeg'
            },
            {
                'name': 'Vitamin C 1000mg',
                'description': 'Supports immune function',
                'price': 8.99,
                'stock_quantity': 150,
                'requires_prescription': False,
                'category': human_cats[4],  # Vitamins & Supplements
                'dosage_instructions': 'Take one tablet daily with food',
                'side_effects': 'Nausea, vomiting, heartburn, stomach cramps',
                'image_url': '/static/images/vitamin.jpeg'
            }
        ]
        
        # Sample animal medications
        animal_meds = [
            {
                'name': 'Vetmedin 5mg',
                'description': 'Heart medication for dogs',
                'price': 45.99,
                'stock_quantity': 50,
                'requires_prescription': True,
                'category': animal_cats[3],  # Supplements
                'dosage_instructions': 'Give as directed by veterinarian',
                'side_effects': 'Vomiting, diarrhea, loss of appetite',
                'image_url': '/static/images/DOG.jpeg'
            },
            {
                'name': 'Frontline Plus for Cats',
                'description': 'Flea and tick control for cats',
                'price': 35.99,
                'stock_quantity': 75,
                'requires_prescription': False,
                'category': animal_cats[2],  # Flea & Tick Control
                'dosage_instructions': 'Apply one dose monthly',
                'side_effects': 'Temporary irritation at application site',
                'image_url': '/static/images/CAT.jpeg'
            },
            {
                'name': 'Panacur Dewormer',
                'description': 'Deworming medication for dogs and cats',
                'price': 18.99,
                'stock_quantity': 100,
                'requires_prescription': False,
                'category': animal_cats[0],  # Dewormers
                'dosage_instructions': 'Administer according to weight. See packaging for details.',
                'side_effects': 'Mild vomiting or diarrhea may occur',
                'image_url': '/static/images/DEWORMER.jpg'
            }
        ]
        
        # Add human medications
        for med_data in human_meds:
            medication = Medication(
                name=med_data['name'],
                description=med_data['description'],
                price=med_data['price'],
                stock_quantity=med_data['stock_quantity'],
                medication_type='human',
                category_id=med_data['category'].id,
                requires_prescription=med_data['requires_prescription'],
                dosage_instructions=med_data['dosage_instructions'],
                side_effects=med_data['side_effects']
            )
            db.session.add(medication)
            db.session.flush()  # To get the medication ID
            
            # Add image
            image = MedicationImage(
                medication_id=medication.id,
                image_url=med_data['image_url'],
                is_primary=True
            )
            db.session.add(image)
        
        # Add animal medications
        for med_data in animal_meds:
            medication = Medication(
                name=med_data['name'],
                description=med_data['description'],
                price=med_data['price'],
                stock_quantity=med_data['stock_quantity'],
                medication_type='animal',
                category_id=med_data['category'].id,
                requires_prescription=med_data['requires_prescription'],
                dosage_instructions=med_data['dosage_instructions'],
                side_effects=med_data['side_effects']
            )
            db.session.add(medication)
            db.session.flush()  # To get the medication ID
            
            # Add image
            image = MedicationImage(
                medication_id=medication.id,
                image_url=med_data['image_url'],
                is_primary=True
            )
            db.session.add(image)
        
        db.session.commit()
        
        return jsonify({
            'message': 'Database seeded successfully',
            'categories_created': len(human_categories) + len(animal_categories),
            'medications_created': len(human_meds) + len(animal_meds)
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'message': f'Error seeding database: {str(e)}'}), 500