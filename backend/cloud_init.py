import os
import subprocess
import shutil

class CloudInitBuilder:
    def __init__(self, output_dir: str):
        self.output_dir = output_dir
        os.makedirs(output_dir, exist_ok=True)

    def build_iso(self, instance_id: str, user_data_content: str) -> str:
        """
        Builds a cloud-init ISO image using xorriso.
        Requires volume label 'cidata'.
        Contains user-data and meta-data files.
        """
        iso_path = os.path.join(self.output_dir, f"{instance_id}-cloud-init.iso")
        temp_dir = os.path.join(self.output_dir, f"{instance_id}-tmp")
        os.makedirs(temp_dir, exist_ok=True)

        meta_data_path = os.path.join(temp_dir, "meta-data")
        user_data_path = os.path.join(temp_dir, "user-data")

        # Write meta-data
        with open(meta_data_path, "w") as f:
            f.write(f"instance-id: {instance_id}\n")
            f.write(f"local-hostname: {instance_id}\n")

        # Write user-data
        with open(user_data_path, "w") as f:
            f.write(user_data_content)

        if os.path.exists(iso_path):
            os.remove(iso_path)

        # Build ISO using xorriso
        # Command: xorriso -as mkisofs -R -V cidata -o iso_path temp_dir
        try:
            subprocess.run([
                "xorriso", "-as", "mkisofs",
                "-R", "-V", "cidata",
                "-o", iso_path,
                temp_dir
            ], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except subprocess.CalledProcessError as e:
            raise Exception(f"Failed to build cloud-init ISO: {e}")
        finally:
            # Cleanup temp directory
            shutil.rmtree(temp_dir)

        return iso_path
