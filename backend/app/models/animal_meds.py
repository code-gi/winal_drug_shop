from datetime import datetime
from app import db

class AnimalMedication(db.Model):
    """Model for animal medications"""
    __tablename__ = 'animal_medications'
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(128), nullable=False)
    description = db.Column(db.Text, nullable=False)
    price = db.Column(db.Float, nullable=False)
    stock_quantity = db.Column(db.Integer, nullable=False)
    image_path = db.Column(db.String(255))
    animal_type = db.Column(db.String(64), nullable=False)  # e.g., 'cat', 'dog', 'cow'
    usage_instructions = db.Column(db.Text)
    side_effects = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def to_dict(self):
        """Convert object to dictionary"""
        return {
            'id': self.id,
            'name': self.name,
            'description': self.description,
            'price': self.price,
            'stock_quantity': self.stock_quantity,
            'image_path': self.image_path,
            'animal_type': self.animal_type,
            'usage_instructions': self.usage_instructions,
            'side_effects': self.side_effects,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }
    
    def __repr__(self):
        return f'<AnimalMedication {self.name}>'