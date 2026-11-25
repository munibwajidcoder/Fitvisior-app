const https = require('https');

const SUPABASE_URL = 'oifklsdxmpmdfbnaazso.supabase.co';
const SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9pZmtsc2R4bXBtZGZibmFhenNvIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc5MTYyNjcyMywiZXhwIjoyMTA3MjAyNzIzfQ.ZRqmi-fxfSJF5PbEICvjStspDRBxS-xI_qkO__W8d1k';

const newGlbUrl = 'https://openapi-dl.data.tripo3d.com/tcli_d7a0383d91f44d5d8f75b0af39dc7fc3/20261113/e93f6521-09dd-4d43-8f5b-c5f904412a32/tripo_retarget_e93f6521-09dd-4d43-8f5b-c5f904412a32.glb?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9vcGVuYXBpLWRsLmRhdGEudHJpcG8zZC5jb20vdGNsaV9kN2EwMzgzZDkxZjQ0ZDVkOGY3NWIwYWYzOWRjN2ZjMy8yMDI2MTExMy9lOTNmNjUyMS0wOWRkLTRkNDMtOGY1Yi1jNWY5MDQ0MTJhMzIvdHJpcG9fcmV0YXJnZXRfZTkzZjY1MjEtMDlkZC00ZDQzLThmNWItYzVmOTA0NDEyYTMyLmdsYiIsIkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTc5NDY5NjQ1OX19fV19&Signature=uc84yp03LCp~-Wwm4uOsPnNt1mRI9nwZZqNtwIzlL8fyNRoBtoPyez~Rtucq6YkEo3b5R~UBUuEk9fnxfnW8g0h4uWUTvB4aOiC3m4gg11AO5~3KjvOnpA~xGnQ3UW7JOwGZhO9~SsBtVRrkuy69pG~gqyqOCzU75~Rkt19PHSdMsolxbd7T7U1H6aqYUNyYG2mw2l9jxuimPFWOsFCVy0k54p9175kEe-7OAXEhNuYeg5QqG945kYNfw2-CP3zPHiwoh6y2kjkHJikD9GxsAJexNs2M84aBRYcYAOKx8l31UpxROLKvigGUDbJ42RxEf1xn0lGbsjYRomPEbt2t3g__&Key-Pair-Id=K1676C64NMVM2J';

const payload = JSON.stringify({
    avatar_glb_url: newGlbUrl
});

const req = https.request({
    hostname: SUPABASE_URL,
    path: '/rest/v1/profiles?avatar_glb_url=neq.empty',
    method: 'PATCH',
    headers: {
        'apikey': SERVICE_KEY,
        'Authorization': `Bearer ${SERVICE_KEY}`,
        'Content-Type': 'application/json',
        'Prefer': 'return=representation'
    }
}, (res) => {
    let body = '';
    res.on('data', chunk => body += chunk);
    res.on('end', () => {
        console.log('Update profiles status:', res.statusCode);
        console.log('Updated rows:', body.substring(0, 300));
    });
});

req.on('error', (e) => console.error(e));
req.write(payload);
req.end();

