import yaml
import os

class LabParser:
    def __init__(self, labs_dir: str):
        self.labs_dir = labs_dir

    def parse_lab(self, lab_id: str):
        lab_yaml = os.path.join(self.labs_dir, lab_id, "lab.yaml")
        if not os.path.exists(lab_yaml):
            raise FileNotFoundError(f"Lab {lab_id} not found")
        
        with open(lab_yaml, "r") as f:
            data = yaml.safe_load(f)
            
        # Optional documentation files
        question_path = os.path.join(self.labs_dir, lab_id, "question.md")
        solution_path = os.path.join(self.labs_dir, lab_id, "solution.md")
        
        data["question"] = ""
        data["solution"] = ""
        
        if os.path.exists(question_path):
            with open(question_path, "r") as f:
                data["question"] = f.read()
                
        if os.path.exists(solution_path):
            with open(solution_path, "r") as f:
                data["solution"] = f.read()
                
        # Set defaults
        if "exposed_ports" not in data:
            data["exposed_ports"] = []
        if "verify_script" not in data and "verify" in data:
            data["verify_script"] = data["verify"]
                
        return data
