from app import db
from datetime import datetime

class Order(db.Model):
    """Order model"""
    __tablename__ = 'orders'

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    total_amount = db.Column(db.Float, nullable=False)
    payment_method = db.Column(db.String(50), nullable=False)
    shipping_address = db.Column(db.Text, nullable=False)
    status = db.Column(db.String(20), default='pending')  # pending, paid, delivered, cancelled
    order_date = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    items = db.relationship('OrderItem', backref='order', lazy=True, cascade='all, delete-orphan')
    user = db.relationship('User', backref='orders')

    def __repr__(self):
        return f'<Order {self.id} - User {self.user_id}>'
    
    def to_dict(self):
        """Convert order to dictionary"""
        return {
            'id': self.id,
            'user_id': self.user_id,
            'total_amount': self.total_amount,
            'payment_method': self.payment_method,
            'shipping_address': self.shipping_address,
            'status': self.status,
            'order_date': self.order_date.isoformat(),
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
            'items': [item.to_dict() for item in self.items]
        }

class OrderItem(db.Model):
    """Order item model"""
    __tablename__ = 'order_items'

    id = db.Column(db.Integer, primary_key=True)
    order_id = db.Column(db.Integer, db.ForeignKey('orders.id'), nullable=False)
    item_id = db.Column(db.Integer, nullable=False)  # Can be medication_id or other item type
    item_type = db.Column(db.String(50), nullable=False)  # medication, service, etc
    name = db.Column(db.String(100), nullable=False)
    price = db.Column(db.Float, nullable=False)
    quantity = db.Column(db.Integer, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def __repr__(self):
        return f'<OrderItem {self.id} - Order {self.order_id}>'
    
    def to_dict(self):
        """Convert order item to dictionary"""
        return {
            'id': self.id,
            'item_id': self.item_id,
            'item_type': self.item_type,
            'name': self.name,
            'price': self.price,
            'quantity': self.quantity,
            'subtotal': self.price * self.quantity
        }

class Cart(db.Model):
    """Cart model"""
    __tablename__ = 'carts'

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    status = db.Column(db.String(20), default='active')  # active, completed, abandoned
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    items = db.relationship('CartItem', backref='cart', lazy=True, cascade='all, delete-orphan')
    user = db.relationship('User', backref='carts')

    def __repr__(self):
        return f'<Cart {self.id} - User {self.user_id}>'

class CartItem(db.Model):
    """Cart item model"""
    __tablename__ = 'cart_items'

    id = db.Column(db.Integer, primary_key=True)
    cart_id = db.Column(db.Integer, db.ForeignKey('carts.id'), nullable=False)
    medication_id = db.Column(db.Integer, db.ForeignKey('medications.id'), nullable=False)
    quantity = db.Column(db.Integer, nullable=False, default=1)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    medication = db.relationship('Medication', backref='cart_items')

    def __repr__(self):
        return f'<CartItem {self.id} - Cart {self.cart_id} - Med {self.medication_id}>'
