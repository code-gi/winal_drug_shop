from flask import Blueprint, jsonify
from app import db
from app.models.appointment import Appointment
from app.utils.auth import token_required
from datetime import datetime

bp = Blueprint('appointments', __name__)

@bp.route('/appointments/<int:id>/cancel', methods=['POST'])
@token_required
def cancel_appointment(current_user, id):
    """Cancel an appointment"""
    try:
        # Get the appointment
        appointment = Appointment.query.get_or_404(id)

        # Ensure user can only cancel their own appointments
        if appointment.user_id != current_user.id:
            return jsonify({'message': 'Unauthorized to cancel this appointment'}), 403

        # Check if appointment can be cancelled
        if appointment.status.lower() not in ['pending', 'confirmed']:
            return jsonify({'message': f'Cannot cancel appointment with status {appointment.status}'}), 400

        # Check if appointment is in the future
        appointment_datetime = datetime.combine(appointment.appointment_date, appointment.appointment_time)
        if appointment_datetime < datetime.utcnow():
            return jsonify({'message': 'Cannot cancel past appointments'}), 400

        # Update appointment status
        appointment.status = 'cancelled'
        db.session.commit()

        return jsonify({
            'message': 'Appointment cancelled successfully',
            'appointment': appointment.to_dict()
        })

    except Exception as e:
        db.session.rollback()
        return jsonify({'message': f'Error cancelling appointment: {str(e)}'}), 500