$ErrorActionPreference = "Stop"
$apiKey = "tsk_HLuaaCSbq8NFGez4T2Urct220isyZ1R5YCCMAqtScGw"
$headers = @{
    "Authorization" = "Bearer $apiKey"
}
$jsonHeaders = @{
    "Authorization" = "Bearer $apiKey"
    "Content-Type" = "application/json"
}

$meshTaskId = "75eae643-5e8c-4725-a640-a888d3b92f23"
Write-Host "Using generated 3D Mesh Task: $meshTaskId"

Write-Host "`n=== STEP 3: Auto-Rigging with Mixamo Humanoid Bones ==="
$rigPayload = @{
    input = $meshTaskId
    model = "v3.0-20260909"
    rig_type = "biped"
    spec = "mixamo"
    out_format = "glb"
} | ConvertTo-Json

$rigResp = Invoke-RestMethod -Uri "https://openapi.tripo3d.ai/v3/animations/rig" -Method Post -Headers $jsonHeaders -Body $rigPayload
Write-Host "Rig Task Response:" ($rigResp | ConvertTo-Json -Compress)
$rigTaskId = $rigResp.data.task_id
if (-not $rigTaskId) { throw "Could not create rig task" }
Write-Host "Rig Task ID: $rigTaskId"

# Poll rig task
Write-Host "Waiting for Skeletal Rigging..."
$riggedGlbUrl = ""
for ($i = 1; $i -le 60; $i++) {
    Start-Sleep -Seconds 3
    $pollResp = Invoke-RestMethod -Uri "https://openapi.tripo3d.ai/v3/tasks/$rigTaskId" -Headers $headers
    $status = $pollResp.data.status
    $progress = $pollResp.data.progress
    Write-Host "[$i/60] Rig Progress: $progress% ($status)"
    if ($status -eq "success") {
        $output = $pollResp.data.output
        $riggedGlbUrl = $output.model_url
        if (-not $riggedGlbUrl) { $riggedGlbUrl = $output.model }
        if (-not $riggedGlbUrl) { $riggedGlbUrl = $output.pbr_model }
        Write-Host "Rigging complete! Rigged GLB: $riggedGlbUrl"
        break
    }
    if ($status -eq "failed" -or $status -eq "cancelled") {
        throw "Rigging failed: $($pollResp | ConvertTo-Json -Compress)"
    }
}
if (-not $riggedGlbUrl) { throw "Rigging timed out" }

Write-Host "`n=== STEP 4: Retargeting ALL 3 Animations (Idle, Catwalk, Turn & Pose) ==="
$retargetPayload = @{
    original_model_task_id = $rigTaskId
    input = $rigTaskId
    animations = @("preset:idle", "preset:walk", "preset:turn")
    animate_in_place = $true
    export_with_geometry = $true
    out_format = "glb"
} | ConvertTo-Json

$retargetResp = Invoke-RestMethod -Uri "https://openapi.tripo3d.ai/v3/animations/retarget" -Method Post -Headers $jsonHeaders -Body $retargetPayload
Write-Host "Retarget Task Response:" ($retargetResp | ConvertTo-Json -Compress)
$retargetTaskId = $retargetResp.data.task_id
if (-not $retargetTaskId) { throw "Could not create retarget task" }
Write-Host "Retarget Task ID: $retargetTaskId"

# Poll retarget task
Write-Host "Waiting for Multi-Animation Retargeting..."
$finalGlbUrl = ""
for ($i = 1; $i -le 60; $i++) {
    Start-Sleep -Seconds 3
    $pollResp = Invoke-RestMethod -Uri "https://openapi.tripo3d.ai/v3/tasks/$retargetTaskId" -Headers $headers
    $status = $pollResp.data.status
    $progress = $pollResp.data.progress
    Write-Host "[$i/60] Retarget Progress: $progress% ($status)"
    if ($status -eq "success") {
        $output = $pollResp.data.output
        $finalGlbUrl = $output.model_url
        if (-not $finalGlbUrl) { $finalGlbUrl = $output.model }
        if (-not $finalGlbUrl) { $finalGlbUrl = $output.pbr_model }
        Write-Host "Multi-Animation Retarget complete! GLB: $finalGlbUrl"
        break
    }
    if ($status -eq "failed" -or $status -eq "cancelled") {
        throw "Retargeting failed: $($pollResp | ConvertTo-Json -Compress)"
    }
}
if (-not $finalGlbUrl) { throw "Retargeting timed out" }

Write-Host "`n=== STEP 5: Downloading Final Rigged & Multi-Animated GLB ==="
$outputPath = "D:\Fitvisor project\assets\models\avatar_runway_catwalk.glb"
Invoke-WebRequest -Uri $finalGlbUrl -OutFile $outputPath
Write-Host "SUCCESS! Saved final 3D Runway Avatar to: $outputPath (Size: $((Get-Item $outputPath).Length) bytes)"
Write-Host "Direct Model URL: $finalGlbUrl"
