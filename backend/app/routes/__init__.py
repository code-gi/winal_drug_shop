from flask import Blueprint
from .auth import auth_bp
from .medications import medications_bp
from .admin import admin_bp
from .notifications import notifications_bp

# Register blueprints
def register_blueprints(app):
    print("Registering blueprints in routes/__init__.py")
    app.register_blueprint(auth_bp, url_prefix='/api/auth')
    app.register_blueprint(medications_bp, url_prefix='/api/medications')
    app.register_blueprint(admin_bp, url_prefix='/api/admin')
    app.register_blueprint(notifications_bp, url_prefix='/api/notifications')
    print("All blueprints registered in routes/__init__.py")
