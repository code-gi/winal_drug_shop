from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_jwt_extended import JWTManager, get_jwt
from flask_bcrypt import Bcrypt
from flask_cors import CORS
import logging
from datetime import datetime, timezone

from .config import config

# Initialize extensions
db = SQLAlchemy()
migrate = Migrate()
jwt = JWTManager()
bcrypt = Bcrypt()


def create_app(config_name='default'):
    """Application factory function"""
    app = Flask(__name__)
    app.config.from_object(config[config_name])
    
    # Initialize extensions with app
    db.init_app(app)
    migrate.init_app(app, db)
    jwt.init_app(app)
    bcrypt.init_app(app)
    CORS(app, supports_credentials=True)
    
    # Set up request logging
    @app.before_request
    def log_request():
        app.logger.info(f"Request: {request.method} {request.path} from {request.remote_addr}")
        if request.headers.get('Authorization'):
            auth_header = request.headers.get('Authorization')
            app.logger.info(f"Auth header: {auth_header[:15]}...")
    
    @app.after_request
    def log_response(response):
        app.logger.info(f"Response: {response.status_code}")
        return response
    
    # Import and register blueprints
    from .routes.auth import auth_bp
    from .routes.users import users_bp
    from .routes.medications import medications_bp
    from .routes.categories import categories_bp
    from .routes.seed import seed_bp
    from .routes.orders import orders_bp
    
    app.register_blueprint(auth_bp, url_prefix='/api/auth')
    app.register_blueprint(users_bp, url_prefix='/api/users')
    app.register_blueprint(medications_bp, url_prefix='/api/medications')
    app.register_blueprint(categories_bp, url_prefix='/api/categories')
    app.register_blueprint(seed_bp, url_prefix='/api/seed')
    app.register_blueprint(orders_bp, url_prefix='/api/orders')
    
    # Create token blocklist table if it doesn't exist
    from .models.user import TokenBlocklist
    
    # This is the modern approach - create tables with app context
    with app.app_context():
        db.create_all()
    
    # JWT token error handlers
    @jwt.user_identity_loader
    def user_identity_lookup(user_id):
        # Convert user_id to string for consistency
        return str(user_id)
    
    @jwt.user_lookup_loader
    def user_lookup_callback(_jwt_header, jwt_data):
        from .models.user import User
        identity = jwt_data["sub"]
        try:
            # Try both string and int versions
            user = User.query.filter_by(id=identity).first()
            if not user:
                user = User.query.filter_by(id=int(identity)).first()
            return user
        except:
            return None
    
    # JWT token blocklist
    @jwt.token_in_blocklist_loader
    def check_if_token_revoked(jwt_header, jwt_payload):
        jti = jwt_payload["jti"]
        token = TokenBlocklist.query.filter_by(jti=jti).first()
        return token is not None
    
    @jwt.expired_token_loader
    def expired_token_callback(jwt_header, jwt_payload):
        return jsonify({"message": "The token has expired", "error": "token_expired"}), 401
    
    @jwt.invalid_token_loader
    def invalid_token_callback(error):
        return jsonify({"message": "Signature verification failed", "error": "invalid_token"}), 401
    
    @jwt.unauthorized_loader
    def missing_token_callback(error):
        return jsonify({"message": "Request does not contain an access token", "error": "authorization_required"}), 401
    
    @jwt.revoked_token_loader
    def revoked_token_callback(jwt_header, jwt_payload):
        return jsonify({"message": "The token has been revoked", "error": "token_revoked"}), 401
    
    return app