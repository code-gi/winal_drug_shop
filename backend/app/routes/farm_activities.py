from flask import Blueprint, jsonify, request
from app import db
from app.models.farm_activity import FarmActivity
from app.models.appointment import Appointment
from datetime import datetime
from app.utils.auth import token_required

bp = Blueprint('farm_activities', __name__)

@bp.route('/farm-activities', methods=['GET'])
def get_farm_activities():
    activities = FarmActivity.query.all()
    return jsonify([activity.to_dict() for activity in activities])

@bp.route('/farm-activities/<int:id>', methods=['GET'])
def get_farm_activity(id):
    activity = FarmActivity.query.get_or_404(id)
    return jsonify(activity.to_dict())

@bp.route('/appointments', methods=['POST'])
@token_required
def create_appointment(current_user):
    data = request.get_json()
    
    # Validate required fields
    required_fields = ['farm_activity_id', 'appointment_date', 'appointment_time']
    for field in required_fields:
        if field not in data:
            return jsonify({'error': f'Missing required field: {field}'}), 400
    
    # Get the farm activity to calculate total amount
    activity = FarmActivity.query.get_or_404(data['farm_activity_id'])
    
    # Create appointment
    appointment = Appointment(
        user_id=current_user.id,
        farm_activity_id=data['farm_activity_id'],
        appointment_date=datetime.strptime(data['appointment_date'], '%Y-%m-%d').date(),
        appointment_time=datetime.strptime(data['appointment_time'], '%H:%M').time(),
        total_amount=activity.price
    )
    
    db.session.add(appointment)
    db.session.commit()
    
    return jsonify(appointment.to_dict()), 201

@bp.route('/appointments/<int:id>/payment', methods=['POST'])
@token_required
def process_payment(current_user, id):
    appointment = Appointment.query.get_or_404(id)
    
    # Verify the appointment belongs to the current user
    if appointment.user_id != current_user.id:
        return jsonify({'error': 'Unauthorized'}), 403
    
    # Process payment (integrate with payment gateway here)
    appointment.payment_status = 'paid'
    appointment.status = 'confirmed'
    
    db.session.commit()
    
    return jsonify(appointment.to_dict())

@bp.route('/appointments/user', methods=['GET'])
@token_required
def get_user_appointments(current_user):
    appointments = Appointment.query.filter_by(user_id=current_user.id).all()
    return jsonify([appointment.to_dict() for appointment in appointments])