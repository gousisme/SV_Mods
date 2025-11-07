import os
import shutil

translated_dir = ".translated"
mods_dir = "mods"

def find_mod_folder(name):
    for root, dirs, files in os.walk(mods_dir):
        if name in dirs:
            return os.path.join(root, name)
    return None

for folder in os.listdir(translated_dir):
    translated_path = os.path.join(translated_dir, folder)
    mods_path = find_mod_folder(folder)

    if mods_path:
        copywhole_flag = os.path.join(translated_path, ".copywhole")

        if os.path.exists(copywhole_flag):
            for item in os.listdir(translated_path):
                if item == ".copywhole":
                    continue
                src = os.path.join(translated_path, item)
                dst = os.path.join(mods_path, item)

                if os.path.isdir(src):
                    shutil.copytree(src, dst, dirs_exist_ok=True)
                else:
                    shutil.copy2(src, dst)

            print(f"Copied entire '{folder}' into '{mods_path}' ✓")
        else:
            # Check if translated_path contains an i18n subfolder
            i18n_source = os.path.join(translated_path, "i18n")
            
            if os.path.isdir(i18n_source):
                # Copy contents of i18n directly to mods_path
                for item in os.listdir(i18n_source):
                    src = os.path.join(i18n_source, item)
                    mods_path = os.path.join(mods_path, "i18n")
                    dst = os.path.join(mods_path, item)

                    if os.path.isdir(src):
                        shutil.copytree(src, dst, dirs_exist_ok=True)
                    else:
                        shutil.copy2(src, dst)

                print(f"Copied from '{i18n_source}' to '{mods_path}' ✓")
            else:
                # Original behavior: copy to mod/i18n
                i18n_path = os.path.join(mods_path, "i18n")
                os.makedirs(i18n_path, exist_ok=True)

                for item in os.listdir(translated_path):
                    src = os.path.join(translated_path, item)
                    dst = os.path.join(i18n_path, item)

                    if os.path.isdir(src):
                        shutil.copytree(src, dst, dirs_exist_ok=True)
                    else:
                        shutil.copy2(src, dst)

                print(f"Copied from '{translated_path}' to '{i18n_path}' ✓")