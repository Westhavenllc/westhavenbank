// ============================================
// SUPABASE INITIALIZATION
// ============================================

(function () {
    const SUPABASE_URL = 'https://ryrjgttivjfgmjtztqnp.supabase.co';
    const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ5cmpndHRpdmpmZ21qdHp0cW5wIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQxMzI0MjgsImV4cCI6MjA4OTcwODQyOH0.tIQFa7evScgc2Bo01OyU_fOXpk_8cP0oMhz5zQv-yiQ';

    if (!window.supabase || typeof window.supabase.createClient !== 'function') {
        console.error('❌ Supabase CDN not loaded. Make sure the CDN <script> tag comes before supabase.js');
        return;
    }

    const client = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
        auth: {
            persistSession: true,
            autoRefreshToken: true,
            detectSessionInUrl: false,
            storage: window.localStorage
        }
    });

    // Expose under both names so auth.js and dashboard.js always find it
    window.supabaseClient = client;
    window.db = client;

    console.log('✅ Supabase initialized');
})();