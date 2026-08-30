import { useRef, useState } from 'react';
import api from '../api/client';
import { useLanguage } from '../context/LanguageContext';

// Uploads to the local disk-storage endpoint (POST /uploads/image) — the MVP
// fallback until S3/Cloudflare R2 is wired up (see PROGRESS.md). Shows
// upload progress per Design_Rules.md Rule 28.
export default function ImageUpload({ label, value, onChange }) {
  const { t } = useLanguage();
  const inputRef = useRef(null);
  const [uploading, setUploading] = useState(false);
  const [error, setError] = useState(null);

  async function handleFile(e) {
    const file = e.target.files?.[0];
    if (!file) return;

    setUploading(true);
    setError(null);
    try {
      const formData = new FormData();
      formData.append('image', file);
      const { data } = await api.post('/uploads/image', formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
      });
      onChange(data.url);
    } catch (err) {
      setError(err.response?.data?.error?.message || t('imageUpload.error'));
    } finally {
      setUploading(false);
      e.target.value = '';
    }
  }

  return (
    <div className="flex flex-col gap-sm">
      {label && <label className="text-[14px] font-medium text-text-primary">{label}</label>}

      {value ? (
        <div className="relative w-full h-48 rounded-lg overflow-hidden border border-border">
          <img src={value} alt="Campaign cover" className="w-full h-full object-cover" />
          <button
            type="button"
            onClick={() => onChange(null)}
            className="absolute top-sm right-sm bg-surface/95 border border-border rounded-full w-8 h-8 flex items-center justify-center text-text-secondary hover:text-error transition-colors"
          >
            <span className="material-symbols-outlined" style={{ fontSize: 18 }}>close</span>
          </button>
        </div>
      ) : (
        <button
          type="button"
          onClick={() => inputRef.current?.click()}
          disabled={uploading}
          className="w-full h-48 rounded-lg border border-dashed border-border flex flex-col items-center justify-center gap-sm text-text-secondary hover:border-primary hover:text-primary transition-colors disabled:opacity-60"
        >
          <span className="material-symbols-outlined" style={{ fontSize: 32 }}>
            {uploading ? 'progress_activity' : 'add_photo_alternate'}
          </span>
          <span className="text-[13px]">{uploading ? t('imageUpload.uploading') : t('imageUpload.clickToUpload')}</span>
        </button>
      )}

      <input
        ref={inputRef}
        type="file"
        accept="image/jpeg,image/png,image/webp"
        onChange={handleFile}
        className="hidden"
      />

      {error && <p className="text-[13px] text-error">{error}</p>}
    </div>
  );
}
