const fs = require('fs');
const path = require('path');

const CATALOG_PATH = path.join(__dirname, '..', 'data', 'catalog.json');

class Database {
  constructor() {
    this.data = { deities: [], categories: [], songs: [] };
    this.load();
  }

  load() {
    try {
      if (fs.existsSync(CATALOG_PATH)) {
        const raw = fs.readFileSync(CATALOG_PATH, 'utf8');
        this.data = JSON.parse(raw);
      }
    } catch (e) {
      console.error('[Database] Failed to read catalog.json:', e);
    }
  }

  save() {
    try {
      fs.writeFileSync(CATALOG_PATH, JSON.stringify(this.data, null, 2), 'utf8');
    } catch (e) {
      console.error('[Database] Failed to save catalog.json:', e);
    }
  }

  getDeities() {
    this.load();
    return this.data.deities || [];
  }

  getCategories() {
    this.load();
    return this.data.categories || [];
  }

  getSongs({ category, deity, search, language } = {}) {
    this.load();
    let result = this.data.songs || [];

    if (category) {
      result = result.filter(s => s.categoryId.toLowerCase() === category.toLowerCase());
    }
    if (deity) {
      result = result.filter(s => s.deityId.toLowerCase() === deity.toLowerCase());
    }
    if (language) {
      result = result.filter(s => s.language.toLowerCase() === language.toLowerCase());
    }
    if (search && search.trim()) {
      const q = search.toLowerCase().trim();
      result = result.filter(s =>
        s.title.toLowerCase().includes(q) ||
        s.artist.toLowerCase().includes(q) ||
        s.deityId.toLowerCase().includes(q) ||
        (s.description && s.description.toLowerCase().includes(q))
      );
    }
    return result;
  }

  getSongById(id) {
    return (this.data.songs || []).find(s => s.id === id);
  }

  addSong(song) {
    this.data.songs.unshift(song);
    this.save();
    return song;
  }

  updateSong(id, updates) {
    const idx = this.data.songs.findIndex(s => s.id === id);
    if (idx === -1) return null;
    this.data.songs[idx] = { ...this.data.songs[idx], ...updates, updatedAt: new Date().toISOString() };
    this.save();
    return this.data.songs[idx];
  }

  deleteSong(id) {
    const prevLen = this.data.songs.length;
    this.data.songs = this.data.songs.filter(s => s.id !== id);
    if (this.data.songs.length !== prevLen) {
      this.save();
      return true;
    }
    return false;
  }
}

const db = new Database();
module.exports = db;
