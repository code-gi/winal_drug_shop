from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager
from flask_cors import CORS
from flask_migrate import Migrate
from flask_bcrypt import Bcrypt
import os
import sys
from datetime import datetime, timezone

# Add the parent directory to the path so we can import the config module
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from config import config

db = SQLAlchemy()
jwt = JWTManager()
migrate = Migrate()
bcrypt = Bcrypt()  # Add bcrypt instance

def create_app(config_name='default'):
    """Application factory function"""
    print("\n=== Creating Flask Application ===")
    app = Flask(__name__)
    app.config.from_object(config[config_name])
    config[config_name].init_app(app)
    print(f"Initialized with config: {config_name}")
    
    # Initialize extensions with app
    db.init_app(app)
    jwt.init_app(app)
    CORS(app, supports_credentials=True)
    migrate.init_app(app, db)
    bcrypt.init_app(app)  # Initialize bcrypt
    print("All extensions initialized")

    # Set up request logging
    @app.before_request
    def log_request():
        print(f"\n=== Incoming Request ===")
        print(f"Request: {request.method} {request.path} from {request.remote_addr}")
        if request.headers.get('Authorization'):
            auth_header = request.headers.get('Authorization')
            print(f"Auth header: {auth_header[:15]}...")
    
    @app.after_request
    def log_response(response):
        print(f"Response status: {response.status_code}")
        return response

    # Import and register blueprints
    print("\n=== Registering Blueprints ===")
    
    try:
        print("Importing blueprints...")        
        from .routes.auth import auth_bp
        from .routes.users import users_bp
        from .routes.medications import medications_bp
        from .routes.categories import categories_bp
        from .routes.seed import seed_bp
        from .routes.orders import orders_bp
        from .routes.farm_activities import bp as farm_activities_bp
        from .routes.appointments import bp as appointments_bp
        from .routes.admin import admin_bp
        from .routes.notifications import notifications_bp
        from .routes.mail import mail_bp
        
        print("All blueprints imported successfully")
          # Register each blueprint and log it
        blueprints = [
            (auth_bp, '/api/auth'),
            (farm_activities_bp, '/api'),
            (users_bp, '/api/users'),
            (medications_bp, '/api/medications'),
            (categories_bp, '/api/categories'),
            (seed_bp, '/api/seed'),
            (orders_bp, '/api/orders'),
            (appointments_bp, '/api'),
            (admin_bp, '/api/admin'),
            (notifications_bp, '/api/notifications'),
            (mail_bp, '/api/mail')
        ]
        
        for blueprint, url_prefix in blueprints:
            print(f"Registering blueprint: {blueprint.name} with prefix: {url_prefix}")
            app.register_blueprint(blueprint, url_prefix=url_prefix)
            print(f"Successfully registered {blueprint.name}")
            
        print("All blueprints registered successfully")
        
        # Log all registered routes
        print("\n=== Registered Routes ===")
        for rule in app.url_map.iter_rules():
            print(f"{rule.endpoint}: {rule.rule}")
            
    except Exception as e:
        print(f"\nERROR during blueprint registration: {str(e)}")
        print("Full traceback:")
        import traceback
        print(traceback.format_exc())
    
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