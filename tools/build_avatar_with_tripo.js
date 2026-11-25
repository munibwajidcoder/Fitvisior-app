const fs = require('fs');
const https = require('https');
const path = require('path');

const API_KEY = 'tsk_HLuaaCSbq8NFGez4T2Urct220isyZ1R5YCCMAqtScGw';
const BASE_HOST = 'openapi.tripo3d.ai';

function makeRequest(method, endpoint, headers, bodyData) {
    return new Promise((resolve, reject) => {
        const req = https.request({
            hostname: BASE_HOST,
            path: endpoint,
            method: method,
            headers: headers
        }, (res) => {
            let body = '';
            res.on('data', chunk => body += chunk);
            res.on('end', () => {
                try {
                    const parsed = JSON.parse(body);
                    resolve(parsed);
                } catch(e) {
                    resolve(body);
                }
            });
        });
        req.on('error', reject);
        if (bodyData) {
            req.write(bodyData);
        }
        req.end();
    });
}

function uploadImage(filePath) {
    return new Promise((resolve, reject) => {
        const boundary = '----WebKitFormBoundary' + Math.random().toString(36).substring(2);
        const fileContent = fs.readFileSync(filePath);
        const filename = path.basename(filePath);

        const pre = `--${boundary}\r\nContent-Disposition: form-data; name="file"; filename="${filename}"\r\nContent-Type: image/jpeg\r\n\r\n`;
        const post = `\r\n--${boundary}--\r\n`;

        const preBuf = Buffer.from(pre, 'utf-8');
        const postBuf = Buffer.from(post, 'utf-8');
        const totalLen = preBuf.length + fileContent.length + postBuf.length;

        const req = https.request({
            hostname: BASE_HOST,
            path: '/v3/files',
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${API_KEY}`,
                'Content-Type': `multipart/form-data; boundary=${boundary}`,
                'Content-Length': totalLen
            }
        }, (res) => {
            let body = '';
            res.on('data', chunk => body += chunk);
            res.on('end', () => {
                try {
                    const json = JSON.parse(body);
                    if (json.code === 0 && json.data) {
                        const token = json.data.image_token || json.data.file_token;
                        resolve(token);
                    } else {
                        reject(new Error('Upload failed: ' + body));
                    }
                } catch (e) {
                    reject(e);
                }
            });
        });
        req.on('error', reject);
        req.write(preBuf);
        req.write(fileContent);
        req.write(postBuf);
        req.end();
    });
}

async function pollTask(taskId, label) {
    console.log(`Polling ${label} (${taskId})...`);
    for (let i = 1; i <= 60; i++) {
        await new Promise(r => setTimeout(r, 4000));
        const res = await makeRequest('GET', `/v3/tasks/${taskId}`, {
            'Authorization': `Bearer ${API_KEY}`
        });
        if (res.code === 0 && res.data) {
            const status = res.data.status;
            const progress = res.data.progress || 0;
            console.log(`[${i}/60] ${label} status: ${status} (${progress}%)`);
            if (status === 'success') {
                return res.data.output;
            }
            if (status === 'failed' || status === 'cancelled') {
                throw new Error(`${label} terminated with status: ${status}`);
            }
        }
    }
    throw new Error(`${label} timed out after polling`);
}

function downloadFile(url, destPath) {
    return new Promise((resolve, reject) => {
        const file = fs.createWriteStream(destPath);
        https.get(url, (res) => {
            if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
                return downloadFile(res.headers.location, destPath).then(resolve).catch(reject);
            }
            res.pipe(file);
            file.on('finish', () => {
                file.close();
                resolve();
            });
        }).on('error', (err) => {
            fs.unlink(destPath, () => {});
            reject(err);
        });
    });
}

async function main() {
    const inputPhoto = 'assets/images/user_scan_front.jpg';
    if (!fs.existsSync(inputPhoto)) {
        throw new Error('Photo not found: ' + inputPhoto);
    }
    console.log('=== STEP 1: Uploading user photo ===');
    const fileToken = await uploadImage(inputPhoto);
    console.log('User photo uploaded! Token:', fileToken);

    console.log('\n=== STEP 2: Creating 3D Mesh from user photo (Tripo v3.1) ===');
    const meshPayload = JSON.stringify({
        input: fileToken,
        model: 'v3.1-20260211',
        texture: true,
        pbr: true,
        delight: true,
        face_limit: 45000,
        texture_quality: 'detailed',
        geometry_quality: 'detailed',
        texture_alignment: 'original_image',
        auto_size: true
    });
    const meshRes = await makeRequest('POST', '/v3/generation/image-to-model', {
        'Authorization': `Bearer ${API_KEY}`,
        'Content-Type': 'application/json'
    }, meshPayload);
    if (!meshRes.data || !meshRes.data.task_id) {
        throw new Error('Could not create mesh task: ' + JSON.stringify(meshRes));
    }
    const meshTaskId = meshRes.data.task_id;
    console.log('Mesh task created:', meshTaskId);
    const meshOutput = await pollTask(meshTaskId, '3D Mesh Generation');
    console.log('Mesh ready! Model URL:', meshOutput.model_url || meshOutput.pbr_model);

    console.log('\n=== STEP 3: Humanoid Skeletal Auto-Rigging ===');
    const rigPayload = JSON.stringify({
        input: meshTaskId,
        model: 'v3.0-20260909',
        rig_type: 'biped',
        spec: 'mixamo',
        out_format: 'glb'
    });
    const rigRes = await makeRequest('POST', '/v3/animations/rig', {
        'Authorization': `Bearer ${API_KEY}`,
        'Content-Type': 'application/json'
    }, rigPayload);
    if (!rigRes.data || !rigRes.data.task_id) {
        throw new Error('Could not create rig task: ' + JSON.stringify(rigRes));
    }
    const rigTaskId = rigRes.data.task_id;
    console.log('Rig task created:', rigTaskId);
    await pollTask(rigTaskId, 'Skeletal Rigging');

    console.log('\n=== STEP 4: Retargeting ALL 3 Runway Animations (Idle, Walk, Turn) ===');
    const retargetPayload = JSON.stringify({
        original_model_task_id: rigTaskId,
        input: rigTaskId,
        animations: [
            'preset:idle',
            'preset:walk',
            'preset:turn'
        ],
        animate_in_place: true,
        export_with_geometry: true,
        out_format: 'glb'
    });
    const retargetRes = await makeRequest('POST', '/v3/animations/retarget', {
        'Authorization': `Bearer ${API_KEY}`,
        'Content-Type': 'application/json'
    }, retargetPayload);
    if (!retargetRes.data || !retargetRes.data.task_id) {
        throw new Error('Could not create retarget task: ' + JSON.stringify(retargetRes));
    }
    const retargetTaskId = retargetRes.data.task_id;
    console.log('Retarget task created:', retargetTaskId);
    const retargetOutput = await pollTask(retargetTaskId, 'Multi-Animation Retargeting');
    const finalGlbUrl = retargetOutput.model_url || retargetOutput.pbr_model || retargetOutput.model;
    console.log('\n🎉 SUCCESS! Multi-Animation Avatar URL:', finalGlbUrl);

    console.log('\n=== STEP 5: Downloading and Saving to Project ===');
    const destinations = [
        'assets/models/base_avatar_female.glb',
        'assets/models/base_avatar_male.glb',
        'backend/assets/models/base_avatar_female.glb',
        'backend/assets/models/base_avatar_male.glb'
    ];

    const tempFile = 'assets/models/temp_new_avatar.glb';
    console.log('Downloading from:', finalGlbUrl);
    await downloadFile(finalGlbUrl, tempFile);

    const stat = fs.statSync(tempFile);
    console.log(`Downloaded ${stat.size} bytes successfully!`);

    destinations.forEach(dest => {
        fs.copyFileSync(tempFile, dest);
        console.log(`Saved -> ${dest}`);
    });
    fs.unlinkSync(tempFile);

    console.log('\n=== VERIFICATION: Checking animation tracks ===');
    const buf = fs.readFileSync('assets/models/base_avatar_female.glb');
    const jsonLen = buf.readUInt32LE(12);
    const gltf = JSON.parse(buf.toString('utf8', 20, 20 + jsonLen));
    console.log('Bake animations count:', (gltf.animations || []).length);
    (gltf.animations || []).forEach((a, i) => {
        console.log(` Track ${i}: "${a.name}"`);
    });
    console.log('ALL COMPLETE! Live Model URL for Supabase/Cloud: ' + finalGlbUrl);
}

main().catch(err => {
    console.error('Fatal generation error:', err);
    process.exit(1);
});
