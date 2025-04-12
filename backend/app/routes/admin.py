from flask import Blueprint, jsonify, request
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.user import User
from app.models.medication import Medication
from app.models.cart import Order
from datetime import datetime, timedelta
from sqlalchemy import func

admin_bp = Blueprint('admin', __name__)

@admin_bp.route('/dashboard', methods=['GET'])
@jwt_required()
def get_dashboard_data():
    """Get admin dashboard statistics and data"""
    # Get the user ID from the JWT token
    user_id = get_jwt_identity()
    
    # Check if the user is an admin
    user = User.query.get(user_id)
    if not user or not user.is_admin:
        return jsonify({'message': 'Admin access required'}), 403
    
    # Calculate dashboard statistics
    total_products = Medication.query.count()
    
    total_orders = Order.query.count()
    
    total_users = User.query.filter_by(is_admin=False).count()
    
    # Calculate today's revenue
    today = datetime.now().date()
    todays_orders = Order.query.filter(
        func.date(Order.order_date) == today, 
        Order.status != 'cancelled'
    ).all()
    todays_revenue = sum(order.total_amount for order in todays_orders)
    
    # Get recent activities
    recent_activities = []
    
    # Recent orders (last 7 days)
    recent_orders = Order.query.filter(
        Order.order_date >= datetime.now() - timedelta(days=7)
    ).order_by(Order.order_date.desc()).limit(5).all()
    
    for order in recent_orders:
        user = User.query.get(order.user_id)
        user_name = f"{user.first_name} {user.last_name}" if user else "Unknown User"
        
        # Format time difference
        time_diff = datetime.now() - order.order_date
        if time_diff < timedelta(hours=1):
            time_str = f"{time_diff.seconds // 60} minutes ago"
        elif time_diff < timedelta(days=1):
            time_str = f"{time_diff.seconds // 3600} hours ago"
        else:
            time_str = f"{time_diff.days} days ago"
        
        recent_activities.append({
            'type': 'order',
            'title': f'New Order #{order.id}',
            'description': f'Order placed by {user_name} - {time_str}',
        })
    
    # Get low stock items
    low_stock_threshold = 10  # Items with stock below this are considered low
    low_stock_items = Medication.query.filter(
        Medication.stock_quantity <= low_stock_threshold
    ).all()
    
    low_stock_data = []
    for item in low_stock_items:
        low_stock_data.append({
            'id': item.id,
            'name': item.name,
            'currentStock': item.stock_quantity,
            'threshold': low_stock_threshold
        })
    
    # Compile all dashboard data
    dashboard_data = {
        'totalProducts': total_products,
        'totalOrders': total_orders,
        'totalUsers': total_users,
        'todaysRevenue': todays_revenue,
        'recentActivities': recent_activities,
        'lowStockItems': low_stock_data
    }
    
    return jsonify(dashboard_data), 200
