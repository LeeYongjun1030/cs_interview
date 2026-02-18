import csv
import json
import os

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
INPUT_FILE = os.path.join(SCRIPT_DIR, '../questions/questions2.csv')
OUTPUT_FILE = os.path.join(SCRIPT_DIR, '../assets/data/questions.json')

def parse_csv_to_json():
    questions = []
    
    print(f"Reading from: {INPUT_FILE}")
    print(f"Writing to: {OUTPUT_FILE}")

    try:
        with open(INPUT_FILE, mode='r', encoding='utf-8') as csvfile:
            reader = csv.reader(csvfile)
            header = next(reader)  # Skip header

            for i, row in enumerate(reader):
                if not row or len(row) < 6:
                    continue

                # Columns based on DataSeeder logic:
                # 0:Subject, 1:Question, 2:Tip, 3:Diff, 4:Keywords, 5:Category
                # 6:Q_En, 7:Tip_En, 8:Keywords_En, 9:Category_En
                
                subject_raw = row[0].strip()
                question_text = row[1].strip()
                tip_text = row[2].strip()
                difficulty_str = row[3].strip()
                keywords_str = row[4].strip()
                category_raw = row[5].strip()
                
                question_en = row[6].strip() if len(row) > 6 else ""
                tip_en = row[7].strip() if len(row) > 7 else ""
                keywords_en_str = row[8].strip() if len(row) > 8 else ""
                category_en = row[9].strip() if len(row) > 9 else ""
                answer_text = row[10].strip() if len(row) > 10 else ""
                answer_en = row[11].strip() if len(row) > 11 else ""

                # Subject Mapping
                subject_key = 'etc'
                subject_map = {
                    '컴퓨터구조': 'computer_architecture',
                    '운영체제': 'operating_system',
                    '네트워크': 'network',
                    '데이터베이스': 'database',
                    '자료구조': 'data_structure',
                    '자바': 'java',
                    '자바스크립트': 'javascript',
                    '알고리즘': 'algorithm'
                }
                if subject_raw in subject_map:
                    subject_key = subject_map[subject_raw]
                
                # Level Mapping
                level = 1
                if difficulty_str == '중': level = 2
                if difficulty_str == '상': level = 3

                # ID Generation
                obj_id = f"{subject_key}_{str(i+1).zfill(3)}"

                question_obj = {
                    "id": obj_id,
                    "subject": subject_key,
                    "category": category_raw,
                    "question": question_text,
                    "questionEn": question_en,
                    "tip": tip_text,
                    "tipEn": tip_en,
                    "answer": answer_text,      
                    "answerEn": answer_en,
                    "depth": 0,
                    "keywords": [k.strip() for k in keywords_str.split(',') if k.strip()],
                    "keywordsEn": [k.strip() for k in keywords_en_str.split(',') if k.strip()],
                    "categoryEn": category_en,
                    "level": level
                }
                questions.append(question_obj)

        os.makedirs(os.path.dirname(OUTPUT_FILE), exist_ok=True)
        with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
            json.dump(questions, f, ensure_ascii=False, indent=2)
            
        print(f"Successfully converted {len(questions)} questions to {OUTPUT_FILE}")

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    parse_csv_to_json()
