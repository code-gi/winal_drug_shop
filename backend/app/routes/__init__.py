from flask import Blueprint
from .auth import auth_bp
from .medications import medications_bp
from .orders import orders_bp
from .cart import cart_bp
from .admin import admin_bp

# Register blueprints
def register_blueprints(app):
    app.register_blueprint(auth_bp, url_prefix='/api/auth')
    app.register_blueprint(medications_bp, url_prefix='/api/medications')
    app.register_blueprint(orders_bp, url_prefix='/api/orders')
    app.register_blueprint(cart_bp, url_prefix='/api/cart')
    app.register_blueprint(admin_bp, url_prefix='/api/admin')
