// ============================================
// AUTHENTICATION MODULE
// Guard: only runs once even if loaded twice
// ============================================

if (!window.Auth) {

if (!window.db) {
    throw new Error('Supabase not initialized. Check supabase.js loads before auth.js.');
}

window.Auth = {

    getCurrencyFromCountry(country) {
        if (!country) return 'USD';
        const c = country.toLowerCase().trim();
        if (c.includes('south africa')) return 'ZAR';
        if (c.includes('botswana')) return 'BWP';
        if (c.includes('mexico')) return 'MXN';
        if (c.includes('argentina')) return 'ARS';
        if (c.includes('colombia')) return 'COP';
        if (c.includes('chile')) return 'CLP';
        if (c.includes('philippines')) return 'PHP';
        if (c.includes('nigeria')) return 'NGN';
        if (c.includes('kenya')) return 'KES';
        if (c.includes('ghana')) return 'GHS';
        if (c.includes('uganda')) return 'UGX';
        if (c.includes('tanzania')) return 'TZS';
        if (c.includes('united kingdom') || c.includes('uk')) return 'GBP';
        if (c.includes('europe') || c.includes('germany') || c.includes('france') || c.includes('spain') || c.includes('italy')) return 'EUR';
        return 'USD';
    },

    async hashPassword(password) {
        const encoder = new TextEncoder();
        const data = encoder.encode(password);
        const hash = await crypto.subtle.digest('SHA-256', data);
        return Array.from(new Uint8Array(hash))
            .map(b => b.toString(16).padStart(2, '0'))
            .join('');
    },

    async verifyPin(pin, storedHash) {
        const hash = await this.hashPassword(pin);
        return hash === storedHash;
    },

    generateRecoveryPhrase() {
const words = [
  'awake','aware','away','awesome','awful','awkward','axis',
  'baby','bachelor','bacon','badge','bag','balance','balcony','ball',
  'bamboo','banana','banner','bar','barely','bargain','barrel','base',
  'basic','basket','battle','beach','bean','beauty','because','become',
  'beef','before','begin','behave','behind','believe','below','belt',
  'bench','benefit','best','betray','better','between','beyond','bicycle',
  'bid','bike','bind','biology','bird','birth','bitter','black',
  'blade','blame','blanket','blast','bleak','bless','blind','blood',
  'blossom','blouse','blue','blur','blush','board','boat','body',
  'boil','bomb','bone','bonus','book','boost','border','boring',
  'borrow','boss','bottom','bounce','box','boy','bracket','brain',
  'brand','brass','brave','bread','breeze','brick','bridge','brief',
  'bright','bring','brisk','broccoli','broken','bronze','broom','brother',
  'brown','brush','bubble','buddy','budget','buffalo','build','bulb',
  'bulk','bullet','bundle','bunker','burden','burger','burst','bus',
  'business','busy','butter','buyer','buzz',
  'cabbage','cabin','cable','cactus','cage','cake','call','calm',
  'camera','camp','can','canal','cancel','candy','cannon','canoe',
  'canvas','canyon','capable','capital','captain','car','carbon','card',
  'cargo','carpet','carry','cart','case','cash','casino','castle',
  'casual','cat','catalog','catch','category','cattle','caught','cause',
  'caution','cave','ceiling','celery','cement','census','century','cereal',
  'certain','chair','chalk','champion','change','chaos','chapter','charge',
  'chase','chat','cheap','check','cheese','chef','cherry','chest',
  'chicken','chief','child','chimney','choice','choose','chronic','chunk',
  'churn','cigar','cinnamon','circle','citizen','city','civil','claim',
  'clap','clarify','claw','clay','clean','clerk','clever','click',
  'client','cliff','climb','clinic','clip','clock','clog','close',
  'cloth','cloud','clown','club','clump','cluster','clutch','coach',
  'coast','coconut','code','coffee','coil','coin','collect','color',
  'column','combine','come','comfort','comic','common','company','concert',
  'conduct','confirm','congress','connect','consider','control','convince','cook',
  'cool','copper','copy','coral','core','corn','correct','cost',
  'cotton','couch','country','couple','course','cousin','cover','coyote',
  'crack','cradle','craft','cram','crane','crash','crater','crawl',
  'crazy','cream','credit','creek','crew','cricket','crime','crisp',
  'critic','crop','cross','crouch','crowd','crucial','cruel','cruise',
  'crumble','crunch','crush','cry','crystal','cube','culture','cup',
  'cupboard','curious','current','curtain','curve','cushion','custom','cute',
  'cycle'
];
        const phrase = [];
        for (let i = 0; i < 12; i++) {
            phrase.push(words[Math.floor(Math.random() * words.length)]);
        }
        return phrase.join(' ');
    },

    generateOTP() {
        return Math.floor(100000 + Math.random() * 900000).toString();
    },

    // ---- SESSION ----

    async createSession(userId) {
        const sessionToken = crypto.randomUUID();
        const expiresAt = new Date();
        expiresAt.setDate(expiresAt.getDate() + 7);

        const { error } = await window.db.from('sessions').insert([{
            user_id: userId,
            session_token: sessionToken,
            expires_at: expiresAt.toISOString()
        }]);
        if (error) throw error;

        const { data: user } = await window.db
            .from('users').select('transaction_pin_hash').eq('id', userId).single();

        localStorage.setItem('West Haven Bank_session', JSON.stringify({
            token: sessionToken,
            userId,
            expiresAt: expiresAt.toISOString(),
            requiresPinSetup: !user?.transaction_pin_hash
        }));

        return sessionToken;
    },

    async validateSession() {
        try {
            const sessionStr = localStorage.getItem('West Haven Bank_session');
            if (!sessionStr) return null;

            const session = JSON.parse(sessionStr);
            if (new Date(session.expiresAt) < new Date()) {
                localStorage.removeItem('West Haven Bank_session');
                return null;
            }

            const { data, error } = await window.db
                .from('sessions')
                .select('*, users(*)')
                .eq('session_token', session.token)
                .gt('expires_at', new Date().toISOString())
                .single();

            if (error || !data) {
                localStorage.removeItem('West Haven Bank_session');
                return null;
            }

            return { ...data, requiresPinSetup: !data.users?.transaction_pin_hash };
        } catch (err) {
            console.error('validateSession error:', err);
            return null;
        }
    },

    async logout() {
        try {
            if (window.db?.auth) {
                await window.db.auth.signOut();
            }
            const sessionStr = localStorage.getItem('West Haven Bank_session');
            if (sessionStr) {
                const { token } = JSON.parse(sessionStr);
                await window.db.from('sessions').delete().eq('session_token', token);
            }
        } catch (err) {
            console.error('logout error:', err);
        } finally {
            localStorage.removeItem('West Haven Bank_session');
            window.location.href = '/auth.html';
        }
    },

    // ---- LOGIN ----

    async login(email, password) {
        try {
            const cleanEmail = email.trim().toLowerCase();

            // 1. Authenticate with standard Supabase Auth
            const { data: authData, error: authError } = await window.db.auth.signInWithPassword({
                email: cleanEmail,
                password: password
            });

            if (!authError && authData?.user) {
                // Find profile in public.users
                let { data: user } = await window.db
                    .from('users').select('*').eq('id', authData.user.id).single();

                if (!user) {
                    const { data: userByEmail } = await window.db
                        .from('users').select('*').eq('email', cleanEmail).single();
                    user = userByEmail;
                }

                if (user) {
                    await this.createSession(user.id);
                    return { success: true, user, requiresPinSetup: !user.transaction_pin_hash };
                }
            }

            // 2. Backward compatibility fallback for legacy accounts with custom SHA-256
            const { data: legacyUsers } = await window.db
                .from('users').select('*').eq('email', cleanEmail);

            if (legacyUsers && legacyUsers.length > 0) {
                const legacyUser = legacyUsers[0];
                if (legacyUser.password_hash) {
                    const legacyHash = await this.hashPassword(password);
                    if (legacyHash === legacyUser.password_hash) {
                        // Migrate legacy user to Supabase Auth on the fly
                        try {
                            await window.db.auth.signUp({
                                email: cleanEmail,
                                password: password
                            });
                        } catch (_) {}

                        await this.createSession(legacyUser.id);
                        return { success: true, user: legacyUser, requiresPinSetup: !legacyUser.transaction_pin_hash };
                    }
                }
            }

            if (authError) {
                if (authError.message?.toLowerCase().includes('email not confirmed')) {
                    return {
                        success: false,
                        error: 'Your email has not been confirmed yet. Please check your inbox for the confirmation link.'
                    };
                }
                return { success: false, error: authError.message };
            }

            return { success: false, error: 'Invalid email or password' };
        } catch (err) {
            console.error('login error:', err);
            return { success: false, error: err.message };
        }
    },

    // ---- INDIVIDUAL SIGNUP ----

    async signUpIndividual(userData) {
        try {
            const cleanEmail = userData.email.trim().toLowerCase();

            // 1. Supabase Auth signup (passwords managed securely by Supabase, never stored in DB)
            const { data: authData, error: authError } = await window.db.auth.signUp({
                email: cleanEmail,
                password: userData.password,
                options: {
                    data: {
                        first_name: userData.firstName,
                        last_name: userData.lastName
                    }
                }
            });

            if (authError) throw authError;
            if (!authData?.user) throw new Error('Failed to create authentication user.');

            const userId = authData.user.id;

            // 2. Store profile in public.users without collecting password or recovery phrase
            const { data: user, error: userError } = await window.db.from('users').insert([{
                id: userId,
                email: cleanEmail,
                password_hash: '', // Never collect password in database
                recovery_phrase_hash: '', // No recovery phrase during auth
                first_name: userData.firstName,
                last_name: userData.lastName,
                birth_date: userData.birthDate,
                gender: userData.gender,
                country: userData.country,
                government_id_url: userData.governmentId,
                profile_picture_url: userData.profilePicture,
                transaction_pin_hash: null,
                account_type: 'individual',
                is_verified: true
            }]).select().single();

            if (userError) throw userError;

            // 3. Create personal bank account
            const accountNumber = 'WH' + Date.now().toString().slice(-8) + Math.floor(Math.random() * 1000);
            await window.db.from('accounts').insert([{
                account_number: accountNumber,
                user_id: user.id,
                balance: 0.00,
                currency: this.getCurrencyFromCountry(userData.country),
                status: 'active'
            }]);

            const hasActiveSession = !!authData.session;
            if (hasActiveSession) {
                await this.createSession(user.id);
            }

            return {
                success: true,
                user,
                emailConfirmationRequired: !hasActiveSession
            };
        } catch (err) {
            console.error('signUpIndividual error:', err);
            return { success: false, error: err.message };
        }
    },

    // ---- JOINT SIGNUP — Primary user ----

    async initJointAccount(primaryUserData) {
        try {
            const cleanEmail = primaryUserData.email.trim().toLowerCase();

            // 1. Supabase Auth signup
            const { data: authData, error: authError } = await window.db.auth.signUp({
                email: cleanEmail,
                password: primaryUserData.password,
                options: {
                    data: {
                        first_name: primaryUserData.firstName,
                        last_name: primaryUserData.lastName
                    }
                }
            });

            if (authError) throw authError;
            if (!authData?.user) throw new Error('Failed to create authentication user.');

            const userId = authData.user.id;
            const otp = this.generateOTP();

            // 2. Create pending joint account
            const { data: jointAccount, error: jointError } = await window.db
                .from('joint_accounts').insert([{
                    account_name: `${primaryUserData.firstName} & Partner`,
                    status: 'pending',
                    invitation_otp: otp,
                    primary_user_id: userId
                }]).select().single();

            if (jointError) throw jointError;

            // 3. Store user record in public.users without collecting password or recovery phrase
            const { data: primaryUser, error: userError } = await window.db
                .from('users').insert([{
                    id: userId,
                    email: cleanEmail,
                    password_hash: '', // Never collect password in database
                    recovery_phrase_hash: '', // No recovery phrase during auth
                    first_name: primaryUserData.firstName,
                    last_name: primaryUserData.lastName,
                    birth_date: primaryUserData.birthDate,
                    gender: primaryUserData.gender,
                    country: primaryUserData.country,
                    government_id_url: primaryUserData.governmentId,
                    profile_picture_url: primaryUserData.profilePicture,
                    transaction_pin_hash: null,
                    account_type: 'joint',
                    joint_account_id: jointAccount.id,
                    is_verified: true
                }]).select().single();

            if (userError) throw userError;

            const hasActiveSession = !!authData.session;
            if (hasActiveSession) {
                await this.createSession(primaryUser.id);
            }

            return {
                success: true,
                otp,
                jointAccountId: jointAccount.id,
                emailConfirmationRequired: !hasActiveSession
            };
        } catch (err) {
            console.error('initJointAccount error:', err);
            return { success: false, error: err.message };
        }
    },

    // ---- JOINT SIGNUP — Secondary user ----

    async completeJointAccount(otp, userData) {
        try {
            const cleanEmail = userData.email.trim().toLowerCase();

            const { data: jointAccount, error: jointError } = await window.db
                .from('joint_accounts')
                .select('*')
                .eq('invitation_otp', otp)
                .eq('status', 'pending')
                .single();

            if (jointError || !jointAccount) {
                return { success: false, error: 'Invalid or expired OTP' };
            }

            // 1. Supabase Auth signup
            const { data: authData, error: authError } = await window.db.auth.signUp({
                email: cleanEmail,
                password: userData.password,
                options: {
                    data: {
                        first_name: userData.firstName,
                        last_name: userData.lastName
                    }
                }
            });

            if (authError) throw authError;
            if (!authData?.user) throw new Error('Failed to create authentication user.');

            const userId = authData.user.id;

            // 2. Store profile without password or recovery phrase
            const { data: secondaryUser, error: userError } = await window.db
                .from('users').insert([{
                    id: userId,
                    email: cleanEmail,
                    password_hash: '', // Never collect password in database
                    recovery_phrase_hash: '', // No recovery phrase during auth
                    first_name: userData.firstName,
                    last_name: userData.lastName,
                    birth_date: userData.birthDate,
                    gender: userData.gender,
                    country: userData.country,
                    government_id_url: userData.governmentId,
                    profile_picture_url: userData.profilePicture,
                    transaction_pin_hash: null,
                    account_type: 'joint',
                    joint_account_id: jointAccount.id,
                    is_verified: true
                }]).select().single();

            if (userError) throw userError;

            await window.db.from('joint_accounts').update({
                secondary_user_id: secondaryUser.id,
                status: 'active',
                activated_at: new Date().toISOString()
            }).eq('id', jointAccount.id);

            // 3. Create shared joint account
            const accountNumber = 'WHJ' + Date.now().toString().slice(-8) + Math.floor(Math.random() * 1000);
            await window.db.from('accounts').insert([{
                account_number: accountNumber,
                joint_account_id: jointAccount.id,
                balance: 0.00,
                currency: this.getCurrencyFromCountry(userData.country),
                status: 'active'
            }]);

            const hasActiveSession = !!authData.session;
            if (hasActiveSession) {
                await this.createSession(secondaryUser.id);
            }

            return {
                success: true,
                emailConfirmationRequired: !hasActiveSession
            };
        } catch (err) {
            console.error('completeJointAccount error:', err);
            return { success: false, error: err.message };
        }
    },

    // ---- PIN SETUP ----

    async setTransactionPin(userId, pin) {
        try {
            if (!/^\d{4}$/.test(pin)) {
                return { success: false, error: 'PIN must be exactly 4 digits' };
            }

            const pinHash = await this.hashPassword(pin);
            const { error } = await window.db
                .from('users').update({ transaction_pin_hash: pinHash }).eq('id', userId);

            if (error) throw error;

            const sessionStr = localStorage.getItem('West Haven Bank_session');
            if (sessionStr) {
                const session = JSON.parse(sessionStr);
                session.requiresPinSetup = false;
                localStorage.setItem('West Haven Bank_session', JSON.stringify(session));
            }

            return { success: true };
        } catch (err) {
            console.error('setTransactionPin error:', err);
            return { success: false, error: err.message };
        }
    },

    // ---- STANDARD SUPABASE PASSWORD RESET ----

    async sendPasswordResetEmail(email) {
        try {
            const cleanEmail = email.trim().toLowerCase();
            const redirectTo = typeof window !== 'undefined' && window.location?.origin
                ? window.location.origin + '/auth.html#type=recovery'
                : undefined;

            const { data, error } = await window.db.auth.resetPasswordForEmail(cleanEmail, {
                redirectTo
            });

            if (error) throw error;
            return { success: true };
        } catch (err) {
            console.error('sendPasswordResetEmail error:', err);
            return { success: false, error: err.message };
        }
    },

    async updatePassword(newPassword) {
        try {
            if (!newPassword || newPassword.length < 8) {
                return { success: false, error: 'Password must be at least 8 characters' };
            }

            const { data, error } = await window.db.auth.updateUser({
                password: newPassword
            });

            if (error) throw error;
            return { success: true };
        } catch (err) {
            console.error('updatePassword error:', err);
            return { success: false, error: err.message };
        }
    },

    // ---- COUNTRIES ----

    async fetchCountries() {
        try {
            const response = await fetch('https://restcountries.com/v3.1/all?fields=name,cca2');
            const data = await response.json();
            return data
                .map(c => ({ name: c.name.common, code: c.cca2 }))
                .sort((a, b) => a.name.localeCompare(b.name));
        } catch (err) {
            return [
                { name: 'Afghanistan', code: 'AF' },
                { name: 'Albania', code: 'AL' },
                { name: 'Algeria', code: 'DZ' },
                { name: 'Andorra', code: 'AD' },
                { name: 'Angola', code: 'AO' },
                { name: 'Argentina', code: 'AR' },
                { name: 'Armenia', code: 'AM' },
                { name: 'Australia', code: 'AU' },
                { name: 'Austria', code: 'AT' },
                { name: 'Azerbaijan', code: 'AZ' },
                { name: 'Bahamas', code: 'BS' },
                { name: 'Bahrain', code: 'BH' },
                { name: 'Bangladesh', code: 'BD' },
                { name: 'Barbados', code: 'BB' },
                { name: 'Belarus', code: 'BY' },
                { name: 'Belgium', code: 'BE' },
                { name: 'Belize', code: 'BZ' },
                { name: 'Benin', code: 'BJ' },
                { name: 'Bermuda', code: 'BM' },
                { name: 'Bhutan', code: 'BT' },
                { name: 'Bolivia', code: 'BO' },
                { name: 'Bosnia and Herzegovina', code: 'BA' },
                { name: 'Botswana', code: 'BW' },
                { name: 'Brazil', code: 'BR' },
                { name: 'Bulgaria', code: 'BG' },
                { name: 'Burkina Faso', code: 'BF' },
                { name: 'Burundi', code: 'BI' },
                { name: 'Cambodia', code: 'KH' },
                { name: 'Cameroon', code: 'CM' },
                { name: 'Canada', code: 'CA' },
                { name: 'Cape Verde', code: 'CV' },
                { name: 'Central African Republic', code: 'CF' },
                { name: 'Chad', code: 'TD' },
                { name: 'Chile', code: 'CL' },
                { name: 'China', code: 'CN' },
                { name: 'Colombia', code: 'CO' },
                { name: 'Comoros', code: 'KM' },
                { name: 'Congo', code: 'CG' },
                { name: 'Costa Rica', code: 'CR' },
                { name: 'Croatia', code: 'HR' },
                { name: 'Cuba', code: 'CU' },
                { name: 'Cyprus', code: 'CY' },
                { name: 'Czech Republic', code: 'CZ' },
                { name: 'Denmark', code: 'DK' },
                { name: 'Djibouti', code: 'DJ' },
                { name: 'Dominica', code: 'DM' },
                { name: 'Dominican Republic', code: 'DO' },
                { name: 'Ecuador', code: 'EC' },
                { name: 'Egypt', code: 'EG' },
                { name: 'El Salvador', code: 'SV' },
                { name: 'Equatorial Guinea', code: 'GQ' },
                { name: 'Eritrea', code: 'ER' },
                { name: 'Estonia', code: 'EE' },
                { name: 'Ethiopia', code: 'ET' },
                { name: 'Fiji', code: 'FJ' },
                { name: 'Finland', code: 'FI' },
                { name: 'France', code: 'FR' },
                { name: 'Gabon', code: 'GA' },
                { name: 'Gambia', code: 'GM' },
                { name: 'Georgia', code: 'GE' },
                { name: 'Germany', code: 'DE' },
                { name: 'Ghana', code: 'GH' },
                { name: 'Greece', code: 'GR' },
                { name: 'Grenada', code: 'GD' },
                { name: 'Guatemala', code: 'GT' },
                { name: 'Guinea', code: 'GN' },
                { name: 'Guinea-Bissau', code: 'GW' },
                { name: 'Guyana', code: 'GY' },
                { name: 'Haiti', code: 'HT' },
                { name: 'Honduras', code: 'HN' },
                { name: 'Hungary', code: 'HU' },
                { name: 'Iceland', code: 'IS' },
                { name: 'India', code: 'IN' },
                { name: 'Indonesia', code: 'ID' },
                { name: 'Iran', code: 'IR' },
                { name: 'Iraq', code: 'IQ' },
                { name: 'Ireland', code: 'IE' },
                { name: 'Israel', code: 'IL' },
                { name: 'Italy', code: 'IT' },
                { name: 'Jamaica', code: 'JM' },
                { name: 'Japan', code: 'JP' },
                { name: 'Jordan', code: 'JO' },
                { name: 'Kazakhstan', code: 'KZ' },
                { name: 'Kenya', code: 'KE' },
                { name: 'Kiribati', code: 'KI' },
                { name: 'Kuwait', code: 'KW' },
                { name: 'Kyrgyzstan', code: 'KG' },
                { name: 'Laos', code: 'LA' },
                { name: 'Latvia', code: 'LV' },
                { name: 'Lebanon', code: 'LB' },
                { name: 'Lesotho', code: 'LS' },
                { name: 'Liberia', code: 'LR' },
                { name: 'Libya', code: 'LY' },
                { name: 'Liechtenstein', code: 'LI' },
                { name: 'Lithuania', code: 'LT' },
                { name: 'Luxembourg', code: 'LU' },
                { name: 'Madagascar', code: 'MG' },
                { name: 'Malawi', code: 'MW' },
                { name: 'Malaysia', code: 'MY' },
                { name: 'Maldives', code: 'MV' },
                { name: 'Mali', code: 'ML' },
                { name: 'Malta', code: 'MT' },
                { name: 'Mauritania', code: 'MR' },
                { name: 'Mauritius', code: 'MU' },
                { name: 'Mexico', code: 'MX' },
                { name: 'Monaco', code: 'MC' },
                { name: 'Mongolia', code: 'MN' },
                { name: 'Montenegro', code: 'ME' },
                { name: 'Morocco', code: 'MA' },
                { name: 'Mozambique', code: 'MZ' },
                { name: 'Myanmar', code: 'MM' },
                { name: 'Namibia', code: 'NA' },
                { name: 'Nepal', code: 'NP' },
                { name: 'Netherlands', code: 'NL' },
                { name: 'New Zealand', code: 'NZ' },
                { name: 'Nicaragua', code: 'NI' },
                { name: 'Niger', code: 'NE' },
                { name: 'Nigeria', code: 'NG' },
                { name: 'Norway', code: 'NO' },
                { name: 'Oman', code: 'OM' },
                { name: 'Pakistan', code: 'PK' },
                { name: 'Panama', code: 'PA' },
                { name: 'Papua New Guinea', code: 'PG' },
                { name: 'Paraguay', code: 'PY' },
                { name: 'Peru', code: 'PE' },
                { name: 'Philippines', code: 'PH' },
                { name: 'Poland', code: 'PL' },
                { name: 'Portugal', code: 'PT' },
                { name: 'Qatar', code: 'QA' },
                { name: 'Romania', code: 'RO' },
                { name: 'Russia', code: 'RU' },
                { name: 'Rwanda', code: 'RW' },
                { name: 'Samoa', code: 'WS' },
                { name: 'San Marino', code: 'SM' },
                { name: 'Saudi Arabia', code: 'SA' },
                { name: 'Senegal', code: 'SN' },
                { name: 'Serbia', code: 'RS' },
                { name: 'Seychelles', code: 'SC' },
                { name: 'Sierra Leone', code: 'SL' },
                { name: 'Singapore', code: 'SG' },
                { name: 'Slovakia', code: 'SK' },
                { name: 'Slovenia', code: 'SI' },
                { name: 'Solomon Islands', code: 'SB' },
                { name: 'Somalia', code: 'SO' },
                { name: 'South Africa', code: 'ZA' },
                { name: 'South Korea', code: 'KR' },
                { name: 'Spain', code: 'ES' },
                { name: 'Sri Lanka', code: 'LK' },
                { name: 'Sudan', code: 'SD' },
                { name: 'Suriname', code: 'SR' },
                { name: 'Swaziland', code: 'SZ' },
                { name: 'Sweden', code: 'SE' },
                { name: 'Switzerland', code: 'CH' },
                { name: 'Syria', code: 'SY' },
                { name: 'Taiwan', code: 'TW' },
                { name: 'Tajikistan', code: 'TJ' },
                { name: 'Tanzania', code: 'TZ' },
                { name: 'Thailand', code: 'TH' },
                { name: 'Togo', code: 'TG' },
                { name: 'Tonga', code: 'TO' },
                { name: 'Trinidad and Tobago', code: 'TT' },
                { name: 'Tunisia', code: 'TN' },
                { name: 'Turkey', code: 'TR' },
                { name: 'Turkmenistan', code: 'TM' },
                { name: 'Uganda', code: 'UG' },
                { name: 'Ukraine', code: 'UA' },
                { name: 'United Arab Emirates', code: 'AE' },
                { name: 'United Kingdom', code: 'GB' },
                { name: 'United States', code: 'US' },
                { name: 'Uruguay', code: 'UY' },
                { name: 'Uzbekistan', code: 'UZ' },
                { name: 'Vanuatu', code: 'VU' },
                { name: 'Venezuela', code: 'VE' },
                { name: 'Vietnam', code: 'VN' },
                { name: 'Yemen', code: 'YE' },
                { name: 'Zambia', code: 'ZM' },
                { name: 'Zimbabwe', code: 'ZW' }
            ];
        }
    }
};

} // end if(!window.Auth)