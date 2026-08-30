import { Link } from 'react-router-dom';
import Logo from './Logo';
import { useLanguage } from '../context/LanguageContext';

export default function Footer() {
  const { t } = useLanguage();

  return (
    <footer className="bg-surface border-t border-border mt-4xl">
      <div className="max-w-container mx-auto px-xl py-3xl grid grid-cols-2 md:grid-cols-4 gap-xl">
        <div className="flex flex-col gap-md col-span-2 md:col-span-1">
          <Logo />
          <p className="text-[13px] text-text-secondary">© 2026 Kaalmo Somalia. {t('footer.tagline')}</p>
        </div>
        <div className="flex flex-col gap-sm text-[13px]">
          <Link to="/how-it-works" className="text-text-secondary hover:text-primary transition-colors">{t('nav.howItWorks')}</Link>
          <Link to="/safety" className="text-text-secondary hover:text-primary transition-colors">{t('nav.safety')}</Link>
        </div>
        <div className="flex flex-col gap-sm text-[13px]">
          <Link to="/help" className="text-text-secondary hover:text-primary transition-colors">{t('footer.helpCenter')}</Link>
          <Link to="/contact" className="text-text-secondary hover:text-primary transition-colors">{t('footer.contact')}</Link>
        </div>
        <div className="flex flex-col gap-sm text-[13px]">
          <Link to="/terms" className="text-text-secondary hover:text-primary transition-colors">{t('footer.terms')}</Link>
          <Link to="/privacy" className="text-text-secondary hover:text-primary transition-colors">{t('footer.privacy')}</Link>
        </div>
      </div>
    </footer>
  );
}
