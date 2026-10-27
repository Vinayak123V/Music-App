import React, { useState } from 'react';
import { Upload, X, ShieldCheck, Music, Image as ImageIcon } from 'lucide-react';
import { apiFetch } from '../../config/api';

export const AdminUploadModal = ({ isOpen, onClose, onSongAdded, categories, deities }) => {
  const [formData, setFormData] = useState({
    title: '',
    artist: '',
    categoryId: 'bhajans',
    deityId: 'shiva',
    language: 'Hindi',
    description: '',
    audioUrl: '',
    artworkUrl: '',
    durationSeconds: 300,
    rightsHolder: '',
    licenseReference: '',
    permittedTerritories: 'IN, GLOBAL',
    permittedUsage: 'Public Devotional Streaming',
    commercialAuthorized: true,
  });

  const [audioFile, setAudioFile] = useState(null);
  const [artworkFile, setArtworkFile] = useState(null);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState('');

  if (!isOpen) return null;

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setIsSubmitting(true);

    try {
      let resolvedAudioUrl = formData.audioUrl;
      let resolvedArtworkUrl = formData.artworkUrl;

      // If user uploaded files, upload via Multer endpoint first
      if (audioFile || artworkFile) {
        const uploadBody = new FormData();
        if (audioFile) uploadBody.append('audio', audioFile);
        if (artworkFile) uploadBody.append('artwork', artworkFile);

        const uploadRes = await apiFetch('/api/admin/upload', {
          method: 'POST',
          body: uploadBody,
        }).then(r => r.json());

        if (uploadRes.success) {
          if (uploadRes.data.audioUrl) resolvedAudioUrl = uploadRes.data.audioUrl;
          if (uploadRes.data.artworkUrl) resolvedArtworkUrl = uploadRes.data.artworkUrl;
        }
      }

      if (!resolvedAudioUrl) {
        throw new Error('Please provide an audio stream URL or upload an audio file.');
      }
      if (!formData.rightsHolder || !formData.licenseReference) {
        throw new Error('Rights Holder and License Reference are mandatory for copyright compliance.');
      }

      const songPayload = {
        title: formData.title,
        artist: formData.artist,
        categoryId: formData.categoryId,
        deityId: formData.deityId,
        language: formData.language,
        description: formData.description,
        audioUrl: resolvedAudioUrl,
        artworkUrl: resolvedArtworkUrl,
        durationSeconds: parseInt(formData.durationSeconds, 10) || 300,
        rights: {
          rightsHolder: formData.rightsHolder,
          licenseReference: formData.licenseReference,
          permittedTerritories: formData.permittedTerritories.split(',').map(s => s.trim()),
          permittedUsage: formData.permittedUsage,
          commercialAuthorized: formData.commercialAuthorized,
        },
      };

      const res = await apiFetch('/api/songs', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(songPayload),
      }).then(r => r.json());

      if (!res.success) {
        throw new Error(res.error || 'Failed to save song');
      }

      onSongAdded(res.data);
      onClose();
    } catch (err) {
      setError(err.message || 'An error occurred while uploading.');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div
      onClick={onClose}
      className="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm flex items-center justify-center p-4 overflow-y-auto animate-in fade-in"
    >
      <div
        onClick={(e) => e.stopPropagation()}
        className="bg-white rounded-3xl max-w-xl w-full p-6 shadow-2xl border border-saffron-200 text-stone-900 my-8"
      >
        <div className="flex items-center justify-between pb-4 border-b border-stone-100">
          <div>
            <h3 className="text-lg font-black text-stone-900">Upload Devotional Audio</h3>
            <p className="text-xs text-stone-500">Add verified spiritual tracks to the Bhakti Music catalog</p>
          </div>
          <button
            onClick={onClose}
            className="p-1 rounded-full text-stone-400 hover:text-stone-700 hover:bg-stone-100"
          >
            <X size={20} />
          </button>
        </div>

        {error && (
          <div className="mt-3 p-3 rounded-xl bg-red-50 text-red-700 text-xs border border-red-200">
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} className="mt-4 space-y-4 text-xs">
          {/* Title & Artist */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <div>
              <label className="block font-bold text-stone-700 mb-1">Track Title *</label>
              <input
                type="text"
                required
                value={formData.title}
                onChange={e => setFormData({ ...formData, title: e.target.value })}
                placeholder="e.g. Om Jai Jagdish Hare"
                className="w-full px-3 py-2 rounded-xl border border-stone-200 focus:outline-none focus:ring-2 focus:ring-saffron-500/40 text-xs"
              />
            </div>
            <div>
              <label className="block font-bold text-stone-700 mb-1">Artist / Singer *</label>
              <input
                type="text"
                required
                value={formData.artist}
                onChange={e => setFormData({ ...formData, artist: e.target.value })}
                placeholder="e.g. Anuradha Paudwal"
                className="w-full px-3 py-2 rounded-xl border border-stone-200 focus:outline-none focus:ring-2 focus:ring-saffron-500/40 text-xs"
              />
            </div>
          </div>

          {/* Category, Deity, Language */}
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
            <div>
              <label className="block font-bold text-stone-700 mb-1">Category *</label>
              <select
                value={formData.categoryId}
                onChange={e => setFormData({ ...formData, categoryId: e.target.value })}
                className="w-full px-3 py-2 rounded-xl border border-stone-200 focus:outline-none focus:ring-2 focus:ring-saffron-500/40 text-xs bg-white"
              >
                {categories.map(c => (
                  <option key={c.id} value={c.id}>{c.name}</option>
                ))}
              </select>
            </div>

            <div>
              <label className="block font-bold text-stone-700 mb-1">Deity *</label>
              <select
                value={formData.deityId}
                onChange={e => setFormData({ ...formData, deityId: e.target.value })}
                className="w-full px-3 py-2 rounded-xl border border-stone-200 focus:outline-none focus:ring-2 focus:ring-saffron-500/40 text-xs bg-white"
              >
                {deities.map(d => (
                  <option key={d.id} value={d.id}>{d.name}</option>
                ))}
              </select>
            </div>

            <div>
              <label className="block font-bold text-stone-700 mb-1">Language</label>
              <select
                value={formData.language}
                onChange={e => setFormData({ ...formData, language: e.target.value })}
                className="w-full px-3 py-2 rounded-xl border border-stone-200 focus:outline-none focus:ring-2 focus:ring-saffron-500/40 text-xs bg-white"
              >
                <option value="Hindi">Hindi</option>
                <option value="Sanskrit">Sanskrit</option>
                <option value="Kannada">Kannada</option>
                <option value="Tamil">Tamil</option>
                <option value="Telugu">Telugu</option>
                <option value="Marathi">Marathi</option>
                <option value="Gujarati">Gujarati</option>
                <option value="Bengali">Bengali</option>
              </select>
            </div>
          </div>

          {/* Audio Source (URL or File) */}
          <div className="p-3 bg-saffron-50/50 rounded-2xl border border-saffron-100 space-y-2">
            <label className="block font-bold text-saffron-900">Audio Stream URL or Upload</label>
            <input
              type="url"
              value={formData.audioUrl}
              onChange={e => setFormData({ ...formData, audioUrl: e.target.value })}
              placeholder="https://... direct audio stream URL (or upload below)"
              className="w-full px-3 py-2 rounded-xl border border-saffron-200 focus:outline-none focus:ring-2 focus:ring-saffron-500/40 text-xs bg-white"
            />
            <div className="flex items-center gap-2">
              <label className="cursor-pointer inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-white border border-stone-200 text-stone-700 font-semibold text-[11px] hover:bg-stone-50">
                <Music size={14} className="text-saffron-600" />
                <span>{audioFile ? audioFile.name : 'Choose local MP3 file'}</span>
                <input
                  type="file"
                  accept="audio/*"
                  className="hidden"
                  onChange={e => setAudioFile(e.target.files[0] || null)}
                />
              </label>
            </div>
          </div>

          {/* Artwork URL or Upload */}
          <div className="p-3 bg-stone-50 rounded-2xl border border-stone-200/60 space-y-2">
            <label className="block font-bold text-stone-800">Artwork Image (URL or File)</label>
            <input
              type="url"
              value={formData.artworkUrl}
              onChange={e => setFormData({ ...formData, artworkUrl: e.target.value })}
              placeholder="https://... cover artwork URL"
              className="w-full px-3 py-2 rounded-xl border border-stone-200 focus:outline-none focus:ring-2 focus:ring-saffron-500/40 text-xs bg-white"
            />
            <div className="flex items-center gap-2">
              <label className="cursor-pointer inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-white border border-stone-200 text-stone-700 font-semibold text-[11px] hover:bg-stone-50">
                <ImageIcon size={14} className="text-saffron-600" />
                <span>{artworkFile ? artworkFile.name : 'Choose cover image'}</span>
                <input
                  type="file"
                  accept="image/*"
                  className="hidden"
                  onChange={e => setArtworkFile(e.target.files[0] || null)}
                />
              </label>
            </div>
          </div>

          {/* Mandatory Rights Management Section */}
          <div className="p-3 bg-emerald-50/60 rounded-2xl border border-emerald-200 space-y-2.5">
            <div className="flex items-center gap-1.5 font-bold text-emerald-900">
              <ShieldCheck size={16} className="text-emerald-700" />
              <span>Mandatory Devotional Rights & Verification</span>
            </div>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
              <div>
                <label className="block font-semibold text-emerald-950 mb-1">Rights Holder *</label>
                <input
                  type="text"
                  required
                  value={formData.rightsHolder}
                  onChange={e => setFormData({ ...formData, rightsHolder: e.target.value })}
                  placeholder="e.g. Bhakti Records India / Public Domain"
                  className="w-full px-2.5 py-1.5 rounded-lg border border-emerald-300 focus:outline-none focus:ring-2 focus:ring-emerald-500/40 text-xs bg-white"
                />
              </div>
              <div>
                <label className="block font-semibold text-emerald-950 mb-1">License Reference *</label>
                <input
                  type="text"
                  required
                  value={formData.licenseReference}
                  onChange={e => setFormData({ ...formData, licenseReference: e.target.value })}
                  placeholder="e.g. CC-BY-SA 4.0 / Direct Devotional Accord"
                  className="w-full px-2.5 py-1.5 rounded-lg border border-emerald-300 focus:outline-none focus:ring-2 focus:ring-emerald-500/40 text-xs bg-white"
                />
              </div>
            </div>
          </div>

          <div className="flex items-center justify-end gap-2 pt-3 border-t border-stone-100">
            <button
              type="button"
              onClick={onClose}
              className="px-4 py-2 rounded-xl text-stone-600 font-bold hover:bg-stone-100"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={isSubmitting}
              className="px-6 py-2 rounded-xl bg-saffron-600 hover:bg-saffron-700 text-white font-bold shadow-md shadow-saffron-600/30 flex items-center gap-2"
            >
              {isSubmitting ? (
                <span>Publishing Track...</span>
              ) : (
                <>
                  <Upload size={15} />
                  <span>Publish to Catalog</span>
                </>
              )}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};
