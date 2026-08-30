import { useState } from 'react';
import { Link } from 'react-router-dom';
import PageLayout from '../../components/PageLayout';
import { useLanguage } from '../../context/LanguageContext';

const FAQS = [
  {
    q: { so: 'Sideen u ogaadaa in ololuhu dhab yahay?', en: 'How do I know a campaign is real?' },
    a: {
      so: 'Olole kastaa wuxuu tusaa calaamado xaqiijin ah oo u gaar ah abaabulaha iyo qofka faa\'iidaysta. Waxaad sidoo kale akhrin kartaa cusboonaysiinta abaabulaha si aad u aragto caddayn sida lacagta loo isticmaalay.',
      en: 'Every campaign shows verification badges for the organizer and beneficiary. You can also read the organizer\'s updates to see proof of how funds are being used.',
    },
  },
  {
    q: { so: 'Waa maxay habka lacag-bixinta ee aan isticmaali karo?', en: 'What payment methods can I use to donate?' },
    a: {
      so: 'Mobile money (EVC Plus, eDahab, Zaad) ayaa loo taageeraa wax-bixiyayaasha Soomaaliya ku sugan. Kaadhka bangiga ayaa u furan wax-bixiyayaasha qurbaha ku nool.',
      en: 'Mobile money (EVC Plus, eDahab, Zaad) is supported for donors inside Somalia. Card payments are available for diaspora donors abroad.',
    },
  },
  {
    q: { so: 'Ma bixin karaa magac la\'aan?', en: 'Can I donate anonymously?' },
    a: {
      so: 'Haa. Magacaaga si dadweyne ah looma muujin doono, laakiin waxaad weli heli doontaa rasiid oo waxaad geli kartaa taariikhda wax-bixintaada.',
      en: 'Yes. Your name will not be shown publicly, but you will still receive a receipt and can access your donation history.',
    },
  },
  {
    q: { so: 'Immisa waqti ayay qaadataa lacag-ka bixinta?', en: 'How long does a withdrawal take?' },
    a: {
      so: 'Xaqiijinta qofka faa\'iidaysta waa in la dhammaystiraa marka hore. Kadib, inta badan lacag-bixinnada waxaa lagu eegaa dhowr maalmood oo shaqo ah.',
      en: 'Beneficiary verification must be complete first. After that, most withdrawals are reviewed within a few business days.',
    },
  },
  {
    q: { so: 'Maxaan sameeyaa haddii aan ka shakisan yahay khiyaano?', en: 'What if I suspect fraud?' },
    a: {
      so: 'Isticmaal batoonka "Ka warbixi" ee bogga ololaha. Kooxdayada Kalsoonida & Nabadgelyada ayaa eegta warbixin kasta.',
      en: 'Use the "Report" button on the campaign page. Our Trust & Safety team reviews every report.',
    },
  },
];

export default function HelpCenter() {
  const { language, t } = useLanguage();
  const [openIndex, setOpenIndex] = useState(null);

  return (
    <PageLayout>
      <div className="max-w-container mx-auto px-xl py-3xl max-w-2xl">
        <h1 className="text-[32px] font-bold text-text-primary mb-sm">{t('helpCenter.title')}</h1>
        <p className="text-[15px] text-text-secondary mb-2xl">
          {t('helpCenter.subtitle')}{' '}
          <Link to="/contact" className="text-primary hover:underline">{t('helpCenter.contactUs')}</Link>.
        </p>

        <div className="flex flex-col divide-y divide-border border-t border-b border-border">
          {FAQS.map((item, i) => {
            const open = openIndex === i;
            return (
              <div key={item.q.en}>
                <button
                  onClick={() => setOpenIndex(open ? null : i)}
                  className="w-full flex items-center justify-between py-lg text-left"
                >
                  <span className="text-[15px] font-medium text-text-primary">{item.q[language] || item.q.so}</span>
                  <span className="material-symbols-outlined text-text-secondary">
                    {open ? 'remove' : 'add'}
                  </span>
                </button>
                {open && <p className="text-[14px] text-text-secondary pb-lg pr-2xl">{item.a[language] || item.a.so}</p>}
              </div>
            );
          })}
        </div>
      </div>
    </PageLayout>
  );
}
