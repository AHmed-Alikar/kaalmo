import { ApiError } from '../utils/ApiError.js';
import { uploadBuffer } from '../services/cloudinaryService.js';
import { asyncHandler } from '../utils/asyncHandler.js';

export const handleImageUpload = asyncHandler(async (req, res, next) => {
  if (!req.file) {
    return next(new ApiError(400, 'VALIDATION_ERROR', 'No image file was provided', { image: 'required' }));
  }

  try {
    const result = await uploadBuffer(req.file.buffer, { folder: 'kaalmo' });
    res.status(201).json({ url: result.secure_url });
  } catch (err) {
    throw new ApiError(502, 'UPLOAD_FAILED', 'The image could not be uploaded. Please try again.', { cause: err.message });
  }
});
