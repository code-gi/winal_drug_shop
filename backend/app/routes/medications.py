from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.models.medication import Medication, Category, MedicationImage
from app import db

medications_bp = Blueprint('medications', __name__)

@medications_bp.route('/', methods=['GET'])
def get_medications():
    """Get all medications with optional filtering"""
    # Get query parameters for filtering
    category_id = request.args.get('category_id', type=int)
    medication_type = request.args.get('type')  # 'human' or 'animal'
    search_query = request.args.get('q')
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 10, type=int)
    
    # Base query
    query = Medication.query
    
    # Apply filters if provided
    if category_id:
        query = query.filter_by(category_id=category_id)
    if medication_type:
        query = query.filter_by(medication_type=medication_type)
    if search_query:
        query = query.filter(Medication.name.ilike(f'%{search_query}%'))
    
    # Paginate results
    paginated_medications = query.paginate(page=page, per_page=per_page, error_out=False)
    
    # Format response
    medications = []
    for med in paginated_medications.items:
        # Get medication images
        images = []
        for img in med.images:
            images.append({
                'id': img.id,
                'url': img.image_url,
                'is_primary': img.is_primary
            })
            
        medications.append({
            'id': med.id,
            'name': med.name,
            'description': med.description,
            'price': med.price,
            'stock_quantity': med.stock_quantity,
            'medication_type': med.medication_type,
            'category_id': med.category_id,
            'category_name': med.category.name if med.category else None,
            'requires_prescription': med.requires_prescription,
            'thumbnail_url': med.get_thumbnail_url(),
            'images': images,
            'created_at': med.created_at.strftime('%Y-%m-%d %H:%M:%S')
        })
    
    return jsonify({
        'medications': medications,
        'total': paginated_medications.total,
        'pages': paginated_medications.pages,
        'current_page': paginated_medications.page
    }), 200

@medications_bp.route('/<int:medication_id>', methods=['GET'])
def get_medication(medication_id):
    """Get a specific medication by ID"""
    medication = Medication.query.get_or_404(medication_id)
    
    # Get all images for this medication
    images = []
    for img in medication.images:
        images.append({
            'id': img.id,
            'url': img.image_url,
            'is_primary': img.is_primary
        })
    
    result = {
        'id': medication.id,
        'name': medication.name,
        'description': medication.description,
        'full_details': medication.full_details,
        'price': medication.price,
        'stock_quantity': medication.stock_quantity,
        'medication_type': medication.medication_type,
        'category_id': medication.category_id,
        'category_name': medication.category.name if medication.category else None,
        'requires_prescription': medication.requires_prescription,
        'dosage_instructions': medication.dosage_instructions,
        'contraindications': medication.contraindications,
        'side_effects': medication.side_effects,
        'storage_instructions': medication.storage_instructions,
        'images': images,
        'created_at': medication.created_at.strftime('%Y-%m-%d %H:%M:%S'),
        'updated_at': medication.updated_at.strftime('%Y-%m-%d %H:%M:%S')
    }
    
    return jsonify(result), 200

@medications_bp.route('/categories', methods=['GET'])
def get_categories():
    """Get all medication categories"""
    categories = Category.query.all()
    
    result = []
    for category in categories:
        result.append({
            'id': category.id,
            'name': category.name,
            'description': category.description,
            'medication_type': category.medication_type
        })
    
    return jsonify(result), 200

@medications_bp.route('/', methods=['POST'])
@jwt_required()
def create_medication():
    """Create a new medication (admin only)"""
    # Verify the user is an admin
    user_id = get_jwt_identity()
    from app.models.user import User
    user = User.query.get(user_id)
    
    if not user or not user.is_admin:
        return jsonify({'message': 'Admin access required'}), 403
    
    data = request.get_json()
    
    # Validate required fields
    required_fields = ['name', 'price', 'medication_type', 'stock_quantity']
    for field in required_fields:
        if field not in data:
            return jsonify({'message': f'Missing required field: {field}'}), 400
    
    # Create new medication
    new_medication = Medication(
        name=data['name'],
        description=data.get('description', ''),
        full_details=data.get('full_details', ''),
        price=data['price'],
        stock_quantity=data['stock_quantity'],
        medication_type=data['medication_type'],
        category_id=data.get('category_id'),
        requires_prescription=data.get('requires_prescription', False),
        dosage_instructions=data.get('dosage_instructions', ''),
        contraindications=data.get('contraindications', ''),
        side_effects=data.get('side_effects', ''),
        storage_instructions=data.get('storage_instructions', '')
    )
    
    db.session.add(new_medication)
    db.session.commit()
    
    # Handle images if provided
    if 'images' in data and isinstance(data['images'], list):
        for img_data in data['images']:
            image = MedicationImage(
                medication_id=new_medication.id,
                image_url=img_data.get('url', ''),
                is_primary=img_data.get('is_primary', False)
            )
            db.session.add(image)
        
        db.session.commit()
    
    return jsonify({
        'message': 'Medication created successfully',
        'medication_id': new_medication.id
    }), 201

@medications_bp.route('/<int:medication_id>', methods=['PUT'])
@jwt_required()
def update_medication(medication_id):
    """Update an existing medication (admin only)"""
    # Verify the user is an admin
    user_id = get_jwt_identity()
    from app.models.user import User
    user = User.query.get(user_id)
    
    if not user or not user.is_admin:
        return jsonify({'message': 'Admin access required'}), 403
    
    # Find the medication
    medication = Medication.query.get_or_404(medication_id)
    
    data = request.get_json()
    
    # Update fields that are provided
    if 'name' in data:
        medication.name = data['name']
    if 'description' in data:
        medication.description = data['description']
    if 'full_details' in data:
        medication.full_details = data['full_details']
    if 'price' in data:
        medication.price = data['price']
    if 'stock_quantity' in data:
        medication.stock_quantity = data['stock_quantity']
    if 'medication_type' in data:
        medication.medication_type = data['medication_type']
    if 'category_id' in data:
        medication.category_id = data['category_id']
    if 'requires_prescription' in data:
        medication.requires_prescription = data['requires_prescription']
    if 'dosage_instructions' in data:
        medication.dosage_instructions = data['dosage_instructions']
    if 'contraindications' in data:
        medication.contraindications = data['contraindications']
    if 'side_effects' in data:
        medication.side_effects = data['side_effects']
    if 'storage_instructions' in data:
        medication.storage_instructions = data['storage_instructions']
    
    db.session.commit()
    
    # Handle images if provided - this is a simplified approach
    # For a more complete solution, you'd want to handle adding, updating, and removing specific images
    if 'images' in data and isinstance(data['images'], list):
        # Remove existing images
        MedicationImage.query.filter_by(medication_id=medication_id).delete()
        
        # Add new images
        for img_data in data['images']:
            image = MedicationImage(
                medication_id=medication.id,
                image_url=img_data.get('url', ''),
                is_primary=img_data.get('is_primary', False)
            )
            db.session.add(image)
        
        db.session.commit()
    
    return jsonify({'message': 'Medication updated successfully'}), 200

@medications_bp.route('/<int:medication_id>', methods=['DELETE'])
@jwt_required()
def delete_medication(medication_id):
    """Delete a medication (admin only)"""
    # Verify the user is an admin
    user_id = get_jwt_identity()
    from app.models.user import User
    user = User.query.get(user_id)
    
    if not user or not user.is_admin:
        return jsonify({'message': 'Admin access required'}), 403
    
    # Find the medication
    medication = Medication.query.get_or_404(medication_id)
    
    # Delete related images first
    MedicationImage.query.filter_by(medication_id=medication_id).delete()
    
    # Delete the medication
    db.session.delete(medication)
    db.session.commit()
    
    return jsonify({'message': 'Medication deleted successfully'}), 200