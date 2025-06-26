const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
const db = new sqlite3.Database('./db.sqlite');

app.use(cors());
app.use(bodyParser.json());

db.serialize(() => {
  // Buat tabel user jika belum ada
  db.run(`CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE,
    password TEXT
  )`);

  // Buat tabel recipes jika belum ada
  db.run(`CREATE TABLE IF NOT EXISTS recipes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    origin TEXT NOT NULL,
    description TEXT NOT NULL,
    ingredients TEXT NOT NULL,
    steps TEXT NOT NULL,
    imagePath TEXT,
    userId INTEGER,
    FOREIGN KEY (userId) REFERENCES users (id)
  )`);

  // Seed user pertama jika belum ada
  const seedUserSql = `INSERT INTO users (username, password)
    SELECT 'admin', 'admin'
    WHERE NOT EXISTS (SELECT 1 FROM users WHERE username = 'admin')`;
  
  db.run(seedUserSql, function(err) {
    if (err) {
      return console.error("Gagal seed user:", err.message);
    }
    
    // Dapatkan ID user yang di-seed
    db.get("SELECT id FROM users WHERE username = 'admin'", (err, user) => {
      if (err || !user) {
        return console.error("Tidak dapat menemukan user yang di-seed.");
      }

      const userId = user.id;

      // SEED DATA RESEP POPULER
      const seedRecipes = [
        {
            title: 'Mie goreng jawa',
            description: 'Mie goreng khas Jawa dengan bumbu tradisional',
            ingredients: 'mie,telur,sawi,bawang merah,bawang putih,kecap manis',
            steps: '1. Rebus mie\n2. Tumis bumbu\n3. Masukkan mie dan kecap\n4. Aduk rata',
            imagePath: null,
        },
        {
            title: 'Rawon daging',
            description: 'Rawon daging sapi khas Jawa Timur',
            ingredients: 'daging sapi,kluwek,daun bawang,bawang merah,bawang putih',
            steps: '1. Rebus daging\n2. Tumis bumbu\n3. Masukkan kluwek\n4. Masak hingga matang',
            imagePath: null,
        },
        {
            title: 'Capcay sayur',
            description: 'Capcay sayur sehat dan lezat',
            ingredients: 'wortel,kembang kol,sawi,ayam,bawang putih',
            steps: '1. Tumis bawang\n2. Masukkan ayam\n3. Tambahkan sayur\n4. Masak hingga matang',
            imagePath: null,
        },
        {
            title: 'Donat kentang',
            description: 'Donat kentang empuk dan manis',
            ingredients: 'kentang,tepung terigu,gula,mentega,telur',
            steps: '1. Rebus kentang\n2. Campur bahan\n3. Bentuk bulat\n4. Goreng hingga matang',
            imagePath: null,
        },
        {
            title: 'Nasi liwet magic com',
            description: 'Nasi liwet praktis pakai magic com',
            ingredients: 'beras,ayam,santan,daun salam,serai',
            steps: '1. Cuci beras\n2. Masukkan bahan ke magic com\n3. Masak hingga matang',
            imagePath: null,
        },
        {
            title: 'Sop iga',
            description: 'Sop iga sapi segar dan gurih',
            ingredients: 'iga sapi,wortel,kentang,daun bawang,bawang putih',
            steps: '1. Rebus iga\n2. Masukkan sayur\n3. Tambahkan bumbu\n4. Masak hingga matang',
            imagePath: null,
        },
        {
            title: 'Tempe bacem',
            description: 'Tempe bacem manis gurih khas Jawa',
            ingredients: 'tempe,gula merah,air kelapa,daun salam,bawang putih',
            steps: '1. Rebus tempe dengan bumbu\n2. Masak hingga air menyusut\n3. Goreng sebentar',
            imagePath: null,
        },
        {
            title: 'Cilok bumbu kacang',
            description: 'Cilok kenyal dengan bumbu kacang pedas',
            ingredients: 'tepung tapioka,air,bawang putih,daun bawang,kacang tanah,cabe',
            steps: '1. Campur bahan cilok\n2. Bentuk bulat\n3. Rebus\n4. Sajikan dengan bumbu kacang',
            imagePath: null,
        },
      ];

      seedRecipes.forEach(r => {
          db.get('SELECT * FROM recipes WHERE title = ? AND userId = ?', [r.title, userId], (err, row) => {
              if (err) return console.error(err.message);
              if (!row) {
                  db.run(
                      'INSERT INTO recipes (title, description, ingredients, steps, imagePath, userId) VALUES (?, ?, ?, ?, ?, ?)',
                      [r.title, r.description, r.ingredients, r.steps, r.imagePath, userId]
                  );
              }
          });
      });
    });
  });
});

// Register endpoint
app.post('/api/register', (req, res) => {
    const { username, password } = req.body;
    db.get('SELECT * FROM users WHERE username = ?', [username], (err, row) => {
        if (row) {
            return res.status(400).json({ message: 'Username sudah ada' });
        }
        db.run('INSERT INTO users (username, password) VALUES (?, ?)', [username, password], function (err) {
            if (err) return res.status(500).json({ message: 'Gagal mendaftar' });
            res.json({ message: 'Registrasi berhasil', userId: this.lastID });
        });
    });
});

// Login endpoint
app.post('/api/login', (req, res) => {
    const { username, password } = req.body;
    db.get('SELECT * FROM users WHERE username = ? AND password = ?', [username, password], (err, row) => {
        if (row) {
            res.json({ message: 'Login berhasil', userId: row.id });
        } else {
            res.status(401).json({ message: 'Username atau password salah' });
        }
    });
});

// GET semua resep milik user tertentu
app.get('/api/recipes', (req, res) => {
    const userId = req.query.userId;
    db.all('SELECT * FROM recipes WHERE userId = ?', [userId], (err, rows) => {
        if (err) return res.status(500).json({ message: 'Gagal mengambil resep' });
        res.json(rows);
    });
});

// Tambah resep baru
app.post('/api/recipes', (req, res) => {
    const { title, description, ingredients, steps, imagePath, userId } = req.body;
    db.run(
        'INSERT INTO recipes (title, description, ingredients, steps, imagePath, userId) VALUES (?, ?, ?, ?, ?, ?)',
        [title, description, ingredients, steps, imagePath, userId],
        function (err) {
            if (err) return res.status(500).json({ message: 'Gagal menambah resep' });
            res.json({ message: 'Resep berhasil ditambahkan', id: this.lastID });
        }
    );
});

// Hapus resep
app.delete('/api/recipes/:id', (req, res) => {
    const id = req.params.id;
    db.run('DELETE FROM recipes WHERE id = ?', [id], function (err) {
        if (err) return res.status(500).json({ message: 'Gagal menghapus resep' });
        res.json({ message: 'Resep berhasil dihapus' });
    });
});

// Update resep
app.put('/api/recipes/:id', (req, res) => {
    const id = req.params.id;
    const { title, description, ingredients, steps, imagePath } = req.body;
    db.run(
        'UPDATE recipes SET title = ?, description = ?, ingredients = ?, steps = ?, imagePath = ? WHERE id = ?',
        [title, description, ingredients, steps, imagePath, id],
        function (err) {
            if (err) return res.status(500).json({ message: 'Gagal mengupdate resep' });
            res.json({ message: 'Resep berhasil diperbarui' });
        }
    );
});

// Endpoint untuk mengambil semua resep dari semua user
app.get('/api/all-recipes', (req, res) => {
    db.all('SELECT * FROM recipes', [], (err, rows) => {
        if (err) return res.status(500).json({ message: 'Gagal mengambil semua resep' });
        res.json(rows);
    });
});

app.get('/recipes', (req, res) => {
  db.all('SELECT * FROM recipes', [], (err, rows) => {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    res.json(rows);
  });
});

app.listen(3000, '0.0.0.0', () => {
    console.log('API berjalan di http://0.0.0.0:3000');
}); 