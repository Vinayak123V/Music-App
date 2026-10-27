const fs = require('fs');
const path = require('path');

const deityPages = [
  { id: 'shiva', page: 'Shiva' },
  { id: 'krishna', page: 'Krishna' },
  { id: 'rama', page: 'Rama' },
  { id: 'hanuman', page: 'Hanuman' },
  { id: 'ganesha', page: 'Ganesha' },
  { id: 'durga', page: 'Durga' },
  { id: 'vishnu', page: 'Venkateswara' },
  { id: 'murugan', page: 'Kartikeya' },
  { id: 'ayyappa', page: 'Ayyappan' },
  { id: 'guru', page: 'Raghavendra_Tirtha' },
];

async function downloadDeityArtworks() {
  const clientArtworkDir = path.join(__dirname, '../../../client/public/artwork');
  const serverArtworkDir = path.join(__dirname, '../../uploads/artwork');

  if (!fs.existsSync(clientArtworkDir)) fs.mkdirSync(clientArtworkDir, { recursive: true });
  if (!fs.existsSync(serverArtworkDir)) fs.mkdirSync(serverArtworkDir, { recursive: true });

  for (const item of deityPages) {
    try {
      console.log(`Fetching summary for ${item.page}...`);
      const res = await fetch(`https://en.wikipedia.org/api/rest_v1/page/summary/${item.page}`, {
        headers: { 'User-Agent': 'BhaktiMusicStreaming/1.0 (info@bhaktimusic.org)' }
      });
      if (!res.ok) {
        console.warn(`Failed to fetch summary for ${item.page}: ${res.status}`);
        continue;
      }
      const data = await res.json();
      const imageUrl = data.originalimage?.source || data.thumbnail?.source;

      if (!imageUrl) {
        console.warn(`No image found for ${item.page}`);
        continue;
      }

      console.log(`Downloading ${item.id} artwork from ${imageUrl}...`);
      const imgRes = await fetch(imageUrl, {
        headers: { 'User-Agent': 'BhaktiMusicStreaming/1.0 (info@bhaktimusic.org)' }
      });

      if (!imgRes.ok) {
        console.warn(`Failed image download for ${item.id}: ${imgRes.status}`);
        continue;
      }

      const buffer = Buffer.from(await imgRes.arrayBuffer());
      const clientDest = path.join(clientArtworkDir, `${item.id}.jpg`);
      const serverDest = path.join(serverArtworkDir, `${item.id}.jpg`);

      fs.writeFileSync(clientDest, buffer);
      fs.writeFileSync(serverDest, buffer);
      console.log(`Successfully saved ${item.id}.jpg (${buffer.length} bytes)`);
    } catch (err) {
      console.error(`Error for ${item.id}:`, err.message);
    }
  }

  console.log('Finished downloading all deity artworks!');
}

downloadDeityArtworks();
