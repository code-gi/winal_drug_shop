from flask import Blueprint, jsonify, request
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.user import User
from app.models.medication import Medication
from app.models.cart import Order
from datetime import datetime, timedelta
from sqlalchemy import func
import traceback

admin_bp = Blueprint('admin', __name__)

@admin_bp.before_request
def before_request():
    """Log before processing any admin route request"""
    print(f"\n=== Admin Route Request ===")
    print(f"Method: {request.method}")
    print(f"Path: {request.path}")
    print(f"Headers: {dict(request.headers)}")
    print(f"Data: {request.get_data()}\n")

@admin_bp.route('/dashboard', methods=['GET'])
@jwt_required()
def get_dashboard_data():
    """Get admin dashboard statistics and data"""
    print("\n=== Starting Admin Dashboard Request ===")
    try:
        # Get the user ID from the JWT token
        user_id = get_jwt_identity()
        print(f"User ID from token: {user_id}")
        
        # Check if the user is an admin
        user = User.query.get(user_id)
        print(f"User found: {user is not None}")
        if user:
            print(f"User details - Email: {user.email}, Is admin: {user.is_admin}")
        
        if not user or not user.is_admin:
            print(f"Admin access denied for user {user_id}")
            return jsonify({'message': 'Admin access required'}), 403
        
        # Calculate dashboard statistics
        print("Calculating dashboard statistics...")
        
        total_products = Medication.query.count()
        print(f"Total products: {total_products}")
        
        total_orders = Order.query.count()
        print(f"Total orders: {total_orders}")
        
        total_users = User.query.filter_by(is_admin=False).count()
        print(f"Total users: {total_users}")
        
        # Calculate today's revenue
        today = datetime.now().date()
        print(f"Calculating revenue for date: {today}")
        
        todays_orders = Order.query.filter(
            func.date(Order.order_date) == today,
            Order.status != 'cancelled'
        ).all()
        todays_revenue = sum(order.total_amount for order in todays_orders)
        print(f"Today's revenue: {todays_revenue}")
        print(f"Number of orders today: {len(todays_orders)}")
        
        # Get recent activities
        print("Fetching recent activities...")
        recent_activities = []
        
        # Recent orders (last 7 days)
        recent_orders = Order.query.filter(
            Order.order_date >= datetime.now() - timedelta(days=7)
        ).order_by(Order.order_date.desc()).limit(5).all()
        
        print(f"Found {len(recent_orders)} recent orders")
        
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
            
            activity = {
                'type': 'order',
                'title': f'New Order #{order.id}',
                'description': f'Order placed by {user_name} - {time_str}',
                'time': order.order_date.isoformat(),
                'amount': order.total_amount
            }
            recent_activities.append(activity)
            print(f"Added activity: {activity}")
        
        # Get low stock items
        print("Checking for low stock items...")
        low_stock_threshold = 10
        low_stock_items = Medication.query.filter(
            Medication.stock_quantity <= low_stock_threshold
        ).all()
        
        low_stock_data = []
        for item in low_stock_items:
            data = {
                'id': item.id,
                'name': item.name,
                'currentStock': item.stock_quantity,
                'threshold': low_stock_threshold
            }
            low_stock_data.append(data)
            print(f"Added low stock item: {data}")
        
        # Compile all dashboard data
        dashboard_data = {
            'totalProducts': total_products,
            'totalOrders': total_orders,
            'totalUsers': total_users,
            'todaysRevenue': todays_revenue,
            'recentActivities': recent_activities,
            'lowStockItems': low_stock_data
        }
        
        print("Dashboard data compiled successfully")
        print(f"Returning dashboard data: {dashboard_data}")
        return jsonify(dashboard_data), 200
        
    except Exception as e:
        print(f"\nERROR in admin dashboard endpoint: {str(e)}")
        print("Full traceback:")
        print(traceback.format_exc())
        return jsonify({'message': f'An error occurred: {str(e)}'}), 500

@admin_bp.route('/users', methods=['GET'])
@jwt_required()
def get_users():
    """Get all users (admin only)"""
    print("\n=== Starting Admin Users Request ===")
    try:
        # Check if user is admin
        user_id = get_jwt_identity()
        print(f"User ID from token: {user_id}")
        
        user = User.query.get(user_id)
        print(f"User found: {user is not None}")
        
        if not user or not user.is_admin:
            print(f"Admin access denied for user {user_id}")
            return jsonify({'message': 'Admin access required'}), 403
        
        users = User.query.filter_by(is_admin=False).all()
        print(f"Found {len(users)} non-admin users")
        
        user_data = [{
            'id': user.id,
            'email': user.email,
            'firstName': user.first_name,
            'lastName': user.last_name,
            'phoneNumber': user.phone_number,
            'dateJoined': user.created_at.isoformat() if user.created_at else None
        } for user in users]
        
        print("Successfully compiled user data")
        return jsonify(user_data), 200
        
    except Exception as e:
        print(f"\nERROR in admin users endpoint: {str(e)}")
        print("Full traceback:")
        print(traceback.format_exc())
        return jsonify({'message': f'An error occurred: {str(e)}'}), 500
