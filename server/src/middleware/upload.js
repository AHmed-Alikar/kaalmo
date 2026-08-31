import multer from 'multer';
import path from 'path';
import { fileURLToPath } from 'url';
import { ApiError } from '../utils/ApiError.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
// Kept only so app.js can keep serving images uploaded before the Cloudinary
// migration — new uploads no longer write here (see uploadController.js).
export const UPLOAD_DIR = path.join(__dirname, '../../uploads');

const ALLOWED_TYPES = new Set(['image/jpeg', 'image/png', 'image/webp']);

function fileFilter(req, file, cb) {
  if (!ALLOWED_TYPES.has(file.mimetype)) {
    return cb(new ApiError(400, 'INVALID_FILE_TYPE', 'Only JPEG, PNG, or WebP images are allowed'));
  }
  cb(null, true);
}

// Memory storage — the file buffer is streamed straight to Cloudinary in
// uploadController and never touches disk (see cloudinaryService.js).
export const uploadImage = multer({
  storage: multer.memoryStorage(),
  fileFilter,
  limits: { fileSize: 5 * 1024 * 1024 },
}).single('image');
