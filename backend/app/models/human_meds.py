from datetime import datetime
from app import db

class HumanMedication(db.Model):
    """Model for human medications"""
    __tablename__ = 'human_medications'
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(128), nullable=False)
    description = db.Column(db.Text, nullable=False)
    price = db.Column(db.Float, nullable=False)
    stock_quantity = db.Column(db.Integer, nullable=False)
    image_path = db.Column(db.String(255))
    category = db.Column(db.String(64), nullable=False)  # e.g., 'painkillers', 'antibiotics'
    requires_prescription = db.Column(db.Boolean, default=False)
    dosage_instructions = db.Column(db.Text)
    side_effects = db.Column(db.Text)
    contraindications = db.Column(db.Text)
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
            'category': self.category,
            'requires_prescription': self.requires_prescription,
            'dosage_instructions': self.dosage_instructions,
            'side_effects': self.side_effects,
            'contraindications': self.contraindications,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }
    
    def __repr__(self):
        return f'<HumanMedication {self.name}>'