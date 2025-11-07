from flask import Flask, render_template_string, jsonify
import os
import re
import json
import webbrowser
import logging
from pathlib import Path
from typing import Set, List, Dict, Any

# -------- CONFIG --------
MOD_LIST_FILE = "mod_list.txt"
MODS_FOLDER = "mods"  # Fixed: actual folder name is lowercase
TRANSLATED_FOLDER = ".translated"  # Vietnamese translations folder
PORT = 5000
DEBUG = False
# ------------------------

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

app = Flask(__name__)
app.config['DEBUG'] = DEBUG

def get_nexus_id_to_folder_mapping(mods_path: str) -> Dict[str, str]:
    """
    Create a mapping from Nexus ID to folder name by reading manifest.json files.
    
    Args:
        mods_path: Path to the mods directory
        
    Returns:
        Dictionary mapping Nexus ID to folder name
    """
    id_to_folder = {}
    mods_path_obj = Path(mods_path)
    
    if not mods_path_obj.exists():
        logger.warning(f"Mods folder '{mods_path}' does not exist")
        return id_to_folder
    
    manifest_count = 0
    for root, _, files in os.walk(mods_path):
        if "manifest.json" in files:
            manifest_path = os.path.join(root, "manifest.json")
            folder_name = os.path.basename(root)
            
            try:
                # Handle UTF-8 BOM by reading with utf-8-sig encoding
                with open(manifest_path, encoding="utf-8-sig") as f:
                    content = f.read()
                
                # Try to fix common JSON issues (same logic as get_installed_ids)
                try:
                    data = json.loads(content)
                except json.JSONDecodeError:
                    # Try to fix common JSON issues
                    import re
                    fixed_content = content
                    
                    # Remove JSON comments more carefully
                    lines = fixed_content.split('\n')
                    cleaned_lines = []
                    in_comment = False
                    
                    for line in lines:
                        # Handle multi-line comments
                        if '/*' in line and '*/' in line:
                            # Single line comment
                            line = re.sub(r'/\*.*?\*/', '', line)
                        elif '/*' in line:
                            # Start of multi-line comment
                            line = line[:line.find('/*')]
                            in_comment = True
                        elif '*/' in line and in_comment:
                            # End of multi-line comment
                            line = line[line.find('*/') + 2:]
                            in_comment = False
                        elif in_comment:
                            # Inside multi-line comment - skip this line
                            line = ""
                        
                        # Remove // comments but not in strings
                        if '//' in line and not line.strip().startswith('"'):
                            comment_pos = line.find('//')
                            # Make sure it's not inside a string
                            quote_count = line[:comment_pos].count('"')
                            if quote_count % 2 == 0:  # Even number of quotes = not inside string
                                line = line[:comment_pos]
                        
                        cleaned_lines.append(line)
                    
                    # Remove empty lines and join
                    fixed_content = '\n'.join(line for line in cleaned_lines if line.strip())
                    
                    # Fix unquoted property names like Name: to "Name": (but not inside strings)
                    # Only match at the beginning of lines (after whitespace)
                    fixed_content = re.sub(r'^(\s*)([A-Za-z_][A-Za-z0-9_]*)\s*:', r'\1"\2":', fixed_content, flags=re.MULTILINE)
                    
                    # Remove trailing commas
                    fixed_content = re.sub(r',(\s*[}\]])', r'\1', fixed_content)
                    
                    try:
                        data = json.loads(fixed_content)
                        logger.debug(f"Fixed JSON formatting in {manifest_path}")
                    except json.JSONDecodeError:
                        # If still can't parse, skip this manifest silently
                        continue
                
                manifest_count += 1
                if "UpdateKeys" in data:
                    for key in data["UpdateKeys"]:
                        if key.startswith("Nexus:"):
                            # Handle spaces in UpdateKeys like "Nexus: 35690"
                            nexus_id = key.split(":")[1].strip()
                            id_to_folder[nexus_id] = folder_name
                            logger.debug(f"Mapped Nexus ID {nexus_id} to folder '{folder_name}'")
                            
            except (UnicodeDecodeError, OSError) as e:
                logger.warning(f"Error reading manifest at {manifest_path}: {e}")
            except Exception as e:
                logger.error(f"Unexpected error reading manifest at {manifest_path}: {e}")
    
    logger.info(f"Scanned {manifest_count} manifests, created {len(id_to_folder)} ID-to-folder mappings")
    return id_to_folder

def get_installed_ids(mods_path: str) -> Set[str]:
    """
    Scan mods folder for installed Nexus IDs by reading manifest.json files.
    
    Args:
        mods_path: Path to the mods directory
        
    Returns:
        Set of Nexus mod IDs found in installed mods
    """
    ids = set()
    mods_path_obj = Path(mods_path)
    
    if not mods_path_obj.exists():
        logger.warning(f"Mods folder '{mods_path}' does not exist")
        return ids
    
    manifest_count = 0
    for root, _, files in os.walk(mods_path):
        if "manifest.json" in files:
            manifest_path = os.path.join(root, "manifest.json")
            try:
                # Handle UTF-8 BOM by reading with utf-8-sig encoding
                with open(manifest_path, encoding="utf-8-sig") as f:
                    content = f.read()
                
                # Try to fix common JSON issues
                try:
                    data = json.loads(content)
                except json.JSONDecodeError:
                    # Try to fix common JSON issues
                    import re
                    fixed_content = content
                    
                    # Remove JSON comments more carefully
                    # Remove /* ... */ comments but preserve URLs
                    lines = fixed_content.split('\n')
                    cleaned_lines = []
                    in_comment = False
                    
                    for line in lines:
                        # Handle multi-line comments
                        if '/*' in line and '*/' in line:
                            # Single line comment
                            line = re.sub(r'/\*.*?\*/', '', line)
                        elif '/*' in line:
                            # Start of multi-line comment
                            line = line[:line.find('/*')]
                            in_comment = True
                        elif '*/' in line and in_comment:
                            # End of multi-line comment
                            line = line[line.find('*/') + 2:]
                            in_comment = False
                        elif in_comment:
                            # Inside multi-line comment - skip this line
                            line = ""
                        
                        # Remove // comments but not in strings
                        if '//' in line and not line.strip().startswith('"'):
                            comment_pos = line.find('//')
                            # Make sure it's not inside a string
                            quote_count = line[:comment_pos].count('"')
                            if quote_count % 2 == 0:  # Even number of quotes = not inside string
                                line = line[:comment_pos]
                        
                        cleaned_lines.append(line)
                    
                    # Remove empty lines and join
                    fixed_content = '\n'.join(line for line in cleaned_lines if line.strip())
                    
                    # Fix unquoted property names like Name: to "Name": (but not inside strings)
                    # Only match at the beginning of lines (after whitespace)
                    fixed_content = re.sub(r'^(\s*)([A-Za-z_][A-Za-z0-9_]*)\s*:', r'\1"\2":', fixed_content, flags=re.MULTILINE)
                    
                    # Remove trailing commas
                    fixed_content = re.sub(r',(\s*[}\]])', r'\1', fixed_content)
                    
                    try:
                        data = json.loads(fixed_content)
                        logger.debug(f"Fixed JSON formatting in {manifest_path}")
                    except json.JSONDecodeError:
                        # If still can't parse, skip this manifest silently
                        continue
                
                manifest_count += 1
                if "UpdateKeys" in data:
                    for key in data["UpdateKeys"]:
                        if key.startswith("Nexus:"):
                            # Handle spaces in UpdateKeys like "Nexus: 35690"
                            nexus_id = key.split(":")[1].strip()
                            ids.add(nexus_id)
                            logger.debug(f"Found Nexus ID {nexus_id} in {manifest_path}")
                            
            except (UnicodeDecodeError, OSError) as e:
                logger.warning(f"Error reading manifest at {manifest_path}: {e}")
            except Exception as e:
                logger.error(f"Unexpected error reading manifest at {manifest_path}: {e}")
    
    logger.info(f"Scanned {manifest_count} manifests, found {len(ids)} unique Nexus IDs")
    return ids

def parse_mod_list(file_path: str) -> List[List[Dict[str, Any]]]:
    """
    Parse mod list file into groups, preserving sublinks and extracting URLs.
    
    Args:
        file_path: Path to the mod list text file
        
    Returns:
        List of mod groups, each containing mod entries with text and URLs
    """
    try:
        # Handle UTF-8 BOM in mod list file
        with open(file_path, encoding="utf-8-sig") as f:
            text = f.read()
    except (OSError, UnicodeDecodeError) as e:
        logger.error(f"Error reading mod list file '{file_path}': {e}")
        return []
    
    # Split by separator lines (10 or more dashes)
    groups = re.split(r"-{10,}", text)
    mod_groups = []
    
    for group_idx, group in enumerate(groups):
        if group.strip():
            lines = [line for line in group.strip().splitlines() if line.strip()]
            mods = []
            
            for line in lines:
                # Extract all URLs from the line
                urls = re.findall(r"https?://[^\s\)]+", line)
                # Clean up URLs (remove trailing punctuation)
                cleaned_urls = []
                for url in urls:
                    # Remove trailing punctuation that's not part of the URL
                    url = re.sub(r'[,;.!?]+$', '', url)
                    cleaned_urls.append(url)
                
                # Calculate indentation level for Reddit-style nesting
                indent_level = 0
                stripped_line = line.lstrip()
                
                if stripped_line.startswith("└"):
                    # Count leading spaces before └ to determine nesting level
                    leading_spaces = len(line) - len(stripped_line)
                    if leading_spaces == 0:
                        indent_level = 1  # Direct └ is level 1
                    else:
                        # Each group of 4 spaces adds one more level
                        indent_level = 1 + (leading_spaces // 4)
                elif line.startswith("    ") and not stripped_line.startswith("└"):
                    # Count groups of 4 spaces for indentation (without └)
                    spaces = len(line) - len(line.lstrip())
                    indent_level = spaces // 4
                
                mods.append({
                    "text": line,
                    "urls": cleaned_urls,
                    "is_subitem": indent_level > 0,
                    "indent_level": indent_level
                })
            
            if mods:  # Only add non-empty groups
                mod_groups.append(mods)
                logger.debug(f"Parsed group {group_idx + 1} with {len(mods)} mods")
    
    logger.info(f"Parsed {len(mod_groups)} mod groups from '{file_path}'")
    return mod_groups

def find_mod_folder(name: str) -> str:
    """
    Find mod folder using the same logic as patch.py.
    
    Args:
        name: Mod folder name to search for
        
    Returns:
        Path to the mod folder if found, None otherwise
    """
    # Check mods/<name> first
    direct_path = os.path.join(MODS_FOLDER, name)
    if os.path.isdir(direct_path):
        return direct_path
    
    # Then check mods/*/<name>
    if os.path.exists(MODS_FOLDER):
        for sub in os.listdir(MODS_FOLDER):
            sub_path = os.path.join(MODS_FOLDER, sub, name)
            if os.path.isdir(sub_path):
                return sub_path
    return None

def get_vietnamese_translations() -> Set[str]:
    """
    Get list of mod folders that have Vietnamese translations available.
    If it exists in .translated folder, assume translation is available.
    
    Returns:
        Set of mod folder names that have Vietnamese translations available
    """
    translated_mods = set()
    translated_path = Path(TRANSLATED_FOLDER)
    
    if not translated_path.exists():
        logger.warning(f"Translated folder '{TRANSLATED_FOLDER}' does not exist")
        return translated_mods
    
    # Simply list all folders in .translated - if it exists, translation is available
    for folder in os.listdir(TRANSLATED_FOLDER):
        translated_folder_path = os.path.join(TRANSLATED_FOLDER, folder)
        if os.path.isdir(translated_folder_path):
            translated_mods.add(folder)
    
    logger.info(f"Found {len(translated_mods)} Vietnamese translation folders")
    return translated_mods

def is_vietnamese_translation_applied(nexus_ids: List[str], main_mod_installed: bool, vietnamese_translations: Set[str], nexus_to_folder: Dict[str, str]) -> bool:
    """
    Check if Vietnamese translation is applied for a main mod.
    Logic: mod link → Nexus ID → manifest.json → folder name → check .translated folder
    
    Args:
        nexus_ids: List of Nexus IDs for this mod
        main_mod_installed: Whether the main mod is installed
        vietnamese_translations: Set of available translation folders
        nexus_to_folder: Mapping from Nexus ID to folder name
        
    Returns:
        True if translation is applied
    """
    if not main_mod_installed:
        return False
    
    # For each Nexus ID, find the corresponding folder and check if translation exists
    for nexus_id in nexus_ids:
        if nexus_id in nexus_to_folder:
            folder_name = nexus_to_folder[nexus_id]
            if folder_name in vietnamese_translations:
                logger.debug(f"Vietnamese translation found: Nexus ID {nexus_id} -> folder '{folder_name}'")
                return True
    
    return False

def parse_discord_links(text: str) -> Dict[str, Any]:
    """
    Parse Discord-style markdown links [title](url) and extract information.
    
    Args:
        text: Text with Discord markdown links
        
    Returns:
        Dictionary with parsed information
    """
    # Pattern to match [title](url) format
    link_pattern = r'\[([^\]]+)\]\(([^)]+)\)'
    matches = re.findall(link_pattern, text)
    
    if matches:
        # Get the first link as the main link
        title, url = matches[0]
        # Remove the markdown link from text, keep only the title
        clean_text = re.sub(link_pattern, r'\1', text, count=1)
        return {
            "title": title,
            "url": url.strip(),
            "clean_text": clean_text,
            "has_link": True
        }
    else:
        # No Discord-style links found, check for plain URLs
        urls = re.findall(r"https?://[^\s\)]+", text)
        return {
            "title": text,
            "url": urls[0] if urls else None,
            "clean_text": text,
            "has_link": bool(urls)
        }

def format_discord_text(text: str) -> str:
    """
    Convert Discord markdown formatting to HTML.
    
    Args:
        text: Text with Discord markdown formatting
        
    Returns:
        Text with HTML formatting
    """
    # Convert **bold** to <strong>bold</strong>
    text = re.sub(r'\*\*(.*?)\*\*', r'<strong>\1</strong>', text)
    
    # Convert *italic* to <em>italic</em>
    text = re.sub(r'\*(.*?)\*', r'<em>\1</em>', text)
    
    # Convert __underline__ to <u>underline</u>
    text = re.sub(r'__(.*?)__', r'<u>\1</u>', text)
    
    # Convert ~~strikethrough~~ to <del>strikethrough</del>
    text = re.sub(r'~~(.*?)~~', r'<del>\1</del>', text)
    
    # Convert `code` to <code>code</code>
    text = re.sub(r'`(.*?)`', r'<code>\1</code>', text)
    
    return text

def create_vietnamese_pill(mod: Dict[str, Any], parent_mod: Dict[str, Any] = None) -> str:
    """
    Create a Vietnamese translation pill with appropriate styling.
    
    Args:
        mod: The Vietnamese mod dictionary
        parent_mod: The parent mod dictionary (if available)
        
    Returns:
        HTML string for the Vietnamese pill
    """
    is_installed = mod.get("vietnamese_applied", False)
    parent_installed = parent_mod.get("checked", False) if parent_mod else False
    
    # Determine pill color based on status
    if is_installed:
        pill_class = "vn-pill-installed"
        status_text = "Installed"
    elif parent_installed:
        pill_class = "vn-pill-available"
        status_text = "Available"
    else:
        pill_class = "vn-pill-unavailable"
        status_text = "Parent not installed"
    
    # Check if this is a generic mod without a link (for mods without Vietnamese sublinks)
    if mod.get("has_link") == False:
        # This is a generic Vietnamese pill without a link
        clean_title = "VN"
        return f'<span class="vn-pill {pill_class}" title="{status_text}">{clean_title}</span>'
    
    # Regular processing for mods with Vietnamese sublinks
    link_info = parse_discord_links(mod["text"])
    title = link_info["title"].replace("└ ", "").strip()
    
    # Clean up the title for pill display
    # Remove brackets and extra formatting
    clean_title = title.replace("[", "").replace("]", "").strip()
    # Remove markdown formatting
    clean_title = re.sub(r'\*\*(.*?)\*\*', r'\1', clean_title)  # Remove **bold**
    clean_title = re.sub(r'\*(.*?)\*', r'\1', clean_title)      # Remove *italic*
    clean_title = re.sub(r'__(.*?)__', r'\1', clean_title)      # Remove __underline__
    
    # If it's just "Việt Hóa" or similar, make it shorter for pills
    if clean_title.lower() in ["việt hóa", "việt hoá", "vietnamese", "vietnamese translation"]:
        clean_title = "VN"
    elif "việt hóa" in clean_title.lower():
        # Keep the descriptive part but make it shorter
        clean_title = clean_title.replace("Việt Hóa", "VN").replace("việt hóa", "VN")
    elif len(clean_title) > 15:
        # For long descriptive titles, try to shorten them
        if "anime" in clean_title.lower():
            clean_title = "VN-Anime"
        elif "seasonal" in clean_title.lower():
            clean_title = "VN-Seasonal"
        elif any(word in clean_title.lower() for word in ["sve", "ridgeside", "east scarp"]):
            # Keep mod-specific identifiers
            if "sve" in clean_title.lower():
                clean_title = "VN-SVE"
            elif "ridgeside" in clean_title.lower():
                clean_title = "VN-RSV"
            elif "east scarp" in clean_title.lower():
                clean_title = "VN-ES"
        else:
            # Generic long title - just use VN
            clean_title = "VN"
    
    if link_info["has_link"]:
        return f'<a href="{link_info["url"]}" target="_blank" class="vn-pill {pill_class}" title="{status_text}">{clean_title}</a>'
    else:
        return f'<span class="vn-pill {pill_class}" title="{status_text}">{clean_title}</span>'

def extract_ids_from_line(line: str) -> List[str]:
    """
    Extract Nexus mod IDs from a text line containing URLs.
    
    Args:
        line: Text line that may contain Nexus URLs
        
    Returns:
        List of Nexus mod IDs found in the line
    """
    # Match Nexus URLs and extract the mod ID
    return re.findall(r"nexusmods\.com/stardewvalley/mods/(\d+)", line)

def is_vietnamese_mod(line: str) -> bool:
    """
    Check if a mod line is a Vietnamese translation.
    
    Args:
        line: Text line to check
        
    Returns:
        True if the line contains Vietnamese translation indicators
    """
    vietnamese_indicators = ["việt hóa", "việt hoá", "vietnamese", "tiếng việt"]
    line_lower = line.lower()
    return any(indicator in line_lower for indicator in vietnamese_indicators)

@app.route("/")
def index():
    """Main page displaying the mod list with installation status."""
    try:
        installed_ids = get_installed_ids(MODS_FOLDER)
        nexus_to_folder = get_nexus_id_to_folder_mapping(MODS_FOLDER)
        vietnamese_translations = get_vietnamese_translations()
        mod_groups = parse_mod_list(MOD_LIST_FILE)

        # Attach checkbox state and process URLs
        total_mods = 0
        installed_count = 0
        vietnamese_count = 0
        
        for group in mod_groups:
            processed_mods = []
            current_main_mod = None
            
            for mod in group:
                ids = extract_ids_from_line(mod["text"])
                mod["checked"] = any(i in installed_ids for i in ids)
                mod["nexus_ids"] = ids
                mod["is_vietnamese"] = is_vietnamese_mod(mod["text"])
                
                # Parse Discord-style links
                link_info = parse_discord_links(mod["text"])
                mod["link_info"] = link_info
                
                if mod["is_vietnamese"]:
                    # This is a Vietnamese mod - add it as a pill to the current main mod
                    if current_main_mod is not None:
                        # Check if translation is applied using the simplified logic
                        main_mod_name = current_main_mod["link_info"]["title"]
                        vn_mod_applied = is_vietnamese_translation_applied(
                            current_main_mod["nexus_ids"], 
                            current_main_mod["checked"], 
                            vietnamese_translations,
                            nexus_to_folder
                        )
                        
                        if vn_mod_applied:
                            current_main_mod["vietnamese_applied"] = True
                        
                        mod["vietnamese_applied"] = vn_mod_applied
                        
                        # Create Vietnamese pill and add to current main mod
                        vn_pill = create_vietnamese_pill(mod, current_main_mod)
                        current_main_mod["vietnamese_pills"].append(vn_pill)
                else:
                    # This is a main mod
                    mod["vietnamese_applied"] = False
                    mod["vietnamese_pills"] = []
                    
                    # Apply Discord formatting and create clickable title
                    if mod["link_info"]["has_link"]:
                        processed_text = f'<a href="{mod["link_info"]["url"]}" target="_blank" class="mod-title-link">{format_discord_text(mod["link_info"]["title"])}</a>'
                    else:
                        processed_text = format_discord_text(mod["link_info"]["clean_text"])
                    
                    mod["processed_text"] = processed_text
                    
                    processed_mods.append(mod)
                    current_main_mod = mod
                    
                    # Don't count "*Hoặc*" (means "or" in Vietnamese) as a mod
                    if "*Hoặc*" not in mod["text"]:
                        total_mods += 1
                        if mod["checked"]:
                            installed_count += 1
            
            # After processing all mods in the group, add generic Vietnamese pills for main mods
            # that have translation folders but no explicit Vietnamese sublinks
            for mod in processed_mods:
                if not mod["is_vietnamese"] and len(mod["vietnamese_pills"]) == 0:
                    # Check if this main mod has a Vietnamese translation folder
                    has_translation_folder = is_vietnamese_translation_applied(
                        mod["nexus_ids"], 
                        mod["checked"], 
                        vietnamese_translations,
                        nexus_to_folder
                    )
                    
                    if has_translation_folder:
                        mod["vietnamese_applied"] = True
                        # Create a generic Vietnamese pill for mods without explicit sublinks (no link)
                        generic_vn_mod = {
                            "text": "Việt Hóa",
                            "vietnamese_applied": True,
                            "has_link": False  # Explicitly mark as no link
                        }
                        vn_pill = create_vietnamese_pill(generic_vn_mod, mod)
                        mod["vietnamese_pills"].append(vn_pill)
            
            # Count Vietnamese translations
            for mod in processed_mods:
                if mod["vietnamese_applied"]:
                    vietnamese_count += 1
            
            # Update the group to only include processed main mods
            group[:] = processed_mods

        stats = {
            "total_mods": total_mods,
            "installed_count": installed_count,
            "vietnamese_count": vietnamese_count,
            "total_groups": len(mod_groups),
            "total_nexus_ids": len(installed_ids),
            "total_translations": len(vietnamese_translations)
        }

        return render_template_string(get_html_template(), 
                                    mod_groups=mod_groups, 
                                    stats=stats)
    
    except Exception as e:
        logger.error(f"Error in index route: {e}")
        return f"<h1>Error</h1><p>An error occurred: {e}</p>", 500

@app.route("/api/apply-translations", methods=["POST"])
def apply_translations():
    """API endpoint to apply Vietnamese translations using patch.py logic."""
    try:
        import subprocess
        result = subprocess.run(["python", "patch.py"], capture_output=True, text=True, cwd=".")
        
        if result.returncode == 0:
            return jsonify({
                "success": True,
                "message": "Vietnamese translations applied successfully",
                "output": result.stdout
            })
        else:
            return jsonify({
                "success": False,
                "message": "Error applying translations",
                "error": result.stderr
            }), 500
    
    except Exception as e:
        logger.error(f"Error applying translations: {e}")
        return jsonify({"success": False, "error": str(e)}), 500

@app.route("/api/stats")
def api_stats():
    """API endpoint for getting mod statistics."""
    try:
        installed_ids = get_installed_ids(MODS_FOLDER)
        nexus_to_folder = get_nexus_id_to_folder_mapping(MODS_FOLDER)
        vietnamese_translations = get_vietnamese_translations()
        mod_groups = parse_mod_list(MOD_LIST_FILE)
        
        total_mods = 0
        installed_count = 0
        vietnamese_count = 0
        
        for group in mod_groups:
            for mod in group:
                # Don't count "*Hoặc*" (means "or" in Vietnamese) as a mod
                if "*Hoặc*" not in mod["text"]:
                    total_mods += 1
                    
                    ids = extract_ids_from_line(mod["text"])
                    if any(i in installed_ids for i in ids):
                        installed_count += 1
                
                # Count Vietnamese translations (now stored as pills)
                if hasattr(mod, 'vietnamese_applied') and mod.get('vietnamese_applied', False):
                    vietnamese_count += 1
        
        return jsonify({
            "total_mods": total_mods,
            "installed_count": installed_count,
            "vietnamese_count": vietnamese_count,
            "total_groups": len(mod_groups),
            "total_nexus_ids": len(installed_ids),
            "total_translations": len(vietnamese_translations),
            "installation_percentage": round((installed_count / total_mods * 100) if total_mods > 0 else 0, 1),
            "vietnamese_percentage": round((vietnamese_count / total_mods * 100) if total_mods > 0 else 0, 1)
        })
    
    except Exception as e:
        logger.error(f"Error in stats API: {e}")
        return jsonify({"error": str(e)}), 500

def get_html_template() -> str:
    """Return the HTML template for the mod list viewer."""
    return """
    <!doctype html>
    <html lang="en">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Stardew Valley Mod List Viewer</title>
        <style>
            * { box-sizing: border-box; }
            body { 
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
                padding: 20px; 
                background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
                margin: 0;
                min-height: 100vh;
                color: #e0e0e0;
            }
            .container {
                max-width: 1200px;
                margin: 0 auto;
                background: rgba(30, 30, 50, 0.95);
                border-radius: 15px;
                padding: 30px;
                box-shadow: 0 10px 30px rgba(0,0,0,0.5);
                border: 1px solid rgba(255, 255, 255, 0.1);
            }
            .header {
                text-align: center;
                margin-bottom: 30px;
                padding-bottom: 20px;
                border-bottom: 2px solid rgba(255, 255, 255, 0.2);
            }
            .header h1 {
                color: #ffffff;
                margin: 0 0 10px 0;
                font-size: 2.5em;
                text-shadow: 0 2px 4px rgba(0,0,0,0.3);
            }
            .stats {
                display: flex;
                justify-content: center;
                gap: 30px;
                margin: 20px 0;
                flex-wrap: wrap;
            }
            .stat-item {
                background: rgba(40, 40, 60, 0.8);
                padding: 15px 25px;
                border-radius: 10px;
                text-align: center;
                border: 2px solid rgba(255, 255, 255, 0.1);
            }
            .stat-number {
                font-size: 2em;
                font-weight: bold;
                color: #4fc3f7;
                display: block;
            }
            .stat-label {
                color: #b0b0b0;
                font-size: 0.9em;
                margin-top: 5px;
            }
            .controls {
                display: flex;
                gap: 15px;
                margin-bottom: 25px;
                justify-content: center;
                flex-wrap: wrap;
            }
            .btn {
                padding: 12px 20px;
                border: none;
                border-radius: 8px;
                cursor: pointer;
                font-size: 14px;
                font-weight: 500;
                transition: all 0.3s ease;
                text-decoration: none;
                display: inline-block;
            }
            .btn-primary {
                background: #4fc3f7;
                color: #1a1a2e;
            }
            .btn-primary:hover {
                background: #29b6f6;
                transform: translateY(-2px);
            }
            .btn-secondary {
                background: rgba(60, 60, 80, 0.8);
                color: #e0e0e0;
                border: 1px solid rgba(255, 255, 255, 0.2);
            }
            .btn-secondary:hover {
                background: rgba(80, 80, 100, 0.9);
            }
            .group {
                background: rgba(40, 40, 60, 0.6);
                padding: 20px;
                margin-bottom: 15px;
                border-radius: 12px;
                box-shadow: 0 4px 15px rgba(0,0,0,0.3);
                border-left: 4px solid #4fc3f7;
                transition: transform 0.2s ease;
                border: 1px solid rgba(255, 255, 255, 0.1);
            }
            .group:hover {
                transform: translateY(-2px);
                background: rgba(50, 50, 70, 0.7);
            }
            .mod-line {
                display: flex;
                align-items: flex-start;
                margin-bottom: 8px;
                padding: 8px;
                border-radius: 6px;
                transition: background-color 0.2s ease;
            }
            .mod-line:hover {
                background-color: rgba(60, 60, 80, 0.5);
            }
            .mod-line.subitem {
                border-left: 3px solid rgba(79, 195, 247, 0.7);
                padding-left: 20px;
                background-color: rgba(40, 40, 60, 0.3);
                border-radius: 0 6px 6px 0;
                position: relative;
                margin-top: 4px;
                margin-bottom: 4px;
            }
            .mod-line.subitem:before {
                content: "";
                position: absolute;
                left: -3px;
                top: 0;
                bottom: 0;
                width: 3px;
                background: linear-gradient(to bottom, rgba(79, 195, 247, 0.8), rgba(79, 195, 247, 0.4));
                border-radius: 2px;
            }
            /* Reddit-style indentation levels */
            .mod-line.indent-1 { margin-left: 30px; }
            .mod-line.indent-2 { 
                margin-left: 60px; 
                border-left-color: rgba(255, 193, 7, 0.7);
            }
            .mod-line.indent-3 { 
                margin-left: 90px; 
                border-left-color: rgba(76, 175, 80, 0.7);
            }
            .mod-line.indent-4 { 
                margin-left: 120px; 
                border-left-color: rgba(156, 39, 176, 0.7);
            }
            .mod-line.indent-5 { 
                margin-left: 150px; 
                border-left-color: rgba(255, 87, 34, 0.7);
            }


            .mod-text {
                flex: 1;
                line-height: 1.4;
            }
            .mod-text a {
                color: #4fc3f7;
                text-decoration: none;
                font-weight: 500;
            }
            .mod-text a:hover {
                text-decoration: underline;
                color: #29b6f6;
            }
            .mod-line.installed {
                background-color: rgba(76, 175, 80, 0.15) !important;
                border-left: 3px solid #4caf50;
                padding-left: 15px;
            }
            .mod-line.installed:hover {
                background-color: rgba(76, 175, 80, 0.25) !important;
            }
            .mod-line.or-separator {
                background-color: rgba(60, 60, 80, 0.4);
                border: none;
                border-radius: 20px;
                padding: 12px 20px;
                margin: 15px 0;
                justify-content: center;
                position: relative;
                overflow: hidden;
            }
            .mod-line.or-separator:before {
                content: "";
                position: absolute;
                left: 0;
                right: 0;
                top: 50%;
                height: 1px;
                background: linear-gradient(to right, transparent, rgba(255, 255, 255, 0.3), transparent);
                z-index: 1;
            }
            .or-text {
                text-align: center;
                width: 100%;
                position: relative;
                z-index: 2;
            }
            .or-title {
                background-color: rgba(40, 40, 60, 0.9);
                color: #b0b0b0;
                font-weight: 500;
                font-size: 0.9em;
                padding: 6px 16px;
                border-radius: 15px;
                border: 1px solid rgba(255, 255, 255, 0.2);
                display: inline-block;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }
            .vietnamese-mod {
                border-right: 4px solid #ffc107;
            }

            .mod-badges {
                display: flex;
                gap: 5px;
                margin-left: 10px;
                align-items: center;
            }
            .badge {
                padding: 2px 8px;
                border-radius: 12px;
                font-size: 0.75em;
                font-weight: bold;
                text-transform: uppercase;
            }
            .badge-vietnamese {
                background-color: #ff9800;
                color: #ffffff;
            }
            .badge-applied {
                background-color: #4caf50;
                color: #ffffff;
            }
            .mod-text strong {
                color: #495057;
                font-weight: 600;
            }
            .mod-text em {
                color: #6c757d;
                font-style: italic;
            }
            .mod-text u {
                text-decoration: underline;
                color: #495057;
            }
            .mod-text del {
                text-decoration: line-through;
                color: #6c757d;
            }
            .mod-text code {
                background-color: rgba(60, 60, 80, 0.8);
                color: #4fc3f7;
                padding: 2px 4px;
                border-radius: 3px;
                font-family: 'Courier New', monospace;
                font-size: 0.9em;
                border: 1px solid rgba(255, 255, 255, 0.1);
            }
            .mod-title {
                display: inline;
            }
            .mod-text strong {
                color: #ffffff;
                font-weight: 600;
            }
            .mod-text em {
                color: #b0b0b0;
                font-style: italic;
            }
            .mod-text u {
                text-decoration: underline;
                color: #e0e0e0;
            }
            .mod-text del {
                text-decoration: line-through;
                color: #888888;
            }
            .mod-title-link {
                color: #e0e0e0 !important;
                text-decoration: none;
                font-weight: 600;
            }
            .mod-title-link:hover {
                text-decoration: underline;
                color: #ffffff !important;
            }
            .vietnamese-pills {
                display: inline-flex;
                flex-wrap: wrap;
                gap: 6px;
                margin-left: 12px;
                align-items: center;
            }
            .vn-pill {
                display: inline-block;
                padding: 4px 8px;
                border-radius: 10px;
                font-size: 0.7em;
                font-weight: 700;
                text-decoration: none;
                transition: all 0.2s ease;
                cursor: pointer;
                margin: 0 3px;
                text-transform: uppercase;
                letter-spacing: 0.3px;
                min-width: 24px;
                text-align: center;
            }
            .vn-pill-installed {
                background-color: #4caf50 !important;
                color: #ffffff !important;
                border: 1px solid #4caf50;
                box-shadow: 0 2px 4px rgba(76, 175, 80, 0.3);
                font-weight: 800 !important;
            }
            .vn-pill-installed:hover {
                background-color: #45a049 !important;
                border-color: #45a049;
                color: #ffffff !important;
                text-decoration: none !important;
                transform: translateY(-1px);
            }
            .vn-pill-available {
                background-color: #ff9800 !important;
                color: #ffffff !important;
                border: 1px solid #ff9800;
                box-shadow: 0 2px 4px rgba(255, 152, 0, 0.3);
                font-weight: 800 !important;
            }
            .vn-pill-available:hover {
                background-color: #f57c00 !important;
                border-color: #f57c00;
                color: #ffffff !important;
                text-decoration: none !important;
                transform: translateY(-1px);
            }
            .vn-pill-unavailable {
                background-color: #757575 !important;
                color: #ffffff !important;
                border: 1px solid #757575;
                opacity: 0.8;
                box-shadow: 0 2px 4px rgba(117, 117, 117, 0.3);
                font-weight: 800 !important;
            }
            .vn-pill-unavailable:hover {
                background-color: #616161 !important;
                border-color: #616161;
                color: #ffffff !important;
                text-decoration: none !important;
                opacity: 1;
            }
            .filter-controls {
                margin-bottom: 20px;
                text-align: center;
            }
            .filter-btn {
                margin: 0 5px;
                padding: 8px 16px;
                border: 2px solid #4fc3f7;
                background: rgba(40, 40, 60, 0.8);
                color: #4fc3f7;
                border-radius: 20px;
                cursor: pointer;
                transition: all 0.3s ease;
            }
            .filter-btn.active, .filter-btn:hover {
                background: #4fc3f7;
                color: #1a1a2e;
            }
            .hidden { display: none !important; }
            .loading {
                text-align: center;
                padding: 40px;
                color: #b0b0b0;
            }
            @media (max-width: 768px) {
                .container { padding: 15px; }
                .stats { gap: 15px; }
                .stat-item { padding: 10px 15px; }
                .controls { justify-content: center; }
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>🎮 Stardew Valley Mod List</h1>
                <div class="stats">
                    <div class="stat-item">
                        <span class="stat-number">{{ stats.installed_count }}</span>
                        <div class="stat-label">Installed Mods</div>
                    </div>
                    <div class="stat-item">
                        <span class="stat-number">{{ stats.total_mods }}</span>
                        <div class="stat-label">Total Mods</div>
                    </div>
                    <div class="stat-item">
                        <span class="stat-number">{{ stats.vietnamese_count }}</span>
                        <div class="stat-label">Việt Hóa Applied</div>
                    </div>
                    <div class="stat-item">
                        <span class="stat-number">{{ stats.total_groups }}</span>
                        <div class="stat-label">Mod Groups</div>
                    </div>
                    <div class="stat-item">
                        <span class="stat-number">{{ "%.1f"|format((stats.installed_count / stats.total_mods * 100) if stats.total_mods > 0 else 0) }}%</span>
                        <div class="stat-label">Completion</div>
                    </div>
                </div>
            </div>
            
            <div class="controls">
                <button class="btn btn-primary" onclick="location.reload()">🔄 Refresh</button>
                <button class="btn btn-secondary" onclick="toggleInstalled()">👁️ Toggle Installed Only</button>
                <button class="btn btn-secondary" onclick="applyTranslations()">🇻🇳 Apply Việt Hóa</button>
                <a href="/api/stats" class="btn btn-secondary" target="_blank">📊 API Stats</a>
            </div>
            
            <div class="filter-controls">
                <button class="filter-btn active" onclick="filterMods('all')">All Mods</button>
                <button class="filter-btn" onclick="filterMods('installed')">Installed Only</button>
                <button class="filter-btn" onclick="filterMods('missing')">Missing Only</button>
                <button class="filter-btn" onclick="filterMods('vietnamese')">Việt Hóa Only</button>
                <button class="filter-btn" onclick="filterMods('vietnamese-applied')">Việt Hóa Applied</button>
            </div>
            
            <div id="mod-groups">
                {% for group in mod_groups %}
                <div class="group" data-group-index="{{ loop.index0 }}">
                    {% for mod in group %}
                    {% if "*Hoặc*" in mod.text %}
                    <div class="mod-line or-separator" data-installed="false" data-vietnamese="false" data-vietnamese-applied="false">
                        <div class="or-text">
                            <span class="or-title">{{ mod.processed_text|safe }}</span>
                        </div>
                    </div>
                    {% else %}
                    <div class="mod-line {% if mod.is_subitem %}subitem indent-{{ mod.indent_level }}{% endif %} {% if mod.checked %}installed{% endif %} {% if mod.vietnamese_applied %}vietnamese-applied{% endif %}" 
                         data-installed="{{ mod.checked|lower }}" 
                         data-vietnamese="{{ mod.vietnamese_applied|lower }}"
                         data-vietnamese-applied="{{ mod.vietnamese_applied|lower }}">
                        <div class="mod-text">
                            <span class="mod-title">{{ mod.processed_text|safe }}</span>
                            {% if mod.vietnamese_pills %}
                                <span class="vietnamese-pills">
                                    {% for pill in mod.vietnamese_pills %}
                                        {{ pill|safe }}
                                    {% endfor %}
                                </span>
                            {% endif %}
                        </div>
                        <div class="mod-badges">
                        </div>
                    </div>
                    {% endif %}
                    {% endfor %}
                </div>
                {% endfor %}
            </div>
        </div>
        
        <script>
            let currentFilter = 'all';
            
            function filterMods(filter) {
                currentFilter = filter;
                const groups = document.querySelectorAll('.group');
                const filterBtns = document.querySelectorAll('.filter-btn');
                
                // Update button states
                filterBtns.forEach(btn => btn.classList.remove('active'));
                event.target.classList.add('active');
                
                groups.forEach(group => {
                    const modLines = group.querySelectorAll('.mod-line');
                    let hasVisibleMods = false;
                    
                    modLines.forEach(modLine => {
                        let shouldShow = false;
                        
                        // Skip or-separator lines from filtering
                        if (modLine.classList.contains('or-separator')) {
                            shouldShow = true;
                        } else {
                            const isInstalled = modLine.getAttribute('data-installed') === 'true';
                            const hasVietnamesePills = modLine.querySelector('.vietnamese-pills');
                            const isVietnameseApplied = modLine.getAttribute('data-vietnamese-applied') === 'true';
                            
                            switch(filter) {
                                case 'installed':
                                    shouldShow = isInstalled;
                                    break;
                                case 'missing':
                                    shouldShow = !isInstalled;
                                    break;
                                case 'vietnamese':
                                    shouldShow = hasVietnamesePills && hasVietnamesePills.children.length > 0;
                                    break;
                                case 'vietnamese-applied':
                                    shouldShow = isVietnameseApplied;
                                    break;
                                default:
                                    shouldShow = true;
                            }
                        }
                        
                        modLine.style.display = shouldShow ? 'flex' : 'none';
                        if (shouldShow && !modLine.classList.contains('or-separator')) {
                            hasVisibleMods = true;
                        }
                    });
                    
                    // Hide the entire group if no mods are visible (except or-separators)
                    group.style.display = hasVisibleMods ? 'block' : 'none';
                });
            }
            
            function toggleInstalled() {
                const newFilter = currentFilter === 'installed' ? 'all' : 'installed';
                const targetBtn = document.querySelector(`[onclick="filterMods('${newFilter}')"]`);
                if (targetBtn) {
                    targetBtn.click();
                }
            }
            
            function applyTranslations() {
                if (!confirm('Apply Vietnamese translations? This will run patch.py script.')) {
                    return;
                }
                
                const btn = event.target;
                const originalText = btn.textContent;
                btn.textContent = '⏳ Applying...';
                btn.disabled = true;
                
                fetch('/api/apply-translations', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    }
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        alert('Vietnamese translations applied successfully!\\n\\n' + data.output);
                        location.reload();
                    } else {
                        alert('Error applying translations:\\n' + (data.error || data.message));
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Network error occurred while applying translations.');
                })
                .finally(() => {
                    btn.textContent = originalText;
                    btn.disabled = false;
                });
            }
            
            // Auto-refresh every 30 seconds
            setInterval(() => {
                console.log('Auto-refreshing mod status...');
                location.reload();
            }, 30000);
        </script>
    </body>
    </html>
    """

if __name__ == "__main__":
    logger.info(f"Starting Stardew Valley Mod List Viewer on port {PORT}")
    logger.info(f"Mods folder: {MODS_FOLDER}")
    logger.info(f"Mod list file: {MOD_LIST_FILE}")
    
    # Check if required files exist
    if not Path(MOD_LIST_FILE).exists():
        logger.error(f"Mod list file '{MOD_LIST_FILE}' not found!")
    if not Path(MODS_FOLDER).exists():
        logger.error(f"Mods folder '{MODS_FOLDER}' not found!")
    
    try:
        webbrowser.open(f"http://127.0.0.1:{PORT}")
        app.run(host='127.0.0.1', port=PORT, debug=DEBUG)
    except Exception as e:
        logger.error(f"Failed to start server: {e}")
        input("Press Enter to exit...")
