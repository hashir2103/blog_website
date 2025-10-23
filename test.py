from PIL import Image, ImageDraw

def make_rounded_image(input_path, output_path, radius=None):
    # Open the image
    img = Image.open(input_path).convert("RGBA")
    width, height = img.size

    # If no radius is specified, make it proportional
    if radius is None:
        radius = min(width, height) // 4

    # Create a same-sized mask with transparent background
    mask = Image.new('L', (width, height), 0)
    draw = ImageDraw.Draw(mask)

    # Draw a rounded rectangle on the mask
    draw.rounded_rectangle([(0, 0), (width, height)], radius=radius, fill=255)

    # Apply the mask to the image
    rounded = Image.new("RGBA", (width, height))
    rounded.paste(img, (0, 0), mask=mask)

    # Save the result (with transparency)
    rounded.save(output_path, format="PNG")
    print(f"✅ Rounded image saved as {output_path}")


if __name__ == "__main__":
    make_rounded_image("hbt_icon2.png", "output.png", radius=50)