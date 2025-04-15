from datetime import datetime
from app import db

class Category(db.Model):
    """Model for medication categories"""
    __tablename__ = 'categories'
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text)
    medication_type = db.Column(db.String(20), nullable=False)  # 'human' or 'animal'
    
    # Relationships
    medications = db.relationship('Medication', backref='category', lazy=True)
    
    def __repr__(self):
        return f'<Category {self.name}>'

class Medication(db.Model):
    """Model for medications (both human and animal)"""
    __tablename__ = 'medications'
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text)
    full_details = db.Column(db.Text)
    price = db.Column(db.Float, nullable=False)
    stock_quantity = db.Column(db.Integer, default=0)
    medication_type = db.Column(db.String(20), nullable=False)  # 'human' or 'animal'
    category_id = db.Column(db.Integer, db.ForeignKey('categories.id'))
    requires_prescription = db.Column(db.Boolean, default=False)
    dosage_instructions = db.Column(db.Text)
    contraindications = db.Column(db.Text)
    side_effects = db.Column(db.Text)
    storage_instructions = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    images = db.relationship('MedicationImage', backref='medication', lazy=True, cascade='all, delete-orphan')
    
    def get_thumbnail_url(self):
        """Get the primary image URL or the first available image"""
        primary_image = MedicationImage.query.filter_by(medication_id=self.id, is_primary=True).first()
        if primary_image:
            return primary_image.image_url
            
        # If no primary image, get the first image
        first_image = MedicationImage.query.filter_by(medication_id=self.id).first()
        if first_image:
            return first_image.image_url
            
        # Default image if none available
        return '/static/images/default_medication.jpg'
    
    def __repr__(self):
        return f'<Medication {self.name}>'

class MedicationImage(db.Model):
    """Model for medication images"""
    __tablename__ = 'medication_images'
    
    id = db.Column(db.Integer, primary_key=True)
    medication_id = db.Column(db.Integer, db.ForeignKey('medications.id'), nullable=False)
    image_url = db.Column(db.String(255), nullable=False)
    is_primary = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def __repr__(self):
        return f'<MedicationImage {self.id} for Medication {self.medication_id}>'