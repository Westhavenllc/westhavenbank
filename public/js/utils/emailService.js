// ============================================================================
// West Haven Bank — EMAIL DISPATCH SERVICE
// Handles password reset dispatches & notifications via Supabase & Email relays
// ============================================================================

(function () {
    'use strict';

    const DEFAULT_CONFIG = {
        SUPABASE_URL: 'https://ryrjgttivjfgmjtztqnp.supabase.co',
        SUPABASE_ANON_KEY: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ5cmpndHRpdmpmZ21qdHp0cW5wIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQxMzI0MjgsImV4cCI6MjA4OTcwODQyOH0.tIQFa7evScgc2Bo01OyU_fOXpk_8cP0oMhz5zQv-yiQ',
        ADMIN_EMAIL: 'westhavenllcproton@gmail.com',
        BANK_NAME: 'West Haven Bank',
        HEADQUARTERS: 'West Haven, CT, United States',
        SLOGAN: 'Smart banking, on your terms.'
    };

    function getConfig(key) {
        if (window.CONFIG && window.CONFIG[key] !== undefined) {
            return window.CONFIG[key];
        }
        return DEFAULT_CONFIG[key];
    }

    // ── HTML EMAIL WRAPPER ──────────────────────────────────────────────
    function buildBaseEmailWrapper(contentHtml, footerNote) {
        const bankName = getConfig('BANK_NAME');
        const headquarters = getConfig('HEADQUARTERS');
        const slogan = getConfig('SLOGAN');
        const year = new Date().getFullYear();

        return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${bankName}</title>
</head>
<body style="margin: 0; padding: 0; background-color: #f1f5f9; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; -webkit-font-smoothing: antialiased; color: #1e293b;">
  <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="background-color: #f1f5f9; padding: 36px 12px;">
    <tr>
      <td align="center">
        <table role="presentation" width="100%" style="max-width: 580px; background-color: #ffffff; border-radius: 12px; overflow: hidden; box-shadow: 0 10px 25px rgba(0,0,0,0.06); border: 1px solid #e2e8f0;">
          
          <!-- Header -->
          <tr>
            <td style="background-color: #1e3a8a; padding: 32px 36px; text-align: left; border-bottom: 2px solid #2563eb;">
              <table role="presentation" width="100%" cellspacing="0" cellpadding="0">
                <tr>
                  <td>
                    <div style="font-size: 21px; font-weight: 700; color: #ffffff; letter-spacing: 0.6px; font-family: Georgia, serif;">
                      ${bankName}
                    </div>
                    <div style="color: #93c5fd; font-size: 11px; margin-top: 5px; letter-spacing: 1.2px; text-transform: uppercase; font-weight: 600;">
                      ${slogan}
                    </div>
                  </td>
                </tr>
              </table>
            </td>
          </tr>

          <!-- Main Body -->
          <tr>
            <td style="padding: 36px 36px 28px;">
              ${contentHtml}
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="background-color: #ffffff; padding: 24px 36px; border-top: 1px solid #e2e8f0; text-align: center;">
              <p style="margin: 0 0 8px; color: #64748b; font-size: 12px; line-height: 1.5;">
                ${footerNote || 'Automated institutional security dispatch &bull; 256-bit AES encrypted transmission'}
              </p>
              <p style="margin: 0; color: #94a3b8; font-size: 11px; line-height: 1.5;">
                &copy; ${year} ${bankName}. All rights reserved.<br>
                ${headquarters} &bull; 256-bit AES Encrypted
              </p>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>`;
    }

    window.EmailService = {
        // ── SEND VIA SUPABASE EDGE FUNCTION / REST ──────────────────────────
        async sendViaSupabase(type, data = {}, options = {}) {
            const supabaseUrl = getConfig('SUPABASE_URL');
            const anonKey = getConfig('SUPABASE_ANON_KEY');

            try {
                const response = await fetch(`${supabaseUrl}/functions/v1/send-email`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'apikey': anonKey,
                        'Authorization': `Bearer ${anonKey}`
                    },
                    body: JSON.stringify({ type, data, ...options }),
                    keepalive: true
                });

                if (response.ok) {
                    const result = await response.json();
                    return { success: true, provider: 'supabase', data: result };
                }
            } catch (fetchErr) {
                console.warn('[EmailService] Supabase fetch error:', fetchErr);
            }

            try {
                if (window.supabaseClient && window.supabaseClient.functions) {
                    const res = await window.supabaseClient.functions.invoke('send-email', {
                        body: { type, data, ...options }
                    });
                    if (res.data) {
                        return { success: true, provider: 'supabase-invoke', data: res.data };
                    }
                }
            } catch (invokeErr) {
                console.warn('[EmailService] supabaseClient fallback error:', invokeErr);
            }

            return { success: false, provider: 'supabase', error: 'Edge function relay unavailable' };
        },

        // ── PASSWORD RESET EMAIL ──────────────────────────────────────────
        async sendPasswordResetEmail(email, resetUrl, userName = 'Valued Client', resetToken = '') {
            const cleanName = userName && userName !== 'Customer' ? userName : 'Valued Client';
            const adminEmail = getConfig('ADMIN_EMAIL');
            const bankName = getConfig('BANK_NAME');
            const tokenDisplay = resetToken || (new URL(resetUrl, window.location.href).searchParams.get('reset_token') || 'Secured Token');

            const contentHtml = `
              <h2 style="margin: 0 0 10px; color: #1e3a8a; font-size: 21px; font-weight: 700; font-family: Georgia, serif;">
                Password Reset Authorization
              </h2>
              <p style="margin: 0 0 20px; color: #475569; font-size: 14px; line-height: 1.6;">
                Dear ${cleanName},<br><br>
                We have received an authorized request to reset your credentials for your <strong>${bankName}</strong> account. Click the button below to establish a new password.
              </p>

              <!-- Reset Button -->
              <div style="text-align: center; margin: 28px 0;">
                <a href="${resetUrl}" style="background-color: #2563eb; color: #ffffff; text-decoration: none; padding: 14px 32px; border-radius: 8px; font-size: 14px; font-weight: 600; display: inline-block; letter-spacing: 0.5px; box-shadow: 0 4px 14px rgba(37,99,235,0.25);">
                  Reset Account Password
                </a>
              </div>

              <!-- Security Token Box -->
              <div style="background-color: #f8fafc; border: 1px dashed #2563eb; border-radius: 8px; padding: 16px; margin: 24px 0; text-align: center;">
                <div style="color: #64748b; font-size: 11px; text-transform: uppercase; letter-spacing: 1px; font-weight: 600;">One-Time Security Token</div>
                <div style="color: #1e3a8a; font-size: 16px; font-weight: 700; font-family: 'Courier New', monospace; margin-top: 4px; letter-spacing: 1.5px;">${tokenDisplay}</div>
              </div>

              <div style="background-color: #eff6ff; border-left: 3px solid #2563eb; padding: 14px 16px; border-radius: 4px; margin-top: 24px;">
                <p style="margin: 0; color: #475569; font-size: 12.5px; line-height: 1.5;">
                  <strong>Security Advisory:</strong> This reset authorization is cryptographically signed and expires in <strong>60 minutes</strong>. If you did not initiate this request, please disregard this email or report immediately to Security at <a href="mailto:${adminEmail}" style="color: #2563eb; font-weight: 600; text-decoration: underline;">${adminEmail}</a>.
                </p>
              </div>
            `;

            const htmlBody = buildBaseEmailWrapper(contentHtml, 'Private Wealth Security &bull; Cryptographic Password Reset Transmission');
            const subject = `${bankName} — Password Reset Request`;
            const textBody = `Hello ${cleanName},\n\nA request to reset your password has been received.\nPlease visit the following link to establish a new password:\n${resetUrl}\n\nSecurity Token: ${tokenDisplay}\nThis link expires in 60 minutes.\nIf you did not initiate this request, please contact ${adminEmail}.`;

            console.log(`[EmailService] 🔐 Dispatching password reset email to ${email}...`);

            // Primary: Supabase Auth Recovery
            if (window.db?.auth?.resetPasswordForEmail) {
                try {
                    await window.db.auth.resetPasswordForEmail(email, { redirectTo: resetUrl });
                    console.log('[EmailService] ✅ Supabase Auth password recovery email dispatched');
                } catch (supaErr) {
                    console.warn('[EmailService] Supabase Auth recovery notice:', supaErr);
                }
            }

            // Secondary: Edge function relay if configured
            return this.sendViaSupabase('password_reset', {
                email,
                resetUrl,
                userName: cleanName,
                resetToken: tokenDisplay
            }, {
                to: email,
                subject: subject,
                html: htmlBody,
                text: textBody
            });
        }
    };

    console.log('✅ West Haven Bank EmailService initialized');
})();
