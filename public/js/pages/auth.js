// ============================================
// AUTH PAGE UI CONTROLLER
// ============================================

let currentOTP  = '';
let resetToken  = '';
let individualData = {};

const CLOUDINARY = {
    cloudName:    'dqhyk9qur',
    uploadPreset: 'West_Haven_uploads'
};

// ── INIT ─────────────────────────────────────

document.addEventListener('DOMContentLoaded', async () => {
    if (!window.Auth) { console.error('Auth not loaded'); return; }
    if (!window.db)   { console.error('Supabase not loaded'); return; }

    const isRecovery = window.location.hash.includes('type=recovery') ||
                       window.location.search.includes('type=recovery') ||
                       window.location.hash.includes('access_token') ||
                       window.location.search.includes('code=');

    // Listen for Supabase password recovery link redirect immediately
    if (window.db?.auth) {
        window.db.auth.onAuthStateChange(async (event, session) => {
            console.log('Supabase Auth State Change:', event);
            if (event === 'PASSWORD_RECOVERY' || (event === 'SIGNED_IN' && isRecovery)) {
                openModal('updatePasswordModal');
            }
        });
    }

    applyTheme();
    await loadCountries();

    if (!isRecovery) {
        await checkSession();
    }

    bindEvents();
    bindFileInputs();

    if (isRecovery) {
        setTimeout(() => {
            openModal('updatePasswordModal');
        }, 250);
    }
});

function applyTheme() {
    const t = localStorage.getItem('theme') || 'light';
    document.documentElement.setAttribute('data-theme', t);
    const icon = document.querySelector('#themeToggle i');
    if (icon) icon.className = t === 'light' ? 'fas fa-moon' : 'fas fa-sun';
}

async function checkSession() {
    try {
        const s = await Auth.validateSession();
        if (s) window.location.href = '/dashboard.html';
    } catch (_) {}
}

function bindEvents() {
    document.getElementById('loginForm')?.addEventListener('submit', handleLogin);
    document.getElementById('jointPrimaryForm')?.addEventListener('submit', handleJointSubmit);
    document.getElementById('secondUserForm')?.addEventListener('submit', handleSecondUserSubmit);

    document.getElementById('themeToggle')?.addEventListener('click', () => {
        const next = document.documentElement.getAttribute('data-theme') === 'light' ? 'dark' : 'light';
        document.documentElement.setAttribute('data-theme', next);
        localStorage.setItem('theme', next);
        const icon = document.querySelector('#themeToggle i');
        if (icon) icon.className = next === 'light' ? 'fas fa-moon' : 'fas fa-sun';
    });

    document.addEventListener('click', (e) => {
        if (e.target.classList.contains('modal') && e.target.classList.contains('active')) {
            closeModal(e.target.id);
        }
    });

    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') {
            const open = document.querySelector('.modal.active');
            if (open) closeModal(open.id);
        }
    });
}

// ── MODAL HELPERS ─────────────────────────────

window.openModal = function(id) {
    const m = document.getElementById(id);
    if (!m) { console.error('Modal not found:', id); return; }
    document.getElementById('authContainer').style.opacity = '0.3';
    document.getElementById('authContainer').style.pointerEvents = 'none';
    m.classList.add('active');
    document.body.style.overflow = 'hidden';

    if (id === 'forgotModal') { resetForgotForm(); }
};

window.closeModal = function(id) {
    const m = document.getElementById(id);
    if (!m) return;
    m.classList.remove('active');
    document.getElementById('authContainer').style.opacity = '1';
    document.getElementById('authContainer').style.pointerEvents = 'auto';
    document.body.style.overflow = '';

    if (id === 'individualModal')      resetIndividualForm();
    if (id === 'jointModal')           resetJointForm();
    if (id === 'secondUserModal')      resetSecondUserForm();
    if (id === 'forgotModal')          resetForgotForm();
    if (id === 'updatePasswordModal')  resetUpdatePasswordForm();
    if (id === 'otpVerifyModal')       document.getElementById('otpInput').value = '';
};

window.showModal = window.openModal;
window.hideModal = window.closeModal;

window.openIndividualForm = function() {
    closeModal('accountTypeModal');
    setTimeout(() => openModal('individualModal'), 250);
};
window.showIndividualForm = window.openIndividualForm;

window.openJointForm = function() {
    closeModal('accountTypeModal');
    setTimeout(() => openModal('jointModal'), 250);
};
window.showJointForm = window.openJointForm;

function changeLanguage(lang) { console.log('Language:', lang); }

// ── LOGIN ─────────────────────────────────────

async function handleLogin(e) {
    e.preventDefault();
    const btn  = e.target.querySelector('button[type="submit"]');
    const orig = btn?.innerHTML;
    if (btn) { btn.disabled = true; btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Signing in…'; }

    const email    = document.getElementById('loginEmail').value.trim();
    const password = document.getElementById('loginPassword').value;
    const result   = await Auth.login(email, password);

    if (result.success) {
        window.location.href = '/dashboard.html';
    } else {
        showLoginError(result.error || 'Invalid email or password');
        if (btn) { btn.disabled = false; btn.innerHTML = orig; }
    }
}

function showLoginError(msg) {
    document.querySelector('.auth-error-msg')?.remove();
    const el = document.createElement('div');
    el.className = 'auth-error-msg';
    el.style.cssText = 'background:#fee2e2;color:#b91c1c;border:1px solid #fca5a5;' +
        'border-radius:8px;padding:10px 14px;margin-top:12px;font-size:.875rem;' +
        'display:flex;align-items:center;gap:8px;';
    el.innerHTML = `<i class="fas fa-exclamation-circle"></i> ${msg}`;
    document.getElementById('loginForm').appendChild(el);
    setTimeout(() => el.remove(), 5000);
}

// ── COUNTRIES ────────────────────────────────

async function loadCountries() {
    const countries = await Auth.fetchCountries();
    ['indCountry', 'jointCountry1', 'secondCountry'].forEach(id => {
        const s = document.getElementById(id);
        if (!s) return;
        s.innerHTML = '<option value="">Select country</option>';
        countries.forEach(c => { s.innerHTML += `<option value="${c.code}">${c.name}</option>`; });
    });
}

// ── INDIVIDUAL REGISTRATION ───────────────────

window.nextIndividualStep = function(step) {
    if (step === 1 && validateStep1()) {
        individualData = {
            firstName: document.getElementById('indFirstName').value,
            lastName:  document.getElementById('indLastName').value,
            email:     document.getElementById('indEmail').value,
            password:  document.getElementById('indPassword').value,
            birthDate: document.getElementById('indBirthDate').value,
            gender:    document.getElementById('indGender').value,
            country:   document.getElementById('indCountry').options[
                           document.getElementById('indCountry').selectedIndex].text
        };
        setStepUI(1, 2);
    }
};

window.prevIndividualStep = function() { setStepUI(2, 1); };

function setStepUI(from, to) {
    document.getElementById('individualStep' + from).classList.remove('active');
    document.getElementById('individualStep' + to).classList.add('active');
    document.querySelectorAll('#individualModal .step').forEach((d, i) => {
        d.classList.remove('active', 'completed');
        if (i + 1 < to)  d.classList.add('completed');
        if (i + 1 === to) d.classList.add('active');
    });
}

function validateStep1() {
    const f  = id => document.getElementById(id)?.value || '';
    const fn = f('indFirstName'), ln = f('indLastName'), em = f('indEmail'),
          pw = f('indPassword'),  cf = f('indConfirm'),
          bd = f('indBirthDate'), gn = f('indGender'),   co = f('indCountry');
    if (!fn||!ln||!em||!pw||!cf||!bd||!gn||!co) { alert('Please fill in all fields'); return false; }
    if (pw.length < 8)    { alert('Password must be at least 8 characters'); return false; }
    if (pw !== cf)         { alert('Passwords do not match'); return false; }
    if (!em.includes('@')) { alert('Please enter a valid email'); return false; }
    return true;
}

window.processIndividualSignup = async function() {
    individualData.governmentId   = document.getElementById('govIdUrl').value;
    individualData.profilePicture = document.getElementById('profilePicUrl').value;

    if (!individualData.governmentId)   { alert('Please upload your government ID'); return; }
    if (!individualData.profilePicture) { alert('Please upload your profile picture'); return; }

    const btn = document.getElementById('indCompleteBtn');
    if (btn) { btn.disabled = true; btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Creating account…'; }

    const result = await Auth.signUpIndividual(individualData);

    if (result.success) {
        if (result.emailConfirmationRequired) {
            alert('Account created! A confirmation link has been sent to your email. Please verify your email before signing in.');
            closeModal('individualModal');
        } else {
            window.location.href = '/dashboard.html';
        }
    } else {
        alert('Registration failed: ' + result.error);
        if (btn) { btn.disabled = false; btn.innerHTML = 'Complete'; }
    }
};

function resetIndividualForm() {
    ['indFirstName','indLastName','indEmail','indPassword','indConfirm',
     'indBirthDate','indGender','indCountry'].forEach(id => {
        const el = document.getElementById(id); if (el) el.value = '';
    });
    clearUpload('govId');
    clearUpload('profilePic');
    document.getElementById('individualStep1').classList.add('active');
    document.getElementById('individualStep2').classList.remove('active');
    document.querySelectorAll('#individualModal .step').forEach((d, i) => {
        d.classList.toggle('active', i === 0);
        d.classList.remove('completed');
    });
    const btn = document.getElementById('indCompleteBtn');
    if (btn) { btn.disabled = false; btn.innerHTML = 'Complete'; }
    individualData = {};
}

// ── JOINT REGISTRATION (User A) ──────────────

async function handleJointSubmit(e) {
    e.preventDefault();

    const pass1 = document.getElementById('jointPass1').value;
    const conf1 = document.getElementById('jointConfirm1').value;
    if (pass1 !== conf1)  { alert('Passwords do not match'); return; }
    if (pass1.length < 8) { alert('Password must be at least 8 characters'); return; }

    const required = ['jointFirst1','jointLast1','jointEmail1','jointBirth1',
                      'jointGender1','jointCountry1','jointEmail2'];
    for (const id of required) {
        if (!document.getElementById(id)?.value) { alert('Please fill in all fields'); return; }
    }

    if (!document.getElementById('jointId1Url').value)  { alert('Please upload your government ID'); return; }
    if (!document.getElementById('jointPic1Url').value) { alert('Please upload your profile picture'); return; }

    const secondUserEmail = document.getElementById('jointEmail2').value.trim();

    const primaryData = {
        firstName:      document.getElementById('jointFirst1').value,
        lastName:       document.getElementById('jointLast1').value,
        email:          document.getElementById('jointEmail1').value,
        password:       pass1,
        birthDate:      document.getElementById('jointBirth1').value,
        gender:         document.getElementById('jointGender1').value,
        country:        document.getElementById('jointCountry1').options[
                            document.getElementById('jointCountry1').selectedIndex].text,
        governmentId:   document.getElementById('jointId1Url').value,
        profilePicture: document.getElementById('jointPic1Url').value
    };

    const btn = document.getElementById('jointSubmitBtn');
    if (btn) { btn.disabled = true; btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Creating account…'; }

    const result = await Auth.initJointAccount(primaryData);

    if (result.success) {
        document.getElementById('jointFormWrapper').style.display = 'none';
        document.getElementById('otpDisplay').style.display       = 'block';
        document.getElementById('jointOtp').textContent           = result.otp;

        const info = document.createElement('div');
        info.className = 'alert alert-info';
        info.style.marginBottom = '16px';
        info.innerHTML = `<i class="fas fa-info-circle"></i>
            <span>Share this OTP with <strong>${secondUserEmail}</strong>.
            They must click <em>"Complete Joint Account Setup"</em> on the login page,
            enter this OTP, then fill in their own details.</span>`;
        document.getElementById('otpDisplay').insertBefore(info, document.getElementById('otpDisplay').firstChild);
    } else {
        alert('Registration failed: ' + result.error);
        if (btn) { btn.disabled = false; btn.innerHTML = 'Create Account &amp; Get OTP'; }
    }
}

function resetJointForm() {
    ['jointFirst1','jointLast1','jointEmail1','jointPass1','jointConfirm1',
     'jointBirth1','jointGender1','jointCountry1','jointEmail2'].forEach(id => {
        const el = document.getElementById(id); if (el) el.value = '';
    });
    clearUpload('jointId1');
    clearUpload('jointPic1');
    document.getElementById('jointFormWrapper').style.display = 'block';
    document.getElementById('otpDisplay').style.display       = 'none';
    document.querySelectorAll('#otpDisplay .alert-info').forEach(el => el.remove());
    const btn = document.getElementById('jointSubmitBtn');
    if (btn) { btn.disabled = false; btn.innerHTML = 'Create Account &amp; Get OTP'; }
}

// ── OTP VERIFICATION (User B) ─────────────────

window.verifyOTP = async function() {
    const otp = document.getElementById('otpInput').value.trim();
    if (!/^\d{6}$/.test(otp)) { alert('Please enter a valid 6-digit OTP'); return; }

    const btn = document.getElementById('otpVerifyBtn');
    if (btn) { btn.disabled = true; btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Verifying…'; }

    try {
        const { data, error } = await window.db
            .from('joint_accounts')
            .select('id, status')
            .eq('invitation_otp', otp)
            .single();

        if (error || !data) {
            alert('Invalid OTP. Please check the code and try again.');
            if (btn) { btn.disabled = false; btn.innerHTML = 'Verify &amp; Continue <i class="fas fa-arrow-right"></i>'; }
            return;
        }
        if (data.status !== 'pending') {
            alert('This OTP has already been used — the account is already active.');
            if (btn) { btn.disabled = false; btn.innerHTML = 'Verify &amp; Continue <i class="fas fa-arrow-right"></i>'; }
            return;
        }

        currentOTP = otp;
        if (btn) { btn.disabled = false; btn.innerHTML = 'Verify &amp; Continue <i class="fas fa-arrow-right"></i>'; }
        closeModal('otpVerifyModal');
        setTimeout(() => openModal('secondUserModal'), 250);

    } catch (err) {
        alert('Error verifying OTP. Please try again.');
        if (btn) { btn.disabled = false; btn.innerHTML = 'Verify &amp; Continue <i class="fas fa-arrow-right"></i>'; }
    }
};

// ── SECOND USER REGISTRATION (User B) ────────

async function handleSecondUserSubmit(e) {
    e.preventDefault();

    const pass = document.getElementById('secondPass').value;
    const conf = document.getElementById('secondConfirm').value;
    if (pass !== conf)   { alert('Passwords do not match'); return; }
    if (pass.length < 8) { alert('Password must be at least 8 characters'); return; }

    const required = ['secondFirstName','secondLastName','secondEmail',
                      'secondBirth','secondGender','secondCountry'];
    for (const id of required) {
        if (!document.getElementById(id)?.value) { alert('Please fill in all fields'); return; }
    }

    if (!document.getElementById('secondGovIdUrl').value)     { alert('Please upload your government ID'); return; }
    if (!document.getElementById('secondProfilePicUrl').value) { alert('Please upload your profile picture'); return; }

    const userData = {
        firstName:      document.getElementById('secondFirstName').value,
        lastName:       document.getElementById('secondLastName').value,
        email:          document.getElementById('secondEmail').value,
        password:       pass,
        birthDate:      document.getElementById('secondBirth').value,
        gender:         document.getElementById('secondGender').value,
        country:        document.getElementById('secondCountry').options[
                            document.getElementById('secondCountry').selectedIndex].text,
        governmentId:   document.getElementById('secondGovIdUrl').value,
        profilePicture: document.getElementById('secondProfilePicUrl').value
    };

    const btn  = e.target.querySelector('button[type="submit"]');
    const orig = btn?.innerHTML;
    if (btn) { btn.disabled = true; btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Completing registration…'; }

    const result = await Auth.completeJointAccount(currentOTP, userData);

    if (result.success) {
        if (result.emailConfirmationRequired) {
            alert('Registration complete! Please check your email to confirm your account before signing in.');
            closeModal('secondUserModal');
        } else {
            document.getElementById('secondUserForm').style.display     = 'none';
            document.getElementById('secondUserSecurity').style.display = 'block';
        }
    } else {
        alert('Registration failed: ' + result.error);
        if (btn) { btn.disabled = false; btn.innerHTML = orig; }
    }
}

function resetSecondUserForm() {
    ['secondFirstName','secondLastName','secondEmail','secondPass','secondConfirm',
     'secondBirth','secondGender','secondCountry'].forEach(id => {
        const el = document.getElementById(id); if (el) el.value = '';
    });
    clearUpload('secondGovId');
    clearUpload('secondProfilePic');
    document.getElementById('secondUserForm').style.display     = 'block';
    document.getElementById('secondUserSecurity').style.display = 'none';
}

// ── GO TO DASHBOARD ───────────────────────────

window.goToDashboard = function() {
    const btn = event?.target;
    if (btn?.tagName === 'BUTTON') {
        btn.disabled = true;
        btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Going to dashboard…';
    }
    window.location.href = '/dashboard.html';
};

// ── FORGOT PASSWORD & SUPABASE PASSWORD RESET ──

window.switchForgotTab = function(tab) {
    const pinWrapper = document.getElementById('forgotPinWrapper');
    const emailWrapper = document.getElementById('forgotEmailWrapper');
    const tabPinBtn = document.getElementById('forgotTabPin');
    const tabEmailBtn = document.getElementById('forgotTabEmail');
    const succ = document.getElementById('forgotSuccessMessage');

    if (succ) succ.style.display = 'none';

    if (tab === 'pin') {
        if (pinWrapper) pinWrapper.style.display = 'block';
        if (emailWrapper) emailWrapper.style.display = 'none';
        if (tabPinBtn) {
            tabPinBtn.classList.remove('btn-outline');
            tabPinBtn.classList.add('btn-primary');
        }
        if (tabEmailBtn) {
            tabEmailBtn.classList.remove('btn-primary');
            tabEmailBtn.classList.add('btn-outline');
        }
    } else {
        if (pinWrapper) pinWrapper.style.display = 'none';
        if (emailWrapper) emailWrapper.style.display = 'block';
        if (tabEmailBtn) {
            tabEmailBtn.classList.remove('btn-outline');
            tabEmailBtn.classList.add('btn-primary');
        }
        if (tabPinBtn) {
            tabPinBtn.classList.remove('btn-primary');
            tabPinBtn.classList.add('btn-outline');
        }
    }
};

window.handleResetPasswordWithPin = async function(e) {
    if (e) e.preventDefault();
    const email = (document.getElementById('pinResetEmail')?.value || '').trim();
    const pin = (document.getElementById('pinResetPin')?.value || '').trim();
    const newPass = (document.getElementById('pinResetNewPass')?.value || '').trim();
    const confPass = (document.getElementById('pinResetConfPass')?.value || '').trim();
    const errEl = document.getElementById('forgotPinErrorMessage');

    if (errEl) { errEl.style.display = 'none'; errEl.innerHTML = ''; }

    if (!email || !pin || !newPass || !confPass) {
        alert('Please fill in all fields.');
        return;
    }
    if (!/^\d{4}$/.test(pin)) {
        if (errEl) {
            errEl.style.display = 'block';
            errEl.innerHTML = `
                <div style="background:#fee2e2;border:1px solid #f87171;color:#b91c1c;padding:10px 14px;border-radius:8px;font-size:0.875rem;display:flex;align-items:center;gap:8px;">
                    <i class="fas fa-exclamation-circle"></i> <span>Transaction PIN must be exactly 4 digits.</span>
                </div>`;
        }
        return;
    }
    if (newPass.length < 8) {
        if (errEl) {
            errEl.style.display = 'block';
            errEl.innerHTML = `
                <div style="background:#fee2e2;border:1px solid #f87171;color:#b91c1c;padding:10px 14px;border-radius:8px;font-size:0.875rem;display:flex;align-items:center;gap:8px;">
                    <i class="fas fa-exclamation-circle"></i> <span>Password must be at least 8 characters.</span>
                </div>`;
        }
        return;
    }
    if (newPass !== confPass) {
        if (errEl) {
            errEl.style.display = 'block';
            errEl.innerHTML = `
                <div style="background:#fee2e2;border:1px solid #f87171;color:#b91c1c;padding:10px 14px;border-radius:8px;font-size:0.875rem;display:flex;align-items:center;gap:8px;">
                    <i class="fas fa-exclamation-circle"></i> <span>Passwords do not match.</span>
                </div>`;
        }
        return;
    }

    const btn = document.getElementById('pinResetSubmitBtn');
    const orig = btn?.innerHTML || 'Reset Password Instantly';
    if (btn) { btn.disabled = true; btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Resetting…'; }

    const result = await Auth.resetPasswordWithPin(email, pin, newPass);

    if (result.success) {
        alert('Password reset successfully! You can now sign in with your new password.');
        closeModal('forgotModal');
        // Prefill login email
        const loginEmail = document.getElementById('loginEmail');
        if (loginEmail) loginEmail.value = email;
        const loginPass = document.getElementById('loginPassword');
        if (loginPass) {
            loginPass.value = '';
            loginPass.focus();
        }
    } else {
        if (errEl) {
            errEl.style.display = 'block';
            errEl.innerHTML = `
                <div style="background:#fee2e2;border:1px solid #f87171;color:#b91c1c;padding:10px 14px;border-radius:8px;font-size:0.875rem;display:flex;align-items:center;gap:8px;">
                    <i class="fas fa-exclamation-circle"></i> <span>${result.error}</span>
                </div>`;
        }
        if (btn) { btn.disabled = false; btn.innerHTML = orig; }
    }
};

window.handleSendResetEmail = async function(e) {
    if (e) e.preventDefault();
    const emailInput = document.getElementById('resetEmail');
    const email = (emailInput?.value || '').trim();
    const errEl = document.getElementById('forgotErrorMessage');
    if (errEl) { errEl.style.display = 'none'; errEl.innerHTML = ''; }

    if (!email) { alert('Please enter your email address'); return; }

    const btn = document.getElementById('sendResetBtn');
    const orig = 'Send Reset Link';
    if (btn) { btn.disabled = true; btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Sending…'; }

    const result = await Auth.sendPasswordResetEmail(email);

    if (result.success) {
        const emailWrapper = document.getElementById('forgotEmailWrapper') || document.getElementById('forgotFormWrapper');
        if (emailWrapper) emailWrapper.style.display = 'none';
        document.getElementById('forgotSuccessMessage').style.display = 'block';
    } else {
        if (errEl) {
            errEl.style.display = 'block';
            if (result.isRateLimit) {
                errEl.innerHTML = `
                    <div style="background:#fef3c7;border:1px solid #f59e0b;color:#92400e;padding:12px 14px;border-radius:8px;font-size:0.875rem;line-height:1.4;">
                        <div style="display:flex;align-items:center;gap:8px;font-weight:600;margin-bottom:4px;">
                            <i class="fas fa-exclamation-triangle"></i> Email Rate Limit Exceeded
                        </div>
                        <span>Too many reset requests have been sent recently. Supabase throttles email sending to protect against abuse. Please wait a few minutes before trying again, or check your spam/junk folder for previous links.</span>
                    </div>`;
            } else {
                errEl.innerHTML = `
                    <div style="background:#fee2e2;border:1px solid #f87171;color:#b91c1c;padding:10px 14px;border-radius:8px;font-size:0.875rem;display:flex;align-items:center;gap:8px;">
                        <i class="fas fa-exclamation-circle"></i> <span>${result.error}</span>
                    </div>`;
            }
        }

        if (result.isRateLimit && btn) {
            let countdown = 60;
            btn.disabled = true;
            btn.innerHTML = `<i class="fas fa-clock"></i> Retry in ${countdown}s`;
            const timer = setInterval(() => {
                countdown--;
                if (countdown <= 0) {
                    clearInterval(timer);
                    btn.disabled = false;
                    btn.innerHTML = orig;
                } else {
                    btn.innerHTML = `<i class="fas fa-clock"></i> Retry in ${countdown}s`;
                }
            }, 1000);
        } else if (btn) {
            btn.disabled = false;
            btn.innerHTML = orig;
        }
    }
};

window.handleUpdatePassword = async function(e) {
    if (e) e.preventDefault();
    const newPass = document.getElementById('newPasswordInput').value;
    const confPass = document.getElementById('confirmNewPasswordInput').value;

    if (!newPass || !confPass) {
        alert('Please fill in both password fields');
        return;
    }
    if (newPass.length < 8) {
        alert('Password must be at least 8 characters');
        return;
    }
    if (newPass !== confPass) {
        alert('Passwords do not match');
        return;
    }

    const btn = document.getElementById('updatePasswordBtn');
    const orig = btn?.innerHTML;
    if (btn) { btn.disabled = true; btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Updating…'; }

    const result = await Auth.updatePassword(newPass);

    if (result.success) {
        alert('Password updated successfully! Please sign in with your new password.');
        closeModal('updatePasswordModal');
        if (window.history.replaceState) {
            window.history.replaceState(null, null, window.location.pathname);
        }
        try { await window.db.auth.signOut(); } catch (_) {}
    } else {
        alert('Password update failed: ' + result.error);
        if (btn) { btn.disabled = false; btn.innerHTML = orig; }
    }
};

function resetForgotForm() {
    ['pinResetEmail', 'pinResetPin', 'pinResetNewPass', 'pinResetConfPass', 'resetEmail'].forEach(id => {
        const el = document.getElementById(id);
        if (el) el.value = '';
    });
    const pinErr = document.getElementById('forgotPinErrorMessage');
    if (pinErr) { pinErr.style.display = 'none'; pinErr.innerHTML = ''; }
    const pinBtn = document.getElementById('pinResetSubmitBtn');
    if (pinBtn) { pinBtn.disabled = false; pinBtn.innerHTML = 'Reset Password Instantly'; }

    const emailWrapper = document.getElementById('forgotEmailWrapper') || document.getElementById('forgotFormWrapper');
    if (emailWrapper) emailWrapper.style.display = 'block';
    const succ = document.getElementById('forgotSuccessMessage');
    if (succ) succ.style.display = 'none';
    const errEl = document.getElementById('forgotErrorMessage');
    if (errEl) { errEl.style.display = 'none'; errEl.innerHTML = ''; }
    const btn = document.getElementById('sendResetBtn');
    if (btn) { btn.disabled = false; btn.innerHTML = 'Send Reset Link'; }

    if (typeof window.switchForgotTab === 'function') {
        window.switchForgotTab('email');
    }
}

function resetUpdatePasswordForm() {
    ['newPasswordInput', 'confirmNewPasswordInput'].forEach(id => {
        const el = document.getElementById(id);
        if (el) el.value = '';
    });
    const btn = document.getElementById('updatePasswordBtn');
    if (btn) { btn.disabled = false; btn.innerHTML = 'Update Password'; }
}

// ── FILE UPLOADS ──────────────────────────────

function bindFileInputs() {
    document.querySelectorAll('input[type="file"]').forEach(input => {
        const id = input.id.replace('File', '');
        input.addEventListener('change', (e) => {
            if (e.target.files.length) handleFile(e.target.files[0], id);
        });
    });
}

window.triggerFileUpload = function(id) {
    let fi = document.getElementById(id + 'File');
    if (!fi) {
        fi = document.createElement('input');
        fi.type = 'file';
        fi.id   = id + 'File';
        fi.style.display = 'none';
        const isPic = id.toLowerCase().includes('pic') || id.toLowerCase().includes('profile');
        fi.accept = isPic ? '.jpg,.jpeg,.png' : '.jpg,.jpeg,.png,.pdf';
        document.body.appendChild(fi);
        fi.addEventListener('change', (e) => { if (e.target.files.length) handleFile(e.target.files[0], id); });
    }
    fi.value = '';
    fi.click();
};

function handleFile(file, id) {
    const isPic   = id.toLowerCase().includes('pic') || id.toLowerCase().includes('profile');
    const maxSize = isPic ? 2097152 : 5242880;
    const allowed = isPic
        ? ['image/jpeg','image/jpg','image/png']
        : ['image/jpeg','image/jpg','image/png','application/pdf'];

    if (!allowed.includes(file.type)) {
        alert(isPic ? 'Please upload a JPG or PNG image' : 'Please upload a JPG, PNG or PDF');
        return;
    }
    if (file.size > maxSize) { alert(`File must be under ${maxSize / 1048576}MB`); return; }
    showPreview(file, id);
    uploadToCloudinary(file, id);
}

function showPreview(file, id) {
    const preview = document.getElementById(id + 'Preview');
    const textEl  = document.getElementById(id + 'Text');
    if (!preview) return;
    if (textEl) textEl.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Preparing…';
    const reader = new FileReader();
    reader.onload = (e) => {
        preview.innerHTML = `
            <div class="single-preview">
                ${file.type.startsWith('image/')
                    ? `<img src="${e.target.result}" alt="Preview">`
                    : `<i class="fas fa-file-pdf" style="font-size:36px;color:var(--error)"></i>`}
                <div class="file-info">
                    <div class="file-name">${file.name}</div>
                    <div class="file-size">${fmtSize(file.size)}</div>
                    <div class="upload-progress" id="${id}Bar"><div class="progress-bar" style="width:0%"></div></div>
                    <div class="progress-text" id="${id}Pct"><span>Uploading…</span><span>0%</span></div>
                </div>
                <i class="fas fa-times remove-file" onclick="removeUpload('${id}')"></i>
            </div>`;
        if (textEl) textEl.style.display = 'none';
    };
    reader.readAsDataURL(file);
}

function uploadToCloudinary(file, id) {
    const fd = new FormData();
    fd.append('file', file);
    fd.append('upload_preset', CLOUDINARY.uploadPreset);
    fd.append('cloud_name',    CLOUDINARY.cloudName);

    const xhr = new XMLHttpRequest();

    xhr.upload.onprogress = (e) => {
        if (!e.lengthComputable) return;
        const pct = Math.round(e.loaded / e.total * 100);
        const bar = document.querySelector(`#${id}Bar .progress-bar`);
        const txt = document.getElementById(id + 'Pct');
        if (bar) bar.style.width = pct + '%';
        if (txt) txt.innerHTML = `<span>Uploading…</span><span>${pct}%</span>`;
    };

    xhr.onload = () => {
        if (xhr.status === 200) {
            const url    = JSON.parse(xhr.responseText).secure_url;
            const hidden = document.getElementById(id + 'Url');
            if (hidden) hidden.value = url;
            const bar    = document.querySelector(`#${id}Bar .progress-bar`);
            const txt    = document.getElementById(id + 'Pct');
            const textEl = document.getElementById(id + 'Text');
            if (bar) { bar.style.width = '100%'; bar.style.background = 'var(--success)'; }
            if (txt) txt.innerHTML = `<span style="color:var(--success)"><i class="fas fa-check-circle"></i> Done!</span><span>100%</span>`;
            if (textEl) { textEl.style.display = 'block'; textEl.textContent = 'Click to replace'; }
        } else {
            uploadError(id);
        }
    };

    xhr.onerror = () => uploadError(id);
    xhr.open('POST', `https://api.cloudinary.com/v1_1/${CLOUDINARY.cloudName}/auto/upload`);
    xhr.send(fd);
}

function uploadError(id) {
    const txt    = document.getElementById(id + 'Pct');
    const textEl = document.getElementById(id + 'Text');
    if (txt)    txt.innerHTML = '<span style="color:var(--error)"><i class="fas fa-exclamation-circle"></i> Upload failed</span>';
    if (textEl) { textEl.style.display = 'block'; textEl.textContent = 'Click to try again'; }
}

window.removeUpload = function(id) {
    const h = document.getElementById(id + 'Url');     if (h) h.value = '';
    const p = document.getElementById(id + 'Preview'); if (p) p.innerHTML = '';
    const f = document.getElementById(id + 'File');    if (f) f.value = '';
    const t = document.getElementById(id + 'Text');
    if (t) {
        t.style.display = 'block';
        const isPic = id.toLowerCase().includes('pic') || id.toLowerCase().includes('profile');
        t.textContent = isPic ? 'Click to upload photo' : 'Click to upload ID (JPG, PNG, PDF)';
    }
};

function clearUpload(id) { window.removeUpload(id); }

function fmtSize(b) {
    if (b < 1024)    return b + ' B';
    if (b < 1048576) return (b / 1024).toFixed(1) + ' KB';
    return (b / 1048576).toFixed(1) + ' MB';
}
