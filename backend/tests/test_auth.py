import pytest
import json
from app import create_app, db
from app.models import User

@pytest.fixture
def app():
    """Create and configure a Flask app for testing."""
    app = create_app('testing')
    
    # Create the database and tables
    with app.app_context():
        db.create_all()
        
        # Create a test user
        test_user = User(
            email='test@example.com',
            password='Test1234',
            first_name='Test',
            last_name='User'
        )
        db.session.add(test_user)
        
        # Create an admin user
        admin_user = User(
            email='admin@example.com',
            password='Admin1234',
            first_name='Admin',
            last_name='User',
            is_admin=True
        )
        db.session.add(admin_user)
        
        db.session.commit()
    
    yield app
    
    # Clean up after test
    with app.app_context():
        db.session.remove()
        db.drop_all()

@pytest.fixture
def client(app):
    """A test client for the app."""
    return app.test_client()

@pytest.fixture
def auth_headers(client):
    """Get auth headers for test user."""
    response = client.post(
        '/api/auth/login',
        data=json.dumps({
            'email': 'test@example.com',
            'password': 'Test1234'
        }),
        content_type='application/json'
    )
    data = json.loads(response.data)
    
    return {
        'Authorization': f'Bearer {data["access_token"]}',
        'Content-Type': 'application/json'
    }

@pytest.fixture
def admin_auth_headers(client):
    """Get auth headers for admin user."""
    response = client.post(
        '/api/auth/login',
        data=json.dumps({
            'email': 'admin@example.com',
            'password': 'Admin1234'
        }),
        content_type='application/json'
    )
    data = json.loads(response.data)
    
    return {
        'Authorization': f'Bearer {data["access_token"]}',
        'Content-Type': 'application/json'
    }

def test_register(client):
    """Test user registration."""
    response = client.post(
        '/api/auth/register',
        data=json.dumps({
            'email': 'newuser@example.com',
            'password': 'Newuser1234',
            'first_name': 'New',
            'last_name': 'User'
        }),
        content_type='application/json'
    )
    
    assert response.status_code == 201
    data = json.loads(response.data)
    assert data['user']['email'] == 'newuser@example.com'
    assert 'password' not in data['user']

def test_register_duplicate_email(client):
    """Test registration with an existing email."""
    response = client.post(
        '/api/auth/register',
        data=json.dumps({
            'email': 'test@example.com',
            'password': 'Duplicate1234',
            'first_name': 'Duplicate',
            'last_name': 'User'
        }),
        content_type='application/json'
    )
    
    assert response.status_code == 409
    data = json.loads(response.data)
    assert 'already registered' in data['message'].lower()

def test_login(client):
    """Test user login."""
    response = client.post(
        '/api/auth/login',
        data=json.dumps({
            'email': 'test@example.com',
            'password': 'Test1234'
        }),
        content_type='application/json'
    )
    
    assert response.status_code == 200
    data = json.loads(response.data)
    assert 'access_token' in data
    assert 'refresh_token' in data
    assert data['user']['email'] == 'test@example.com'

def test_login_invalid_credentials(client):
    """Test login with invalid credentials."""
    response = client.post(
        '/api/auth/login',
        data=json.dumps({
            'email': 'test@example.com',
            'password': 'WrongPassword'
        }),
        content_type='application/json'
    )
    
    assert response.status_code == 401
    data = json.loads(response.data)
    assert 'invalid' in data['message'].lower()

def test_refresh_token(client, auth_headers):
    """Test token refresh."""
    # First login to get the refresh token
    login_response = client.post(
        '/api/auth/login',
        data=json.dumps({
            'email': 'test@example.com',
            'password': 'Test1234'
        }),
        content_type='application/json'
    )
    login_data = json.loads(login_response.data)
    refresh_token = login_data['refresh_token']
    
    # Use refresh token to get a new access token
    response = client.post(
        '/api/auth/refresh',
        headers={'Authorization': f'Bearer {refresh_token}'}
    )
    
    assert response.status_code == 200
    data = json.loads(response.data)
    assert 'access_token' in data

def test_logout(client, auth_headers):
    """Test user logout."""
    response = client.post(
        '/api/auth/logout',
        headers=auth_headers
    )
    
    assert response.status_code == 200
    data = json.loads(response.data)
    assert 'successfully logged out' in data['message'].lower()