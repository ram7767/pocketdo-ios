#!/bin/bash
# Create simple placeholder PNG files for screenshots
# These should be replaced with actual app screenshots

for file in login.png signup.png dashboard.png task-list.png add-task.png settings.png premium.png; do
  # Create a 750x1334 PNG (iPhone 8 resolution) with a simple gradient
  convert -size 750x1334 gradient:#667eea-#764ba2 "$file" 2>/dev/null || \
  python3 -c "
import struct, zlib
width, height = 750, 1334
# Create simple PNG
raw_data = b''
for y in range(height):
    raw_data += b'\\x00'  # filter byte
    for x in range(width):
        r = int(102 + (x * 30 / width))
        g = int(126 + (x * 20 / width))
        b = int(234 - (y * 50 / height))
        raw_data += struct.pack('BBB', r, g, b)

compressed = zlib.compress(raw_data)
ihdr = struct.pack('>IIBBBBB', width, height, 8, 2, 0, 0, 0)

def chunk(chunk_type, data):
    chunk_data = chunk_type + data
    return struct.pack('>I', len(data)) + chunk_data + struct.pack('>I', zlib.crc32(chunk_data) & 0xffffffff)

png = b'\\x89PNG\\r\\n\\x1a\\n'
png += chunk(b'IHDR', ihdr)
png += chunk(b'IDAT', compressed)
png += chunk(b'IEND', b'')

with open('$file', 'wb') as f:
    f.write(png)
print('Created $file')
"
done
