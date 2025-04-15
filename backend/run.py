import os
from dotenv import load_dotenv
from app import create_app, db, migrate
from app.models import User
from flask_migrate import Migrate
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Load environment variables from .env file
load_dotenv()

# Get environment from .env file or default to development
config_name = os.environ.get('FLASK_ENV', 'production')

# Create the Flask application instance
app = create_app(config_name)

# Import models to ensure they're registered with SQLAlchemy before migration
from app.models import User  # Import models after app creation

# Create CLI command for initializing the database
@app.cli.command('init-db')
def initialize_db():
    """Initialize the database."""
    db.create_all()
    print('Database initialized.')

# Create CLI command for creating an admin user
@app.cli.command('create-admin')
def create_admin():
    """Create an admin user."""
    admin = User.query.filter_by(email='admin@winaldrugshop.com').first()
    
    if admin:
        print('Admin user already exists.')
        return
        
    admin = User(
        email='admin@winaldrugshop.com',
        password='Admin123',  # This would be a strong password in production
        first_name='Admin',
        last_name='User',
        is_admin=True
    )
    
    db.session.add(admin)
    db.session.commit()
    print('Admin user created.')

# Create a route to check if the API is running
@app.route('/')
def index():
    return {
        'message': 'Welcome to Winal Drug Shop API',
        'version': '1.0.0',
        'status': 'online'
    }

@app.shell_context_processor
def make_shell_context():
    return {'db': db, 'User': User}

# Run the application
if __name__ == '__main__':
    app.run(host=os.environ.get('FLASK_HOST', '0.0.0.0'),
            port=int(os.environ.get('FLASK_PORT', 5000)))