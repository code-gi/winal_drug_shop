"""
Script to populate the database with sample medications.
Run this script after setting up the database to add initial data.
"""

from app import create_app, db
from app.models.medication import Medication, Category, MedicationImage
from datetime import datetime

app = create_app()

def populate_db():
    with app.app_context():
        # Check if data already exists
        if Medication.query.count() > 0:
            print("Database already has medications. Skipping population.")
            return
            
        # Current timestamp for created_at and updated_at
        now = datetime.utcnow()
        
        # Create categories if they don't exist
        human_categories = [
            {"name": "Antibiotics", "description": "Medicines that combat bacterial infections", "medication_type": "human"},
            {"name": "Vitamins", "description": "Dietary supplements", "medication_type": "human"},
            {"name": "Steroids", "description": "Anti-inflammatory medications", "medication_type": "human"},
            {"name": "Syrups", "description": "Liquid medications for oral use", "medication_type": "human"},
            {"name": "Painkillers", "description": "Medications for pain relief", "medication_type": "human"},
            {"name": "Creams", "description": "Topical medications for skin conditions", "medication_type": "human"},
        ]
        
        animal_categories = [
            {"name": "Ear Treatments", "description": "Medications for animal ear problems", "medication_type": "animal"},
            {"name": "Dewormers", "description": "Medications to treat worm infestations", "medication_type": "animal"},
            {"name": "Allergy Medicine", "description": "Treatment for animal allergies", "medication_type": "animal"},
            {"name": "Infection Control", "description": "Medications for bacterial and viral infections", "medication_type": "animal"},
            {"name": "Digestive Health", "description": "Treatments for diarrhea and digestive issues", "medication_type": "animal"},
            {"name": "Pain Relief", "description": "Pain management medications for animals", "medication_type": "animal"},
        ]
        
        category_map = {}
        
        # Add human categories
        for i, cat_data in enumerate(human_categories, 1):
            category = Category(
                id=i,
                name=cat_data["name"],
                description=cat_data["description"],
                medication_type=cat_data["medication_type"]
            )
            db.session.add(category)
            category_map[cat_data["name"]] = i
            
        # Add animal categories
        for i, cat_data in enumerate(animal_categories, 101):
            category = Category(
                id=i,
                name=cat_data["name"],
                description=cat_data["description"],
                medication_type=cat_data["medication_type"]
            )
            db.session.add(category)
            category_map[cat_data["name"]] = i
            
        db.session.commit()
        print("Categories added successfully.")
        
        # Create human medications
        human_medications = [
            {
                "id": 1,
                "name": "Anti biotics",
                "description": "Effective against various bacterial infections",
                "full_details": "Broad-spectrum antibiotic suitable for various infections. Take with food to reduce stomach upset.",
                "price": 5000,
                "stock_quantity": 50,
                "medication_type": "human",
                "category_id": category_map["Antibiotics"],
                "requires_prescription": True,
                "dosage_instructions": "Take 1 tablet twice daily with food.",
                "contraindications": "Allergic to penicillin, liver disease, kidney problems.",
                "side_effects": "Nausea, diarrhea, allergic reactions.",
                "storage_instructions": "Store in a cool, dry place away from direct sunlight."
            },
            {
                "id": 2,
                "name": "Vitamin B",
                "description": "Essential vitamin supplement for overall health",
                "full_details": "Supports energy metabolism and nervous system function. Contains B1, B2, B6, and B12.",
                "price": 8000,
                "stock_quantity": 100,
                "medication_type": "human",
                "category_id": category_map["Vitamins"],
                "requires_prescription": False,
                "dosage_instructions": "Take 1 tablet daily with a meal.",
                "contraindications": "None known.",
                "side_effects": "Rarely causes upset stomach or headache.",
                "storage_instructions": "Store at room temperature away from moisture."
            },
            {
                "id": 3,
                "name": "Steroids",
                "description": "Anti-inflammatory medication for severe conditions",
                "full_details": "Potent anti-inflammatory medication used for severe allergic reactions, autoimmune disorders, and inflammatory conditions.",
                "price": 12000,
                "stock_quantity": 30,
                "medication_type": "human",
                "category_id": category_map["Steroids"],
                "requires_prescription": True,
                "dosage_instructions": "Follow doctor's instructions carefully. Typically tapered dosage.",
                "contraindications": "Active infections, diabetes, high blood pressure, glaucoma.",
                "side_effects": "Weight gain, mood changes, increased appetite, fluid retention.",
                "storage_instructions": "Store at room temperature in the original container."
            },
            {
                "id": 4,
                "name": "Syrups",
                "description": "Liquid medication for cough and cold relief",
                "full_details": "Pleasant-tasting cough suppressant with expectorant properties to loosen mucus and relieve chest congestion.",
                "price": 10000,
                "stock_quantity": 45,
                "medication_type": "human",
                "category_id": category_map["Syrups"],
                "requires_prescription": False,
                "dosage_instructions": "Take 10ml (2 teaspoons) every 4-6 hours as needed. Do not exceed 6 doses in 24 hours.",
                "contraindications": "High blood pressure, heart disease, diabetes.",
                "side_effects": "Drowsiness, dizziness, nervousness.",
                "storage_instructions": "Store below 25°C. Keep bottle tightly closed."
            },
            {
                "id": 5,
                "name": "Panadol tabs",
                "description": "Fast-acting pain relief and fever reducer",
                "full_details": "Paracetamol-based pain reliever and fever reducer suitable for headaches, toothaches, and general pain.",
                "price": 2000,
                "stock_quantity": 200,
                "medication_type": "human",
                "category_id": category_map["Painkillers"],
                "requires_prescription": False,
                "dosage_instructions": "Adults and children over 12: 1-2 tablets every 4-6 hours when necessary, up to a maximum of 8 tablets in 24 hours.",
                "contraindications": "Liver disease, alcoholism, severe kidney problems.",
                "side_effects": "Rarely causes side effects when taken as directed.",
                "storage_instructions": "Store below 30°C in a dry place."
            },
            {
                "id": 6,
                "name": "Eczema Creams",
                "description": "Topical treatment for skin irritation and itching",
                "full_details": "Steroid-based cream that reduces inflammation, itching, and redness associated with eczema and dermatitis.",
                "price": 35000,
                "stock_quantity": 25,
                "medication_type": "human",
                "category_id": category_map["Creams"],
                "requires_prescription": True,
                "dosage_instructions": "Apply a thin layer to the affected area 1-2 times daily.",
                "contraindications": "Fungal, viral, or bacterial skin infections.",
                "side_effects": "Skin thinning, stretch marks, and increased hair growth with prolonged use.",
                "storage_instructions": "Store at room temperature, away from heat and direct light."
            }
        ]
        
        # Create animal medications
        animal_medications = [
            {
                "id": 101,
                "name": "Ear Drops",
                "description": "Treatment for ear infections in pets",
                "full_details": "Antibiotic and anti-inflammatory solution for treating bacterial and yeast ear infections in dogs and cats.",
                "price": 18000,
                "stock_quantity": 40,
                "medication_type": "animal",
                "category_id": category_map["Ear Treatments"],
                "requires_prescription": True,
                "dosage_instructions": "Clean ear first, then apply 5-10 drops into the ear canal once daily for 7-14 days.",
                "contraindications": "Perforated eardrum, animals with hypersensitivity to ingredients.",
                "side_effects": "Temporary discomfort, head shaking after application.",
                "storage_instructions": "Store between 15-30°C. Keep bottle tightly closed."
            },
            {
                "id": 102,
                "name": "Dewormer",
                "description": "Eliminates intestinal parasites in animals",
                "full_details": "Broad-spectrum deworming medication effective against roundworms, hookworms, whipworms, and tapeworms in dogs and cats.",
                "price": 15000,
                "stock_quantity": 60,
                "medication_type": "animal",
                "category_id": category_map["Dewormers"],
                "requires_prescription": False,
                "dosage_instructions": "Administer 1 tablet per 10kg body weight as a single dose. Repeat in 2 weeks.",
                "contraindications": "Not for use in animals less than 2 weeks of age or weighing less than 2 pounds.",
                "side_effects": "Occasionally causes vomiting or diarrhea.",
                "storage_instructions": "Store in a cool, dry place protected from light."
            },
            {
                "id": 103,
                "name": "Allergy Relief",
                "description": "Reduces symptoms of allergic reactions in pets",
                "full_details": "Antihistamine medication that helps relieve itching, inflammation, and other symptoms associated with allergic reactions in dogs and cats.",
                "price": 22000,
                "stock_quantity": 35,
                "medication_type": "animal",
                "category_id": category_map["Allergy Medicine"],
                "requires_prescription": True,
                "dosage_instructions": "1 tablet per 20kg body weight every 12 hours, or as directed by your veterinarian.",
                "contraindications": "Glaucoma, prostatic hypertrophy, severe heart conditions.",
                "side_effects": "Drowsiness, dry mouth, urinary retention.",
                "storage_instructions": "Store at room temperature away from moisture and heat."
            },
            {
                "id": 104,
                "name": "Infection Treatment",
                "description": "Antibiotic for bacterial infections in animals",
                "full_details": "Broad-spectrum antibiotic used to treat a variety of bacterial infections in pets, including skin, respiratory, and urinary tract infections.",
                "price": 25000,
                "stock_quantity": 30,
                "medication_type": "animal",
                "category_id": category_map["Infection Control"],
                "requires_prescription": True,
                "dosage_instructions": "10mg per kg body weight twice daily for 7-14 days.",
                "contraindications": "Known sensitivity to this class of antibiotics, severe kidney or liver disease.",
                "side_effects": "Vomiting, diarrhea, loss of appetite.",
                "storage_instructions": "Store between 20-25°C. Keep container tightly closed."
            },
            {
                "id": 105,
                "name": "Diarrhea Relief",
                "description": "Controls diarrhea and restores gut health in animals",
                "full_details": "Fast-acting medication that helps control diarrhea in dogs and cats by absorbing toxins and promoting normal gut flora.",
                "price": 12000,
                "stock_quantity": 50,
                "medication_type": "animal",
                "category_id": category_map["Digestive Health"],
                "requires_prescription": False,
                "dosage_instructions": "Mix powder with food, 1 teaspoon per 5kg body weight, 2-3 times daily for up to 3 days.",
                "contraindications": "Animals with suspected intestinal obstruction or toxic ingestion requiring elimination.",
                "side_effects": "Constipation with excessive use.",
                "storage_instructions": "Store in a cool, dry place with container tightly closed."
            },
            {
                "id": 106,
                "name": "Pain Reliever",
                "description": "Safe pain management for pets",
                "full_details": "Non-steroidal anti-inflammatory drug (NSAID) designed specifically for dogs to relieve pain and inflammation associated with arthritis and soft tissue injuries.",
                "price": 28000,
                "stock_quantity": 25,
                "medication_type": "animal",
                "category_id": category_map["Pain Relief"],
                "requires_prescription": True,
                "dosage_instructions": "1 tablet per 25kg body weight once daily with food.",
                "contraindications": "History of gastric ulcers, kidney or liver disease, bleeding disorders.",
                "side_effects": "Vomiting, diarrhea, decreased appetite, lethargy.",
                "storage_instructions": "Store below 25°C. Protect from light and moisture."
            }
        ]
        
        # Add human medications
        for med_data in human_medications:
            medication = Medication(**med_data)
            db.session.add(medication)
            
        # Add animal medications
        for med_data in animal_medications:
            medication = Medication(**med_data)
            db.session.add(medication)
            
        db.session.commit()
        print("Medications added successfully.")
        
        # Create medication images
        images = [
            # Images for Human Medications
            {"id": 1, "medication_id": 1, "image_url": "assets/images/antibiotics.jpeg", "is_primary": True},
            {"id": 2, "medication_id": 2, "image_url": "assets/images/vitamin.jpeg", "is_primary": True},
            {"id": 3, "medication_id": 3, "image_url": "assets/images/steroids.jpeg", "is_primary": True},
            {"id": 4, "medication_id": 4, "image_url": "assets/images/SYRUP.jpeg", "is_primary": True},
            {"id": 5, "medication_id": 5, "image_url": "assets/images/panadol.jpeg", "is_primary": True},
            {"id": 6, "medication_id": 6, "image_url": "assets/images/ECZEMA CREAM.jpeg", "is_primary": True},
            
            # Images for Animal Medications
            {"id": 101, "medication_id": 101, "image_url": "assets/images/EARDROPS .jpeg", "is_primary": True},
            {"id": 102, "medication_id": 102, "image_url": "assets/images/DEWORMER.jpg", "is_primary": True},
            {"id": 103, "medication_id": 103, "image_url": "assets/images/allergy.jpeg", "is_primary": True},
            {"id": 104, "medication_id": 104, "image_url": "assets/images/infection.jpeg", "is_primary": True},
            {"id": 105, "medication_id": 105, "image_url": "assets/images/diarrhoea.jpeg", "is_primary": True},
            {"id": 106, "medication_id": 106, "image_url": "assets/images/painkillers.jpeg", "is_primary": True}
        ]
        
        for img_data in images:
            image = MedicationImage(**img_data)
            db.session.add(image)
            
        db.session.commit()
        print("Medication images added successfully.")
        print("Database population complete!")

if __name__ == "__main__":
    populate_db()