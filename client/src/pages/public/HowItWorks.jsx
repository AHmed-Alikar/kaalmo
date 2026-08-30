import PageLayout from '../../components/PageLayout';
import { useLanguage } from '../../context/LanguageContext';

const ORGANIZER_STEPS = [
  {
    title: { so: 'Abuur ololahaaga', en: 'Create your campaign' },
    text: { so: 'Sheeko sheekadaada, dhig hadaf, kudar sawirro Soomaali ama Ingiriisi ah.', en: 'Tell your story, set a goal, and add photos in Somali or English.' },
  },
  {
    title: { so: 'La xaqiiji', en: 'Get verified' },
    text: { so: 'Waxaan xaqiijinaa aqoonsiga abaabulaha iyo qofka faa\'iidaysta ka hor inta ololihiisu bilaabmin.', en: 'We confirm the organizer and beneficiary identity before the campaign goes live.' },
  },
  {
    title: { so: 'La wadaag oo hel lacag-bixin', en: 'Share and receive donations' },
    text: { so: 'Wax-bixiyayaashu waxay ku bixin karaan mobile money ama kaadh, waxayna arki karaan horumarkaaga waqti dhab ah.', en: 'Donors can give by mobile money or card, and see your progress in real time.' },
  },
  {
    title: { so: 'Codso lacag-ka bixin', en: 'Request a withdrawal' },
    text: { so: 'Marka qofka faa\'iidaysta la xaqiijiyo, codso in lacagta lagugu diro mobile money ama bangi.', en: 'Once your beneficiary is verified, request a payout to mobile money or bank.' },
  },
];

const DONOR_STEPS = [
  {
    title: { so: 'Hel olole', en: 'Find a campaign' },
    text: { so: 'Ku baadh ololayaal la xaqiijiyay iyadoo lagu qaybiyo qayb, gobol, ama degdegnimo.', en: 'Browse verified campaigns by category, region, or urgency.' },
  },
  {
    title: { so: 'Hubi calaamadaha xaqiijinta', en: 'Check the verification badges' },
    text: { so: 'Arag cida abaabulaha ah, in qofka faa\'iidaysta la xaqiijiyay iyo in kale, akhrina cusboonaysiintii ugu dambaysay.', en: 'See who the organizer is, whether the beneficiary is verified, and read recent updates.' },
  },
  {
    title: { so: 'Wax bixi', en: 'Donate' },
    text: { so: 'Ku bixi mobile money ama kaadh — adiga ayaa go\'aamiya qadarka.', en: 'Give by mobile money or card — you choose the amount.' },
  },
  {
    title: { so: 'La soco saameynta', en: 'Follow the impact' },
    text: { so: 'Hel cusboonaysiin abaabulaha ka socota oo tusaya sida wax-bixintaada loo isticmaalay.', en: 'Get updates from the organizer showing how your donation was used.' },
  },
];

function StepList({ steps, language }) {
  return (
    <ol className="flex flex-col gap-lg">
      {steps.map((step, i) => (
        <li key={step.title.en} className="flex gap-lg">
          <span className="flex-shrink-0 w-8 h-8 rounded-full bg-primary/10 text-primary font-semibold flex items-center justify-center text-[14px]">
            {i + 1}
          </span>
          <div>
            <h3 className="text-[16px] font-semibold text-text-primary">{step.title[language] || step.title.so}</h3>
            <p className="text-[14px] text-text-secondary mt-xs">{step.text[language] || step.text.so}</p>
          </div>
        </li>
      ))}
    </ol>
  );
}

export default function HowItWorks() {
  const { language, t } = useLanguage();
  return (
    <PageLayout>
      <div className="max-w-container mx-auto px-xl py-3xl flex flex-col gap-4xl">
        <div className="max-w-2xl">
          <h1 className="text-[32px] font-bold text-text-primary mb-sm">{t('howItWorks.title')}</h1>
          <p className="text-[15px] text-text-secondary">
            {t('howItWorks.subtitle')}
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4xl">
          <div>
            <h2 className="text-[20px] font-semibold text-text-primary mb-lg">{t('howItWorks.forOrganizers')}</h2>
            <StepList steps={ORGANIZER_STEPS} language={language} />
          </div>
          <div>
            <h2 className="text-[20px] font-semibold text-text-primary mb-lg">{t('howItWorks.forDonors')}</h2>
            <StepList steps={DONOR_STEPS} language={language} />
          </div>
        </div>
      </div>
    </PageLayout>
  );
}
