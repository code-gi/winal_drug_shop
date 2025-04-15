from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.cart import Cart, CartItem
from app.models.medication import Medication
from app.models.user import User
from datetime import datetime
import logging

# Set up logging
logger = logging.getLogger(__name__)

cart_bp = Blueprint('cart', __name__)

@cart_bp.route('/', methods=['GET'])
@jwt_required()
def get_cart():
    """Get the current user's cart"""
    print("🛒 Getting user's cart...")
    user_id = get_jwt_identity()
    print(f"👤 User ID: {user_id}")

    try:
        # Get user's active cart
        cart = Cart.query.filter_by(user_id=user_id, status='active').first()
        print(f"🛍️ Cart found: {cart}")

        if not cart:
            print("📭 No active cart found")
            return jsonify({
                'message': 'No active cart found',
                'items': [],
                'total': 0
            }), 200

        # Get cart items with medication details
        cart_data = {
            'id': cart.id,
            'items': [],
            'total': 0
        }

        for item in cart.items:
            medication = Medication.query.get(item.medication_id)
            if medication:
                item_data = {
                    'id': item.id,
                    'medication_id': medication.id,
                    'name': medication.name,
                    'price': medication.price,
                    'quantity': item.quantity,
                    'subtotal': medication.price * item.quantity
                }
                cart_data['items'].append(item_data)
                cart_data['total'] += item_data['subtotal']

        print(f"✅ Cart data compiled: {cart_data}")
        return jsonify(cart_data), 200

    except Exception as e:
        print(f"❌ Error getting cart: {str(e)}")
        return jsonify({'message': f'Error getting cart: {str(e)}'}), 500

@cart_bp.route('/add', methods=['POST'])
@jwt_required()
def add_to_cart():
    """Add an item to the cart"""
    print("➕ Adding item to cart...")
    user_id = get_jwt_identity()
    print(f"👤 User ID: {user_id}")

    data = request.get_json()
    print(f"📦 Request data: {data}")

    try:
        # Validate required fields
        if not data or 'medication_id' not in data or 'quantity' not in data:
            print("❌ Missing required fields")
            return jsonify({'message': 'Missing required fields'}), 400

        # Get or create active cart
        cart = Cart.query.filter_by(user_id=user_id, status='active').first()
        if not cart:
            print("🛍️ Creating new cart")
            cart = Cart(user_id=user_id, status='active')
            db.session.add(cart)
            db.session.flush()

        # Check if medication exists
        medication = Medication.query.get(data['medication_id'])
        if not medication:
            print(f"❌ Medication not found: {data['medication_id']}")
            return jsonify({'message': 'Medication not found'}), 404

        # Check if item already in cart
        cart_item = CartItem.query.filter_by(
            cart_id=cart.id,
            medication_id=data['medication_id']
        ).first()

        if cart_item:
            print("📝 Updating existing cart item")
            cart_item.quantity += data['quantity']
        else:
            print("📝 Creating new cart item")
            cart_item = CartItem(
                cart_id=cart.id,
                medication_id=data['medication_id'],
                quantity=data['quantity']
            )
            db.session.add(cart_item)

        db.session.commit()
        print("✅ Item added to cart successfully")
        return jsonify({'message': 'Item added to cart successfully'}), 200

    except Exception as e:
        print(f"❌ Error adding to cart: {str(e)}")
        db.session.rollback()
        return jsonify({'message': f'Error adding to cart: {str(e)}'}), 500

@cart_bp.route('/update/<int:item_id>', methods=['PUT'])
@jwt_required()
def update_cart_item(item_id):
    """Update cart item quantity"""
    print(f"📝 Updating cart item {item_id}...")
    user_id = get_jwt_identity()
    print(f"👤 User ID: {user_id}")

    data = request.get_json()
    print(f"📦 Request data: {data}")

    try:
        if 'quantity' not in data:
            print("❌ Missing quantity field")
            return jsonify({'message': 'Quantity is required'}), 400

        # Get user's active cart
        cart = Cart.query.filter_by(user_id=user_id, status='active').first()
        if not cart:
            print("❌ No active cart found")
            return jsonify({'message': 'No active cart found'}), 404

        # Find cart item
        cart_item = CartItem.query.filter_by(id=item_id, cart_id=cart.id).first()
        if not cart_item:
            print("❌ Cart item not found")
            return jsonify({'message': 'Cart item not found'}), 404

        # Update quantity
        cart_item.quantity = data['quantity']
        db.session.commit()
        print("✅ Cart item updated successfully")
        return jsonify({'message': 'Cart item updated successfully'}), 200

    except Exception as e:
        print(f"❌ Error updating cart item: {str(e)}")
        db.session.rollback()
        return jsonify({'message': f'Error updating cart item: {str(e)}'}), 500

@cart_bp.route('/remove/<int:item_id>', methods=['DELETE'])
@jwt_required()
def remove_from_cart(item_id):
    """Remove item from cart"""
    print(f"🗑️ Removing item {item_id} from cart...")
    user_id = get_jwt_identity()
    print(f"👤 User ID: {user_id}")

    try:
        # Get user's active cart
        cart = Cart.query.filter_by(user_id=user_id, status='active').first()
        if not cart:
            print("❌ No active cart found")
            return jsonify({'message': 'No active cart found'}), 404

        # Find and remove cart item
        cart_item = CartItem.query.filter_by(id=item_id, cart_id=cart.id).first()
        if not cart_item:
            print("❌ Cart item not found")
            return jsonify({'message': 'Cart item not found'}), 404

        db.session.delete(cart_item)
        db.session.commit()
        print("✅ Item removed from cart successfully")
        return jsonify({'message': 'Item removed from cart successfully'}), 200

    except Exception as e:
        print(f"❌ Error removing from cart: {str(e)}")
        db.session.rollback()
        return jsonify({'message': f'Error removing from cart: {str(e)}'}), 500

@cart_bp.route('/clear', methods=['POST'])
@jwt_required()
def clear_cart():
    """Clear all items from cart"""
    print("🗑️ Clearing cart...")
    user_id = get_jwt_identity()
    print(f"👤 User ID: {user_id}")

    try:
        # Get user's active cart
        cart = Cart.query.filter_by(user_id=user_id, status='active').first()
        if not cart:
            print("❌ No active cart found")
            return jsonify({'message': 'No active cart found'}), 404

        # Remove all items
        CartItem.query.filter_by(cart_id=cart.id).delete()
        db.session.commit()
        print("✅ Cart cleared successfully")
        return jsonify({'message': 'Cart cleared successfully'}), 200

    except Exception as e:
        print(f"❌ Error clearing cart: {str(e)}")
        db.session.rollback()
        return jsonify({'message': f'Error clearing cart: {str(e)}'}), 500
