from app import db
from datetime import datetime

class Appointment(db.Model):
    __tablename__ = 'appointments'

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    farm_activity_id = db.Column(db.Integer, db.ForeignKey('farm_activities.id'), nullable=False)
    appointment_date = db.Column(db.Date, nullable=False)
    appointment_time = db.Column(db.Time, nullable=False)
    status = db.Column(db.String(20), default='pending')  # pending, confirmed, completed, cancelled
    total_amount = db.Column(db.Float, nullable=False)
    payment_status = db.Column(db.String(20), default='unpaid')  # unpaid, paid
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'farm_activity_id': self.farm_activity_id,
            'appointment_date': self.appointment_date.isoformat(),
            'appointment_time': self.appointment_time.isoformat(),
            'status': self.status,
            'total_amount': self.total_amount,
            'payment_status': self.payment_status,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat()
        }