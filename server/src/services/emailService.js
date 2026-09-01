import { Resend } from 'resend';

// Real transport via Resend when RESEND_API_KEY is set; otherwise falls back
// to a dev-mode console log so the app still works without an API key
// configured. The rest of the codebase only depends on sendEmail()'s
// signature, so swapping providers later only touches this file.
const resend = process.env.RESEND_API_KEY ? new Resend(process.env.RESEND_API_KEY) : null;

export async function sendEmail({ to, subject, html }) {
  if (!resend) {
    if (process.env.NODE_ENV === 'production') {
      console.warn('[emailService] RESEND_API_KEY is not set — no real email provider configured.');
    }
    console.log(`\n--- [DEV EMAIL] ---\nTo: ${to}\nSubject: ${subject}\n${html}\n-------------------\n`);
    return { delivered: false, dev: true };
  }

  const from = process.env.EMAIL_FROM || 'Kaalmo <onboarding@resend.dev>';
  const { data, error } = await resend.emails.send({ from, to, subject, html });

  if (error) {
    console.error('[emailService] Resend failed to send email:', error);
    return { delivered: false, error };
  }

  return { delivered: true, id: data?.id };
}

export async function sendVerificationEmail(user, code) {
  return sendEmail({
    to: user.email,
    subject: `${code} waa lambarkaaga xaqiijinta — Kaalmo`,
    html: `<p>Salaan ${user.fullName},</p><p>Lambarkan geli bogga Kaalmo si aad email-kaaga u xaqiijiso:</p><p style="font-size:32px;font-weight:bold;letter-spacing:8px;">${code}</p><p>Lambarkani wuxuu dhacayaa 15 daqiiqo gudahood. Haddii aanad codsan xaqiijintan, iska indha tir email-kan.</p>`,
  });
}

export async function sendPasswordResetEmail(user, code) {
  return sendEmail({
    to: user.email,
    subject: `${code} waa lambarkaaga dib-u-dejinta furaha sirta ah — Kaalmo`,
    html: `<p>Salaan ${user.fullName},</p><p>Waxaa la codsaday in furaha sirta ah ee akoonkaaga Kaalmo dib loo dejiyo. Lambarkan geli bogga si aad u dhigato fure cusub:</p><p style="font-size:32px;font-weight:bold;letter-spacing:8px;">${code}</p><p>Lambarkani wuxuu dhacayaa 15 daqiiqo gudahood. Haddii aanad codsan dib-u-dejintan, iska indha tir email-kan — furahaaga sirta ah wax isma beddeli doonaan.</p>`,
  });
}

// Routes a non-user to register (email prefilled) and an existing user to
// log in — both land back on /organizer/invites afterward to accept.
export async function sendTeamInviteEmail({ inviteEmail, inviterName, campaignTitle, hasAccount }) {
  const clientOrigin = (process.env.CLIENT_ORIGIN || '').split(',')[0];
  const redirect = encodeURIComponent('/organizer/invites');
  const link = hasAccount
    ? `${clientOrigin}/login?redirect=${redirect}`
    : `${clientOrigin}/register?email=${encodeURIComponent(inviteEmail)}&redirect=${redirect}`;
  const cta = hasAccount ? 'Gal si aad u aqbasho' : 'Iska diiwaan geli si aad u aqbasho';

  return sendEmail({
    to: inviteEmail,
    subject: `${inviterName} ku casuumay inaad ka caawiso "${campaignTitle}" — Kaalmo`,
    html: `<p>Salaan,</p><p>${inviterName} wuxuu ku casuumay inaad co-organizer ka noqoto campaign-ka "${campaignTitle}" ee Kaalmo.</p><p>Fadlan <a href="${link}">${cta}</a> si aad u aragto casuumaadda oo aad u aqbasho.</p>`,
  });
}

// Beneficiary invitation. Routes a non-user to register (email prefilled) and
// an existing user to log in — both land on /verification, where they see the
// pending invitation, accept it, and submit their verification details. The
// email never verifies anyone; an admin still reviews the submission.
export async function sendBeneficiaryInviteEmail({ inviteEmail, inviterName, campaignTitle, hasAccount }) {
  const clientOrigin = (process.env.CLIENT_ORIGIN || '').split(',')[0];
  const redirect = encodeURIComponent('/verification');
  const link = hasAccount
    ? `${clientOrigin}/login?redirect=${redirect}`
    : `${clientOrigin}/register?email=${encodeURIComponent(inviteEmail)}&redirect=${redirect}`;
  const cta = hasAccount ? 'Gal si aad u aragto casuumaadda' : 'Iska diiwaan geli si aad u sii wadato';

  return sendEmail({
    to: inviteEmail,
    subject: `${inviterName} ku magacaabay inaad ka faa'iidaysato "${campaignTitle}" — Kaalmo`,
    html: `<p>Salaan,</p><p>${inviterName} wuxuu kugu magacaabay qofka ka faa'iidaysanaya (beneficiary) campaign-ka "${campaignTitle}" ee Kaalmo.</p><p>Fadlan <a href="${link}">${cta}</a>. Kadib waxaad:</p><ol><li>aqbali doontaa casuumaadda,</li><li>gudbin doontaa xogtaada xaqiijinta,</li><li>sugi doontaa in kooxda Kaalmo ay ansixiso.</li></ol><p>Aqbalitaanka casuumaadda kaligiis kuma dhigayo mid la xaqiijiyay — maamulaha ayaa dib u eegaya xogtaada.</p>`,
  });
}

export async function sendOrganizerConfirmationEmail(user, code, purpose) {
  return sendEmail({
    to: user.email,
    subject: `${code} waa lambarkaaga xaqiijinta organizer-ka — Kaalmo`,
    html: `<p>Salaan ${user.fullName},</p><p>Waxaad codsatay inaad organizer ka noqoto Kaalmo${
      purpose ? ` si aad u sameyso: "${purpose}"` : ''
    }.</p><p>Lambarkan geli si aad u xaqiijiso codsigan:</p><p style="font-size:32px;font-weight:bold;letter-spacing:8px;">${code}</p><p>Lambarkani wuxuu dhacayaa 15 daqiiqo gudahood. Haddii aanad ahayn adiga, iska indha tir email-kan.</p>`,
  });
}
