import React, { useState } from 'react';
import { Shield, ShieldCheck, Info, X } from 'lucide-react';

export const RightsBadge = ({ rights }) => {
  const [isOpen, setIsOpen] = useState(false);

  if (!rights) return null;

  return (
    <>
      <button
        onClick={(e) => {
          e.stopPropagation();
          setIsOpen(true);
        }}
        className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-emerald-50 text-emerald-800 border border-emerald-200 text-[10px] font-semibold hover:bg-emerald-100 transition-colors"
      >
        <ShieldCheck size={12} className="text-emerald-600" />
        <span>Verified Rights</span>
      </button>

      {/* Rights Details Modal */}
      {isOpen && (
        <div
          onClick={(e) => {
            e.stopPropagation();
            setIsOpen(false);
          }}
          className="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm flex items-center justify-center p-4 animate-in fade-in"
        >
          <div
            onClick={(e) => e.stopPropagation()}
            className="bg-white rounded-3xl max-w-md w-full p-6 shadow-2xl border border-saffron-100 text-stone-900"
          >
            <div className="flex items-center justify-between pb-3 border-b border-stone-100">
              <div className="flex items-center gap-2 text-emerald-800 font-bold text-base">
                <ShieldCheck size={20} className="text-emerald-600" />
                <span>Verified Devotional Rights</span>
              </div>
              <button
                onClick={() => setIsOpen(false)}
                className="p-1 rounded-full text-stone-400 hover:text-stone-700 hover:bg-stone-100"
              >
                <X size={18} />
              </button>
            </div>

            <div className="mt-4 space-y-3 text-xs">
              <div>
                <p className="text-stone-400 font-semibold uppercase tracking-wider text-[10px]">Rights Holder</p>
                <p className="font-bold text-stone-900 mt-0.5">{rights.rightsHolder || 'Public Domain / Verified'}</p>
              </div>
              <div>
                <p className="text-stone-400 font-semibold uppercase tracking-wider text-[10px]">License Agreement Ref</p>
                <p className="font-mono text-saffron-900 bg-saffron-50 px-2 py-1 rounded border border-saffron-100 mt-0.5">
                  {rights.licenseReference || 'Standard Devotional License'}
                </p>
              </div>
              <div>
                <p className="text-stone-400 font-semibold uppercase tracking-wider text-[10px]">Permitted Territories</p>
                <p className="text-stone-700 mt-0.5">{(rights.permittedTerritories || ['IN', 'GLOBAL']).join(', ')}</p>
              </div>
              <div>
                <p className="text-stone-400 font-semibold uppercase tracking-wider text-[10px]">Authorized Usage</p>
                <p className="text-stone-700 mt-0.5">{rights.permittedUsage || 'Non-commercial & Commercial Devotional Streaming'}</p>
              </div>
              <div className="pt-2 text-[11px] text-stone-500 bg-emerald-50/50 p-2.5 rounded-xl border border-emerald-100">
                ✅ This audio asset complies with Bhakti Music's copyright and ethical publishing standards.
              </div>
            </div>
          </div>
        </div>
      )}
    </>
  );
};
