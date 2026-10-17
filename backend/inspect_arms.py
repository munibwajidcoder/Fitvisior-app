import json

with open('backend/assets/models/base_avatar_male.glb', 'rb') as f:
    f.read(12)
    jlen = int.from_bytes(f.read(4), 'little')
    f.read(4)
    data = json.loads(f.read(jlen).decode('utf-8'))

nodes = data['nodes']
for idx in [37, 36, 35, 34, 67, 66, 65, 64]:
    n = nodes[idx]
    print(f"Node {idx} ({n.get('name')}):")
    print(f"  rotation: {n.get('rotation')}")
    print(f"  translation: {n.get('translation')}")
