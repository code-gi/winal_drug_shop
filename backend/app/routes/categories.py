from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.models.medication import Category
from app import db

categories_bp = Blueprint('categories', __name__)

@categories_bp.route('/', methods=['GET'])
def get_all_categories():
    """Get all medication categories with optional filtering"""
    # Get query parameters for filtering
    medication_type = request.args.get('type')  # 'human' or 'animal'
    
    # Base query
    query = Category.query
    
    # Apply filters if provided
    if medication_type:
        query = query.filter_by(medication_type=medication_type)
    
    # Get all categories
    categories = query.all()
    
    # Format response
    result = []
    for category in categories:
        result.append({
            'id': category.id,
            'name': category.name,
            'description': category.description,
            'medication_type': category.medication_type,
            'medication_count': len(category.medications)
        })
    
    return jsonify(result), 200

@categories_bp.route('/<int:category_id>', methods=['GET'])
def get_category(category_id):
    """Get a specific category by ID"""
    category = Category.query.get_or_404(category_id)
    
    result = {
        'id': category.id,
        'name': category.name,
        'description': category.description,
        'medication_type': category.medication_type,
        'medications': [{
            'id': med.id,
            'name': med.name,
            'price': med.price,
            'thumbnail_url': med.get_thumbnail_url()
        } for med in category.medications]
    }
    
    return jsonify(result), 200

@categories_bp.route('/', methods=['POST'])
@jwt_required()
def create_category():
    """Create a new category (admin only)"""
    # Verify the user is an admin
    user_id = get_jwt_identity()
    from app.models.user import User
    user = User.query.get(user_id)
    
    if not user or not user.is_admin:
        return jsonify({'message': 'Admin access required'}), 403
    
    data = request.get_json()
    
    # Validate required fields
    required_fields = ['name', 'medication_type']
    for field in required_fields:
        if field not in data:
            return jsonify({'message': f'Missing required field: {field}'}), 400
    
    # Validate medication_type
    valid_types = ['human', 'animal']
    if data['medication_type'] not in valid_types:
        return jsonify({'message': f'Invalid medication_type. Must be one of: {", ".join(valid_types)}'}), 400
    
    # Create new category
    new_category = Category(
        name=data['name'],
        description=data.get('description', ''),
        medication_type=data['medication_type']
    )
    
    db.session.add(new_category)
    db.session.commit()
    
    return jsonify({
        'message': 'Category created successfully',
        'category_id': new_category.id
    }), 201

@categories_bp.route('/<int:category_id>', methods=['PUT'])
@jwt_required()
def update_category(category_id):
    """Update an existing category (admin only)"""
    # Verify the user is an admin
    user_id = get_jwt_identity()
    from app.models.user import User
    user = User.query.get(user_id)
    
    if not user or not user.is_admin:
        return jsonify({'message': 'Admin access required'}), 403
    
    # Find the category
    category = Category.query.get_or_404(category_id)
    
    data = request.get_json()
    
    # Update fields that are provided
    if 'name' in data:
        category.name = data['name']
    if 'description' in data:
        category.description = data['description']
    if 'medication_type' in data:
        valid_types = ['human', 'animal']
        if data['medication_type'] not in valid_types:
            return jsonify({'message': f'Invalid medication_type. Must be one of: {", ".join(valid_types)}'}), 400
        category.medication_type = data['medication_type']
    
    db.session.commit()
    
    return jsonify({'message': 'Category updated successfully'}), 200

@categories_bp.route('/<int:category_id>', methods=['DELETE'])
@jwt_required()
def delete_category(category_id):
    """Delete a category (admin only)"""
    # Verify the user is an admin
    user_id = get_jwt_identity()
    from app.models.user import User
    user = User.query.get(user_id)
    
    if not user or not user.is_admin:
        return jsonify({'message': 'Admin access required'}), 403
    
    # Find the category
    category = Category.query.get_or_404(category_id)
    
    # Check if there are medications in this category
    if category.medications:
        return jsonify({
            'message': 'Cannot delete category with associated medications. Please reassign or delete the medications first.',
            'medication_count': len(category.medications)
        }), 400
    
    # Delete the category
    db.session.delete(category)
    db.session.commit()
    
    return jsonify({'message': 'Category deleted successfully'}), 200