import json
import numpy as np

def compute_torso_scales(sc_h, sc_b, sc_w, sc_hp, sc_sh):
    # If hips are large (e.g. 1.25), clamp hips so it doesn't overpower waist
    # Natural human waist-to-hip ratio: waist is at least 0.85-0.95 of hips in heavy males
    eff_hp = float(np.clip(sc_hp, 0.70, 1.25))
    eff_w = float(np.clip(sc_w, 0.65, 1.45))
    eff_b = float(np.clip(sc_b, 0.70, 1.40))
    
    # In heavy build, waist should be robust
    eff_w = max(eff_w, eff_hp * 0.90)
    eff_b = max(eff_b, eff_w * 0.92)

    # 1. Hips scale
    hips_scale = [round(eff_hp, 4), round(sc_h, 4), round(eff_hp, 4)]

    # 2. Spine (waist)
    # Target world scale is eff_w
    loc_spine_x = eff_w / eff_hp
    loc_spine_z = eff_w / eff_hp
    spine_scale = [round(loc_spine_x, 4), 1.0, round(loc_spine_z, 4)]

    # 3. Spine1 (belly depth in Z)
    spine1_scale = [1.0, 1.0, round(max(1.0, eff_w * 0.95), 4)]

    # 4. Spine2 (chest)
    # Target world scale is eff_b
    loc_spine2_x = eff_b / eff_w
    loc_spine2_z = eff_b / eff_w
    spine2_scale = [round(loc_spine2_x, 4), 1.0, round(loc_spine2_z, 4)]

    # 5. Shoulders
    eff_sh = sc_sh * max(1.0, (eff_b - 1.0) * 0.5 + 1.0)

    print(f"Computed Scales for Inputs (h={sc_h}, b={sc_b}, w={sc_w}, hp={sc_hp}):")
    print(f"  Hips: {hips_scale} -> World Width: {eff_hp:.2f}")
    print(f"  Spine (Waist): {spine_scale} -> World Width: {eff_w:.2f}")
    print(f"  Spine2 (Chest): {spine2_scale} -> World Width: {eff_b:.2f}")
    print(f"  Shoulders scale: {eff_sh:.2f}")

compute_torso_scales(0.95, 1.15, 1.15, 1.30, 1.0)
compute_torso_scales(1.0, 0.80, 0.75, 0.85, 1.0)
