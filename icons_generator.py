from PIL import Image
import os

def generate_ios_icons(input_path, output_dir):
    # Create output directory if it doesn't exist
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    # Define all required sizes
    icon_sizes = {
        'Icon-20.png': 20,      # iPad Notification 1x
        'Icon-29.png': 29,      # iPad Settings 1x
        'Icon-40.png': 40,      # iPad Notification 2x, iPhone Notification 2x
        'Icon-58.png': 58,      # iPhone Settings 2x
        'Icon-60.png': 60,      # iPhone Notification 3x
        'Icon-76.png': 76,      # iPad App 1x
        'Icon-80.png': 80,      # iPhone Spotlight 2x
        'Icon-87.png': 87,      # iPhone Settings 3x
        'Icon-120.png': 120,    # iPhone App 2x
        'Icon-152.png': 152,    # iPad App 2x
        'Icon-167.png': 167,    # iPad Pro App 2x
        'Icon-180.png': 180,    # iPhone App 3x
        'Icon-1024.png': 1024,  # App Store
    }

    # Open original image
    try:
        original = Image.open(input_path)
    except Exception as e:
        print(f"Error opening image: {e}")
        return

    # Generate each size
    for icon_name, size in icon_sizes.items():
        try:
            # Create a copy of the original image and resize it
            resized = original.copy()
            resized = resized.resize((size, size), Image.Resampling.LANCZOS)
            
            # Save the resized image
            output_path = os.path.join(output_dir, icon_name)
            resized.save(output_path, 'PNG')
            print(f"Generated {icon_name} ({size}x{size})")
        except Exception as e:
            print(f"Error generating {icon_name}: {e}")

if __name__ == "__main__":
    # Set your paths here
    input_icon = "assets/app_icon.png"  # Your original 180x180 icon
    output_directory = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    
    generate_ios_icons(input_icon, output_directory)
    print("Icon generation complete!")