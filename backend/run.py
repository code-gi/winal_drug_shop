import os
from dotenv import load_dotenv
from app import create_app, db
from app.models import User
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Load environment variables from .env file
load_dotenv()

# Get configuration from environment or default to development
config_name = os.getenv('FLASK_CONFIG', 'default')

# Create the Flask application instance
app = create_app(config_name)

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
        'version': '1.0.0'
    }

# Run the application
if __name__ == '__main__':
    host = os.getenv('FLASK_HOST', '0.0.0.0')
    port = int(os.getenv('FLASK_PORT', 5000))
    debug = os.getenv('FLASK_DEBUG', 'False').lower() == 'true'
    
    app.run(host=host, port=port, debug=debug)