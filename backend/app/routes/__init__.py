from app.routes.auth import auth_bp
from app.routes.user import user_bp
from app.routes.orders import orders_bp

__all__ = ['auth_bp', 'user_bp', 'orders_bp']