from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.user import User
from app.models.cart import Order, OrderItem
from datetime import datetime
import uuid

orders_bp = Blueprint('orders', __name__)

@orders_bp.route('/', methods=['GET'])
@jwt_required()
def get_orders():
    """Get all orders for the current user"""
    # Get the user ID from the JWT token
    user_id = get_jwt_identity()
    
    # Find the user in the database
    user = User.query.get(user_id)
    if not user:
        return jsonify({'message': 'User not found'}), 404
    
    # Get all orders for this user
    user_orders = Order.query.filter_by(user_id=user_id).all()
    
    # Convert to JSON response
    orders = []
    for order in user_orders:
        orders.append(order.to_dict())
    print(orders)
    return jsonify({'orders': orders}), 200

@orders_bp.route('/<int:order_id>', methods=['GET'])
@jwt_required()
def get_order(order_id):
    """Get a specific order"""
    # Get the user ID from the JWT token
    user_id = get_jwt_identity()
    
    # Find the order
    order = Order.query.filter_by(id=order_id).first()
    if not order:
        return jsonify({'message': 'Order not found'}), 404
    
    # Ensure user can only access their own orders
    if int(order.user_id) != int(user_id):
        return jsonify({'message': 'Unauthorized to view this order'}), 403
    
    return jsonify({'order': order.to_dict()}), 200

@orders_bp.route('/', methods=['POST'])
@jwt_required()
def create_order():
    """Create a new order"""
    # Get the user ID from the JWT token
    user_id = get_jwt_identity()
    print(f"⭐ Backend: Received order creation request from user ID: {user_id}")
    
    # Find the user in the database
    user = User.query.get(user_id)
    if not user:
        print(f"❌ Backend: User not found for ID: {user_id}")
        return jsonify({'message': 'User not found'}), 404
    
    # Get data from request
    data = request.get_json()
    print(f"📦 Backend: Order data received: {data}")
    
    # Validate required fields
    if not data or 'items' not in data or not data['items']:
        print("❌ Backend: Missing items in order data")
        return jsonify({'message': 'Order must contain at least one item'}), 400
    
    if 'total_amount' not in data:
        print("❌ Backend: Missing total_amount in order data")
        return jsonify({'message': 'Total amount is required'}), 400
    
    if 'payment_method' not in data:
        print("❌ Backend: Missing payment_method in order data")
        return jsonify({'message': 'Payment method is required'}), 400
    
    if 'delivery_address' not in data:
        print("❌ Backend: Missing delivery_address in order data")
        return jsonify({'message': 'Delivery address is required'}), 400
    
    try:
        # Create new order
        order = Order(
            user_id=user_id,
            total_amount=data['total_amount'],
            payment_method=data['payment_method'],
            shipping_address=data['delivery_address'],
            status='pending',
            order_date=datetime.utcnow()
        )
        
        # Add order items
        for item_data in data['items']:
            # Extract item info
            product_id = item_data['product_id']
            product_type = item_data.get('type', 'medication')  # Default type
            name = item_data.get('name', f'Product {product_id}')  # Default name
            
            print(f"📦 Backend: Creating order item: {name}, type: {product_type}, id: {product_id}")
            
            order_item = OrderItem(
                item_id=product_id,  # Changed from product_id to item_id
                item_type=product_type,  # Changed from product_type to item_type
                name=name,
                price=item_data['price'],
                quantity=item_data['quantity']
            )
            order.items.append(order_item)
        
        # Save to database
        db.session.add(order)
        db.session.commit()
        
        print(f"✅ Backend: Order created successfully with ID: {order.id}")
        print(f"✅ Backend: Order details: {order.to_dict()}")
        
        return jsonify({
            'message': 'Order created successfully',
            'order': order.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        print(f"❌ Backend: Error creating order: {str(e)}")
        return jsonify({'message': f'Error creating order: {str(e)}'}), 500

@orders_bp.route('/<int:order_id>/cancel', methods=['POST'])
@jwt_required()
def cancel_order(order_id):
    """Cancel an order"""
    # Get the user ID from the JWT token
    user_id = get_jwt_identity()
    
    # Find the order
    order = Order.query.filter_by(id=order_id).first()
    if not order:
        return jsonify({'message': 'Order not found'}), 404
    
    # Ensure user can only cancel their own orders
    if int(order.user_id) != int(user_id):
        return jsonify({'message': 'Unauthorized to cancel this order'}), 403
    
    # Check if order can be cancelled
    if order.status != 'pending':
        return jsonify({'message': f'Cannot cancel order with status {order.status}'}), 400
    
    # Update order status
    try:
        order.status = 'cancelled'
        db.session.commit()
        
        return jsonify({
            'message': 'Order cancelled successfully',
            'order': order.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'message': f'Error cancelling order: {str(e)}'}), 500