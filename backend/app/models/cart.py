from datetime import datetime
from app import db

class CartItem(db.Model):
    """Model for cart items"""
    __tablename__ = 'cart_items'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    item_type = db.Column(db.String(20), nullable=False)  # 'animal' or 'human'
    item_id = db.Column(db.Integer, nullable=False)
    quantity = db.Column(db.Integer, nullable=False, default=1)
    added_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def to_dict(self):
        """Convert cart item to dictionary"""
        return {
            'id': self.id,
            'user_id': self.user_id,
            'item_type': self.item_type,
            'item_id': self.item_id,
            'quantity': self.quantity,
            'added_at': self.added_at.isoformat() if self.added_at else None
        }
    
    def __repr__(self):
        return f'<CartItem {self.id} for user {self.user_id}>'


class Order(db.Model):
    """Model for orders"""
    __tablename__ = 'orders'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    total_amount = db.Column(db.Float, nullable=False)
    status = db.Column(db.String(20), nullable=False, default='pending')  # pending, processing, shipped, delivered, cancelled
    shipping_address = db.Column(db.Text, nullable=False)
    payment_method = db.Column(db.String(50), nullable=False)
    order_date = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Define relationship with order items
    items = db.relationship('OrderItem', backref='order', lazy=True, cascade='all, delete-orphan')
    
    def to_dict(self):
        """Convert order to dictionary"""
        return {
            'id': self.id,
            'user_id': self.user_id,
            'total_amount': self.total_amount,
            'status': self.status,
            'shipping_address': self.shipping_address,
            'payment_method': self.payment_method,
            'order_date': self.order_date.isoformat() if self.order_date else None,
            'items': [item.to_dict() for item in self.items]
        }
    
    def __repr__(self):
        return f'<Order {self.id} by user {self.user_id}>'


class OrderItem(db.Model):
    """Model for order items"""
    __tablename__ = 'order_items'
    
    id = db.Column(db.Integer, primary_key=True)
    order_id = db.Column(db.Integer, db.ForeignKey('orders.id'), nullable=False)
    item_type = db.Column(db.String(20), nullable=False)  # 'animal' or 'human'
    item_id = db.Column(db.Integer, nullable=False)
    name = db.Column(db.String(128), nullable=False)  # Store name at time of purchase
    price = db.Column(db.Float, nullable=False)  # Store price at time of purchase
    quantity = db.Column(db.Integer, nullable=False)
    
    def to_dict(self):
        """Convert order item to dictionary"""
        return {
            'id': self.id,
            'order_id': self.order_id,
            'item_type': self.item_type,
            'item_id': self.item_id,
            'name': self.name,
            'price': self.price,
            'quantity': self.quantity,
            'subtotal': self.price * self.quantity
        }
    
    def __repr__(self):
        return f'<OrderItem {self.id} for order {self.order_id}>'