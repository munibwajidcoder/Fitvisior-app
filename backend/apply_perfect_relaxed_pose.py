import json
import struct
import numpy as np

def update_model(input_path, output_path, is_male):
    with open(input_path, "rb") as f:
        magic = f.read(4)
        version = int.from_bytes(f.read(4), "little")
        total_len = int.from_bytes(f.read(4), "little")
        chunk0_len = int.from_bytes(f.read(4), "little")
        chunk0_type = f.read(4)
        json_bytes = f.read(chunk0_len)
        chunk1_header = f.read(8)
        chunk1_len = int.from_bytes(chunk1_header[:4], "little")
        bin_data = bytearray(f.read(chunk1_len))

    data = json.loads(json_bytes.decode("utf-8"))
    nodes = data['nodes']
    name_to_node = {n.get('name'): n for n in nodes if n.get('name')}

    # 1. Arm rotation (hands directly against hips)
    deg = 11.0 if is_male else 10.5
    theta = np.radians(deg)
    dq = [np.sin(theta/2), 0, 0, np.cos(theta/2)]
    w1, x1, y1, z1 = dq[3], dq[0], dq[1], dq[2]

    for arm_name in ['RightArm', 'LeftArm']:
        if arm_name in name_to_node:
            orig_q = name_to_node[arm_name]['rotation']
            w2, x2, y2, z2 = orig_q[3], orig_q[0], orig_q[1], orig_q[2]
            q_new = [
                float(w1*x2 + x1*w2 + y1*z2 - z1*y2),
                float(w1*y2 - x1*z2 + y1*w2 + z1*x2),
                float(w1*z2 + x1*y2 - y1*x2 + z1*w2),
                float(w1*w2 - x1*x2 - y1*y2 - z1*z2)
            ]
            # normalize
            norm = np.sqrt(sum(x*x for x in q_new))
            name_to_node[arm_name]['rotation'] = [round(x/norm, 6) for x in q_new]

    # 2. If male: transform h_wig into a tight masculine buzz cut
    if is_male and 'h_wig' in name_to_node:
        wig_node = name_to_node['h_wig']
        wig_mesh = data['meshes'][wig_node['mesh']]
        prim = wig_mesh['primitives'][0]
        pos_acc = data['accessors'][prim['attributes']['POSITION']]
        bv = data['bufferViews'][pos_acc['bufferView']]
        offset = bv.get('byteOffset', 0) + pos_acc.get('byteOffset', 0)
        count = pos_acc['count']
        stride = bv.get('byteStride', 12)

        for i in range(count):
            off = offset + i * stride
            x, y, z = struct.unpack('<3f', bin_data[off : off + 12])
            if y < 0.83:
                new_y = 0.85 + (y - 0.83) * 0.02
                new_x = x * 0.88
                new_z = z * 0.88
                bin_data[off : off + 12] = struct.pack('<3f', new_x, new_y, new_z)

        wig_node['scale'] = [1.0, 1.0, 1.0]

    # Save
    new_json_bytes = json.dumps(data, separators=(",", ":")).encode("utf-8")
    while len(new_json_bytes) % 4 != 0:
        new_json_bytes += b" "

    new_total_len = 12 + 8 + len(new_json_bytes) + 8 + len(bin_data)
    with open(output_path, "wb") as f:
        f.write(magic)
        f.write(version.to_bytes(4, "little"))
        f.write(new_total_len.to_bytes(4, "little"))
        f.write(len(new_json_bytes).to_bytes(4, "little"))
        f.write(chunk0_type)
        f.write(new_json_bytes)
        f.write(chunk1_header)
        f.write(bin_data)

    print(f"Updated {output_path}")

# Update male models
update_model("backend/assets/models/base_avatar_male.glb", "backend/assets/models/base_avatar_male.glb", is_male=True)
update_model("backend/assets/models/base_avatar_female.glb", "backend/assets/models/base_avatar_female.glb", is_male=False)
update_model("assets/models/base_avatar_male.glb", "assets/models/base_avatar_male.glb", is_male=True)
update_model("assets/models/base_avatar_female.glb", "assets/models/base_avatar_female.glb", is_male=False)
update_model("assets/models/base_avatar.glb", "assets/models/base_avatar.glb", is_male=True)
update_model("backend/assets/models/base_avatar.glb", "backend/assets/models/base_avatar.glb", is_male=True)
